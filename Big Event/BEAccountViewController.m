//  Big Event
//  Created by Jonathan Willing

#import "BEAccountViewController.h"
#import "BEAccountController.h"
#import "BEConstants.h"


@interface BEAccountViewController ()

@property (weak) IBOutlet UIBarButtonItem *cancelButton;
@property (weak) IBOutlet UITextField *usernameField;
@property (weak) IBOutlet UITextField *passwordField;
@property (weak) IBOutlet UIButton *authenticationActionButton;

@end


@implementation BEAccountViewController


#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
	
	[self.usernameField becomeFirstResponder];
	[self setup];
}

- (void)setup {
	self.cancelButton.enabled = BEAccountController.sharedController.client.authenticated;
}


#pragma mark - Actions

- (IBAction)performAuthenticationAction:(UIButton *)sender {
	// async login (or logout)
}


#pragma mark - Segues

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
	if ([identifier isEqualToString:BEAccountDoneSegueIdentifier]) {
		
		// async login
		
		return NO;
	}
	
	return YES;
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
