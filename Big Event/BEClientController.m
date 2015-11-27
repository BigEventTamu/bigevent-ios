//  Big Event
//  Created by Jonathan Willing

#import "BEClientController.h"
#import "BECachedClient.h"

@interface BEClientController ()

@property (nonatomic, readwrite, strong) BEClient *client;

@end


@implementation BEClientController


#pragma mark - Lifecycle

+ (instancetype)sharedController {
	static BEClientController *controller = nil;
	
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		controller = [[self alloc] init];
	});
	
	return controller;
}


#pragma mark - Client

- (BEClient *)client {
	if (_client == nil) {
		_client = [[BECachedClient alloc] init];
	}
	
	return _client;
}

@end
