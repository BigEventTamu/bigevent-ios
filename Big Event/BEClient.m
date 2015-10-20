//  Big Event
//  Created by Jonathan Willing

#import "BEClient.h"
#import <UICKeyChainStore/UICKeyChainStore.h>

static NSString * const BEClientKeychainTokenIdentifier = @"authentication-token";
NSString * const BEClientDidLogoutNotification = @"BEClientDidLogout";

// Resources
static NSString * const BEClientAuthenticationResource = @"get-token";

// Typedefs.
typedef void (^BERequestCompletion)(NSData *data, NSURLResponse *response, NSError *error);

@interface BEClient () <NSURLSessionDelegate>

@property (nonatomic, assign) NSString *token;
@property (readwrite, strong) BEAccount *currentAccount;

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


#pragma mark - URLs

- (NSString *)currentProvider {
	return self.currentAccount.provider;
}

- (NSURL *)resourceURLWithBaseProvider:(NSString *)provider resource:(NSString *)resource {
	NSURL *baseURL = [NSURL URLWithString:provider];
	return [baseURL URLByAppendingPathComponent:resource];
}


#pragma mark - Networking

- (NSURLSessionUploadTask *)POSTRequestWithResource:(NSString *)resource parameters:(NSDictionary *)parameters completionHandler:(BERequestCompletion)completionHandler {
	NSURL *resourceURL = [self resourceURLWithBaseProvider:self.currentProvider resource:resource];
	NSURLSessionConfiguration *configuration = NSURLSessionConfiguration.defaultSessionConfiguration;
	NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
	
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:resourceURL];
	request.HTTPMethod = @"POST";
	
	NSError *serializationError = nil;
	NSData *data = [NSJSONSerialization dataWithJSONObject:parameters options:kNilOptions error:&serializationError];
	
	if (serializationError == nil) {
		return [session uploadTaskWithRequest:request fromData:data completionHandler:completionHandler];
	} else {
		return nil;
	}
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
	NSAssert(account.username.length > 0 && account.password.length > 0 && account.provider.length > 0, @"invalid account");
	self.currentAccount = account;

	NSDictionary *parameters = @{
		@"username": self.currentAccount.username,
		@"password": self.currentAccount.password
	};
	
	NSString *resource = BEClientAuthenticationResource;
	
	BERequestCompletion requestCompletion = ^(NSData *data, NSURLResponse *response, NSError *error) {
		if (error != nil || data == nil) {
			NSLog(@"error: %@", error);
			completion(NO);
		} else {
			//completion(YES);
			NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
			NSLog(@"result: %@", result);
			NSLog(@"response: %@", response);
		}
	};
	
	NSURLSessionUploadTask *task = [self POSTRequestWithResource:resource parameters:parameters completionHandler:requestCompletion];
	[task resume];
}

#pragma mark - NSURLSessionDelegate

- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential *))completionHandler {
	// Allow self-signed certs for development environments.
	if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
		NSURL *url = [NSURL URLWithString:self.currentAccount.provider];
		if ([challenge.protectionSpace.host isEqualToString:url.host]) {
			NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
			completionHandler(NSURLSessionAuthChallengeUseCredential, credential);
		}
	}
}

@end
