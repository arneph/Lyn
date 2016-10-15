//
//  LynClassOutlineController.m
//  Lyn
//
//  Created by Programmieren on 23.06.13.
//  Copyright (c) 2013 Arne Philipeit Software. All rights reserved.
//

#import "LynClassOutlineController.h"

#define LynFunctionDragType @"de.AP-Software.Lyn.FunctionDragType"
#define LynFunctionPboardType @"de.AP-Software.Lyn.FunctionPboardType"
#define LynCommandDragType @"de.AP-Software.Lyn.CommandDragType"
#define LynCommandPboardType @"de.AP-Software.Lyn.CommandPboardType"

typedef enum{
    LynFunctionRenamingIssueEmptyName,
    LynFunctionRenamingIssueIllegalCharacters,
    LynFunctionRenamingIssueNameAlreadyUsed
}LynFunctionRenamingIssue;

@implementation LynClassOutlineController{
    LynProjectSettingsManager *projectSettingsManager;
    
    LynFunction *lastRenamedFunction;
}

@synthesize shownClass = _shownClass;
@synthesize document = _document;
@synthesize inspectorView = _inspectorView;

- (id)init{
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)awakeFromNib{
    [super awakeFromNib];
    if (_outlineView.nextResponder != self) {
        self.nextResponder = _outlineView.nextResponder;
        _outlineView.nextResponder = self;
    }
    [_outlineView setDraggingSourceOperationMask:NSDragOperationMove|NSDragOperationGeneric|NSDragOperationCopy|NSDragOperationDelete forLocal:YES];
    [_outlineView registerForDraggedTypes:@[LynFunctionDragType, LynCommandDragType]];
}

#pragma mark Properties

- (LynClass *)shownClass{
    return _shownClass;
}

- (void)setShownClass:(LynClass *)shownClass{
    _shownClass = shownClass;
    LynOutlineObject *lastParent = _shownClass.parents.lastObject;
    if ([lastParent isKindOfClass:[LynProject class]]) {
        projectSettingsManager = [LynProjectSettingsManager managerForProject:(LynProject*)lastParent];
    }else{
        projectSettingsManager = nil;
    }
    [_outlineView reloadData];
    [self expandAllItems:nil];
    [self setupObservation];
}

- (NSDocument *)document{
    return _document;
}

- (void)setDocument:(NSDocument *)document{
    _document = document;
}

- (LynInspectorView *)inspectorView{
    return _inspectorView;
}

- (void)setInspectorView:(LynInspectorView *)inspectorView{
    _inspectorView = inspectorView;
}

#pragma mark Notifications

- (void)setupObservation{
    [NotificationCenter removeObserver:self
                                  name:LynOutlineObjectNumberOfSubObjectsChangedNotification
                                object:nil];
    [NotificationCenter removeObserver:self
                                  name:LynOutlineObjectDidAddSubObjectNotification
                                object:nil];
    [NotificationCenter removeObserver:self
                                  name:LynOutlineObjectWillRemoveSubObjectNotification
                                object:nil];
    [NotificationCenter removeObserver:self
                                  name:LynFunctionNameChangedNotification
                                object:nil];
    [NotificationCenter removeObserver:self
                                  name:LynOutlineObjectNumberOfWarningsAndErrorsChangedNotification
                                object:nil];
    [NotificationCenter removeObserver:self
                                  name:LynOutlineObjectNumberOfErrorsChangedNotification
                                object:nil];
    [NotificationCenter removeObserver:self
                                  name:LynOutlineObjectNumberOfWarningsChangedNotification
                                object:nil];
    [NotificationCenter removeObserver:self
                                  name:LynCommandSummaryChangedNotification
                                object:nil];
    [NotificationCenter removeObserver:self
                                  name:LynProjectManagerColorsChangedNotification
                                object:nil];
    [NotificationCenter addObserver:self
                           selector:@selector(colorsChanged:)
                               name:LynProjectManagerColorsChangedNotification
                             object:nil];
    if (_shownClass) {
        [NotificationCenter addObserver:self
                               selector:@selector(numberOfFunctionsChanged:)
                                   name:LynOutlineObjectNumberOfSubObjectsChangedNotification
                                 object:_shownClass];
        [NotificationCenter addObserver:self
                               selector:@selector(didAddFunction:)
                                   name:LynOutlineObjectDidAddSubObjectNotification
                                 object:_shownClass];
        [NotificationCenter addObserver:self
                               selector:@selector(willRemoveFunction:)
                                   name:LynOutlineObjectWillRemoveSubObjectNotification
                                 object:_shownClass];
        for (LynFunction *function in _shownClass.subObjects) {
            [self observeFunction:function];
        }
    }
}

- (void)observeFunction: (LynFunction*)function{
    [NotificationCenter addObserver:self
                           selector:@selector(functionNameChanged:)
                               name:LynFunctionNameChangedNotification
                             object:function];
    [NotificationCenter addObserver:self
                           selector:@selector(numberOfWarningsAndErrorsOfFunctionChanged:)
                               name:LynOutlineObjectNumberOfWarningsAndErrorsChangedNotification
                             object:function];
    [NotificationCenter addObserver:self
                           selector:@selector(numberOfWarningsAndErrorsOfFunctionChanged:)
                               name:LynOutlineObjectNumberOfErrorsChangedNotification
                             object:function];
    [NotificationCenter addObserver:self
                           selector:@selector(numberOfWarningsAndErrorsOfFunctionChanged:)
                               name:LynOutlineObjectNumberOfWarningsChangedNotification
                             object:function];
    [NotificationCenter addObserver:self
                           selector:@selector(numberOfCommandsChanged:)
                               name:LynOutlineObjectNumberOfSubObjectsChangedNotification
                             object:function];
    [NotificationCenter addObserver:self
                           selector:@selector(didAddCommand:)
                               name:LynOutlineObjectDidAddSubObjectNotification
                             object:function];
    [NotificationCenter addObserver:self
                           selector:@selector(willRemoveCommand:)
                               name:LynOutlineObjectWillRemoveSubObjectNotification
                             object:function];
    for (LynCommand *command in function.subObjects) {
        [self observeCommand:command];
    }
}

- (void)endObservingFunction: (LynFunction*)function{
    [NotificationCenter removeObserver:self
                                  name:LynFunctionNameChangedNotification
                                object:function];
    [NotificationCenter removeObserver:self
                                  name:LynOutlineObjectNumberOfWarningsAndErrorsChangedNotification
                                object:function];
    [NotificationCenter removeObserver:self
                                  name:LynOutlineObjectNumberOfErrorsChangedNotification
                                object:function];
    [NotificationCenter removeObserver:self
                                  name:LynOutlineObjectNumberOfWarningsChangedNotification
                                object:function];
    [NotificationCenter removeObserver:self
                                  name:LynOutlineObjectNumberOfSubObjectsChangedNotification
                                object:function];
    [NotificationCenter removeObserver:self
                                  name:LynOutlineObjectDidAddSubObjectNotification
                                object:function];
    [NotificationCenter removeObserver:self
                                  name:LynOutlineObjectWillRemoveSubObjectNotification
                                object:function];
    for (LynCommand *command in function.subObjects) {
        [self endObservingCommand:command];
    }
}

