//
//  LynDefineParametersViewController.m
//  Lyn
//
//  Created by Programmieren on 07.08.13.
//  Copyright (c) 2013 Arne Philipeit Software. All rights reserved.
//

#define LynParameterPBoardType @"com.AP-Software.Lyn_Framework.LynParameterPBoardType"
#define LynParameterDragType @"com.AP-Software.Lyn_Framework.LynParameterDragType"

#import "LynDefineParametersViewController.h"

@interface LynDefineParametersViewController () <NSTableViewDataSource, NSTableViewDelegate>

@property IBOutlet NSTableView *tableView;
@property IBOutlet NSButton *btnRemove;
@property IBOutlet NSButton *btnReferences;

- (IBAction)addBooleanParameter:(id)sender;
- (IBAction)addIntegerParameter:(id)sender;
- (IBAction)addStringParameter:(id)sender;
- (IBAction)removeParameter:(id)sender;

- (IBAction)parameterNameChanged:(NSTextField*)sender;

@end

@implementation LynDefineParametersViewController{
    LynParameter *lastRenamedParameter;
}

@synthesize function = _function;

- (id)init{
    self = [super initWithNibName:@"LynDefineParametersView"
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
        [_tableView registerForDraggedTypes:@[LynParameterDragType]];
    }
}

- (void)reload{
    [_tableView reloadData];
    if (_tableView.selectedRow == -1||_tableView.numberOfSelectedRows > 1
        ||_tableView.selectedRow >= _function.parameters.count
        ||_function.parameters.count < 1) {
        [_btnRemove setEnabled:NO];
        _btnReferences.title = @"";
    }else{
        NSUInteger row = _tableView.selectedRow;
        LynParameter *parameter = _function.parameters[row];
        [_btnRemove setEnabled:(parameter.referenceCount < 1)];
        _btnReferences.title = [@(parameter.referenceCount).stringValue stringByAppendingString:@" Refs"];
    }
}

- (LynFunction *)function{
    return _function;
}

- (void)setFunction:(LynFunction *)function{
    _function = function;
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter removeObserver:self
                                  name:LynFunctionNumberOfParametersChangedNotification
                                object:nil];
    [notificationCenter addObserver:self
                           selector:@selector(parametersDidChange:)
                               name:LynFunctionNumberOfParametersChangedNotification
                             object:_function];
    [self reload];
}

- (void)parametersDidChange: (NSNotification*)notification{
    [self reload];
}

- (void)colorsChanged: (NSNotification*)notification{
    [self reload];
}

#pragma mark TableView DataSource/Delegate

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    return (_function.parameters.count > 0) ? _function.parameters.count : 1;
}

- (id)tableView:(NSTableView *)tableView
objectValueForTableColumn:(NSTableColumn *)tableColumn
            row:(NSInteger)row{
    return (_function.parameters.count > 0) ? _function.parameters[row] : @0;
}

- (NSView *)tableView:(NSTableView *)tableView
   viewForTableColumn:(NSTableColumn *)tableColumn
                  row:(NSInteger)row{
    if (_function.parameters.count < 1) return [_tableView makeViewWithIdentifier:@"NoParametersCell" owner:self];
    if (row >= _function.parameters.count) return nil;
    LynParameter *parameter = _function.parameters[row];
    LynDefineParameterTableCellView *cellView = [_tableView makeViewWithIdentifier:@"ParameterCell" owner:self];
    if (parameter.parameterType == LynDataTypeBoolean) {
        cellView.textField.stringValue = @"Boolean";
    }else if (parameter.parameterType == LynDataTypeInteger) {
        cellView.textField.stringValue = @"Integer";
    }else if (parameter.parameterType == LynDataTypeString) {
        cellView.textField.stringValue = @"String";
    }
    cellView.nameTextField.stringValue = parameter.name;
    return cellView;
}

- (NSTableRowView*)tableView:(NSTableView *)tableView rowViewForRow:(NSInteger)row{
    if (_function.parameters.count < 1) return [[NSTableRowView alloc] init];
    return [[LynDefineParametersTableRowView alloc] init];
}

