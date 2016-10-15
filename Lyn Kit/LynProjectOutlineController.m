//
//  LynProjectOutlineController.m
//  Lyn
//
//  Created by Programmieren on 28.06.13.
//  Copyright (c) 2013 Arne Philipeit Software. All rights reserved.
//

#import "LynProjectOutlineController.h"

@implementation LynProjectOutlineController{
    LynProjectOutlineObject *lastRenamedObject;
}
@synthesize project = _project;

- (id)init{
    self = [super init];
    if (self) {
        self.lowestHierarchyClass = [LynClass class];
    }
    return self;
}

- (void)awakeFromNib{
    [super awakeFromNib];
    [self.outlineView performSelector:@selector(expandItem:)
                           withObject:_project
                           afterDelay:.01];
    [self selectObject:_project];
    [self selectedObject:nil];
}

- (NSString *)dragType{
    return @"de.AP-Software.Lyn.LynProjectOutlineItemsDragype";
}

- (NSString *)pasteboardType{
    return @"de.AP-Software.Lyn.LynProjectOutlineItemsPasteboardType";
}

- (LynProject *)project{
    return _project;
}

- (void)setProject:(LynProject *)project{
    _project = project;
    self.rootObject = project;
    [self observeAllSubObjectsInProject];
}

#pragma mark Notifications

- (void)observeAllSubObjectsInProject{
    [NotificationCenter removeObserver:self
                                  name:LynOutlineObjectNumberOfSubObjectsChangedNotification
                                object:nil];
    [NotificationCenter removeObserver:self
                                  name:LynOutlineObjectWillAddSubObjectNotification
                                object:nil];
    [NotificationCenter addObserver:self
                           selector:@selector(numberOfSubObjectsChanged:)
                               name:LynOutlineObjectNumberOfSubObjectsChangedNotification
                             object:_project];
    [NotificationCenter addObserver:self
                           selector:@selector(willAddSubObject:)
                               name:LynOutlineObjectWillAddSubObjectNotification
                             object:_project];
    [self observeAllSubObjectsInFolder: _project];
}

- (void)observeAllSubObjectsInFolder: (LynFolder*)folder{
    for (LynProjectOutlineObject *subObject in folder.subObjects) {
        if ([subObject isKindOfClass:[LynFolder class]]) {
            [NotificationCenter addObserver:self
                                   selector:@selector(numberOfSubObjectsChanged:)
                                       name:LynOutlineObjectNumberOfSubObjectsChangedNotification
                                     object:subObject];
            [NotificationCenter addObserver:self
                                   selector:@selector(willAddSubObject:)
                                       name:LynOutlineObjectWillAddSubObjectNotification
                                     object:subObject];
            [self observeAllSubObjectsInFolder:(LynFolder*)subObject];
        }
    }
}

- (void)numberOfSubObjectsChanged: (NSNotification*)notification{
    [self.outlineView reloadData];
    if (self.outlineView.selectedRow > 0) {
        LynProjectOutlineObject *object = [self.outlineView itemAtRow:self.outlineView.selectedRow];
        if (![object isMemberOfClass:[LynFolder class]]) {
            _editorView.shownObject = object;
        }
    }
    if ([_inspectorView.object isKindOfClass:[LynClass class]]) {
        if (self.outlineView.selectedRow < 0) {
            [_inspectorView setNoObject];
        }
    }
    [self observeAllSubObjectsInProject];
}

- (void)willAddSubObject: (NSNotification*)notification{
    LynOutlineObject *subObject = notification.userInfo[@"subObject"];
    if (![subObject isKindOfClass:[LynClass class]]) {
        return;
    }
    LynClass *class = (LynClass*)subObject;
    NSString *name = class.name;
    NSUInteger i = 1;
    while ([_project hasClassNamed:name]) {
        i++;
        name = [NSString stringWithFormat:@"%@ %i", class.name, (int)i];
    }
    class.name = name;
}

#pragma mark OutlineViewDelegate

