//  Big Event
//  Created by Jonathan Willing

#import "BEDismissSegue.h"

@implementation BEDismissSegue

- (void)perform {
	UIViewController *presentingViewController = self.sourceViewController.presentingViewController;
	[presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
