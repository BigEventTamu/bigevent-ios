//  Big Event
//  Created by Jonathan Willing

#import <Foundation/Foundation.h>

@interface NSHTTPURLResponse (BEAdditions)

/// Returns whether the HTTP status code signifies a success (2xx).
@property (readonly) BOOL be_statusSuccess;

@end
