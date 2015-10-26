//  Big Event
//  Created by Jonathan Willing

#import <Foundation/Foundation.h>
#import <Mantle/Mantle.h>

@interface BELocation : MTLModel <MTLJSONSerializing>

@property (readonly, copy) NSString *city;
@property (readonly, copy) NSString *state;
@property (readonly, copy) NSString *address1;
@property (readonly, copy) NSString *address2;
@property (readonly, copy) NSString *zipCode;
@property (readonly) NSNumber *latitude;
@property (readonly) NSNumber *longitude;

@end
