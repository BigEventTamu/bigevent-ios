//  Big Event
//  Created by Jonathan Willing

#import <Mantle/Mantle.h>

#import "BEField.h"

@interface BEForm : MTLModel <MTLJSONSerializing>

@property (readonly, copy) NSString *name;
@property (readonly, copy) NSString *detail;
@property (readonly, strong) NSNumber *formTypeID;
@property (readonly, strong) NSArray<BEField *> *fields;

@end
