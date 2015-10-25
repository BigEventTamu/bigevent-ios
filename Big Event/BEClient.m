//  Big Event
//  Created by Jonathan Willing

#import "BEClient.h"
#import "NSDictionary+BEEncoding.h"

#import <UICKeyChainStore/UICKeyChainStore.h>


// Notifications.
NSString * const BEClientDidLogoutNotification = @"BEClientDidLogout";

// Keychain.
static NSString * const BEClientKeychainTokenIdentifier = @"authentication-token";
static NSString * const BEClientKeychainUsernameIdentifier = @"username";
static NSString * const BEClientKeychainPasswordIdentifier = @"password";
static NSString * const BEClientKeychainProviderIdentifier = @"provider";

// Resources
static NSString * const BEClientAuthenticationResource = @"get-token/";

// Typedefs.
typedef void (^BERequestCompletion)(NSData *data, NSURLResponse *response, NSError *error);


@interface BEClient () <NSURLSessionDelegate>

@property (nonatomic, copy) NSString *token;
@property (readwrite, nonatomic, strong) BEAccount *currentAccount;

@end


@implementation BEClient
@synthesize currentAccount = _currentAccount;

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

- (void)setCurrentAccount:(BEAccount *)currentAccount {
	_currentAccount = currentAccount;
	
	self.keychain[BEClientKeychainUsernameIdentifier] = currentAccount.username;
	self.keychain[BEClientKeychainPasswordIdentifier] = currentAccount.password;
	self.keychain[BEClientKeychainProviderIdentifier] = currentAccount.provider;
}

- (BEAccount *)currentAccount {
	if (_currentAccount == nil) {
		_currentAccount = [[BEAccount alloc] init];
		
		_currentAccount.username = self.keychain[BEClientKeychainUsernameIdentifier];
		_currentAccount.password = self.keychain[BEClientKeychainPasswordIdentifier];
		_currentAccount.provider = self.keychain[BEClientKeychainProviderIdentifier];
	}
	
	return _currentAccount;
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

- (NSURLSessionDataTask *)POSTRequestWithResource:(NSString *)resource parameters:(NSDictionary *)parameters completionHandler:(BERequestCompletion)completionHandler {
	NSURL *resourceURL = [self resourceURLWithBaseProvider:self.currentAccount.provider resource:resource];
	
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:resourceURL];
	request.HTTPBody = [parameters.be_URLEncodedParameters dataUsingEncoding:NSUTF8StringEncoding];
	request.HTTPMethod = @"POST";
	request.allHTTPHeaderFields = @{
		@"Content-Type": @"application/x-www-form-urlencoded"
	};
	
	NSURLSessionConfiguration *configuration = NSURLSessionConfiguration.defaultSessionConfiguration;
	NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
	
	return [session dataTaskWithRequest:request completionHandler:completionHandler];
}


#pragma mark - Authentication

- (BOOL)authenticated {
	// Token never expires. If it exists, we're authentiated.
	return (self.token != nil);
}

- (void)logout {
	NSAssert(NSThread.isMainThread, @"-logout should be called on the main thread");
	self.token = nil;
	self.currentAccount = nil;
	
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
		NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
		
		dispatch_async(dispatch_get_main_queue(), ^{
			if (data != nil && httpResponse.statusCode == 200) {
				self.token = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
				completion(YES);
			} else {
				completion(NO);
			}
		});
	};
	
	NSURLSessionDataTask *task = [self POSTRequestWithResource:resource parameters:parameters completionHandler:requestCompletion];
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
