//  Big Event
//  Created by Jonathan Willing

#import "BEPopSegue.h"

@implementation BEPopSegue

- (void)perform {
	[self.sourceViewController.navigationController popViewControllerAnimated:YES];
}

@end
