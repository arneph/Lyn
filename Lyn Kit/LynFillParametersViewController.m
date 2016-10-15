//
//  LynFillParametersViewController.m
//  Lyn
//
//  Created by Programmieren on 23.06.13.
//  Copyright (c) 2013 Arne Philipeit Software. All rights reserved.
//

#import "LynFillParametersViewController.h"

@interface LynFillParametersViewController () <NSTableViewDataSource, NSTableViewDelegate>

@property IBOutlet NSTableView *tableView;

- (IBAction)parameterFillTypeChanged:(NSMatrix*)sender;

- (IBAction)staticBooleanCheckBoxChanged:(NSButton*)sender;

- (IBAction)staticIntegerTextFieldChanged:(NSTextField*)sender;
- (IBAction)staticIntegerStepperChanged:(NSStepper*)sender;

- (IBAction)staticStringTextFieldChanged:(NSTextField*)sender;

@end

@implementation LynFillParametersViewController
@synthesize command = _command;

- (id)init{
    self = [super initWithNibName:@"LynFillParametersView"
                           bundle:[NSBundle bundleForClass:self.class]];
    if (self) {
        [NotificationCenter addObserver:self
                               selector:@selector(colorsChanged:)
                                   name:LynSettingChangedNotification
                                 object:nil];
    }
    return self;
}

- (id)command{
    return _command;
}

- (void)setCommand:(id)command{
    _command = command;
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:LynCommandNumberOfParametersChangedNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(parametersDidChange:)
                                                 name:LynCommandNumberOfParametersChangedNotification
                                               object:_command];
    [_tableView reloadData];
}

- (void)parametersDidChange: (NSNotification*)notification{
    [_tableView reloadData];
}

- (void)colorsChanged: (NSNotification*)notification{
    [_tableView reloadData];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    if (_command.parameters.count > 0) {
        return _command.parameters.count;
    }else{
        return 1;
    }
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    if (_command.parameters.count > 0) {
        return _command.parameters[row];
    }else{
        return @0;
    }
}

- (NSView*)tableView:(NSTableView *)tableView
  viewForTableColumn:(NSTableColumn *)tableColumn
                 row:(NSInteger)row{
    if (_command.parameters.count < 1) {
        NSTableCellView *cellView = [_tableView makeViewWithIdentifier:@"NoParametersCell" owner:self];
        return cellView;
    }
    LynFunction *function;
    LynOutlineObject *parent = _command.parent;
    while (![parent isKindOfClass:[LynFunction class]]&&parent) {
        parent = parent.parent;
    }
    if (!parent) return nil;
    function = (LynFunction*)parent;
    LynParameter *parameter = _command.parameters[row];
    LynFillParameterTableCellView *cellView;
    if (parameter.parameterType == LynDataTypeBoolean) {
        cellView = [_tableView makeViewWithIdentifier:@"BooleanParameterCell" owner:self];
    }else if (parameter.parameterType == LynDataTypeInteger) {
        cellView = [_tableView makeViewWithIdentifier:@"IntegerParameterCell" owner:self];
    }else if (parameter.parameterType == LynDataTypeString) {
        cellView = [_tableView makeViewWithIdentifier:@"StringParameterCell" owner:self];
    }
    cellView.textField.stringValue = [parameter.name stringByAppendingString:@":"];
    [cellView.fillTypeMatrix setEnabled:!parameter.fixedStatic];
    [cellView.fillTypeMatrix selectCellAtRow:(parameter.fillType != LynParameterFillTypeStatic) column:0];
    if (parameter.fillType == LynParameterFillTypeDynamicFromVariable||
        parameter.fillType == LynParameterFillTypeDynamicFromParameter) {
        [cellView.variableChooser setHidden:NO];
        [cellView.variableChooser setType:parameter.parameterType];
        LynScope *scope;
        for (LynOutlineObject *parent in _command.parents) {
            if (!scope&&[[parent class] hasScope]) scope = parent.scope;
        }
        [cellView.variableChooser beginUpdates];
        [cellView.variableChooser setScope:scope];
        [cellView.variableChooser setParameters:function.parameters];
        [cellView.variableChooser selectVariable:parameter.parameterValue];
        [cellView.variableChooser endUpdates];
        
        [cellView.variableChooser setTarget:self];
        [cellView.variableChooser setAction:@selector(variableChooserChanged:)];
        
        if (!parameter.parameterValue&&cellView.variableChooser.selectedVariable) {
            [self undoableSetParameterValue:@{@"parameter" : parameter,
                                              @"value" : cellView.variableChooser.selectedVariable}];
            [_document.undoManager setActionName:@"Changing Parameter"];
        }
    }
    if (parameter.parameterType == LynDataTypeBoolean) {
        LynFillParameterBooleanTableCellView *booleanCellView = (LynFillParameterBooleanTableCellView*)cellView;
        [booleanCellView.staticBooleanCheckBox setHidden:(parameter.fillType == LynParameterFillTypeDynamicFromVariable||
                                                          parameter.fillType == LynParameterFillTypeDynamicFromParameter)];
        if (parameter.fillType == LynParameterFillTypeStatic) {
            booleanCellView.staticBooleanCheckBox.state = ((NSNumber*)parameter.absoluteValue).boolValue;
            [booleanCellView.variableChooser setHidden:YES];
        }
    }else if (parameter.parameterType == LynDataTypeInteger) {
        LynFillParameterIntegerTableCellView *integerCellView = (LynFillParameterIntegerTableCellView*)cellView;
        [integerCellView.staticIntegerTextField setHidden:(parameter.fillType == LynParameterFillTypeDynamicFromVariable||
                                                           parameter.fillType == LynParameterFillTypeDynamicFromParameter)];
        [integerCellView.staticIntegerStepper setHidden:(parameter.fillType == LynParameterFillTypeDynamicFromVariable||
                                                         parameter.fillType == LynParameterFillTypeDynamicFromParameter)];
        if (parameter.fillType == LynParameterFillTypeStatic) {
            integerCellView.staticIntegerTextField.objectValue = parameter.parameterValue;
            integerCellView.staticIntegerStepper.objectValue = parameter.parameterValue;
            [integerCellView.variableChooser setHidden:YES];
        }
    }else if (parameter.parameterType == LynDataTypeString) {
        LynFillParameterStringTableCellView *stringCellView = (LynFillParameterStringTableCellView*)cellView;
        [stringCellView.staticStringTextField setHidden:(parameter.fillType == LynParameterFillTypeDynamicFromVariable||
                                                         parameter.fillType == LynParameterFillTypeDynamicFromParameter)];
        if (parameter.fillType == LynParameterFillTypeStatic) {
            stringCellView.staticStringTextField.stringValue = (NSString*)parameter.parameterValue;
            [stringCellView.variableChooser setHidden:YES];
        }
    }
    return cellView;
}

