//  Big Event
//  Created by Jonathan Willing

#import "BEJobStub.h"

@implementation BEJobStub

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
		@"state": @"job_state",
		@"location": @"location",
		@"detail": @"job_description",
		@"requestID": @"job_request_id"
	};
}

+ (NSValueTransformer *)stateJSONTransformer {
	return [NSValueTransformer mtl_valueMappingTransformerWithDictionary:@{
		@"needs_survey": @(BEJobStubStateSurveyNeeded),
		@"survey_cancelled": @(BEJobStubStateSurveyCancelled),
		@"survey_completed": @(BEJobStubStateSurveyCompleted)
	}];
}

+ (NSValueTransformer *)locationJSONTransformer {
	return [MTLJSONAdapter dictionaryTransformerWithModelClass:BELocation.class];
}

@end
