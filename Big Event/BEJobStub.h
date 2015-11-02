//  Big Event
//  Created by Jonathan Willing

#import <Foundation/Foundation.h>
#import <Mantle/Mantle.h>

#import "BELocation.h"

typedef NS_ENUM(NSInteger, BEJobStubState) {
	BEJobStubStateSurveyNeeded,
	BEJobStubStateSurveyCancelled,
	BEJobStubStateSurveyCompleted
};

@interface BEJobStub : MTLModel <MTLJSONSerializing>

@property (readonly) BEJobStubState state;
@property (readonly) BELocation *location;
@property (readonly, copy) NSString *detail;
@property (readonly) NSString *requestID;

+ (NSValueTransformer *)stateJSONTransformer;

@end
