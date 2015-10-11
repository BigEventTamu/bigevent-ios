//  Big Event
//  Created by Jonathan Willing

#import "BEAccountController.h"

@implementation BEAccountController


#pragma mark - Lifecycle

+ (instancetype)sharedController {
	static BEAccountController *controller = nil;
	
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		controller = [[self alloc] init];
	});
	
	return controller;
}

@end
