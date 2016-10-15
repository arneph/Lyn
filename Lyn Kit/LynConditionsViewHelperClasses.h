//
//  LynConditionsViewHelperClasses.h
//  Lyn
//
//  Created by Programmieren on 05.10.13.
//  Copyright (c) 2013 Arne Philipeit Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "LynVariableChooserView.h"

@interface LynComparingConditionTableCellView : NSTableCellView

@property IBOutlet NSMatrix *fillTypeMatrixA;
@property IBOutlet NSMatrix *fillTypeMatrixB;

@property IBOutlet LynVariableChooserView *variableChooserA;
@property IBOutlet LynVariableChooserView *variableChooserB;

@property IBOutlet NSTextField *operationTextField;

@property IBOutlet NSBox *separator1;
@property IBOutlet NSBox *separator2;

- (void)showDataTypeSpecificControlsForParameterA;
- (void)showDataTypeSpecificControlsForParameterB;

- (void)hideDataTypeSpecificControlsForParameterA;
- (void)hideDataTypeSpecificControlsForParameterB;

@end

@interface LynComparingConditionBooleanTableCellView : LynComparingConditionTableCellView

@property IBOutlet NSButton *staticBooleanCheckBoxA;
@property IBOutlet NSButton *staticBooleanCheckBoxB;

@end

@interface LynComparingConditionIntegerTableCellView : LynComparingConditionTableCellView

@property IBOutlet NSTextField *staticIntegerTextFieldA;
@property IBOutlet NSTextField *staticIntegerTextFieldB;

@property IBOutlet NSStepper *staticIntegerStepperA;
@property IBOutlet NSStepper *staticIntegerStepperB;

@end

@interface LynComparingConditionStringTableCellView : LynComparingConditionTableCellView

@property IBOutlet NSTextField *staticStringTextFieldA;
@property IBOutlet NSTextField *staticStringTextFieldB;

@end

@interface LynCombiningConditionTableCellView : NSTableCellView

@property IBOutlet NSPopUpButton *typeChooser;

@end

@interface LynConditionNegationTableCellView : NSTableCellView

@property IBOutlet NSButton *chkNegate;

@end

@interface LynConditionParameterSeparator : NSBox

@end

@interface LynComparingConditionTableRowView : NSTableRowView

@end

@interface LynConditionsOutlineView : NSOutlineView

@end
