//  Big Event
//  Created by Jonathan Willing

#import <Mantle/Mantle.h>

@interface BEChoice : MTLModel <MTLJSONSerializing>

@property (readonly, copy) NSString *value;
@property (readonly, copy) NSString *choiceID;

@end
