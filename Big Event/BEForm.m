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

@end
