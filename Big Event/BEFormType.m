//  Big Event
//  Created by Jonathan Willing

#import "BEFormType.h"

@implementation BEFormType

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
		@"name": @"name",
		@"identifier": @"id",
		@"detail": @"description",
		@"current": @"is_current"
	};
}

+ (NSValueTransformer *)currentJSONTransformer {
	return [NSValueTransformer valueTransformerForName:MTLBooleanValueTransformerName];
}

@end
