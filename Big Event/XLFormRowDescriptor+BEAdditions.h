//  Big Event
//  Created by Jonathan Willing

#import <XLForm/XLForm.h>

#import "BEField.h"

@interface XLFormRowDescriptor (BEAdditions)

+ (instancetype)be_formDescriptorWithField:(BEField *)field;

@end