- (void)outlineViewSelectionDidChange:(NSNotification *)notification{
    if (self.outlineView.numberOfSelectedRows > 0) {
        LynProjectOutlineObject *object = [self.outlineView itemAtRow:self.outlineView.selectedRow];
        if (![object isMemberOfClass:[LynFolder class]]) {
            _editorView.shownObject = object;
        }
    }
    if ([_inspectorView.object isKindOfClass:[LynClass class]]&&self.outlineView.selectedRow < 0) {
        [_inspectorView setNoObject];
    }
    [self.document invalidateRestorableState];
}

- (NSView *)outlineView:(NSOutlineView *)outlineView viewForTableColumn:(NSTableColumn *)tableColumn item:(id)item{
    LynProjectOutlineObject *object = (LynProjectOutlineObject*)item;
    Class objectClass = [item class];
    if (objectClass == [LynProject class]) {
        return [self.outlineView makeViewWithIdentifier:@"ProjectCell" owner:self];
    }else if (objectClass == [LynFolder class]) {
        NSTableCellView *cellView = [self.outlineView makeViewWithIdentifier:@"FolderCell" owner:self];
        cellView.textField.stringValue = object.name;
        return cellView;
    }else if (objectClass == [LynClass class]) {
        NSTableCellView *cellView = [self.outlineView makeViewWithIdentifier:@"ClassCell" owner:self];
        cellView.textField.stringValue = object.name;
        return cellView;
    }else{
        return nil;
    }
}

- (CGFloat)outlineView:(NSOutlineView *)outlineView heightOfRowByItem:(id)item{
    return ([item isKindOfClass:[LynProject class]]) ? 32 : 17;
}

#pragma mark Public Methods

- (void)selectObject:(LynOutlineObject *)object{
    if ([object isKindOfClass:[LynProjectOutlineObject class]]) {
        [super selectObject:object];
        if ([object isKindOfClass:[LynClass class]]) {
            [_inspectorView setObject:object];
        }
    }else{
        LynOutlineObject *parent = object;
        while (![parent isKindOfClass:[LynProjectOutlineObject class]]) {
            if (parent.parent == nil) {
                return;
            }
            parent = parent.parent;
        }
        [super selectObject:parent];
        [_editorView setShownObject:(LynClass*)parent];
        [_editorView selectObject:object];
    }
}

- (void)selectedObject:(id)sender{
    if (self.outlineView.numberOfSelectedRows < 1) {
        return;
    }
    LynProjectOutlineObject *object;
    object = [self.outlineView itemAtRow:self.outlineView.selectedRowIndexes.lastIndex];
    if ([object isKindOfClass:[LynClass class]]) {
        [_inspectorView setObject:object];
    }else if ([object isKindOfClass:[LynProject class]]) {
        [_inspectorView setNoObject];
    }
}

#pragma mark Actions

- (void)nameChanged:(NSTextField*)sender{
    LynProjectOutlineObject *object = [self.outlineView itemAtRow:[self.outlineView rowForView:sender.superview]];
    if ([sender.stringValue isEqualToString:@""]) {
        lastRenamedObject = object;
        NSAlert *alert = [[NSAlert alloc] init];
        alert.messageText = @"Naming Issue";
        alert.informativeText = @"An empty name is not allowed.";
        [alert setAlertStyle:NSWarningAlertStyle];
        [alert addButtonWithTitle:@"Rename"];
        [alert addButtonWithTitle:@"Abort"];
        [alert beginSheetModalForWindow:self.outlineView.window
                          modalDelegate:self
                         didEndSelector:@selector(emptyNameNamingIssueAlertDidEnd:returnCode:contextInfo:)
                            contextInfo:NULL];
        return;
    }else if ([sender.stringValue rangeOfString:@" "].location != NSNotFound||[sender.stringValue rangeOfString:@"/"].location != NSNotFound){
        lastRenamedObject = object;
        NSAlert *alert = [[NSAlert alloc] init];
        alert.messageText = @"Naming Issue";
        alert.informativeText = @"The characters ' ' and '/' are not allowed.";
        [alert setAlertStyle:NSWarningAlertStyle];
        [alert addButtonWithTitle:@"Rename"];
        [alert addButtonWithTitle:@"Abort"];
        [alert beginSheetModalForWindow:self.outlineView.window
                          modalDelegate:self
                         didEndSelector:@selector(invalidCharactersNamingIssueDidEnd:returnCode:contextInfo:)
                            contextInfo:NULL];
        return;
    }
    if ([object isKindOfClass:[LynFolder class]]) {
        [self renameSubObject:object newName:sender.stringValue];
        return;
    }
    LynClass *result = [_project classNamed:sender.stringValue];
    if (result&&result != object) {
        lastRenamedObject = object;
        NSAlert *alert = [[NSAlert alloc] init];
        alert.messageText = @"Naming Issue";
        alert.informativeText = @"For clear identification Class names may only be used ones in a Project. This name is already in use.";
        [alert setAlertStyle:NSWarningAlertStyle];
        [alert addButtonWithTitle:@"Rename Class"];
        [alert addButtonWithTitle:@"Abort"];
        [alert beginSheetModalForWindow:self.outlineView.window
                          modalDelegate:self
                         didEndSelector:@selector(classNamingIssueAlertDidEnd:returnCode:contextInfo:)
                            contextInfo:NULL];
        return;
    }else{
        [self renameSubObject:object newName:sender.stringValue];
    }
}

- (void)emptyNameNamingIssueAlertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo{
    if (returnCode == NSAlertFirstButtonReturn) {
        NSUInteger row = [self.outlineView rowForItem:lastRenamedObject];
        NSTableCellView *cellView = [self.outlineView viewAtColumn:0 row:row makeIfNecessary:YES];
        [self.outlineView.window makeFirstResponder:cellView.textField];
    }else if (returnCode == NSAlertSecondButtonReturn) {
        NSUInteger row = [self.outlineView rowForItem:lastRenamedObject];
        NSTableCellView *cellView = [self.outlineView viewAtColumn:0 row:row makeIfNecessary:YES];
        cellView.textField.stringValue = lastRenamedObject.name;
    }
}

- (void)invalidCharactersNamingIssueDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo{
    if (returnCode == NSAlertFirstButtonReturn) {
        NSUInteger row = [self.outlineView rowForItem:lastRenamedObject];
        NSTableCellView *cellView = [self.outlineView viewAtColumn:0 row:row makeIfNecessary:YES];
        [self.outlineView.window makeFirstResponder:cellView.textField];
    }else if (returnCode == NSAlertSecondButtonReturn) {
        NSUInteger row = [self.outlineView rowForItem:lastRenamedObject];
        NSTableCellView *cellView = [self.outlineView viewAtColumn:0 row:row makeIfNecessary:YES];
        cellView.textField.stringValue = lastRenamedObject.name;
    }
}

- (void)classNamingIssueAlertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo{
    if (returnCode == NSAlertFirstButtonReturn) {
        NSUInteger row = [self.outlineView rowForItem:lastRenamedObject];
        NSTableCellView *cellView = [self.outlineView viewAtColumn:0 row:row makeIfNecessary:YES];
        [self.outlineView.window makeFirstResponder:cellView.textField];
    }else if (returnCode == NSAlertSecondButtonReturn) {
        NSUInteger row = [self.outlineView rowForItem:lastRenamedObject];
        NSTableCellView *cellView = [self.outlineView viewAtColumn:0 row:row makeIfNecessary:YES];
        cellView.textField.stringValue = lastRenamedObject.name;
    }
}

- (void)pushedAddFolder:(NSMenuItem*)sender{
    LynFolder *newFolder = [[LynFolder alloc] init];
    newFolder.name = @"New Folder";
    if (sender.tag == 2) {
        [self addSubObject:newFolder toObject:sender.representedObject];
    }else if (sender.tag == 1) {
        [self addSubObjectAtSuggestedPossition:newFolder];
    }else{
        [self addSubObject:newFolder toObject:_project];
    }
    [self selectObject:newFolder];
    [self.document.undoManager setActionName:@"Add Folder"];
}

- (void)pushedAddClass:(NSMenuItem*)sender{
    LynClass *newClass = [[LynClass alloc] init];
    for (NSUInteger i = 1; YES; i++) {
        if (i == 1) {
            newClass.name = @"New Class";
        }else{
            newClass.name = [NSString stringWithFormat:@"New Class %i", (int)i];
        }
        if (![_project hasClassNamed:newClass.name]) {
            break;
        }
    }
    if (sender.tag == 2) {
        [self addSubObject:newClass toObject:sender.representedObject];
    }else if (sender.tag == 1) {
        [self addSubObjectAtSuggestedPossition:newClass];
    }else{
        [self addSubObject:newClass toObject:_project];
    }
    [self selectObject:newClass];
    [self.document.undoManager setActionName:@"Add Class"];
}

