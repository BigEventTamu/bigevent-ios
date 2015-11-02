//  Big Event
//  Created by Jonathan Willing

#import "BELocation.h"

@implementation BELocation

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
		@"city": @"city",
		@"state": @"state",
		@"latitude": @"lat",
		@"longitude": @"lon",
		@"zipCode": @"zip_code",
		@"address1": @"address_1",
		@"address2": @"address_2"
	};
}

@end
