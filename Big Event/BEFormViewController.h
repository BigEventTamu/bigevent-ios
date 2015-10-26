//  Big Event
//  Created by Jonathan Willing

#import "XLFormViewController.h"

@protocol BEFormDelegate <NSObject>

@end

@interface BEFormViewController : XLFormViewController

@property (copy) NSString *requestID;
@property (weak) id<BEFormDelegate> delegate;

@end
