//  Big Event
//  Created by Jonathan Willing

#import "BEClient.h"
#import <UICKeyChainStore/UICKeyChainStore.h>

static NSString * const BEClientKeychainTokenIdentifier = @"authentication-token";
NSString * const BEClientDidLogoutNotification = @"BEClientDidLogout";


@interface BEClient ()

@property (nonatomic, assign) NSString *token;

@end


@implementation BEClient


#pragma mark - Keychain

- (UICKeyChainStore *)keychain {
	return [UICKeyChainStore keyChainStoreWithService:@"com.bigevent.client"];
}

- (void)setToken:(NSString *)token {
	self.keychain[BEClientKeychainTokenIdentifier] = token;
}

- (NSString *)token {
	return self.keychain[BEClientKeychainTokenIdentifier];
}


#pragma mark - Authentication

- (BOOL)authenticated {
	// Token never expires. If it exists, we're authentiated.
	return (self.token != nil);
}

- (void)logout {
	NSAssert(NSThread.isMainThread, @"-logout should be called on the main thread");
	self.token = nil;
	
	[NSNotificationCenter.defaultCenter postNotificationName:BEClientDidLogoutNotification object:nil];
}

- (void)authenticateWithAccount:(BEAccount *)account completion:(void (^)(BOOL success))completion {
	
}

@end