- (void)observeCommand: (LynCommand*)command{
    [NotificationCenter addObserver:self
                           selector:@selector(commandSummaryChanged:)
                               name:LynCommandSummaryChangedNotification
                             object:command];
    [NotificationCenter addObserver:self
                           selector:@selector(numberOfWarningsAndErrorsOfCommandChanged:)
                               name:LynOutlineObjectNumberOfWarningsAndErrorsChangedNotification
                             object:command];
    [NotificationCenter addObserver:self
                           selector:@selector(numberOfWarningsAndErrorsOfCommandChanged:)
                               name:LynOutlineObjectNumberOfErrorsChangedNotification
                             object:command];
    [NotificationCenter addObserver:self
                           selector:@selector(numberOfWarningsAndErrorsOfCommandChanged:)
                               name:LynOutlineObjectNumberOfWarningsChangedNotification
                             object:command];
    if ([[command class] allowsSubObjects]) {
        [NotificationCenter addObserver:self
                               selector:@selector(numberOfCommandsChanged:)
                                   name:LynOutlineObjectNumberOfSubObjectsChangedNotification
                                 object:command];
        [NotificationCenter addObserver:self
                               selector:@selector(didAddCommand:)
                                   name:LynOutlineObjectDidAddSubObjectNotification
                                 object:command];
        [NotificationCenter addObserver:self
                               selector:@selector(willRemoveCommand:)
                                   name:LynOutlineObjectWillRemoveSubObjectNotification
                                 object:command];
        for (LynCommand *subCommand in command.subObjects) {
            [self observeCommand:subCommand];
        }
    }
}

- (void)endObservingCommand: (LynCommand*)command{
    [NotificationCenter removeObserver:self
                                  name:LynCommandSummaryChangedNotification
                                object:command];
    [NotificationCenter removeObserver:self
                                  name:LynOutlineObjectNumberOfWarningsAndErrorsChangedNotification
                                object:command];
    [NotificationCenter removeObserver:self
                                  name:LynOutlineObjectNumberOfErrorsChangedNotification
                                object:command];
    [NotificationCenter removeObserver:self
                                  name:LynOutlineObjectNumberOfWarningsChangedNotification
                                object:command];
    [NotificationCenter removeObserver:self
                                  name:LynOutlineObjectNumberOfSubObjectsChangedNotification
                                object:command];
    [NotificationCenter removeObserver:self
                                  name:LynOutlineObjectDidAddSubObjectNotification
                                object:command];
    [NotificationCenter removeObserver:self
                                  name:LynOutlineObjectWillRemoveSubObjectNotification
                                object:command];
    for (LynCommand *subCommand in command.subObjects) {
        [self endObservingCommand:subCommand];
    }
}

- (void)numberOfFunctionsChanged: (NSNotification*)notification{
    [_outlineView reloadData];
}

- (void)didAddFunction: (NSNotification*)notification{
    LynFunction *function = notification.userInfo[@"subObject"];
    [self observeFunction:function];
}

- (void)willRemoveFunction: (NSNotification*)notification{
    LynFunction *function = notification.userInfo[@"subObject"];
    [self endObservingFunction:function];
}

- (void)functionNameChanged: (NSNotification*)notification{
    LynFunction *function = notification.object;
    [_outlineView reloadItem:function reloadChildren:NO];
}

- (void)numberOfWarningsAndErrorsOfFunctionChanged: (NSNotification*)notification{
    LynFunction *function = notification.object;
    [_outlineView reloadItem:function reloadChildren:NO];
}

- (void)numberOfCommandsChanged: (NSNotification*)notification{
    [_outlineView reloadItem:notification.object reloadChildren:YES];
}

- (void)didAddCommand: (NSNotification*)notification{
    LynCommand *command = notification.userInfo[@"subObject"];
    [self observeCommand:command];
}

- (void)willRemoveCommand: (NSNotification*)notification{
    LynCommand *command = notification.userInfo[@"subObject"];
    [self endObservingCommand:command];
}

- (void)commandSummaryChanged: (NSNotification*)notification{
    LynCommand *command = notification.object;
    [_outlineView reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:[_outlineView rowForItem:command]]
                            columnIndexes:[NSIndexSet indexSetWithIndex:0]];
}

- (void)numberOfWarningsAndErrorsOfCommandChanged: (NSNotification*)notificiation{
    LynCommand *command = notificiation.object;
    [_outlineView reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:[_outlineView rowForItem:command]]
                            columnIndexes:[NSIndexSet indexSetWithIndex:0]];
}

- (void)colorsChanged: (NSNotification*)notification{
    if (notification.userInfo[@"project"] == projectSettingsManager.project) {
        [_outlineView reloadData];
    }
}

#pragma mark Undo / Redo

- (void)addSubObjectAtSuggestedPossition: (LynOutlineObject*)subObject{
    NSUInteger selectedRow = _outlineView.selectedRow;
    LynOutlineObject *selectedObject = [_outlineView itemAtRow:selectedRow];
    if ([subObject isKindOfClass:[LynFunction class]]) {
        if (!selectedObject) {
            [self addSubObject:subObject
                      toObject:_shownClass
                       atIndex:_shownClass.subObjects.count];
        }else if ([selectedObject isKindOfClass:[LynFunction class]]) {
            [self addSubObject:subObject
                      toObject:_shownClass
                       atIndex:[_shownClass.subObjects indexOfObject:selectedObject] + 1];
        }else{
            LynFunction *function;
            for (LynOutlineObject *parent in selectedObject.parents) {
                if ([parent isKindOfClass:[LynFunction class]]) {
                    function = (LynFunction*)parent;
                    break;
                }
            }
            [self addSubObject:subObject
                      toObject:_shownClass
                       atIndex:[_shownClass.subObjects indexOfObject:function] + 1];
        }
    }else if ([subObject isKindOfClass:[LynCommand class]]) {
        if (!selectedObject) {
            LynFunction *function = _shownClass.subObjects.lastObject;
            if (!function) return;
            [self addSubObject:subObject
                      toObject:function
                       atIndex:function.subObjects.count];
        }else if ([selectedObject isKindOfClass:[LynFunction class]]) {
            [self addSubObject:subObject
                      toObject:selectedObject
                       atIndex:selectedObject.subObjects.count];
        }else{
            LynOutlineObject *parent = selectedObject.parent;
            [self addSubObject:subObject
                      toObject:parent
                       atIndex:[parent.subObjects indexOfObject:selectedObject] + 1];
        }
    }
}

- (void)addSubObjectsAtSuggestedPossition: (NSArray*)subObjects{
        NSIndexSet *selectedRowIndexes = _outlineView.selectedRowIndexes;
    for (NSUInteger i = 0; i < subObjects.count; i++) {
        [self addSubObjectAtSuggestedPossition:subObjects[i]];
        [_outlineView selectRowIndexes:selectedRowIndexes byExtendingSelection:NO];
    }
}

- (void)addSubObject: (LynOutlineObject*)subObject
            toObject: (LynOutlineObject*)object{
    [self addSubObject:subObject toObject:object atIndex:object.subObjects.count];
}

- (void)addSubObjects: (NSArray*)subObjects
             toObject: (LynOutlineObject*)object{
    [self addSubObjects:subObjects toObject:object atIndex:object.subObjects.count];
}
- (void)addSubObject: (LynOutlineObject*)subObject
            toObject: (LynOutlineObject*)object
             atIndex: (NSUInteger)index{
    [self addSubObjects:@[subObject] toObject:object atIndex:index];
}

