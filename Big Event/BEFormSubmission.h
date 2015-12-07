//  Big Event
//  Created by Jonathan Willing

#import <Mantle/Mantle.h>
#import "BEForm.h"

@interface BEFormSubmission : MTLModel <MTLJSONSerializing>

@property BEForm *form;
@property NSString *requestID;

@end
