//
//  LynFillParametersViewHelperClasses.h
//  Lyn
//
//  Created by Programmieren on 11.10.13.
//  Copyright (c) 2013 Arne Philipeit Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "LynVariableChooserView.h"

@interface LynFillParameterTableCellView : NSTableCellView

@property IBOutlet NSMatrix *fillTypeMatrix;

@property IBOutlet LynVariableChooserView *variableChooser;

@end

@interface LynFillParameterBooleanTableCellView : LynFillParameterTableCellView

@property IBOutlet NSButton *staticBooleanCheckBox;

@end

@interface LynFillParameterIntegerTableCellView : LynFillParameterTableCellView

@property IBOutlet NSTextField *staticIntegerTextField;
@property IBOutlet NSStepper *staticIntegerStepper;

@end

@interface LynFillParameterStringTableCellView : LynFillParameterTableCellView

@property IBOutlet NSTextField *staticStringTextField;

@end


@interface LynFillParameterTableRowView : NSTableRowView

@end
