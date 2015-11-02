//  Big Event
//  Created by Jonathan Willing

#import "NSArray+BEHigherOrder.h"

@implementation NSArray (BEHigherOrder)

- (NSArray *)be_map:(id (^)(id))mappingBlock {
	NSMutableArray *objects = [NSMutableArray array];
	
	for (id obj in self) {
		[objects addObject:mappingBlock(obj)];
	}
	
	return objects;
}

@end