- (void)addSubObjects: (NSArray*)subObjects
             toObject: (LynOutlineObject*)object
              atIndex: (NSUInteger)index{
    [self addSubObjects:subObjects toObjects:@[object] atIndex:index];
}

- (void)addSubObjects: (NSArray*)subObjects
             toObject: (LynOutlineObject*)object
            atIndexes: (NSArray*)indexes{
    [self addSubObjects:subObjects toObjects:@[object] atIndexes:indexes];
}

- (void)addSubObjects: (NSArray*)subObjects
            toObjects: (NSArray*)objects
              atIndex: (NSUInteger)index{
    NSMutableArray *indexes = [NSMutableArray arrayWithCapacity:subObjects.count];
    for (NSUInteger i = 0; i < subObjects.count; i++) {
        [indexes addObject:@(index + i)];
    }
    [self addSubObjects:subObjects toObjects:objects atIndexes:indexes];
}

- (void)addSubObjects: (NSArray*)subObjects
            toObjects: (NSArray*)objects
            atIndexes: (NSArray*)indexes{
    [self undoableAddSubObjectsToObjectsAtIndexes:@{@"subObjects" : subObjects, @"objects" : objects, @"indexes" : indexes}];
}

- (void)removeSubObjects: (NSArray*)subObjects{
    NSMutableArray *objects = [NSMutableArray arrayWithCapacity:subObjects.count];
    for (LynOutlineObject *subObject in subObjects) {
        [objects addObject:subObject.parent];
    }
    [self removeSubObjects:subObjects fromObjects:objects];
}

- (void)removeSubObjects: (NSArray*)subObjects fromObjects: (NSArray*)objects{
    [self undoableRemoveSubObjectsFromObjects:@{@"subObjects" : subObjects, @"objects" : objects}];
}

- (void)moveSubObject: (LynOutlineObject*)subObject toParent: (LynOutlineObject*)parent{
    [self moveSubObject:subObject toParent:parent atIndex:parent.subObjects.count];
}

- (void)moveSubObject: (LynOutlineObject*)subObject toParent: (LynOutlineObject*)parent atIndex: (NSUInteger)index{
    [self moveSubObjects:@[subObject] toParent:parent atIndex:index];
}

- (void)moveSubObjects: (NSArray*)subObjects toParent: (LynOutlineObject*)parent atIndex: (NSUInteger)index{
    NSMutableArray *indexes = [NSMutableArray arrayWithCapacity:subObjects.count];
    for (NSUInteger i = 0; i < subObjects.count; i++) {
        [indexes addObject:@(index + i)];
    }
    [self moveSubObjects:subObjects toParents:@[parent] atIndexes:indexes];
}

- (void)moveSubObjects: (NSArray*)subObjects toParents: (NSArray*)newParents atIndexes: (NSArray*)indexes{
    [self undoableMoveSubObjects:@{@"subObjects" : subObjects, @"newParents" : newParents, @"newIndexes" : indexes}];
}

- (void)renameFunction:(LynFunction *)function newName:(NSString *)newName{
    [self undoableRenameFunction:@{@"function": function, @"newName" : newName}];
}

- (void)changeComment: (LynComment*)comment newComment: (NSString*)newComment{
    [self undoableChangeComment:@{@"comment": comment, @"newComment" : newComment}];
}

#pragma mark Core Undo / Redo

- (void)undoableAddSubObjectsToObjectsAtIndexes: (NSDictionary*)info{
    NSArray *subObjects = info[@"subObjects"];
    NSArray *objects = info[@"objects"];
    NSArray *indexes = info[@"indexes"];
    
    if (!subObjects||!objects||!indexes||
        subObjects.count < 1||subObjects.count != indexes.count||
        !(objects.count == 1||objects.count == subObjects.count)) {
        return;
    }
    
    for (LynOutlineObject *subObject in subObjects) {
        NSNumber *index = indexes[[subObjects indexOfObject:subObject]];
        LynOutlineObject *object;
        if (objects.count == 1) {
            object = objects[0];
        }else{
            object = objects[[subObjects indexOfObject:subObject]];
        }
        
        if ([subObject isKindOfClass: object.allowedSubObjectClass]) {
            [object.subObjects insertObject:subObject atIndex:index.unsignedIntegerValue];
        }else{
            @throw NSInvalidArgumentException;
            return;
        }
    }
    
    [_outlineView reloadData];
    [_document.undoManager registerUndoWithTarget:self
                                         selector:@selector(undoableRemoveSubObjectsFromObjects:)
                                           object:@{@"subObjects" : subObjects, @"objects" : objects}];
}

- (void)undoableRemoveSubObjectsFromObjects: (NSDictionary*)info{
    NSArray *subObjects = info[@"subObjects"];
    NSArray *objects = info[@"objects"];
    
    if (!subObjects||!objects||
        subObjects.count < 1||
        !(objects.count == 1||objects.count == subObjects.count)) {
        return;
    }
    
    NSMutableArray *indexes = [NSMutableArray arrayWithCapacity:subObjects.count];
    for (LynOutlineObject *subObject in subObjects) {
        LynOutlineObject *object;
        if (objects.count == 1) {
            object = objects[0];
        }else{
            object = objects[[subObjects indexOfObject:subObject]];
        }
        NSUInteger index = [object.subObjects indexOfObject:subObject];
        
        if (index == NSNotFound) {
            @throw NSInvalidArgumentException;
            return;
        }
        
        [object.subObjects removeObject:subObject];
        
        [indexes addObject:@(index)];
    }
    
    [_outlineView reloadData];
    [_document.undoManager registerUndoWithTarget:self
                                         selector:@selector(undoableAddSubObjectsToObjectsAtIndexes:)
                                           object:@{@"subObjects" : subObjects, @"objects" : objects, @"indexes" : indexes}];
}

- (void)undoableMoveSubObjects: (NSDictionary*)info{
    NSArray *subObjects = info[@"subObjects"];
    NSArray *newParents = info[@"newParents"];
    NSArray *newIndexes = info[@"newIndexes"];
    if (!subObjects||!newParents||!newIndexes||
        subObjects.count < 1||newParents.count < 1||newIndexes.count < 1||
        (newParents.count != 1&&newParents.count != subObjects.count)||
        newIndexes.count != subObjects.count) {
        return;
    }/*
    if (newParents.count == 1&&subObjects.count > 1) {
        LynOutlineObject *newParent = newParents.lastObject;
        NSMutableArray *newNewParents = [[NSMutableArray alloc] initWithCapacity:subObjects.count];
        for (NSUInteger i = 0; i < subObjects.count; i++) {
            [newNewParents addObject:newParent];
        }
        newParents = [NSArray arrayWithArray:newNewParents];
    }*/
    NSMutableArray *oldParents = [NSMutableArray arrayWithCapacity:subObjects.count];
    NSMutableArray *oldIndexes = [NSMutableArray arrayWithCapacity:subObjects.count];
    for (NSUInteger i = 0; i < subObjects.count; i++) {
        LynOutlineObject *subObject = subObjects[i];
        LynOutlineObject *newParent;
        NSUInteger newIndex;
        
        LynOutlineObject *oldParent = subObject.parent;
        NSUInteger oldIndex = [oldParent.subObjects indexOfObject:subObject];
        if (!oldParent||oldIndex == NSNotFound) {
            @throw NSInvalidArgumentException;
            return;
        }
        
        if (newParents.count == 1) {
            newParent = newParents.lastObject;
        }else{
            newParent = newParents[i];
        }
        newIndex = ((NSNumber*)newIndexes[i]).unsignedIntegerValue;
        
        [oldParents addObject:oldParent];
        [oldIndexes addObject:@(oldIndex)];
        
        [oldParent.subObjects removeObject:subObject];
        if (newIndex > newParent.subObjects.count) {
            newIndex = newParent.subObjects.count;
        }
        [newParent.subObjects insertObject:subObject atIndex:newIndex];
    }
    
    subObjects = [[subObjects reverseObjectEnumerator] allObjects];
    oldParents = [NSMutableArray arrayWithArray:[[oldParents reverseObjectEnumerator] allObjects]];
    oldIndexes = [NSMutableArray arrayWithArray:[[oldIndexes reverseObjectEnumerator] allObjects]];
    
    [_outlineView reloadData];
    [_document.undoManager registerUndoWithTarget:self
                                         selector:@selector(undoableMoveSubObjects:)
                                           object:@{@"subObjects" : subObjects, @"newParents" : oldParents, @"newIndexes" : oldIndexes}];
}

