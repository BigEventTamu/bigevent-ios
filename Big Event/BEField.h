//  Big Event
//  Created by Jonathan Willing

#import <Mantle/Mantle.h>

#import "BEChoice.h"

typedef NS_ENUM(NSInteger, BEFieldType) {
	BEFieldTypeText,
	BEFieldTypeChar,
	BEFieldTypeEmail,
	BEFieldTypeChoice,
	BEFieldTypeBoolean,
	BEFieldTypeInteger
};

@interface BEField : MTLModel <MTLJSONSerializing>

@property (readonly) BEFieldType type;
@property (readonly, copy) NSString *name;
@property (readonly, copy) NSString *fieldID;
@property (readonly, copy) NSString *helpText;
@property (readonly, strong) NSNumber *required;

/// If the field is a choice field, and if choices are specified in the model,
/// then this array will be non-null.
@property (readonly, strong) NSArray<BEChoice *> *choices;

@property (copy) NSString *value;

@end
