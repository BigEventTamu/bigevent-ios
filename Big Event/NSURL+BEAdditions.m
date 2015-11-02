//  Big Event
//  Created by Jonathan Willing

#import "NSURL+BEAdditions.h"

@implementation NSURL (BEAdditions)

static BOOL BEContainsTrailingSlash(NSURL *url) {
	return [url.absoluteString hasSuffix:@"/"];
}

- (NSURL *)be_URLByAppendingTrailingSlash {
	if (BEContainsTrailingSlash(self)) {
		return self;
	}
	
	NSString *URLString = [self.absoluteString stringByAppendingString:@"/"];
	return [NSURL URLWithString:URLString];
}

@end
