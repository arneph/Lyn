//
//  LynDefineScopeViewController.m
//  Lyn
//
//  Created by Programmieren on 05.07.13.
//  Copyright (c) 2013 Arne Philipeit Software. All rights reserved.
//

#define LynVariablePBoardType @"com.AP-Software.Lyn_Framework.LynVariablePBoardType"
#define LynVariableDragType @"com.AP-Software.Lyn_Framework.LynVariableDragType"

#import "LynDefineScopeViewController.h"

@interface LynDefineScopeViewController () <NSTableViewDataSource, NSTableViewDelegate>

@property IBOutlet NSTableView *tableView;
@property IBOutlet NSButton *btnRemove;
@property IBOutlet NSButton *btnReferences;
@property IBOutlet NSButton *btnShowSuperScope;

- (IBAction)pushedAddBooleanVariable:(id)sender;
- (IBAction)pushedAddIntegerVariable:(id)sender;
- (IBAction)pushedAddStringVariable:(id)sender;
- (IBAction)pushedRemoveVariable:(id)sender;

- (IBAction)pushedShowSuperScope:(id)sender;

- (IBAction)variableNameChanged:(id)sender;

- (IBAction)booleanVariableDefaultValueChanged:(id)sender;
- (IBAction)integerVariableDefaultValueChangedByField:(id)sender;
- (IBAction)integerVariableDefaultValueChangedByStepper:(id)sender;
- (IBAction)stringVariableDefaultValueChanged:(id)sender;

@end

@implementation LynDefineScopeViewController{
    LynVariable *lastRenamedVariable;
}

@synthesize scope = _scope;

- (id)init {
    self = [super initWithNibName:@"LynDefineScopeView"
                           bundle:[NSBundle bundleForClass:self.class]];
    if (self) {
        [NotificationCenter addObserver:self
                               selector:@selector(colorsChanged:)
                                   name:LynSettingChangedNotification
                                 object:nil];
    }
    return self;
}

- (void)awakeFromNib{
    if (_tableView&&_tableView.nextResponder != self) {
        self.nextResponder = _tableView.nextResponder;
        _tableView.nextResponder = self;
        [_tableView registerForDraggedTypes:@[LynVariableDragType]];
    }
}

- (void)reload{
    [_tableView reloadData];
    if (_tableView.selectedRow == -1||_tableView.numberOfSelectedRows > 1
        ||_tableView.selectedRow >= _scope.variables.count
        ||_scope.variables.count < 1) {
        [_btnRemove setEnabled:NO];
        _btnReferences.title = @"";
    }else{
        NSUInteger row = _tableView.selectedRow;
        LynVariable *variable = _scope.variables[row];
        [_btnRemove setEnabled:(variable.referenceCount < 1)];
        _btnReferences.title = [@(variable.referenceCount).stringValue stringByAppendingString:@" Ref's"];
    }
    [_btnShowSuperScope setEnabled:(_scope&&_scope.superScope)];
}

- (LynScope *)scope{
    return _scope;
}

- (void)setScope:(LynScope *)scope{
    _scope = scope;
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter removeObserver:self
                             name:LynScopeNumberOfVariablesChangedNotification
                           object:nil];
    [defaultCenter removeObserver:self
                             name:LynScopeVariableNameChangedNotification
                           object:nil];
    [defaultCenter addObserver:self
                      selector:@selector(variablesDidChange:)
                          name:LynScopeNumberOfVariablesChangedNotification
                        object:_scope];
    [defaultCenter addObserver:self
                      selector:@selector(variablesDidChange:)
                          name:LynScopeVariableNameChangedNotification
                        object:_scope];
    [self reload];
}

- (void)variablesDidChange: (NSNotification*)notification{
    [self reload];
}

- (void)colorsChanged: (NSNotification*)notification{
    [self reload];
}

