//  Big Event
//  Created by Jonathan Willing

#import "BEFormRowDescriptor.h"
#import "NSArray+BEHigherOrder.h"

@implementation BEFormRowDescriptor


static NSString * BEXLFormTypeFromBEFormType(BEFieldType type) {
	switch (type) {
		case BEFieldTypeText:
			return XLFormRowDescriptorTypeTextView;
		case BEFieldTypeChar:
			return XLFormRowDescriptorTypeText;
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

+ (instancetype)formDescriptorWithField:(BEField *)field {
	NSString *rowType = BEXLFormTypeFromBEFormType(field.type);
	
	BEFormRowDescriptor *row = [BEFormRowDescriptor formRowDescriptorWithTag:field.fieldID rowType:rowType];
	row.required = field.required.boolValue;
	row.title = field.name;
	row->_field = field;
	
	if (field.choices != nil) {
		row.selectorOptions = [field.choices be_map:^id(BEChoice *choice) {
			return [XLFormOptionsObject formOptionsObjectWithValue:choice.choiceID displayText:choice.value];
		}];
		row.selectorTitle = field.name;
	}
	
	return row;
}

@end
