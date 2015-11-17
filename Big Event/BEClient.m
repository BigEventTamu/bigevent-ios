//  Big Event
//  Created by Jonathan Willing

#import "BEClient.h"
#import "NSURL+BEAdditions.h"
#import "NSDictionary+BEEncoding.h"
#import "NSJSONSerialization+BEAdditions.h"

#import <UICKeyChainStore/UICKeyChainStore.h>


// Notifications.
NSString * const BEClientDidLogoutNotification = @"BEClientDidLogout";
NSString * const BEClientDidUpdateFormTypeNotification = @"BEClientDidUpdateFormType";

// Keychain.
static NSString * const BEClientKeychainTokenIdentifier = @"authentication-token";
static NSString * const BEClientKeychainUsernameIdentifier = @"username";
static NSString * const BEClientKeychainPasswordIdentifier = @"password";
static NSString * const BEClientKeychainProviderIdentifier = @"provider";
static NSString * const BEClientKeychainFormTypeIdentifier = @"form-type";

// Resources
static NSString * const BEClientAuthenticationResource = @"get-token/";
static NSString * const BEClientFormTypesResource = @"formtypes/";
static NSString * const BEClientJobStubsResource = @"jobstubs/";
static NSString * const BEClientFormResource = @"form/";

// Status codes.
static const NSInteger BEClientHTTPStatusOK = 200;
static const NSInteger BEClientHTTPStatusProcessed = 203;
static const NSInteger BEClientHTTPStatusPartialContent = 206;

// Typedefs.
typedef void (^BERequestCompletion)(NSData *data, NSHTTPURLResponse *response, NSError *error);


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
	
	if (currentAccount == nil) {
		self.keychain[BEClientKeychainFormTypeIdentifier] = nil;
	}
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

- (void)setCurrentFormTypeID:(NSNumber *)currentFormTypeID {
	self.keychain[BEClientKeychainFormTypeIdentifier] = currentFormTypeID.stringValue;
	
	[NSNotificationCenter.defaultCenter postNotificationName:BEClientDidUpdateFormTypeNotification object:nil];
}

- (NSNumber *)currentFormTypeID {
	NSString *formTypeID = self.keychain[BEClientKeychainFormTypeIdentifier];
	
	if (formTypeID != nil) {
		return @(formTypeID.integerValue);
	}
	
	return nil;
}


#pragma mark - URLs

- (NSString *)currentProvider {
	return self.currentAccount.provider;
}

- (NSURL *)resourceURLWithBaseProvider:(NSString *)provider resource:(NSString *)resource {
	NSURL *baseURL = [NSURL URLWithString:provider];
	baseURL = [baseURL URLByAppendingPathComponent:resource];
	return [baseURL be_URLByAppendingTrailingSlash];
}


#pragma mark - Formatting

static NSString * BEAuthorizationToken(NSString *token) {
	return (token != nil ? [NSString stringWithFormat:@"Token %@", token] : @"");
}


#pragma mark - Networking

- (NSURLSessionDataTask *)POSTRequestWithResource:(NSString *)resource parameters:(NSDictionary *)parameters completion:(BERequestCompletion)completion {
	NSURL *resourceURL = [self resourceURLWithBaseProvider:self.currentAccount.provider resource:resource];
	
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:resourceURL];
	request.HTTPBody = [parameters.be_URLEncodedParameters dataUsingEncoding:NSUTF8StringEncoding];
	request.HTTPMethod = @"POST";
	request.allHTTPHeaderFields = @{
		@"Content-Type": @"application/x-www-form-urlencoded",
		@"Authorization": BEAuthorizationToken(self.token)
	};
	
	NSURLSessionConfiguration *configuration = NSURLSessionConfiguration.defaultSessionConfiguration;
	NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
	
	return [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
		dispatch_async(dispatch_get_main_queue(), ^{
			completion(data, (NSHTTPURLResponse *)response, error);
		});
	}];
}

