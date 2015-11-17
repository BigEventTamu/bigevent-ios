//  Big Event
//  Created by Jonathan Willing

#import <Foundation/Foundation.h>

@interface NSJSONSerialization (BEAdditions)

/// If data is nil, nil will be returned and no exception will be thrown.
///
/// Otherwise, an object will be returned.
+ (id)be_JSONObjectWithData:(NSData *)data error:(NSError **)error;

@end
