//
//  LynDefineScopeViewHelperClasses.h
//  Lyn
//
//  Created by Programmieren on 06.10.13.
//  Copyright (c) 2013 Arne Philipeit Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface LynDefineVariableBooleanTableCellView : NSTableCellView

@property IBOutlet NSButton *valueCheckbox;

@end

@interface LynDefineVariableIntegerTableCellView : NSTableCellView

@property IBOutlet NSTextField *valueField;
@property IBOutlet NSStepper *valueStepper;

@end

@interface LynDefineVariableStringTableCellView : NSTableCellView

@property IBOutlet NSTextField *valueField;

@end

@interface LynDefineVariablesRowView : NSTableRowView

@end

@interface LynDefineVariablesTableView : NSTableView

@end