- (void)undoableRenameFunction: (NSDictionary*)info{
    LynFunction *function = info[@"function"];
    NSString *newName = info[@"newName"];
    if (!function||!newName) {
        return;
    }
    
    NSString *oldName = function.name;
    function.name = newName;
    if ([_outlineView rowForItem:function] > -1) {
        [_outlineView reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:[_outlineView rowForItem:function]]
                                columnIndexes:[NSIndexSet indexSetWithIndex:0]];
    }
    [_document.undoManager registerUndoWithTarget:self
                                         selector:@selector(undoableRenameFunction:)
                                           object:@{@"function": function, @"newName" : oldName}];
}

- (void)undoableChangeComment: (NSDictionary*)info{
    LynComment *comment = info[@"comment"];
    NSString *newComment = info[@"newComment"];
    if (!comment||!newComment) {
        return;
    }
    
    NSString *oldComment = comment.comment;
    comment.comment = newComment;
    if ([_outlineView rowForItem:comment] > -1) {
        [_outlineView reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:[_outlineView rowForItem:comment]]
                                columnIndexes:[NSIndexSet indexSetWithIndex:0]];
    }
    [_document.undoManager registerUndoWithTarget:self
                                         selector:@selector(undoableChangeComment:)
                                           object:@{@"comment" : comment, @"newComment" : oldComment}];
}

#pragma mark OutlineView DataSource

- (NSInteger)outlineView: (NSOutlineView*)outlineView numberOfChildrenOfItem:(id)item{
    if (!item) {
        return _shownClass.subObjects.count;
    }else if ([item isKindOfClass:[LynFunction class]]) {
        LynFunction *function = (LynFunction*)item;
        return function.subObjects.count;
    }else if ([item isKindOfClass:[LynCommand class]]) {
        LynCommand *command = (LynCommand*)item;
        return ([[command class] allowsSubObjects]) ? command.subObjects.count : 0;
    }else{
        return 0;
    }
}

- (BOOL)outlineView: (NSOutlineView*)outlineView isItemExpandable:(id)item{
    if ([item isKindOfClass:[LynFunction class]]) {
        return YES;
    }else if ([item isKindOfClass:[LynCommand class]]) {
        LynCommand *command = (LynCommand*)item;
        return [[command class] allowsSubObjects];
    }else{
        return NO;
    }
}

- (id)outlineView: (NSOutlineView*)outlineView child:(NSInteger)index ofItem:(id)item{
    if (!item) {
        if (index >= _shownClass.subObjects.count) return nil;
        return _shownClass.subObjects[index];
        
    }else if ([item isKindOfClass:[LynFunction class]]) {
        LynFunction *function = (LynFunction*)item;
        
        if (index >= function.subObjects.count) return nil;
        return function.subObjects[index];
        
    }else if ([item isKindOfClass:[LynCommand class]]) {
        LynCommand *command = (LynCommand*)item;
        
        if (![[command class] allowsSubObjects]||
            index >= command.subObjects.count) return nil;
        return command.subObjects[index];
        
    }else{
        return nil;
    }
}

- (id)outlineView: (NSOutlineView*)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item{
    return item;
}

#pragma mark OutlineView Delegate

- (NSView *)outlineView:(NSOutlineView *)outlineView
     viewForTableColumn:(NSTableColumn *)tableColumn
                   item:(id)item{
    if ([item isKindOfClass:[LynFunction class]]) {
        LynFunction *function = (LynFunction*)item;
        NSTableCellView *cellView = [_outlineView makeViewWithIdentifier:@"FunctionCell" owner:self];
        cellView.textField.stringValue = function.name;
        if (![_outlineView isItemExpanded:function]||function.hasErrors||function.hasWarnings) {
            if ([function hasErrorsIncludingSubObjects:YES]) {
                cellView.imageView.image = [NSImage imageNamed:NSImageNameStatusUnavailable];
            }else if ([function hasWarningsIncludingSubObjects:YES]) {
                cellView.imageView.image = [NSImage imageNamed:NSImageNameStatusPartiallyAvailable];
            }else{
                cellView.imageView.image = nil;
            }
        }
        return cellView;
    }else if ([item isKindOfClass:[LynComment class]]) {
        LynComment *comment = (LynComment*)item;
        NSTableCellView *cellView = [_outlineView makeViewWithIdentifier:@"CommentCell" owner:self];
        cellView.textField.stringValue = comment.comment;
        return cellView;
    }else if ([item isKindOfClass:[LynCommand class]]) {
        LynCommand *command = (LynCommand*)item;
        NSTableCellView *cellView = [_outlineView makeViewWithIdentifier:@"CommandCell" owner:self];
        cellView.textField.stringValue = command.summary;
        if (![_outlineView isItemExpanded:command]||command.hasErrors||command.hasWarnings) {
            if ([command hasErrorsIncludingSubObjects:YES]) {
                cellView.imageView.image = [NSImage imageNamed:NSImageNameStatusUnavailable];
            }else if ([command hasWarningsIncludingSubObjects:YES]) {
                cellView.imageView.image = [NSImage imageNamed:NSImageNameStatusPartiallyAvailable];
            }else{
                cellView.imageView.image = nil;
            }
        }
        return cellView;
    }else{
        return nil;
    }
}

- (NSTableRowView*)outlineView:(NSOutlineView *)outlineView rowViewForItem:(id)item{
    return [[LynClassRowView alloc] init];
}

- (void)outlineViewItemDidExpand:(NSNotification *)notification{
    LynOutlineObject *object = notification.userInfo[@"NSObject"];
    NSTableCellView *cellView = [_outlineView viewAtColumn:0 row:[_outlineView rowForItem:object] makeIfNecessary:NO];
    if (object.hasErrors) {
        cellView.imageView.image = [NSImage imageNamed:NSImageNameStatusUnavailable];
    }else if (object.hasWarnings) {
        cellView.imageView.image = [NSImage imageNamed:NSImageNameStatusPartiallyAvailable];
    }else{
        cellView.imageView.image = nil;
    }
}

