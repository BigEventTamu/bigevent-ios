//  Big Event
//  Created by Jonathan Willing

#import <Mantle/Mantle.h>

@interface BEFormType : MTLModel <MTLJSONSerializing>

@property (readonly, copy) NSString *name;
@property (readonly, copy) NSString *detail;
@property (readonly) NSNumber *identifier;
@property (readonly) BOOL current;

@end
