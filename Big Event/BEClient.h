//  Big Event
//  Created by Jonathan Willing

#import <Foundation/Foundation.h>

#import "BEAccount.h"
#import "BEJobStubPage.h"

extern NSString * const BEClientDidLogoutNotification;

@interface BEClient : NSObject

@property (readonly, assign) BOOL authenticated;
@property (readonly, nonatomic, strong) BEAccount *currentAccount;

- (void)logout;
- (void)authenticateWithAccount:(BEAccount *)account completion:(void (^)(BOOL success))completion;
- (void)requestFormTypesWithCompletion:(void (^)(NSArray *form, BOOL success))completion;
- (void)requestJobStubsPageWithState:(BEJobStubState)state completion:(void (^)(BEJobStubPage *page, BOOL success))completion;

@end
