//  Big Event
//  Created by Jonathan Willing

#import <Foundation/Foundation.h>

#import "BEFormSubmission.h"
#import "BEOfflineQueue.h"
#import "BEJobStubPage.h"
#import "BEFormType.h"
#import "BEAccount.h"
#import "BEForm.h"

extern NSString * const BEClientDidLogoutNotification;
extern NSString * const BEClientDidSubmitFormNotification;
extern NSString * const BEClientDidUpdateFormTypeNotification;

/// The client object that is responsible for performing network requests.
@interface BEClient : NSObject


#pragma mark - Caching

/// Returns a proxy object that responds to all requests.
///
/// All requests that support caching, when called on this proxy, will return
/// the cached result, if it exists. If no cached result is available, it will
/// attempt to fallback to a normal network request.
///
/// If a request is performed on the cache that does not support caching, it
/// will perform it as normal by dispatching a network reqeust.
- (instancetype)cache;


#pragma mark - Offline

@property (readonly) BEOfflineQueue *offlineQueue;


#pragma mark - Authentication

/// The account that is currently logged in, if any.
@property (readonly, nonatomic, strong) BEAccount *currentAccount;

/// Whether or not there is a user that is currently authenticated.
@property (readonly, assign) BOOL authenticated;

/// Removes the current account, and erases the stored keychain values.
- (void)logout;

/// Attempts to authenticate with the specified account.
///
/// The account's username, password, and provider should be non-null.
///
/// THe completion block's success determines if the auth was successful.
- (void)authenticateWithAccount:(BEAccount *)account completion:(void (^)(BOOL success))completion;


#pragma mark - Forms

/// Represents an opaque storage of the current form type in the keychain.
///
/// This value will be set to nil if a logout is performed.
@property (strong) NSNumber *currentFormTypeID;

/// Attempts to request the form types, if authenticated.
///
/// Upon successful request, the form types will be returned, otherwise nil.
- (void)requestFormTypesWithCompletion:(void (^)(NSArray<BEFormType *> *types))completion;

- (void)requestFormWithFormType:(NSNumber *)formTypeID completion:(void (^)(BEForm *form))completion;
- (void)submitForm:(BEFormSubmission *)formSubmission completion:(void (^)(BOOL success))completion;


#pragma mark - Jobs

/// Attempts to request the job stubs, if authenticated.
///
/// Upon successful request, a job stub will be returned, otherwise nil.
///
/// This request supports caching.
- (void)requestJobStubsPageWithState:(BEJobStubState)state completion:(void (^)(BEJobStubPage *page))completion;

@end
