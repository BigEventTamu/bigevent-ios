//  Big Event
//  Created by Jonathan Willing

#import "NSDictionary+BEEncoding.h"

@implementation NSDictionary (BEEncoding)

NSString * const BENullString() {
	return @"%00";
}

NSString * BEURLEncode(NSString *string) {
	NSCharacterSet *characters = NSCharacterSet.URLQueryAllowedCharacterSet;
	return [string stringByAddingPercentEncodingWithAllowedCharacters:characters];
}

- (NSString *)be_URLEncodedParameters {
	NSMutableArray *components = [NSMutableArray array];
	
	[self enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *obj, BOOL *stop) {
		NSAssert([key isKindOfClass:NSString.class], @"key must be a string");
		NSAssert([obj isKindOfClass:NSString.class] ||
				 [obj isKindOfClass:NSNull.class], @"object must be a string or NSNull");
		
		// Replace NSNull with characters representing null.
		if ([obj isKindOfClass:NSNull.class]) {
			obj = BENullString();
		} else {
			obj = BEURLEncode(obj);
		}
		
		NSString *component = [NSString stringWithFormat:@"%@=%@", BEURLEncode(key), obj];
		[components addObject:component];
	}];
	
	return [components componentsJoinedByString:@"&"];
}

@end
