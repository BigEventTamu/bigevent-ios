//  Big Event
//  Created by Jonathan Willing

#import "XLFormRowDescriptor+BEAdditions.h"
#import "NSArray+BEHigherOrder.h"

@implementation XLFormRowDescriptor (BEAdditions)

static NSString * BEXLFormTypeFromBEFormType(BEFieldType type) {
	switch (type) {
		case BEFieldTypeText:
			return XLFormRowDescriptorTypeText;
		case BEFieldTypeChar:
			return XLFormRowDescriptorTypeText; // TODO: is this correct behavior?
		case BEFieldTypeEmail:
			return XLFormRowDescriptorTypeEmail;
		case BEFieldTypeChoice:
			return XLFormRowDescriptorTypeSelectorPush;
		case BEFieldTypeBoolean:
			return XLFormRowDescriptorTypeBooleanSwitch;
		case BEFieldTypeInteger:
			return XLFormRowDescriptorTypeInteger;
		default:
			return nil;
	}
}


+ (instancetype)be_formDescriptorWithField:(BEField *)field {
	NSString *rowType = BEXLFormTypeFromBEFormType(field.type);
	
	XLFormRowDescriptor *row = [XLFormRowDescriptor formRowDescriptorWithTag:field.fieldID rowType:rowType];
	row.required = field.required.boolValue;
	row.title = field.name;
	
	if (field.choices != nil) {
		row.selectorOptions = [field.choices be_map:^id(BEChoice *choice) {
			return [XLFormOptionsObject formOptionsObjectWithValue:choice.choiceID displayText:choice.value];
		}];
		row.selectorTitle = field.name;
	}
	
	
	return row;
}

@end