- (NSURLSessionDataTask *)GETRequestWithResource:(NSString *)resource pathParameters:(NSArray<NSString *> *)parameters completion:(BERequestCompletion)completion {
	NSURLSessionConfiguration *configuration = NSURLSessionConfiguration.defaultSessionConfiguration;
	
	NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
	
	NSURL *resourceURL = [self resourceURLWithBaseProvider:self.currentAccount.provider resource:resource];
	for (NSString *parameter in parameters) {
		resourceURL = [resourceURL URLByAppendingPathComponent:parameter];
	}
	
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:resourceURL];
	request.allHTTPHeaderFields = @{
		@"Authorization": BEAuthorizationToken(self.token)
	};
	
	return [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
		dispatch_async(dispatch_get_main_queue(), ^{
			completion(data, (NSHTTPURLResponse *)response, error);
		});
	}];
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
	
	BERequestCompletion requestCompletion = ^(NSData *data, NSHTTPURLResponse *response, NSError *error) {
		if (response.statusCode == BEClientHTTPStatusOK && data != nil) {
			NSString *token = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
			self.token = [token stringByReplacingOccurrencesOfString:@"\"" withString:@""]; // strip quotes
			completion(YES);
		} else {
			completion(NO);
		}
	};
	
	NSURLSessionDataTask *task = [self POSTRequestWithResource:resource parameters:parameters completion:requestCompletion];
	[task resume];
}


#pragma mark - Forms

- (void)requestFormTypesWithCompletion:(void (^)(NSArray<BEFormType *> *))completion {
	if (self.token == nil) {
		completion(nil);
		return;
	}
	
	NSString *resource = BEClientFormTypesResource;
	
	BERequestCompletion requestCompletion = ^(NSData *data, NSHTTPURLResponse *response, NSError *error) {
		if (response.statusCode != BEClientHTTPStatusOK) {
			completion(nil);
		} else {
			NSArray *JSON = [NSJSONSerialization be_JSONObjectWithData:data error:&error];
			NSArray *objects = [MTLJSONAdapter modelsOfClass:BEFormType.class fromJSONArray:JSON error:&error];
			completion(objects);
		}
	};
	
	NSURLSessionDataTask *task = [self GETRequestWithResource:resource pathParameters:nil completion:requestCompletion];
	[task resume];
}

- (void)requestFormWithFormType:(NSNumber *)formTypeID completion:(void (^)(BEForm *))completion {
	if (self.token == nil) {
		completion(nil);
		return;
	}
	
	NSString *resource = BEClientFormResource;
	resource = [resource stringByAppendingPathComponent:formTypeID.stringValue];
	
	BERequestCompletion requestCompletion = ^(NSData *data, NSHTTPURLResponse *response, NSError *error) {
		if (response.statusCode != BEClientHTTPStatusOK) {
			completion(nil);
		} else {
			NSDictionary *JSON = [NSJSONSerialization be_JSONObjectWithData:data error:&error];
			BEForm *form = [MTLJSONAdapter modelOfClass:BEForm.class fromJSONDictionary:JSON error:&error];
			completion(form);
		}
	};
	
	NSURLSessionDataTask *task = [self GETRequestWithResource:resource pathParameters:nil completion:requestCompletion];
	[task resume];
}

- (void)submitForm:(BEForm *)form stub:(BEJobStub *)stub completion:(void (^)(BOOL))completion {
	if (self.token == nil) {
		completion(NO);
		return;
	}
	
	NSString *resource = BEClientFormResource;
	resource = [resource stringByAppendingPathComponent:form.formTypeID.stringValue];
	
	// Encode the form and the job request id into url-encoded parameters.
	NSMutableDictionary *parameters = form.parameterValue.mutableCopy;
	[parameters addEntriesFromDictionary:@{
		@"job_request_id": stub.requestID
	}];
	
	BERequestCompletion requestCompletion = ^(NSData *data, NSHTTPURLResponse *response, NSError *error) {
		if (response.statusCode != BEClientHTTPStatusProcessed || data == nil) {
			completion(NO);
		} else {
			NSString *identifier = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

			NSLog(@"unique form ID: %@", identifier);
			completion(YES);
		}
	};
	
	NSLog(@"form params: %@", parameters);
	
	NSURLSessionDataTask *task = [self POSTRequestWithResource:resource parameters:parameters completion:requestCompletion];
	[task resume];
}


#pragma mark - Jobs

- (void)requestJobStubsPageWithState:(BEJobStubState)state completion:(void (^)(BEJobStubPage *))completion {
	if (self.token == nil) {
		completion(nil);
		return;
	}
	
	NSString *resource = BEClientJobStubsResource;
	
	BERequestCompletion requestCompletion = ^(NSData *data, NSHTTPURLResponse *response, NSError *error) {
		if (response.statusCode != BEClientHTTPStatusPartialContent) {
			completion(nil);
		} else {
			NSDictionary *JSON = [NSJSONSerialization be_JSONObjectWithData:data error:&error];
			BEJobStubPage *page = [MTLJSONAdapter modelOfClass:BEJobStubPage.class fromJSONDictionary:JSON error:&error];
			completion(page);
		}
	};
	
	NSURLSessionDataTask *task = [self GETRequestWithResource:resource pathParameters:nil completion:requestCompletion];
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
