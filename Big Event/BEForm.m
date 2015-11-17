//  Big Event
//  Created by Jonathan Willing

#import "BEForm.h"

@implementation BEForm

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
		@"fields": @"fields",
		@"name": @"form_name",
		@"detail": @"form_desc",
		@"formTypeID": @"form_type"
	};
}

+ (NSValueTransformer *)fieldsJSONTransformer {
	return [MTLJSONAdapter arrayTransformerWithModelClass:BEField.class];
}

- (NSDictionary *)parameterValue {
	NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
	
	[self.fields enumerateObjectsUsingBlock:^(BEField *field, NSUInteger idx, BOOL *stop) {
		id value = field.value;
		if ([value respondsToSelector:@selector(stringValue)]) {
			value = [value stringValue];
		}
		
		parameters[field.fieldID] = value;
	}];
	
	return parameters;
}

@end
