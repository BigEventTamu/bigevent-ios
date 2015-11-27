//  Big Event
//  Created by Jonathan Willing

#import "NSHTTPURLResponse+BEAdditions.h"

@implementation NSHTTPURLResponse (BEAdditions)

- (BOOL)be_statusSuccess {
	NSString *status = @(self.statusCode).stringValue;
	return ([status characterAtIndex:0] == '2');
}

@end
