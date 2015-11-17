//  Big Event
//  Created by Jonathan Willing

#import "BEFormViewController.h"
#import "BEFormRowDescriptor.h"
#import "BEClientController.h"
#import "BEConstants.h"

#import <SVProgressHUD/SVProgressHUD.h>


@interface BEFormViewController ()

@property BEForm *formValue;

@end


@implementation BEFormViewController


#pragma mark - Lifecycle

- (void)viewDidLoad {
	[super viewDidLoad];
	
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
	[client requestFormWithFormType:client.currentFormTypeID completion:^(BEForm *form) {
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
	[SVProgressHUD show];
	
	[client submitForm:self.formValue stub:self.stub completion:^(BOOL success) {
		if (success) {
			[SVProgressHUD showSuccessWithStatus:@"Submitted"];
		} else {
			[SVProgressHUD showErrorWithStatus:@"Submission error"];
		}
	}];
}


#pragma mark - XLFormDescriptorDelegate

- (void)formRowDescriptorValueHasChanged:(XLFormRowDescriptor *)formRow oldValue:(id)oldValue newValue:(id)newValue {
	BEFormRowDescriptor *row = (BEFormRowDescriptor *)formRow;

	if ([newValue isKindOfClass:XLFormOptionsObject.class]) { // choice field
		row.field.value = ((XLFormOptionsObject *)newValue).formValue;
	} else {
		row.field.value = newValue;
	}
	
	NSLog(@"* row (%@) has new value (%@)", row.tag, row.field.value);
	
	// TODO: save locally
}

@end
