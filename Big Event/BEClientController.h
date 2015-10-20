//  Big Event
//  Created by Jonathan Willing

#import <Foundation/Foundation.h>
#import "BEClient.h"

@interface BEClientController : NSObject

+ (instancetype)sharedController;

@property (nonatomic, readonly, strong) BEClient *client;

@end
