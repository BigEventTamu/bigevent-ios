//  Big Event
//  Created by Jonathan Willing

#import "BEAccountViewController.h"
#import "BEClientController.h"
#import "BEConstants.h"


@interface BEAccountViewController () <UITextFieldDelegate>

@property (nonatomic, assign) BOOL authenticationEnabled;

@property (weak) IBOutlet UITextField *usernameField;
@property (weak) IBOutlet UITextField *passwordField;
@property (weak) IBOutlet UITextField *providerField;
@property (weak) IBOutlet UIBarButtonItem *doneButton;
@property (weak) IBOutlet UIBarButtonItem *cancelButton;
@property (weak) IBOutlet UIButton *authenticationActionButton;

@end


@implementation BEAccountViewController


#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
	
	[self.usernameField becomeFirstResponder];
	
	self.authenticationEnabled = YES;
	[self updateState];
}


#pragma mark - Actions

- (IBAction)performAuthenticationAction:(UIButton *)sender {
	// async login (or logout)
	
	self.authenticationEnabled = NO;
	[self updateState];
	
	BEAccount *account = [self createAccount];
	[BEClientController.sharedController.client authenticateWithAccount:account completion:^(BOOL success) {
		self.authenticationEnabled = YES;
		[self updateState];
		
		NSLog(@"authentication successful: %x", success);
		
		if (success) {
			
		} else {
			
		}
	}];
}

- (IBAction)textFieldDidChange:(id)sender {
	[self updateState];
}


#pragma mark - Segues

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
	if ([identifier isEqualToString:BEAccountDoneSegueIdentifier]) {
		
		// async login
		
		return NO;
	}
	
	return YES;
}

#pragma mark - State

- (BEAccount *)createAccount {
	BEAccount *account = [[BEAccount alloc] init];
	account.username = self.usernameField.text;
	account.password = self.passwordField.text;
	account.provider = self.providerField.text;
	
	if (account.provider.length == 0) {
		account.provider = BEAccountDefaultProvider;
	}
	
	return account;
}

- (void)updateState {
	BOOL canAuthenticate = (self.usernameField.text.length > 0 && self.passwordField.text.length > 0);
	
	self.doneButton.enabled = canAuthenticate && self.authenticationEnabled;
	self.authenticationActionButton.enabled = self.authenticationEnabled;
	
	//	// We don't want to be able to cancel out if we aren't authenticated.
	BOOL authenticationRequired = !BEClientController.sharedController.client.authenticated;
	self.cancelButton.enabled = !(authenticationRequired || self.authenticationEnabled);
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
