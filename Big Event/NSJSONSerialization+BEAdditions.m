//  Big Event
//  Created by Jonathan Willing

#import "NSJSONSerialization+BEAdditions.h"

@implementation NSJSONSerialization (BEAdditions)

+ (id)be_JSONObjectWithData:(NSData *)data error:(NSError *__autoreleasing *)error {
	if (data == nil) {
		return nil;
	}
	
	return [NSJSONSerialization JSONObjectWithData:data options:0 error:error];
}

@end