- (void)outlineViewItemDidCollapse:(NSNotification *)notification{
    LynOutlineObject *object = notification.userInfo[@"NSObject"];
    NSTableCellView *cellView = [_outlineView viewAtColumn:0 row:[_outlineView rowForItem:object] makeIfNecessary:NO];
    if ([object hasErrorsIncludingSubObjects:YES]) {
        cellView.imageView.image = [NSImage imageNamed:NSImageNameStatusUnavailable];
    }else if ([object hasWarningsIncludingSubObjects:YES]) {
        cellView.imageView.image = [NSImage imageNamed:NSImageNameStatusPartiallyAvailable];
    }else{
        cellView.imageView.image = nil;
    }
}

- (void)outlineView:(NSOutlineView *)outlineView didAddRowView:(NSTableRowView *)rowView forRow:(NSInteger)row{
    rowView.groupRowStyle = NO;
    if (_outlineView.numberOfSelectedRows > 0&&[_outlineView.selectedRowIndexes containsIndex:row]) return;
    if ([[_outlineView itemAtRow:row] isKindOfClass:[LynFunction class]]) {
        rowView.backgroundColor = [NSColor colorWithCalibratedWhite:.9 alpha:1];
    }else{
        LynCommand *command = [_outlineView itemAtRow:row];
        __block BOOL isCommented = NO;
        [command.parents enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
            LynOutlineObject *parent = obj;
            if ([parent isKindOfClass:[LynComment class]]) {
                isCommented = YES;
                BOOL stp = YES;
                stop = &stp;
            }else if ([parent isKindOfClass:[LynFunction class]]) {
                BOOL stp = YES;
                stop = &stp;
            }
        }];
        NSColor *color;
        if (isCommented) {
            color = [projectSettingsManager colorForType:@"Comment"];
        }else{
            NSString *type = [[command class] name];
            color = [projectSettingsManager colorForType:type];
        }
        rowView.backgroundColor = color;
        NSColor *convertedColor = [color colorUsingColorSpace:[NSColorSpace deviceRGBColorSpace]];
        NSTableCellView *cellView = [rowView viewAtColumn:0];
        cellView.backgroundStyle = (convertedColor.brightnessComponent > 0.9) ? NSBackgroundStyleLight : NSBackgroundStyleDark;
    }
}

- (void)outlineViewSelectionDidChange:(NSNotification *)notification{
    if (_outlineView.selectedRow < 0) {
        if ([_inspectorView.object isKindOfClass:[LynCommand class]]||[_inspectorView.object isKindOfClass:[LynFunction class]]) {
            [_inspectorView setNoObject];
            return;
        }
    }
    LynOutlineObject *selectedObject = [_outlineView itemAtRow:_outlineView.selectedRow];
    if (![selectedObject isKindOfClass:[LynComment class]]) {
        [_inspectorView setObject:selectedObject];
    }else{
        [_inspectorView setNoObject];
    }
    [self updateRowBackgroundColors];
}

- (void)updateRowBackgroundColors{
    for (NSUInteger i = 0; i < _outlineView.numberOfRows; i++) {
        NSTableRowView *rowView = [_outlineView rowViewAtRow:i makeIfNecessary:NO];
        if (_outlineView.numberOfSelectedRows > 0&&[_outlineView.selectedRowIndexes containsIndex:i]) return;
        if ([[_outlineView itemAtRow:i] isKindOfClass:[LynFunction class]]) {
            rowView.backgroundColor = [NSColor colorWithCalibratedWhite:.9 alpha:1];
        }else{
            LynCommand *command = [_outlineView itemAtRow:i];
            __block BOOL isCommented = NO;
            [command.parents enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
                LynOutlineObject *parent = obj;
                if ([parent isKindOfClass:[LynComment class]]) {
                    isCommented = YES;
                    BOOL stp = YES;
                    stop = &stp;
                }else if ([parent isKindOfClass:[LynFunction class]]) {
                    BOOL stp = YES;
                    stop = &stp;
                }
            }];
            NSColor *color;
            if (isCommented) {
                color = [projectSettingsManager colorForType:@"Comment"];
            }else{
                NSString *type = [[command class] name];
                color = [projectSettingsManager colorForType:type];
            }
            rowView.backgroundColor = color;
            NSColor *convertedColor = [color colorUsingColorSpace:[NSColorSpace deviceRGBColorSpace]];
            NSTableCellView *cellView = [rowView viewAtColumn:0];
            cellView.backgroundStyle = (convertedColor.brightnessComponent > 0.9) ? NSBackgroundStyleLight : NSBackgroundStyleDark;
        }
    }
}

#pragma mark Drag & Drop

- (NSArray *)simplifiedSubObjectsCollection: (NSArray*)subObjectsCollection{
    NSMutableArray *simplifiedCollection = [NSMutableArray arrayWithArray:subObjectsCollection];
    
    for (LynOutlineObject *subObject in subObjectsCollection) {
        BOOL hasParentInCollection = NO;
        LynOutlineObject *parent = subObject.parent;
        while (parent != nil&&![parent isKindOfClass:[LynClass class]]) {
            if ([subObjectsCollection indexOfObject:parent] != NSNotFound) {
                hasParentInCollection = YES;
            }
            parent = parent.parent;
        }
        if (hasParentInCollection) {
            [simplifiedCollection removeObject:subObject];
        }
    }
    return [NSArray arrayWithArray:simplifiedCollection];
}

- (NSArray*)simplifiedSubObjectsCollectionForPasteboard: (NSArray*)subObjectsCollection{
    NSMutableArray *simplifiedCollection = [NSMutableArray arrayWithArray:[self simplifiedSubObjectsCollection:subObjectsCollection]];
    if (simplifiedCollection.count < 1) return @[];
    
    BOOL containsFunction = NO;
    for (LynOutlineObject *subObject in simplifiedCollection) {
        if ([subObject isKindOfClass:[LynFunction class]]) containsFunction = YES;
    }
    
    if (!containsFunction) return [NSArray arrayWithArray:simplifiedCollection];
    
    NSMutableArray *copiedCollection = [[NSMutableArray alloc] init];
    [simplifiedCollection enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
        [copiedCollection addObject:((LynOutlineObject*)simplifiedCollection[idx]).copy];
    }];
    [simplifiedCollection removeAllObjects];
    [simplifiedCollection addObjectsFromArray:copiedCollection];
    
    if (containsFunction) {
        NSMutableArray *commandsToAddToFirstFunction = [[NSMutableArray alloc] init];
        LynFunction *function;
        for (LynOutlineObject *object in simplifiedCollection) {
            
            if ([object isKindOfClass:[LynFunction class]]) {
                BOOL firstFunction = (!function);
                function = (LynFunction*)function;
                
                if (firstFunction&&commandsToAddToFirstFunction.count > 0) {
                    [function.subObjects insertObjects:commandsToAddToFirstFunction
                                             atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, commandsToAddToFirstFunction.count)]];
                }
                
            }else if ([object isKindOfClass:[LynCommand class]]) {
                if (function) {
                    [function.subObjects addObject:object];
                }else{
                    [commandsToAddToFirstFunction addObject:object];
                }
                [simplifiedCollection removeObject:object];
            }
            
        }
    }
    
    return [NSArray arrayWithArray:simplifiedCollection];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView
         writeItems:(NSArray *)items
       toPasteboard:(NSPasteboard *)pasteboard{
    NSMutableArray *simplifiedItems = [NSMutableArray arrayWithArray:[self simplifiedSubObjectsCollectionForPasteboard:items]];
    if (simplifiedItems.count < 1) {
        return NO;
    }
    
    NSString *dragType = ([simplifiedItems[0] isKindOfClass:[LynFunction class]]) ? LynFunctionDragType : LynCommandDragType;
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:simplifiedItems];
    [pasteboard clearContents];
    [pasteboard declareTypes:@[dragType] owner:self];
    [pasteboard setData:data forType:dragType];
    
    if (!_document.isInViewingMode) {
        [self performSelector:@selector(removeDragObjects:)
                   withObject:[self simplifiedSubObjectsCollection:items]
                   afterDelay:.01];
    }
    return YES;
}

