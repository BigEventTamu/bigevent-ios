//  Big Event
//  Created by Jonathan Willing

#import <Foundation/Foundation.h>

@interface NSArray (BEHigherOrder)

- (NSArray *)be_map:(id (^)(id obj))mappingBlock;

@end
