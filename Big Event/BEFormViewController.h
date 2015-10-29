//  Big Event
//  Created by Jonathan Willing

#import "XLFormViewController.h"
#import "BEJobStub.h"

@protocol BEFormDelegate <NSObject>

@end

@interface BEFormViewController : XLFormViewController

@property (strong) BEJobStub *stub;
@property (weak) id<BEFormDelegate> delegate;

@end
