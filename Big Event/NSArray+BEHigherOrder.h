//  Big Event
//  Created by Jonathan Willing

#import <Foundation/Foundation.h>

@interface NSArray (BEHigherOrder)

- (id)be_findFirst:(BOOL (^)(id obj))predicate;
- (NSArray *)be_map:(id (^)(id obj))mappingBlock;

@end