- (void)removeDragObjects: (NSArray*)dragObjects{
    [self removeSubObjects:dragObjects];
    [_document.undoManager setActionName:@"Dragging"];
}

- (NSDragOperation)outlineView:(NSOutlineView *)outlineView
                  validateDrop:(id<NSDraggingInfo>)info
                  proposedItem:(id)item
            proposedChildIndex:(NSInteger)index{
    if (_document.isInViewingMode) return NSDragOperationNone;
    if (![((LynOutlineObject*)item).class allowsSubObjects]&&item) return NSDragOperationNone;
    NSData *functionData = [info.draggingPasteboard dataForType:LynFunctionDragType];
    NSData *commandData = [info.draggingPasteboard dataForType:LynCommandDragType];
    if (functionData) {
        return (item) ? NSDragOperationNone : NSDragOperationMove;
    }else if (commandData) {
        return (item) ? NSDragOperationMove : NSDragOperationNone;
    }else{
        return NSDragOperationNone;
    }
}

- (BOOL)outlineView:(NSOutlineView *)outlineView
         acceptDrop:(id<NSDraggingInfo>)info
               item:(id)item
         childIndex:(NSInteger)index{
    if (_document.isInViewingMode) return NO;
    NSData *functionData = [info.draggingPasteboard dataForType:LynFunctionDragType];
    NSData *commandData = [info.draggingPasteboard dataForType:LynCommandDragType];
    NSArray *newSubObjects;
    
    if (functionData&&!item) {
        newSubObjects = [NSKeyedUnarchiver unarchiveObjectWithData:functionData];
    }else if (commandData&&item) {
        newSubObjects = [NSKeyedUnarchiver unarchiveObjectWithData:commandData];
    }else{
        return NO;
    }
    
    if (!item) {
        item = _shownClass;
    }
    if (index > ((LynOutlineObject*)item).subObjects.count) {
        index = ((LynOutlineObject*)item).subObjects.count;
    }
    
    [self addSubObjects:newSubObjects toObject:item atIndex:index];
    [self selectObjects:newSubObjects];
    [_document.undoManager setActionName:@"Dropping"];
    return YES;
}

#pragma mark Selection

- (LynOutlineObject*)selectedObject{
    if (_outlineView.numberOfSelectedRows < 1) return nil;
    NSUInteger index = _outlineView.selectedRow;
    return [_outlineView itemAtRow:index];
}

- (NSArray*)selectedObjects{
    if (_outlineView.numberOfSelectedRows < 2) return ([self selectedObject]) ? @[[self selectedObject]] : nil;
    NSIndexSet *selectedRowIndexes = _outlineView.selectedRowIndexes;
    NSMutableArray *selectedObjects = [NSMutableArray arrayWithCapacity:selectedRowIndexes.count];
    [selectedRowIndexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop){
        [selectedObjects addObject:[_outlineView itemAtRow:idx]];
    }];
    return [NSArray arrayWithArray:selectedObjects];
}

- (void)expandParentsOfObject:(LynOutlineObject*)object {
    while (object != nil) {
        LynOutlineObject *parent = object.parent;
        if (![_outlineView isExpandable: parent]) break;
        if (![_outlineView isItemExpanded: parent])[_outlineView expandItem: parent];
        object = parent;
    }
}

- (void)selectNothing{
    [_outlineView deselectAll:self];
}

- (void)selectEverything{
    [_outlineView selectAll:self];
}

- (void)invertSelection{
    if (_outlineView.numberOfSelectedRows < 1) {
        [self selectEverything];
        return;
    }
    NSIndexSet *oldSelectedIndexes = _outlineView.selectedRowIndexes;
    NSMutableIndexSet *newSelectedIndexes = [NSMutableIndexSet indexSetWithIndexesInRange:NSMakeRange(0, _outlineView.numberOfRows)];
    [newSelectedIndexes removeIndexes:oldSelectedIndexes];
    [_outlineView selectRowIndexes:newSelectedIndexes byExtendingSelection:NO];
}

- (void)selectObject:(LynOutlineObject *)object {
    NSInteger objectIndex = [_outlineView rowForItem:object];
    if (objectIndex < 0) {
        [self expandParentsOfObject: object];
        objectIndex = [_outlineView rowForItem:object];
        if (objectIndex < 0)
            return;
    }
    [_outlineView selectRowIndexes: [NSIndexSet indexSetWithIndex: objectIndex] byExtendingSelection: NO];
    [_outlineView.window makeFirstResponder:_outlineView];
}

- (void)selectObjects:(NSArray *)objects{
    [_outlineView selectRowIndexes:[NSIndexSet indexSet] byExtendingSelection:NO];
    for (LynOutlineObject *object in objects) {
        NSInteger objectIndex = [_outlineView rowForItem:object];
        if (objectIndex < 0) {
            [self expandParentsOfObject: object];
            objectIndex = [_outlineView rowForItem:object];
            if (objectIndex < 0)
                return;
        }
        
        [_outlineView selectRowIndexes: [NSIndexSet indexSetWithIndex: objectIndex] byExtendingSelection: YES];
    }
    [_outlineView.window makeFirstResponder:_outlineView];
}

#pragma mark Actions

- (void)nameChanged:(NSTextField*)sender{
    LynFunction *function = [_outlineView itemAtRow:[_outlineView rowForView:sender.superview]];
    lastRenamedFunction = function;
    NSString *newName = sender.stringValue;
    
    LynFunctionRenamingIssue issue;
    if ([newName isEqualToString:@""]) {
        issue = LynFunctionRenamingIssueEmptyName;
    }else if ([newName rangeOfString:@" "].location != NSNotFound||[newName rangeOfString:@"/"].location != NSNotFound) {
        issue = LynFunctionRenamingIssueIllegalCharacters;
    }else if ([_shownClass functionNamed:newName]&&[_shownClass functionNamed:newName] != function) {
        issue = LynFunctionRenamingIssueNameAlreadyUsed;
    }else{
        [self renameFunction:function newName:newName];
        [_document.undoManager setActionName:@"Renaming Function"];
        return;
    }
    
    NSAlert *alert = [[NSAlert alloc] init];
    if (issue == LynFunctionRenamingIssueEmptyName) {
        alert.messageText = @"Naming Issue";
        alert.informativeText = @"An empty name is not allowed.";
    }else if (issue == LynFunctionRenamingIssueIllegalCharacters) {
        alert.messageText = @"Naming Issue";
        alert.informativeText = @"The characters ' ' and '/' are not allowed.";
    }else if (issue == LynFunctionRenamingIssueNameAlreadyUsed) {
        alert.messageText = @"Naming Issue";
        alert.informativeText = @"For clear identification Function names may only be used ones in a Class. This name is already in use.";
    }
    
    [alert setAlertStyle:NSWarningAlertStyle];
    [alert addButtonWithTitle:@"Rename"];
    [alert addButtonWithTitle:@"Abort"];
    [alert beginSheetModalForWindow:self.outlineView.window
                      modalDelegate:self
                     didEndSelector:@selector(namingIssueAlertDidEnd:returnCode:contextInfo:)
                        contextInfo:NULL];
}

