//  Big Event
//  Created by Jonathan Willing

#import "NSDictionary+BEEncoding.h"

@implementation NSDictionary (BEEncoding)

NSString * BEURLEncode(NSString *string) {
	NSCharacterSet *characters = NSCharacterSet.URLQueryAllowedCharacterSet;
	return [string stringByAddingPercentEncodingWithAllowedCharacters:characters];
}

- (NSString *)be_URLEncodedParameters {
	NSMutableArray *components = [NSMutableArray array];
	
	[self enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *obj, BOOL *stop) {
		NSAssert([key isKindOfClass:NSString.class], @"key must be a string");
		NSAssert([obj isKindOfClass:NSString.class], @"object must be a string");
		
		NSString *component = [NSString stringWithFormat:@"%@=%@", BEURLEncode(key), BEURLEncode(obj)];
		[components addObject:component];
	}];
	
	return [components componentsJoinedByString:@"&"];
}

@end