- (void)importClass:(NSMenuItem*)sender{
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    [openPanel setTitle:@"Import Clas"];
    [openPanel setPrompt:@"Import"];
    [openPanel setMessage:@"Choose which Class (.lynclass file) to import:"];
    [openPanel setAllowedFileTypes:@[@"lynclass"]];
    [openPanel setAllowsOtherFileTypes:NO];
    [openPanel setCanChooseFiles:YES];
    [openPanel setCanChooseDirectories:NO];
    [openPanel setResolvesAliases:YES];
    [openPanel setAllowsMultipleSelection:NO];
    [openPanel beginSheetModalForWindow:self.outlineView.window completionHandler:^(NSInteger result){
        if (result == NSFileHandlingPanelOKButton) {
            NSURL *url = openPanel.URLs[0];
            NSError *error;
            NSData *data = [NSData dataWithContentsOfURL:url options:NSDataReadingUncached error:&error];
            if (error) {
                NSAlert *alert = [NSAlert alertWithError:error];
                [alert beginSheetModalForWindow:self.outlineView.window
                                  modalDelegate:nil
                                 didEndSelector:NULL
                                    contextInfo:NULL];
            }
            LynClass *newClass = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            NSString *name = newClass.name;
            if ([_project hasClassNamed:name]) {
                for (NSUInteger i = 2; YES; i++) {
                    newClass.name = [NSString stringWithFormat:@"%@ %i", name, (int)i];
                    if (![_project hasClassNamed:newClass.name]) {
                        break;
                    }
                }
            }
            if (sender.tag == 2) {
                [self addSubObject:newClass toObject:sender.representedObject];
            }else if (sender.tag == 1) {
                [self addSubObjectAtSuggestedPossition:newClass];
            }else{
                [self addSubObject:newClass toObject:_project];
            }
            [self selectObject:newClass];
            [self.document.undoManager setActionName:@"Import Class"];
        }
    }];
}

- (void)exportClass:(id)sender{
    LynProjectOutlineObject *object = [self.outlineView itemAtRow:self.outlineView.selectedRow];
    if (!object||![object isKindOfClass:[LynClass class]]) {
        return;
    }
    LynClass *class = (LynClass*)object;
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:class];
    NSSavePanel *savePanel = [NSSavePanel savePanel];
    [savePanel setTitle:@"Export Class"];
    [savePanel setPrompt:@"Export"];
    [savePanel setMessage:@"Choose where to export the Class:"];
    [savePanel setNameFieldStringValue:class.name];
    [savePanel setCanCreateDirectories:YES];
    [savePanel setAllowedFileTypes:@[@"lynclass"]];
    [savePanel setAllowsOtherFileTypes:NO];
    [savePanel beginSheetModalForWindow:self.outlineView.window completionHandler:^(NSInteger result){
        if (result == NSFileHandlingPanelOKButton) {
            NSURL *url = savePanel.URL;
            NSError *error;
            [data writeToURL:url options:NSDataWritingAtomic error:&error];
            if (error) {
                NSAlert *alert = [NSAlert alertWithError:error];
                [alert beginSheetModalForWindow:self.outlineView.window
                                  modalDelegate:nil
                                 didEndSelector:NULL
                                    contextInfo:NULL];
            }
            NSWorkspace *sharedWorkspace = [NSWorkspace sharedWorkspace];
            NSString *file = url.path;
            NSImage *image = [[NSBundle bundleForClass:[self class]] imageForResource:@"Lyn DocumentIcon.icns"];
            [sharedWorkspace setIcon:image forFile:file options:NSExcludeQuickDrawElementsIconCreationOption];
        }
    }];
}

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem{
    if (menuItem.action == @selector(importClass:)) {
        return YES;
    }else if (menuItem.action == @selector(exportClass:)) {
        LynProjectOutlineObject *object = [self.outlineView itemAtRow:self.outlineView.selectedRow];
        return (object&&[object isKindOfClass:[LynClass class]]);
    }else{
        return [super validateMenuItem:menuItem];
    }
}

@end