- (void)tableView:(NSTableView *)tableView didAddRowView:(NSTableRowView *)rowView forRow:(NSInteger)row{
    if (_function.parameters.count < 1) return;
    LynParameter *parameter = _function.parameters[row];
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

- (BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row{
    return (_function.parameters.count > 0);
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification{
    if (_tableView.selectedRow == -1||_tableView.numberOfSelectedRows > 1
        ||_tableView.selectedRow >= _function.parameters.count
        ||_function.parameters.count < 1) {
        [_btnRemove setEnabled:NO];
        _btnReferences.title = @"";
    }else{
        NSUInteger row = _tableView.selectedRow;
        LynParameter *parameter = _function.parameters[row];
        [_btnRemove setEnabled:(parameter.referenceCount < 1)];
        _btnReferences.title = [@(parameter.referenceCount).stringValue stringByAppendingString:@" Refs"];
    }
}

#pragma mark Undo

- (void)undoableAddParameters: (NSDictionary*)info{
    LynFunction *function = info[@"function"];
    NSArray *parameters = info[@"parameters"];
    NSArray *indexes = info[@"indexes"];
    
    if (!function||!parameters||!indexes||
        parameters.count < 1||(indexes.count != parameters.count&&indexes.count != 1)) {
        return;
    }
    
    for (LynParameter *parameter in parameters) {
        NSNumber *index;
        if (indexes.count == 1) {
            index = indexes[0];
        }else{
            index = indexes[[parameters indexOfObject:parameter]];
        }
        if (index.unsignedIntegerValue > function.parameters.count) {
            index = @(function.parameters.count);
        }
        
        NSString *name = parameter.name;
        while ([function parameterNamed:name]) {
            name = [@"_" stringByAppendingString:name];
        }
        [parameter setName:name];
        
        [function.parameters insertObject:parameter
                                  atIndex:index.unsignedIntegerValue];
    }
    
    [self reload];
    [_document.undoManager registerUndoWithTarget:self
                                         selector:@selector(undoableRemoveParameters:)
                                           object:@{@"function" : function, @"parameters" : parameters}];
}

- (void)undoableRemoveParameters: (NSDictionary*)info{
    LynFunction *function = info[@"function"];
    NSArray *parameters = info[@"parameters"];
    
    if (!function||!parameters||
        parameters.count < 1) {
        return;
    }
    
    NSMutableArray *indexes = [NSMutableArray arrayWithCapacity:parameters.count];
    for (LynParameter *parameter in parameters) {
        NSUInteger index = [function.parameters indexOfObject:parameter];
        if (index == NSNotFound) {
            @throw NSInvalidArgumentException;
        }
        
        [function.parameters removeObject:parameter];
        
        [indexes addObject:@(index)];
    }
    
    [self reload];
    [_document.undoManager registerUndoWithTarget:self
                                         selector:@selector(undoableAddParameters:)
                                           object:@{@"function" : function, @"parameters" : parameters, @"indexes" : indexes}];
}

- (void)undoableSetParameterName: (NSDictionary*)info{
    LynParameter *parameter = info[@"parameter"];
    NSString *name = info[@"name"];
    if (!parameter||!name) {
        return;
    }
    
    NSString *oldName = parameter.name;
    parameter.name = name;
    
    [_tableView reloadData];
    [_document.undoManager registerUndoWithTarget:self
                                         selector:@selector(undoableSetParameterName:)
                                           object:@{@"parameter" : parameter, @"name" : oldName}];
}

#pragma mark Actions

- (void)addBooleanParameter:(id)sender{
    if (!_function) return;
    LynParameterBoolean *parameter = [[LynParameterBoolean alloc] init];
    parameter.name = @"NewBooleanParameter";
    NSInteger index = _tableView.selectedRow;
    if (index == -1) {
        index = _function.parameters.count;
    }else{
        index++;
    }
    [self undoableAddParameters:@{@"function" : _function,
     @"parameters" : @[parameter],
     @"indexes" : @[@(index)]}];
    [_document.undoManager setActionName:@"Adding Boolean Parameter"];
}

- (void)addIntegerParameter:(id)sender{
    if (!_function) return;
    LynParameterInteger *parameter = [[LynParameterInteger alloc] init];
    parameter.name = @"NewIntegerParameter";
    NSInteger index = _tableView.selectedRow;
    if (index == -1) {
        index = _function.parameters.count;
    }else{
        index++;
    }
    [self undoableAddParameters:@{@"function" : _function,
     @"parameters" : @[parameter],
     @"indexes" : @[@(index)]}];
    [_document.undoManager setActionName:@"Adding Integer Parameter"];
}

- (void)addStringParameter:(id)sender{
    if (!_function) return;
    LynParameterString *parameter = [[LynParameterString alloc] init];
    parameter.name = @"NewStringParameter";
    NSInteger index = _tableView.selectedRow;
    if (index == -1) {
        index = _function.parameters.count;
    }else{
        index++;
    }
    [self undoableAddParameters:@{@"function" : _function,
     @"parameters" : @[parameter],
     @"indexes" : @[@(index)]}];
    [_document.undoManager setActionName:@"Adding String Parameter"];
}

- (void)removeParameter:(id)sender{
    if (!_function||_tableView.selectedRow < 0) {
        return;
    }
    NSIndexSet *indexes = _tableView.selectedRowIndexes;
    NSArray *parameters = [_function.parameters objectsAtIndexes:indexes];
    [self undoableRemoveParameters:@{@"function" : _function,
     @"parameters" : parameters}];
    [_tableView deselectAll:sender];
    if (indexes.count > 1) {
        [_document.undoManager setActionName:@"Removing Parameters"];
    }else{
        [_document.undoManager setActionName:@"Removing Parameter"];
    }
}


- (void)parameterNameChanged:(NSTextField *)sender{
    NSUInteger row = [_tableView rowForView:sender.superview];
    if (row >= _function.parameters.count) return;
    LynParameter *parameter = _function.parameters[row];
    NSString *oldName = parameter.name;
    NSString *newName = sender.stringValue;
    
    if ([oldName isEqualToString:newName]) {
        return;
    }
    
    LynParameter *result = [_function parameterNamed:newName];
    NSUInteger alertReason = 0;
    if ([newName isEqualToString:@""]) {
        alertReason = 1;
    }else if ([newName rangeOfString:@" "].location != NSNotFound
              ||[sender.stringValue rangeOfString:@"/"].location != NSNotFound) {
        alertReason = 2;
    }else if (result&&result != parameter) {
        alertReason = 3;
    }
    if (alertReason > 0) {
        lastRenamedParameter = parameter;
        NSAlert *alert = [[NSAlert alloc] init];
        alert.messageText = @"Naming Issue";
        if (alertReason == 1) {
            alert.informativeText = @"An empty name is not allowed.";
        }else if (alertReason == 2) {
            alert.informativeText = @"The characters ' ' and '/' are not allowed.";
        }else if (alertReason == 3) {
            alert.informativeText = @"For clear identification Parameter names may only be used ones in a Function. This name is already in use.";
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
    
    [self undoableSetParameterName:@{@"parameter" : parameter, @"name" : newName}];
    [_document.undoManager setActionName:@"Renaming Parameter"];
}

- (void)namingIssueAlertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo{
    if (returnCode == NSAlertFirstButtonReturn) {
        LynDefineParameterTableCellView *cellView;
        cellView = [_tableView viewAtColumn:0
                                        row:[_function.parameters indexOfObject: lastRenamedParameter]
                            makeIfNecessary:YES];
        [_tableView.window makeFirstResponder:cellView.nameTextField];
    }else if (returnCode == NSAlertSecondButtonReturn) {
        LynDefineParameterTableCellView *cellView;
        cellView = [_tableView viewAtColumn:0
                                        row:[_function.parameters indexOfObject: lastRenamedParameter]
                            makeIfNecessary:YES];
        cellView.nameTextField.stringValue = lastRenamedParameter.name;
    }
}

#pragma mark Drag & Drop

- (BOOL)tableView:(NSTableView *)tableView
writeRowsWithIndexes:(NSIndexSet *)rowIndexes
     toPasteboard:(NSPasteboard *)pboard{
    NSMutableArray *parameters = [NSMutableArray arrayWithArray:[_function.parameters objectsAtIndexes:rowIndexes]];
    for (LynParameter *parameter in parameters) {
        if (parameter.referenceCount > 0) [parameters removeObject:parameter];
    }
    if (parameters.count < 1) return NO;
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:parameters];
    
    [pboard declareTypes:@[LynParameterDragType] owner:self];
    [pboard setData:data forType:LynParameterDragType];
    
    [self performSelector:@selector(removeDraggedParameters:) withObject:parameters afterDelay:.01];
    return YES;
}

- (void)removeDraggedParameters: (NSArray*)parameters{
    [self undoableRemoveParameters:@{@"function" : _function,
     @"parameters" : parameters}];
    [_document.undoManager setActionName:@"Dragging Parameters"];
}

- (NSDragOperation)tableView:(NSTableView *)tableView
                validateDrop:(id<NSDraggingInfo>)info
                 proposedRow:(NSInteger)row
       proposedDropOperation:(NSTableViewDropOperation)dropOperation{
    return (dropOperation == NSTableViewDropAbove||_function.parameters.count < 1) ? NSDragOperationMove : NSDragOperationNone;
}

- (BOOL)tableView:(NSTableView *)tableView
       acceptDrop:(id<NSDraggingInfo>)info
              row:(NSInteger)row
    dropOperation:(NSTableViewDropOperation)dropOperation{
    NSPasteboard *pboard = [info draggingPasteboard];
    NSData *data = [pboard dataForType:LynParameterDragType];
    NSArray *parameters = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    if (_function&&_function.parameters.count < 1) {
        row = 0;
    }
    [self undoableAddParameters:@{@"function" : _function,
     @"parameters" : parameters,
     @"indexes" : @[@(row)]}];
    [_document.undoManager setActionName:@"Dropping Parameters"];
    return YES;
}

#pragma mark Menu Items

- (void)cut: (id)sender{
    if (!_function||_tableView.selectedRow < 0) {
        return;
    }
    NSIndexSet *indexes = _tableView.selectedRowIndexes;
    NSMutableArray *parameters = [NSMutableArray arrayWithArray:[_function.parameters objectsAtIndexes:indexes]];
    for (LynParameter *parameter in parameters) {
        if (parameter.referenceCount > 0) [parameters removeObject:parameter];
    }
    if (parameters.count < 1) return;
    
    [self undoableRemoveParameters:@{@"function" : _function,
     @"parameters" : parameters}];
    
    [_tableView deselectAll:sender];
    [_document.undoManager setActionName:@"Cut"];
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:parameters];
    NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
    [pasteboard declareTypes:@[LynParameterPBoardType] owner:self];
    [pasteboard setData:data forType:LynParameterPBoardType];
}

- (void)copy: (id)sender{
    if (!_function||_tableView.selectedRow < 0) {
        return;
    }
    NSIndexSet *indexes = _tableView.selectedRowIndexes;
    NSArray *parameters = [_function.parameters objectsAtIndexes:indexes];
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:parameters];
    NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
    [pasteboard declareTypes:@[LynParameterPBoardType] owner:self];
    [pasteboard setData:data forType:LynParameterPBoardType];
}

- (void)paste: (id)sender{
    NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
    NSData *data = [pasteboard dataForType:LynParameterPBoardType];
    if (!data) return;
    NSArray *parameters = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    NSInteger index = _tableView.selectedRow;
    if (index == -1) {
        index = _function.parameters.count;
    }else{
        index++;
    }
    [self undoableAddParameters:@{@"function" : _function,
                                  @"parameters" : parameters,
                                  @"indexes" : @[@(index)]}];
    [_document.undoManager setActionName:@"Paste"];
}

- (void)duplicate: (id)sender{
    if (!_function||_tableView.selectedRow < 0) {
        return;
    }
    NSIndexSet *indexes = _tableView.selectedRowIndexes;
    NSMutableArray *parameters = [NSMutableArray arrayWithArray:[_function.parameters objectsAtIndexes:indexes]];
    for (LynParameter *parameter in parameters) {
        NSUInteger index = [parameters indexOfObject:parameter];
        parameters[index] = parameter.copy;
    }
    if (!parameters) return;
    NSInteger index = _tableView.selectedRow + 1;
    [self undoableAddParameters:@{@"function" : _function,
                                  @"parameters" : parameters,
                                  @"indexes" : @[@(index)]}];
    [_document.undoManager setActionName:@"Duplicate"];
}

- (void)delete: (id)sender{
    if (!_function||_tableView.selectedRow < 0) {
        return;
    }
    NSIndexSet *indexes = _tableView.selectedRowIndexes;
    NSMutableArray *parameters = [NSMutableArray arrayWithArray:[_function.parameters objectsAtIndexes:indexes]];
    for (LynParameter *parameter in parameters) {
        if (parameter.referenceCount > 0) [parameters removeObject:parameter];
    }
    if (parameters.count < 1) return;
    [self undoableRemoveParameters:@{@"function" : _function,
     @"parameters" : parameters}];
    
    [_tableView deselectAll:sender];
    
    if (indexes.count > 1) {
        [_document.undoManager setActionName:@"Deleting Variables"];
    }else{
        [_document.undoManager setActionName:@"Deleting Variable"];
    }
}

- (void)invertSelection: (id)sender{
    if (!_function||_function.parameters.count < 1||_tableView.selectedRow < 0) {
        return;
    }
    NSMutableIndexSet *indexes = [NSMutableIndexSet indexSetWithIndexesInRange:NSMakeRange(0, _tableView.numberOfRows)];
    [indexes removeIndexes:_tableView.selectedRowIndexes];
    [_tableView selectRowIndexes:indexes byExtendingSelection:NO];
}

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem{
    NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
    BOOL hasSelection = (_tableView.selectedRow > -1&&_function&&_function.parameters.count > 0);
    if (menuItem.action == @selector(cut:)&&hasSelection) {
        return YES;
    }else if (menuItem.action == @selector(copy:)&&hasSelection) {
        return YES;
    }else if (menuItem.action == @selector(paste:)&&[pasteboard dataForType:LynParameterPBoardType]) {
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