- (void)namingIssueAlertDidEnd: (NSAlert*)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo{
    NSUInteger row = [self.outlineView rowForItem:lastRenamedFunction];
    NSTableCellView *cellView = [self.outlineView viewAtColumn:0 row:row makeIfNecessary:YES];
    
    if (returnCode == NSAlertFirstButtonReturn) {
        [self.outlineView.window makeFirstResponder:cellView.textField];
    }else if (returnCode == NSAlertSecondButtonReturn) {
        cellView.textField.stringValue = lastRenamedFunction.name;
    }
}

- (void)commentChanged:(NSTextField*)sender{
    LynComment *comment = [_outlineView itemAtRow:[_outlineView rowForView:sender.superview]];
    NSString *newComment = sender.stringValue;
    if (![comment.comment isEqualToString:newComment]) {
        [self changeComment:comment newComment:newComment];
    }
}

#pragma mark Menu Actions

- (void)cut:(id)sender{
    if (_document.isInViewingMode||_outlineView.selectedRow == -1) {
        return;
    }
    NSMutableArray *subObjects = [NSMutableArray arrayWithCapacity:_outlineView.numberOfSelectedRows];
	NSIndexSet *indexes = [_outlineView selectedRowIndexes];
    NSUInteger rowIndex = [indexes firstIndex];
    while (rowIndex != NSNotFound) {
        [subObjects addObject:[_outlineView itemAtRow:rowIndex]];
        rowIndex = [indexes indexGreaterThanIndex:rowIndex];
    }
    NSArray *simplifiedSubObjectsToDelete = [self simplifiedSubObjectsCollection:subObjects];
    NSArray *simplifiedSubObjects = [self simplifiedSubObjectsCollectionForPasteboard:subObjects];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:simplifiedSubObjects];
    NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
    NSString *pboardType = ([subObjects[0] isKindOfClass:[LynFunction class]]) ? LynFunctionPboardType : LynCommandPboardType;
    [pasteboard clearContents];
    [pasteboard declareTypes:@[pboardType] owner:self];
    [pasteboard setData:data forType:pboardType];
    [self removeSubObjects:simplifiedSubObjectsToDelete];
    [_document.undoManager setActionName:@"Cut"];
}

- (void)copy:(id)sender{
    if (_outlineView.selectedRow == -1) {
        return;
    }
    NSMutableArray *subObjects = [NSMutableArray arrayWithCapacity:_outlineView.numberOfSelectedRows];
	NSIndexSet *indexes = [_outlineView selectedRowIndexes];
    NSUInteger rowIndex = [indexes firstIndex];
    while (rowIndex != NSNotFound) {
        [subObjects addObject:[_outlineView itemAtRow:rowIndex]];
        rowIndex = [indexes indexGreaterThanIndex:rowIndex];
    }
    NSArray *simplifiedSubObjects = [self simplifiedSubObjectsCollectionForPasteboard:subObjects];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:simplifiedSubObjects];
    NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
    NSString *pboardType = ([subObjects[0] isKindOfClass:[LynFunction class]]) ? LynFunctionPboardType : LynCommandPboardType;
    [pasteboard clearContents];
    [pasteboard declareTypes:@[pboardType] owner:self];
    [pasteboard setData:data forType:pboardType];
}

- (void)paste:(id)sender{
    if (_document.isInViewingMode) {
        return;
    }
    NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
    NSData *functionData = [pasteboard dataForType:LynFunctionPboardType];
    NSData *commandData = [pasteboard dataForType:LynCommandPboardType];
    NSArray *subObjects;
    if (functionData) {
        subObjects = [NSKeyedUnarchiver unarchiveObjectWithData:functionData];
    }else if (commandData) {
        subObjects = [NSKeyedUnarchiver unarchiveObjectWithData:commandData];
    }else{
        return;
    }
    [self addSubObjectsAtSuggestedPossition:subObjects];
    [self selectObjects:subObjects];
    [_document.undoManager setActionName:@"Paste"];
}

- (void)duplicate:(id)sender{
    if (_outlineView.selectedRow == -1) {
        return;
    }
    NSMutableArray *subObjects = [NSMutableArray arrayWithCapacity:_outlineView.numberOfSelectedRows];
	NSIndexSet *indexes = [_outlineView selectedRowIndexes];
    NSUInteger rowIndex = [indexes firstIndex];
    while (rowIndex != NSNotFound) {
        [subObjects addObject:[_outlineView itemAtRow:rowIndex]];
        rowIndex = [indexes indexGreaterThanIndex:rowIndex];
    }
    subObjects = [NSMutableArray arrayWithArray:[self simplifiedSubObjectsCollectionForPasteboard:subObjects]];
    subObjects = [[NSMutableArray alloc] initWithArray:subObjects copyItems:YES];
    [self addSubObjectsAtSuggestedPossition:subObjects];
    [self selectObjects:subObjects];
    [_document.undoManager setActionName:@"Dublicate"];
}

- (void)delete:(id)sender{
    if (_document.isInViewingMode||_outlineView.selectedRow == -1) {
        return;
    }
    NSMutableArray *subObjects = [NSMutableArray arrayWithCapacity:_outlineView.numberOfSelectedRows];
	NSIndexSet *indexes = [_outlineView selectedRowIndexes];
    NSUInteger rowIndex = [indexes firstIndex];
    while (rowIndex != NSNotFound) {
        [subObjects addObject:[_outlineView itemAtRow:rowIndex]];
        rowIndex = [indexes indexGreaterThanIndex:rowIndex];
    }
    NSArray *simplifiedSubObjects = [self simplifiedSubObjectsCollection:subObjects];
    [self removeSubObjects:simplifiedSubObjects];
    [_document.undoManager setActionName:@"Delete"];
}

- (IBAction)invertSelection: (id)sender{
    [self invertSelection];
}

- (IBAction)collapseAllItems:(id)sender{
    [_outlineView collapseItem:nil collapseChildren:YES];
}

- (IBAction)expandAllItems:(id)sender{
    [_outlineView expandItem:nil expandChildren:YES];
}

- (void)addFunction:(id)sender{
    LynFunction *newFunction = [[LynFunction alloc] init];
    for (NSUInteger i = 1; YES; i++) {
        if (i == 1) {
            newFunction.name = @"newFunction";
        }else{
            newFunction.name = [NSString stringWithFormat:@"newFunction%i", (int)i];
        }
        if (![_shownClass hasFunctionNamed:newFunction.name]) {
            break;
        }
    }
    [self addSubObjectAtSuggestedPossition:newFunction];
    [_document.undoManager setActionName:@"Adding Function"];
    [self selectObject:newFunction];
}

