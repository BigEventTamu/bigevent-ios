//  Big Event
//  Created by Jonathan Willing

#import "BEFormViewController.h"
#import "NSArray+BEHigherOrder.h"
#import "BEFormRowDescriptor.h"
#import "BEClientController.h"
#import "BEFormSubmission.h"
#import "BEOfflineQueue.h"
#import "BEConstants.h"

#import <SVProgressHUD/SVProgressHUD.h>


@interface BEFormViewController ()

@property BEForm *formValue;

@end


@implementation BEFormViewController


#pragma mark - Lifecycle

- (void)viewDidLoad {
	[super viewDidLoad];
	
	[self.navigationController setToolbarHidden:YES animated:YES];
	
	// If the form we're trying to edit is in the offline queue, return.
	BEOfflineQueue *offlineQueue = BEClientController.sharedController.client.offlineQueue;
	if ([offlineQueue submissionExistsWithRequestID:self.stub.requestID]) {
		[SVProgressHUD showErrorWithStatus:@"Job is already pending submission"];
		[self performSegueWithIdentifier:BEFormPopSegueIdentifier sender:nil];
		
		return;
	}
	
	[self setupNotifications];
	[self setupNavigationItems];
	
	BEClient *client = BEClientController.sharedController.client;
	if (client.currentFormTypeID != nil) {
		[self requestAndGenerateFormWithClient:client];
	} else {
		[self performSegueWithIdentifier:BEFormTypeShowSegueIdentifier sender:nil];
	}
}

- (void)setupNotifications {
	NSNotificationCenter *nc = NSNotificationCenter.defaultCenter;
	[nc addObserver:self selector:@selector(formTypeDidUpdate:) name:BEClientDidUpdateFormTypeNotification object:nil];
}

- (void)setupNavigationItems {
	SEL submit = @selector(submitPressed:);
	
	UIBarButtonItem *right = [[UIBarButtonItem alloc] initWithTitle:@"Submit" style:UIBarButtonItemStylePlain target:self action:submit];
	self.navigationItem.rightBarButtonItem = right;
}


#pragma mark - Navigation Items

- (void)submitPressed:(id)sender {
	[self.tableView endEditing:YES];
	
	// Validate the form and let users know of any mistakes they made.
	NSArray *validationErrors = self.formValidationErrors;
	if (validationErrors.count > 0){
		[self showFormValidationError:validationErrors.firstObject];
		return;
	}
	
	BEClient *client = BEClientController.sharedController.client;
	[self submitFormWithClient:client];
}


#pragma mark - Notifications

- (void)formTypeDidUpdate:(NSNotification *)note {
	BEClient *client = BEClientController.sharedController.client;
	
	if (client.currentFormTypeID == nil) {
		[SVProgressHUD showErrorWithStatus:@"Must select form type"];
		return;
	}
	
	[self requestAndGenerateFormWithClient:client];
}


#pragma mark - Form Requests

- (void)requestAndGenerateFormWithClient:(BEClient *)client {
	[client.cache requestFormWithFormType:client.currentFormTypeID completion:^(BEForm *form) {
		self.formValue = form;
		[self generateFormWithForm:form];
	}];
}

- (void)generateFormWithForm:(BEForm *)formData {
	XLFormDescriptor *form = [XLFormDescriptor formDescriptorWithTitle:formData.name];
	XLFormSectionDescriptor *section = [XLFormSectionDescriptor formSection];
	
	for (BEField *field in formData.fields) {
		BEFormRowDescriptor *row = [BEFormRowDescriptor formDescriptorWithField:field];
		[section addFormRow:row];
	}
	
	[form addFormSection:section];
	self.form = form;
}

- (void)submitFormWithClient:(BEClient *)client {
	BEFormSubmission *submission = [[BEFormSubmission alloc] init];
	submission.form = self.formValue;
	submission.requestID = self.stub.requestID;
	
	[client submitForm:submission completion:^(BOOL success) {
		if (success) {
			[SVProgressHUD showSuccessWithStatus:@"Submitted"];
			
			[self performSegueWithIdentifier:BEFormPopSegueIdentifier sender:nil];
		} else {
			[SVProgressHUD showErrorWithStatus:@"Submission error"];
		}
	}];
}


#pragma mark - XLFormDescriptorDelegate

- (void)formRowDescriptorValueHasChanged:(XLFormRowDescriptor *)formRow oldValue:(id)oldValue newValue:(id)newValue {
	BEFormRowDescriptor *row = (BEFormRowDescriptor *)formRow;
	
	id value = newValue;
	
	if ([newValue isKindOfClass:XLFormOptionsObject.class]) { // choice field
		value = ((XLFormOptionsObject *)newValue).formValue;
	}
	
	if ([value respondsToSelector:@selector(stringValue)]) {
		value = [value stringValue];
	}
	
	row.field.value = value;
	
	// TODO: potentially cache locally if draft mode is needed.
}

@end
