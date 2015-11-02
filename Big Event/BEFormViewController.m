//  Big Event
//  Created by Jonathan Willing

#import "BEFormViewController.h"
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
	}];
}

@end
