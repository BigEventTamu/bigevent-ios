//  Big Event
//  Created by Jonathan Willing

#import <Foundation/Foundation.h>

#import "BEJobStubPage.h"
#import "BEFormType.h"
#import "BEAccount.h"

extern NSString * const BEClientDidLogoutNotification;

@interface BEClient : NSObject

@property (readonly, nonatomic, strong) BEAccount *currentAccount;


#pragma mark - Authentication

@property (readonly, assign) BOOL authenticated;

- (void)logout;
- (void)authenticateWithAccount:(BEAccount *)account completion:(void (^)(BOOL success))completion;


#pragma mark - Forms

@property (strong) NSNumber *currentFormTypeID;
- (void)requestFormTypesWithCompletion:(void (^)(NSArray<BEFormType *> *types, BOOL success))completion;


#pragma mark - Jobs

- (void)requestJobStubsPageWithState:(BEJobStubState)state completion:(void (^)(BEJobStubPage *page, BOOL success))completion;

@end