#pragma mark TableView DataSource/Delegate

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    return (_scope.variables.count > 0) ? _scope.variables.count : 1;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    if (_scope.variables.count > 0) {
        return _scope.variables[row];
    }else{
        return @0;
    }
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    if (_scope.variables.count > 0) {
        LynVariable *variable = _scope.variables[row];
        if ([variable isKindOfClass:[LynVariableBoolean class]]) {
            LynDefineVariableBooleanTableCellView *cellView = [_tableView makeViewWithIdentifier:@"DefineVariableBooleanCell" owner:self];
            cellView.textField.stringValue = variable.name;
            cellView.valueCheckbox.state = ((NSNumber*)variable.value).boolValue;
            return cellView;
        }else if ([variable isKindOfClass:[LynVariableInteger class]]) {
            LynDefineVariableIntegerTableCellView *cellView = [_tableView makeViewWithIdentifier:@"DefineVariableIntegerCell" owner:self];
            cellView.textField.stringValue = variable.name;
            cellView.valueField.doubleValue = ((NSNumber*)variable.value).doubleValue;
            cellView.valueStepper.doubleValue = ((NSNumber*)variable.value).doubleValue;
            return cellView;
        }else if ([variable isKindOfClass:[LynVariableString class]]) {
            LynDefineVariableStringTableCellView *cellView = [_tableView makeViewWithIdentifier:@"DefineVariableStringCell" owner:self];
            cellView.textField.stringValue = variable.name;
            cellView.valueField.stringValue = (NSString*)variable.value;
            return cellView;
        }else {
            return nil;
        }
    }else{
        NSTableCellView *cellView = [_tableView makeViewWithIdentifier:@"NoVariablesCell" owner:self];
        return cellView;
    }
}

- (NSTableRowView *)tableView:(NSTableView *)tableView rowViewForRow:(NSInteger)row{
    if (_scope.variables.count < 1) return [[NSTableRowView alloc] init];
    return [[LynDefineVariablesRowView alloc] init];
}

