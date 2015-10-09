//  Big Event
//  Created by Jonathan Willing

#import "BEAccountViewController.h"

static NSString * const BEDoneSegueIdentifier = @"done";
static NSString * const BECancelSegueIdentifier = @"cancel";

@interface BEAccountViewController ()

@property (weak) IBOutlet UITextField *usernameField;
@property (weak) IBOutlet UITextField *passwordField;
@property (weak) IBOutlet UIButton *authenticationActionButton;

@end


@implementation BEAccountViewController


#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
	
	[self.usernameField becomeFirstResponder];
}


#pragma mark - Actions

- (IBAction)performAuthenticationAction:(UIButton *)sender {
	// async login (or logout)
}


#pragma mark - Segues

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
	if ([identifier isEqualToString:BEDoneSegueIdentifier]) {
		
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
