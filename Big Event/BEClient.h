//  Big Event
//  Created by Jonathan Willing

#import <Foundation/Foundation.h>
#import "BEAccount.h"

extern NSString * const BEClientDidLogoutNotification;


@interface BEClient : NSObject

@property (readonly, assign) BOOL authenticated;

- (void)logout;
- (void)authenticateWithAccount:(BEAccount *)account completion:(void (^)(BOOL success))completion;

@end
