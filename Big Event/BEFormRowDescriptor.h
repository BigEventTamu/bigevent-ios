//  Big Event
//  Created by Jonathan Willing

#import <XLForm/XLForm.h>

#import "BEField.h"

@interface BEFormRowDescriptor : XLFormRowDescriptor

+ (instancetype)formDescriptorWithField:(BEField *)field;
@property (readonly, strong) BEField *field;

@end
