//  Big Event
//  Created by Jonathan Willing

#import <Foundation/Foundation.h>
#import <Mantle/Mantle.h>

#import "BEJobStub.h"

@interface BEJobStubPage : MTLModel <MTLJSONSerializing>

@property (readonly) BEJobStubState state;
@property (readonly) NSInteger currentPage;
@property (readonly) NSInteger numberOfPages;
@property (readonly) NSArray<BEJobStub *> *stubs;

@end
