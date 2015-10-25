//  Big Event
//  Created by Jonathan Willing

#import "BEAccountViewController.h"
#import "BEClientController.h"
#import "BEConstants.h"

#import <SVProgressHUD/SVProgressHUD.h>


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
	
	[self setup];
}

- (void)setup {
	self.authenticationEnabled = YES;
	
	if (self.isAuthenticated) {
		// If already authenticated, fill in the content.
		BEAccount *account = BEClientController.sharedController.client.currentAccount;
		
		self.usernameField.text = account.username;
		self.passwordField.text = account.password;
		self.providerField.text = account.provider;
	} else {
		// Begin editing.
		[self.usernameField becomeFirstResponder];
		
		// Set a placeholder for the default provider.
		self.providerField.placeholder = BEAccountDefaultProvider;
	}
	
	[self updateState];
}


#pragma mark - Actions

- (IBAction)performAuthenticationAction:(UIButton *)sender {
	if (self.isAuthenticated) {
		// Logout.
		[BEClientController.sharedController.client logout];
		
		self.usernameField.text = @"";
		self.passwordField.text = @"";
		self.providerField.text = @"";
		
		[self.usernameField becomeFirstResponder];
		
		[self updateState];
		
		return;
	}
	
	self.authenticationEnabled = NO;
	[self updateState];
	
	[SVProgressHUD show];
	
	BEAccount *account = [self createAccount];
	[BEClientController.sharedController.client authenticateWithAccount:account completion:^(BOOL success) {
		self.authenticationEnabled = YES;
		[self updateState];
		
		if (success) {
			[SVProgressHUD showSuccessWithStatus:@"Authenticated"];
			
			[self performSegueWithIdentifier:BEAccountDoneSegueIdentifier sender:self];
		} else {
			[SVProgressHUD showErrorWithStatus:@"Invalid Login"];
		}
	}];
}

- (IBAction)textFieldDidChange:(id)sender {
	[self updateState];
}


#pragma mark - Segues

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
	if ([identifier isEqualToString:BEAccountDoneSegueIdentifier]) {
		// Async authentication.
		if (!self.isAuthenticated) {
			[self performAuthenticationAction:nil];
			
			return NO;
		} else {
			return YES;
		}
	}
	
	return YES;
}


#pragma mark - State

- (BOOL)isAuthenticated {
	return BEClientController.sharedController.client.authenticated;
}

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
	
	// We don't want to be able to cancel out if we aren't authenticated.
	BOOL authenticationRequired = !self.isAuthenticated;
	self.cancelButton.enabled = !authenticationRequired;
	
	// If already authenticated, don't allow editing, and update the text color.
	self.usernameField.enabled = !self.isAuthenticated;
	self.passwordField.enabled = !self.isAuthenticated;
	self.providerField.enabled = !self.isAuthenticated;

	UIColor *textColor = (self.isAuthenticated ? UIColor.lightGrayColor : UIColor.blackColor);
	self.usernameField.textColor = textColor;
	self.passwordField.textColor = textColor;
	self.providerField.textColor = textColor;
	
	// Toggle the state of the authentication action button based on the current
	// authentication state, and upddate its color.
	NSString *authenticationTitle = (self.isAuthenticated ? @"Sign Out" : @"Sign In");
	[self.authenticationActionButton setTitle:authenticationTitle forState:UIControlStateNormal];
	
	UIColor *authenticationColor = (self.isAuthenticated ? UIColor.redColor : self.view.tintColor);
	[self.authenticationActionButton setTitleColor:authenticationColor forState:UIControlStateNormal];
}

@end