- (NSTableRowView*)tableView:(NSTableView *)tableView rowViewForRow:(NSInteger)row{
    if (_command.parameters.count < 1) return [[NSTableRowView alloc] init];
    return [[LynFillParameterTableRowView alloc] init];
}

- (void)tableView:(NSTableView *)tableView didAddRowView:(NSTableRowView *)rowView forRow:(NSInteger)row{
    if (_command.parameters.count < 1) return;
    LynParameter *parameter = _command.parameters[row];
    LynSetting *colorSetting;
    if (parameter.parameterType == LynDataTypeBoolean) {
        colorSetting = [LynGeneral settingForKey:@"variables.boolean.color"];
    }else if (parameter.parameterType == LynDataTypeInteger) {
        colorSetting = [LynGeneral settingForKey:@"variables.integer.color"];
    }else if (parameter.parameterType == LynDataTypeString) {
        colorSetting = [LynGeneral settingForKey:@"variables.string.color"];
    }else {
        return;
    }
    NSArray *value = colorSetting.value;
    NSNumber *red = value[0];
    NSNumber *green = value[1];
    NSNumber *blue = value[2];
    NSColor *color = [NSColor colorWithCalibratedRed:red.unsignedIntegerValue / 255.0
                                               green:green.unsignedIntegerValue / 255.0
                                                blue:blue.unsignedIntegerValue / 255.0
                                               alpha:1];
    rowView.backgroundColor = color;
}

- (void)undoableSetParameterFillType: (NSDictionary*)info{
    LynParameter *parameter = info[@"parameter"];
    LynCommand *command = info[@"command"];
    NSNumber *nFillType = info[@"fillType"];
    NSObject *newValue = info[@"parameterValue"];
    if (!parameter||!nFillType||!command||
        !(nFillType.unsignedIntegerValue == 0||nFillType.unsignedIntegerValue == 1||nFillType.unsignedIntegerValue == 2)) {
        return;
    }
    if (newValue == [NSNull null]) newValue = nil;
    LynParameterFillType fillType = (LynParameterFillType)nFillType.unsignedIntegerValue;
    LynParameterFillType oldFillType = parameter.fillType;
    NSObject *oldValue = parameter.parameterValue;
    [parameter setFillType:fillType];
    if (!parameter.parameterValue&&!newValue&&parameter.fillType != LynParameterFillTypeStatic&&command) {
        LynScope *scope;
        LynFunction *function;
        for (LynOutlineObject *parent in command.parents) {
            if (!scope&&[[parent class] hasScope]) scope = parent.scope;
            if (!function&&[parent isKindOfClass:[LynFunction class]]) function = (LynFunction*)parent;
        }
        NSArray *possibleObjects = [LynVariableChooserView objectsForScope:scope
                                                        includeSuperScopes:YES
                                                                parameters:function.parameters
                                                                  withType:parameter.parameterType];
        if (possibleObjects.count > 0) parameter.parameterValue = possibleObjects[0];
    }else if (newValue) {
        [parameter setParameterValue:(NSObject<NSCoding, NSCopying>*)newValue];
    }
    if (!oldValue) oldValue = [NSNull null];
    [_tableView reloadData];
    [_document.undoManager registerUndoWithTarget:self
                                         selector:@selector(undoableSetParameterFillType:)
                                           object:@{@"parameter" : parameter, @"command" : command, @"fillType": @(oldFillType), @"parameterValue" : oldValue}];
}