- (void)addMainFunction:(id)sender{
    if ([_shownClass hasFunctionNamed:@"main"]) {
        return;
    }
    LynFunction *newFunction = [[LynFunction alloc] init];
    newFunction.name = @"main";
    [self addSubObjectAtSuggestedPossition:newFunction];
    [_document.undoManager setActionName:@"Adding main-Function"];
    [self selectObject:newFunction];
}

- (void)moveSelectionUp:(id)sender{
    
}

- (void)moveSelectionDown:(id)sender{
    NSArray *selectedObjects = [self selectedObjects];
    if (!selectedObjects) return;
    __block BOOL containsFunction = NO;
    [selectedObjects enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
        if ([obj isKindOfClass:[LynFunction class]]) {
            containsFunction = YES;
            BOOL stp = YES;
            stop = &stp;
        }
    }];
    
    if (!containsFunction) {
        NSArray *simplifiedObjects = [self simplifiedSubObjectsCollection:selectedObjects];
        LynOutlineObject *lastObject = selectedObjects.lastObject;
        LynOutlineObject *parent = lastObject.parent;
        NSUInteger index = [parent.subObjects indexOfObject:lastObject];
        if (index < parent.subObjects.count - 1) {
            [self moveSubObjects:simplifiedObjects toParent:parent atIndex:index + 1];
        }else{
            LynOutlineObject *superParent = parent.parent;
            NSUInteger superIndex = [superParent.subObjects indexOfObject:parent];
            if ([superParent isKindOfClass:[LynCommand class]]||[superParent isKindOfClass:[LynFunction class]]) {
                [self moveSubObjects:simplifiedObjects toParent:superParent atIndex:superIndex + 1];
            }else if ([superParent isKindOfClass:[LynClass class]]) {
                if (superIndex < superParent.subObjects.count - 1) {
                    LynFunction *newParent = superParent.subObjects[superIndex + 1];
                    [self moveSubObjects:simplifiedObjects toParent:newParent atIndex:0];
                }
            }
        }
    }else{
        NSArray *simplifiedObjects = [self simplifiedSubObjectsCollection:selectedObjects];
        LynFunction *lastFunction;
        for (NSInteger i = simplifiedObjects.count - 1; i > -1; i--) {
            LynOutlineObject *object = simplifiedObjects[i];
            if ([object isKindOfClass:[LynFunction class]]) {
                lastFunction = (LynFunction*)object;
            }
        }
        NSUInteger destinationIndex = [_shownClass.subObjects indexOfObject:lastFunction];
        if (destinationIndex < _shownClass.subObjects.count - 1) {
            NSMutableArray *objects = [NSMutableArray arrayWithCapacity:simplifiedObjects.count];
            NSMutableArray *parents = [NSMutableArray arrayWithCapacity:simplifiedObjects.count];
            NSMutableArray *indexes = [NSMutableArray arrayWithCapacity:simplifiedObjects.count];
            __block LynOutlineObject *firstFunction;
            [simplifiedObjects enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
                if ([obj isKindOfClass:[LynFunction class]]) {
                    firstFunction = obj;
                    BOOL stp = YES;
                    stop = &stp;
                }
            }];
            LynFunction *lastFunction = nil;
            NSUInteger index = 0;
            for (LynOutlineObject *object in simplifiedObjects) {
                if ([object isKindOfClass:[LynCommand class]]) {
                    [objects addObject:object];
                    if (lastFunction) {
                        [parents addObject:lastFunction];
                        [indexes addObject:@(index)];
                    }else{
                        [parents addObject:firstFunction];
                        [indexes addObject:@(index)];
                    }
                    index++;
                }else if ([object isKindOfClass:[LynFunction class]]) {
                    lastFunction = (LynFunction*)object;
                    index = lastFunction.subObjects.count;
                }
            }
            for (LynOutlineObject *object in simplifiedObjects) {
                if ([object isKindOfClass:[LynFunction class]]) {
                    [objects addObject:object];
                    [parents addObject:_shownClass];
                    [indexes addObject:@(destinationIndex + 1)];
                }
            }
            [self moveSubObjects:objects toParents:parents atIndexes:indexes];
        }
    }
    [self selectObjects:selectedObjects];
    
    /*
    if (_outlineView.selectedRowIndexes.count < 2) {
        LynOutlineObject *selectedObject = [_outlineView itemAtRow:_outlineView.selectedRow];
        LynOutlineObject *parent = selectedObject.parent;
        NSUInteger index = [parent.subObjects indexOfObject:selectedObject];
        [self moveSubObject:selectedObject toParent:parent atIndex:index + 1];
        [_document.undoManager setActionName:@"Move Selection Down"];
        [_outlineView selectRowIndexes:[NSIndexSet indexSetWithIndex:[_outlineView rowForItem:selectedObject]]
                  byExtendingSelection:NO];
        return;
    }else{
        return;
    }
    NSMutableArray *selectedObjects = [[NSMutableArray alloc] initWithCapacity:_outlineView.selectedRowIndexes.count];
    */
}

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem{
    if (_outlineView.window.firstResponder != _outlineView) {
        return NO;
    }
    
    BOOL changesDocument = (menuItem.action == @selector(cut:)||
                            menuItem.action == @selector(paste:)||
                            menuItem.action == @selector(duplicate:)||
                            menuItem.action == @selector(delete:)||
                            menuItem.action == @selector(addFunction:)||
                            menuItem.action == @selector(addMainFunction:)||
                            menuItem.action == @selector(moveSelectionUp:)||
                            menuItem.action == @selector(moveSelectionDown:));
    BOOL needsSelection = (menuItem.action == @selector(cut:)||
                           menuItem.action == @selector(copy:)||
                           menuItem.action == @selector(duplicate:)||
                           menuItem.action == @selector(delete:)||
                           menuItem.action == @selector(invertSelection:)||
                           menuItem.action == @selector(moveSelectionUp:)||
                           menuItem.action == @selector(moveSelectionDown:));
    BOOL needsPasteboardContent = (menuItem.action == @selector(paste:));
    BOOL wantsToAddMainFunction = (menuItem.action == @selector(addMainFunction:));
    BOOL wantsToMoveSelectionUp = (menuItem.action == @selector(moveSelectionUp:));
    BOOL wantsToMoveSelectionDown = (menuItem.action == @selector(moveSelectionDown:));
    
    BOOL mayChangeDocument = !_document.isInViewingMode;
    BOOL hasSelection = (_outlineView.selectedRow != -1);
    BOOL hasPasteboardContent = ([[NSPasteboard generalPasteboard] dataForType:LynFunctionPboardType]||
                                 [[NSPasteboard generalPasteboard] dataForType:LynCommandPboardType]);
    BOOL hasMainFunction = [_shownClass hasFunctionNamed:@"main"];
    BOOL canMoveSelectionUp = YES;
    BOOL canMoveSelectionDown = YES;
    if (changesDocument&&!mayChangeDocument) {
        return NO;
    }else if (needsSelection&&!hasSelection) {
        return NO;
    }else if (needsPasteboardContent&&!hasPasteboardContent) {
        return NO;
    }else if (wantsToAddMainFunction&&hasMainFunction) {
        return NO;
    }else if (wantsToMoveSelectionUp&&!canMoveSelectionUp) {
        return NO;
    }else if (wantsToMoveSelectionDown&&!canMoveSelectionDown) {
        return NO;
    }else{
        return YES;
    }
}

@end
