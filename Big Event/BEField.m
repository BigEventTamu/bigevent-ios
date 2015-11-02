//  Big Event
//  Created by Jonathan Willing

#import "BEField.h"

@implementation BEField

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
		@"type": @"type",
		@"name": @"name",
		@"fieldID": @"id",
		@"value": @"value",
		@"choices": @"choices",
		@"required": @"required",
		@"helpText": @"help_text"
	};
}

+ (NSValueTransformer *)typeJSONTransformer {
	return [NSValueTransformer mtl_valueMappingTransformerWithDictionary:@{
		@"TextField": @(BEFieldTypeText),
		@"CharField": @(BEFieldTypeChar),
		@"EmailField": @(BEFieldTypeEmail),
		@"ChoiceField": @(BEFieldTypeChoice),
		@"BooleanField": @(BEFieldTypeBoolean),
		@"IntegerField": @(BEFieldTypeInteger)
	}];
}

+ (NSValueTransformer *)choicesJSONTransformer {
	return [MTLJSONAdapter arrayTransformerWithModelClass:BEChoice.class];
}

+ (NSValueTransformer *)requiredJSONTransformer {
	return [NSValueTransformer valueTransformerForName:MTLBooleanValueTransformerName];
}

@end