- (void)undoableSetParameterValue: (NSDictionary*)info{
    LynParameter *parameter = info[@"parameter"];
    NSObject <NSCoding, NSCopying> *value = info[@"value"];
    if (!parameter||!value) {
        return;
    }
    if (value == [NSNull null]) value = nil;
    NSObject *oldValue = parameter.parameterValue;
    [parameter setParameterValue:value];
    if (!oldValue) oldValue = [NSNull null];
    [_tableView reloadData];
    [_document.undoManager registerUndoWithTarget:self
                                         selector:@selector(undoableSetParameterValue:)
                                           object:@{@"parameter" : parameter, @"value" : oldValue}];
}

- (void)parameterFillTypeChanged:(NSMatrix *)sender{
    NSUInteger row = [_tableView rowForView:sender.superview];
    LynParameter *parameter = _command.parameters[row];
    LynParameterFillType newFillType = (sender.selectedRow == 0) ? LynParameterFillTypeStatic :
                                                                   LynParameterFillTypeDynamicFromVariable;
    [self undoableSetParameterFillType:@{@"parameter" : parameter, @"command" : _command, @"fillType": @(newFillType)}];
    [_document.undoManager setActionName:@"Changing Parameter"];
}

- (void)staticBooleanCheckBoxChanged:(NSButton*)sender{
    NSUInteger row = [_tableView rowForView:sender.superview];
    if (row >= _command.parameters.count) return;
    LynParameterBoolean *parameter = _command.parameters[row];
    if (parameter.fillType == LynParameterFillTypeStatic) {
        if (sender.state == parameter.absoluteBoolValue) {
            return;
        }
    }
    [self undoableSetParameterValue:@{@"parameter" : parameter, @"value" : @(sender.state)}];
    [_document.undoManager setActionName:@"Changing Parameter"];
}

- (void)staticIntegerTextFieldChanged:(NSTextField*)sender{
    NSUInteger row = [_tableView rowForView:sender.superview];
    if (row >= _command.parameters.count) return;
    LynParameterInteger *parameter = _command.parameters[row];
    if (parameter.fillType == LynParameterFillTypeStatic) {
        if (sender.doubleValue == parameter.absoluteNumberValue.doubleValue) {
            return;
        }
    }
    [self undoableSetParameterValue:@{@"parameter" : parameter, @"value" : @(sender.doubleValue)}];
    [_document.undoManager setActionName:@"Changing Parameter"];
}

- (void)staticIntegerStepperChanged:(NSStepper*)sender{
    NSUInteger row = [_tableView rowForView:sender.superview];
    if (row >= _command.parameters.count) return;
    LynParameterInteger *parameter = _command.parameters[row];
    if (parameter.fillType == LynParameterFillTypeStatic) {
        if (sender.doubleValue == parameter.absoluteNumberValue.doubleValue) {
            return;
        }
    }
    [self undoableSetParameterValue:@{@"parameter" : parameter, @"value" : @(sender.doubleValue)}];
    [_document.undoManager setActionName:@"Changing Parameter"];
}

- (void)staticStringTextFieldChanged:(NSTextField *)sender{
    NSUInteger row = [_tableView rowForView:sender.superview];
    if (row >= _command.parameters.count) return;
    LynParameterString *parameter = _command.parameters[row];
    if (parameter.fillType == LynParameterFillTypeStatic) {
        if ([sender.stringValue isEqualToString:parameter.absoluteStringValue]) {
            return;
        }
    }
    [self undoableSetParameterValue:@{@"parameter" : parameter, @"value" : sender.stringValue}];
    [_document.undoManager setActionName:@"Changing Parameter"];
}

- (void)variableChooserChanged:(LynVariableChooserView *)sender{
    NSUInteger row = [_tableView rowForView:sender.superview];
    
    if (row >= _command.parameters.count) return;
    
    LynParameter *parameter = _command.parameters[row];
    
    if (sender.selectedVariable == parameter.parameterValue) return;
    
    [self undoableSetParameterValue:@{@"parameter" : parameter, @"value" : sender.selectedVariable}];
    [_document.undoManager setActionName:@"Changing Parameter"];
}

@end