- (void)tableView:(NSTableView *)tableView didAddRowView:(NSTableRowView *)rowView forRow:(NSInteger)row{
    if (_scope.variables.count < 1) return;
    LynVariable *variable = _scope.variables[row];
    LynSetting *colorSetting;
    if ([variable isKindOfClass:[LynVariableBoolean class]]) {
        colorSetting = [LynGeneral settingForKey:@"variables.boolean.color"];
    }else if ([variable isKindOfClass:[LynVariableInteger class]]) {
        colorSetting = [LynGeneral settingForKey:@"variables.integer.color"];
    }else if ([variable isKindOfClass:[LynVariableString class]]) {
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

- (BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row{
    return (_scope.variables.count > 0);
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification{
    if (_tableView.selectedRow == -1||_tableView.numberOfSelectedRows > 1
        ||_tableView.selectedRow >= _scope.variables.count
        ||_scope.variables.count < 1) {
        [_btnRemove setEnabled:NO];
        _btnReferences.title = @"";
    }else{
        NSUInteger row = _tableView.selectedRow;
        LynVariable *variable = _scope.variables[row];
        [_btnRemove setEnabled:(variable.referenceCount < 1)];
        _btnReferences.title = [@(variable.referenceCount).stringValue stringByAppendingString:@" Refs"];
    }
}

#pragma mark Undo/Redo

- (void)undoableAddVariables: (NSDictionary*)info{
    LynScope *scope = info[@"scope"];
    NSArray *variables = info[@"variables"];
    NSArray *indexes = info[@"indexes"];
    
    if (!scope||!variables||!indexes||
        variables.count < 1||(indexes.count != variables.count&&indexes.count != 1)) {
        return;
    }
    
    for (LynVariable *variable in variables) {
        NSNumber *index;
        if (indexes.count == 1) {
            index = indexes[0];
        }else{
            index = indexes[[variables indexOfObject:variable]];
        }
        if (index.unsignedIntegerValue > scope.variables.count) {
            index = @(scope.variables.count);
        }
        
        NSString *name = variable.name;
        while ([scope hasVariableNamed:name inSuperScopes:YES]) {
            name = [@"_" stringByAppendingString:name];
        }
        [variable setName:name];
        
        [scope.variables insertObject:variable atIndex:index.unsignedIntegerValue];
    }
    
    [self reload];
    [_document.undoManager registerUndoWithTarget:self
                                         selector:@selector(undoableRemoveVariables:)
                                           object:@{@"scope" : scope, @"variables" : variables}];
}

- (void)undoableRemoveVariables: (NSDictionary*)info{
    LynScope *scope = info[@"scope"];
    NSArray *variables = info[@"variables"];
    
    if (!scope||!variables||
        variables.count < 1) {
        return;
    }
    
    NSMutableArray *indexes = [NSMutableArray arrayWithCapacity:variables.count];
    for (LynVariable *variable in variables) {
        NSUInteger index = [scope.variables indexOfObject:variable];
        if (index == NSNotFound) {
            @throw NSInvalidArgumentException;
        }
        
        [scope.variables removeObject:variable];
        
        [indexes addObject:@(index)];
    }
        
    [self reload];
    [_document.undoManager registerUndoWithTarget:self
                                         selector:@selector(undoableAddVariables:)
                                           object:@{@"scope" : scope, @"variables" : variables, @"indexes" : indexes}];
}

- (void)undoableSetVariableName: (NSDictionary*)info{
    LynVariable *variable = info[@"variable"];
    NSString *name = info[@"name"];
    if (!variable||!name) {
        return;
    }
    
    NSString *oldName = variable.name;
    variable.name = name;
    
    [_tableView reloadData];
    [_document.undoManager registerUndoWithTarget:self
                                         selector:@selector(undoableSetVariableName:)
                                           object:@{@"variable" : variable, @"name" : oldName}];
}

- (void)undoableSetVariableValue: (NSDictionary*)info{
    LynVariable *variable = info[@"variable"];
    id value = info[@"value"];
    if (!variable||!value) {
        return;
    }
    
    id oldValue = variable.value;
    variable.value = value;
    
    [_tableView reloadData];
    [_document.undoManager registerUndoWithTarget:self
                                         selector:@selector(undoableSetVariableValue:)
                                           object:@{@"variable" : variable, @"value" : oldValue}];
}

#pragma mark Actions

- (void)pushedAddBooleanVariable:(id)sender{
    if (!_scope) {
        return;
    }
    LynVariableBoolean *variable = [[LynVariableBoolean alloc] init];
    variable.name = @"NewVariable";
    NSInteger index = _tableView.selectedRow;
    if (index == -1) {
        index = _scope.variables.count;
    }else{
        index++;
    }
    [self undoableAddVariables:@{@"scope" : _scope,
                                 @"variables" : @[variable],
                                 @"indexes" : @[@(index)]}];
    [_document.undoManager setActionName:@"Adding Boolean Variable"];
}

- (void)pushedAddIntegerVariable:(id)sender{
    if (!_scope) {
        return;
    }
    LynVariableInteger *variable = [[LynVariableInteger alloc] init];
    variable.name = @"NewVariable";
    NSInteger index = _tableView.selectedRow;
    if (index == -1) {
        index = _scope.variables.count;
    }else{
        index++;
    }
    [self undoableAddVariables:@{@"scope" : _scope,
     @"variables" : @[variable],
     @"indexes" : @[@(index)]}];
    [_document.undoManager setActionName:@"Adding Integer Variable"];
}

- (void)pushedAddStringVariable:(id)sender{
    if (!_scope) {
        return;
    }
    LynVariableString *variable = [[LynVariableString alloc] init];
    variable.name = @"NewVariable";
    NSInteger index = _tableView.selectedRow;
    if (index == -1) {
        index = _scope.variables.count;
    }else{
        index++;
    }
    [self undoableAddVariables:@{@"scope" : _scope,
                                 @"variables" : @[variable],
                                 @"indexes" : @[@(index)]}];
    [_document.undoManager setActionName:@"Adding String Variable"];
}

- (void)pushedRemoveVariable:(id)sender{
    if (!_scope||_tableView.selectedRow < 0) {
        return;
    }
    NSIndexSet *indexes = _tableView.selectedRowIndexes;
    NSArray *variables = [_scope.variables objectsAtIndexes:indexes];
    [self undoableRemoveVariables:@{@"scope" : _scope,
                                    @"variables" : variables}];
    [_tableView deselectAll:sender];
    if (indexes.count > 1) {
        [_document.undoManager setActionName:@"Removing Variables"];
    }else{
        [_document.undoManager setActionName:@"Removing Variable"];
    }
}

- (void)pushedShowSuperScope:(id)sender{
    if (!_scope.superScope) return;
    [_delegate selectObject:_scope.superScope.scopeOwner];
}

- (void)variableNameChanged:(NSTextField*)sender{
    NSUInteger row = [_tableView rowForView:sender.superview];
    if (row == NSNotFound||row >= _scope.variables.count) return;
    LynVariable *variable = _scope.variables[row];
    NSString *newName = sender.stringValue;
    if ([variable.name isEqualToString:newName]) return;
    
    LynVariable *result = [_scope variableNamed:newName inSuperScopes:YES];
    NSUInteger alertReason = 0;
    if ([newName isEqualToString:@""]) {
        alertReason = 1;
    }else if ([newName rangeOfString:@" "].location != NSNotFound
              ||[sender.stringValue rangeOfString:@"/"].location != NSNotFound) {
        alertReason = 2;
    }else if (result&&result != variable) {
        alertReason = 3;
    }
    if (alertReason > 0) {
        lastRenamedVariable = variable;
        NSAlert *alert = [[NSAlert alloc] init];
        alert.messageText = @"Naming Issue";
        if (alertReason == 1) {
            alert.informativeText = @"An empty name is not allowed.";
        }else if (alertReason == 2) {
            alert.informativeText = @"The characters ' ' and '/' are not allowed.";
        }else if (alertReason == 3) {
            alert.informativeText = @"For clear identification Variable names may only be used ones in a Scope. This name is already in use.";
        }
        [alert setAlertStyle:NSWarningAlertStyle];
        [alert addButtonWithTitle:@"Rename"];
        [alert addButtonWithTitle:@"Abort"];
        [alert beginSheetModalForWindow:_tableView.window
                          modalDelegate:self
                         didEndSelector:@selector(namingIssueAlertDidEnd:returnCode:contextInfo:)
                            contextInfo:NULL];
        return;
    }
    
    [self undoableSetVariableName:@{@"variable" : variable, @"name" : newName}];
    [_document.undoManager setActionName:@"Renaming Variable"];
}

- (void)namingIssueAlertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo{
    if (returnCode == NSAlertFirstButtonReturn) {
        NSTableCellView *cellView = [_tableView viewAtColumn:0
                                                         row:[_scope.variables indexOfObject: lastRenamedVariable]
                                             makeIfNecessary:YES];
        [_tableView.window makeFirstResponder:cellView.textField];
    }else if (returnCode == NSAlertSecondButtonReturn) {
        NSTableCellView *cellView = [_tableView viewAtColumn:0
                                                         row:[_scope.variables indexOfObject: lastRenamedVariable]
                                             makeIfNecessary:YES];
        cellView.textField.stringValue = lastRenamedVariable.name;
    }
}

- (void)booleanVariableDefaultValueChanged:(NSButton*)sender{
    NSUInteger row = [_tableView rowForView:sender.superview];
    if (row == NSNotFound||row >= _scope.variables.count) return;
    LynVariable *variable = _scope.variables[row];
    
    [self undoableSetVariableValue:@{@"variable" : variable, @"value" : @(sender.state)}];
    [_document.undoManager setActionName:@"Changing Initial Value"];
}

- (void)integerVariableDefaultValueChangedByField:(NSTextField*)sender{
    NSUInteger row = [_tableView rowForView:sender.superview];
    if (row == NSNotFound||row >= _scope.variables.count) return;
    LynVariable *variable = _scope.variables[row];
    
    [self undoableSetVariableValue:@{@"variable" : variable, @"value" : @(sender.doubleValue)}];
    [_document.undoManager setActionName:@"Changing Initial Value"];
}

- (void)integerVariableDefaultValueChangedByStepper:(NSStepper*)sender{
    NSUInteger row = [_tableView rowForView:sender.superview];
    if (row == NSNotFound||row >= _scope.variables.count) return;
    LynVariable *variable = _scope.variables[row];
    
    [self undoableSetVariableValue:@{@"variable" : variable, @"value" : @(sender.doubleValue)}];
    [_document.undoManager setActionName:@"Changing Initial Value"];
}

- (void)stringVariableDefaultValueChanged:(NSTextField*)sender{
    NSUInteger row = [_tableView rowForView:sender.superview];
    if (row == NSNotFound||row >= _scope.variables.count) return;
    LynVariable *variable = _scope.variables[row];
    if ([(NSString*)variable.value isEqualToString:sender.stringValue]) return;
    
    [self undoableSetVariableValue:@{@"variable" : variable, @"value" : sender.stringValue}];
    [_document.undoManager setActionName:@"Changing Initial Value"];
}

#pragma mark Drag & Drop

- (BOOL)tableView:(NSTableView *)tableView
writeRowsWithIndexes:(NSIndexSet *)rowIndexes
     toPasteboard:(NSPasteboard *)pboard{
    NSMutableArray *variables = [NSMutableArray arrayWithArray:[_scope.variables objectsAtIndexes:rowIndexes]];
    for (LynVariable *variable in variables) {
        if (variable.referenceCount > 0) [variables removeObject:variable];
    }
    if (variables.count < 1) return NO;
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:variables];
    
    [pboard declareTypes:@[LynVariableDragType] owner:self];
    [pboard setData:data forType:LynVariableDragType];
    
    [self performSelector:@selector(removeDraggedVariables:) withObject:variables afterDelay:.01];
    return YES;
}

- (void)removeDraggedVariables: (NSArray*)variables{
    [self undoableRemoveVariables:@{@"scope" : _scope,
                                    @"variables" : variables}];
    [_document.undoManager setActionName:@"Dragging Variables"];
}

- (NSDragOperation)tableView:(NSTableView *)tableView
                validateDrop:(id<NSDraggingInfo>)info
                 proposedRow:(NSInteger)row
       proposedDropOperation:(NSTableViewDropOperation)dropOperation{
    if (_scope&&_scope.variables.count < 1) {
        return NSDragOperationMove;
    }else{
        return (dropOperation == NSTableViewDropAbove) ? NSDragOperationMove : NSDragOperationNone;
    }
}

- (BOOL)tableView:(NSTableView *)tableView
       acceptDrop:(id<NSDraggingInfo>)info
              row:(NSInteger)row
    dropOperation:(NSTableViewDropOperation)dropOperation{
    NSPasteboard *pboard = [info draggingPasteboard];
    NSData *data = [pboard dataForType:LynVariableDragType];
    NSArray *variables = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    if (_scope&&_scope.variables.count < 1) {
        row = 0;
    }
    [self undoableAddVariables:@{@"scope" : _scope,
                                 @"variables" : variables,
                                 @"indexes" : @[@(row)]}];
    [_document.undoManager setActionName:@"Dropping Variables"];
    return YES;
}

#pragma mark Menu Items

- (void)cut: (id)sender{
    if (!_scope||_tableView.selectedRow < 0) {
        return;
    }
    NSIndexSet *indexes = _tableView.selectedRowIndexes;
    NSMutableArray *variables = [NSMutableArray arrayWithArray:[_scope.variables objectsAtIndexes:indexes]];
    for (LynVariable *variable in variables) {
        if (variable.referenceCount > 0) [variables removeObject:variable];
    }
    if (variables.count < 1) return;
    
    [self undoableRemoveVariables:@{@"scope" : _scope,
                                    @"variables" : variables}];
    
    [_tableView deselectAll:sender];
    [_document.undoManager setActionName:@"Cut"];
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:variables];
    NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
    [pasteboard declareTypes:@[LynVariablePBoardType] owner:self];
    [pasteboard setData:data forType:LynVariablePBoardType];
}

- (void)copy: (id)sender{
    if (!_scope||_tableView.selectedRow < 0) {
        return;
    }
    NSIndexSet *indexes = _tableView.selectedRowIndexes;
    NSArray *variables = [_scope.variables objectsAtIndexes:indexes];
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:variables];
    NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
    [pasteboard declareTypes:@[LynVariablePBoardType] owner:self];
    [pasteboard setData:data forType:LynVariablePBoardType];
}

- (void)paste: (id)sender{
    NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
    NSData *data = [pasteboard dataForType:LynVariablePBoardType];
    if (!data) return;
    NSArray *variables = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    NSInteger index = _tableView.selectedRow;
    if (index == -1) {
        index = _scope.variables.count;
    }else{
        index++;
    }
    [self undoableAddVariables:@{@"scope" : _scope,
                                 @"variables" : variables,
                                 @"indexes" : @[@(index)]}];
    [_document.undoManager setActionName:@"Paste"];
}

//TODO: Duplicate

- (void)delete: (id)sender{
    if (!_scope||_tableView.selectedRow < 0) {
        return;
    }
    NSIndexSet *indexes = _tableView.selectedRowIndexes;
    NSMutableArray *variables = [NSMutableArray arrayWithArray:[_scope.variables objectsAtIndexes:indexes]];
    for (LynVariable *variable in variables) {
        if (variable.referenceCount > 0) [variables removeObject:variable];
    }
    if (variables.count < 1) return;
    [self undoableRemoveVariables:@{@"scope" : _scope,
                                    @"variables" : variables}];
    [_tableView deselectAll:sender];
    if (indexes.count > 1) {
        [_document.undoManager setActionName:@"Deleting Variables"];
    }else{
        [_document.undoManager setActionName:@"Deleting Variable"];
    }
}

- (void)invertSelection: (id)sender{
    if (!_scope||_scope.variables.count < 1||_tableView.selectedRow < 0) {
        return;
    }
    NSMutableIndexSet *indexes = [NSMutableIndexSet indexSetWithIndexesInRange:NSMakeRange(0, _tableView.numberOfRows)];
    [indexes removeIndexes:_tableView.selectedRowIndexes];
    [_tableView selectRowIndexes:indexes byExtendingSelection:NO];
}

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem{
    NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
    BOOL hasSelection = (_tableView.selectedRow > -1&&_scope&&_scope.variables.count > 0);
    if (menuItem.action == @selector(cut:)&&hasSelection) {
        return YES;
    }else if (menuItem.action == @selector(copy:)&&hasSelection) {
        return YES;
    }else if (menuItem.action == @selector(paste:)&&[pasteboard dataForType:LynVariablePBoardType]) {
        return YES;
    }else if (menuItem.action == @selector(duplicate:)&&hasSelection) {
        return YES;
    }else if (menuItem.action == @selector(delete:)&&hasSelection) {
        return YES;
    }else if (menuItem.action == @selector(invertSelection:)&&hasSelection) {
        return YES;
    }else{
        return NO;
    }
}

@end
