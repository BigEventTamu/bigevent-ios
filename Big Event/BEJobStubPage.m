//  Big Event
//  Created by Jonathan Willing

#import "BEJobStubPage.h"

@implementation BEJobStubPage

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
		@"state": @"job_state",
		@"stubs": @"job_stubs",
		@"numberOfPages": @"num_pages",
		@"currentPage": @"current_page"
	};
}

+ (NSValueTransformer *)stateJSONTransformer {
	return BEJobStub.stateJSONTransformer;
}

+ (NSValueTransformer *)stubsJSONTransformer {
	return [MTLJSONAdapter arrayTransformerWithModelClass:BEJobStub.class];
}

@end
