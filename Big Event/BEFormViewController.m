//  Big Event
//  Created by Jonathan Willing

#import "BEFormViewController.h"
#import "BEFormRowDescriptor.h"
#import "BEClientController.h"
#import "BEConstants.h"

@interface BEFormViewController ()

@end


@implementation BEFormViewController

- (void)setStub:(BEJobStub *)stub {
	_stub = stub;
	
	BEClient *client = BEClientController.sharedController.client;
	[client requestFormWithFormType:client.currentFormTypeID completion:^(BEForm *form) {
		NSLog(@"%@", form);
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

@end
