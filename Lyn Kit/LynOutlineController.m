//
//  LynOutlineController.m
//  Lyn
//
//  Created by Programmieren on 28.04.13.
//  Copyright (c) 2013 Arne Philipeit Software. All rights reserved.
//

#import "LynOutlineController.h"

@implementation LynOutlineController
@synthesize rootObject = _rootObject;

- (id)init{
    self = [super init];
    if (self) {
        _rootObject = nil;
        _showRootObject = YES;
        _lowestHierarchyClass = [LynOutlineObject class];
    }
    return self;
}

- (void)awakeFromNib{
    if (_outlineView.nextResponder != self) {
        self.nextResponder = _outlineView.nextResponder;
        _outlineView.nextResponder = self;
    }
    [_outlineView registerForDraggedTypes:@[self.dragType]];
}

- (LynOutlineObject *)rootObject{
    return _rootObject;
}

- (void)setRootObject:(LynOutlineObject *)rootObject{
    BOOL needsReload = (_rootObject != rootObject);
    _rootObject = rootObject;
    if (needsReload) [_outlineView reloadData];
    if (_outlineView.numberOfRows > 0) [_outlineView selectRowIndexes:[NSIndexSet indexSetWithIndex:0] byExtendingSelection:NO];
}

#pragma mark NSOutlineView DataSource

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item{
    if (!_rootObject) {
        return nil;
    }
    if (item == nil) {
        return (_showRootObject) ? _rootObject : _rootObject.subObjects[index];
    }else {
        return ((LynOutlineObject*)item).subObjects[index];
    }
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item{
    if (!_rootObject) {
        return NO;
    }
    if ([[((LynOutlineObject*)item) class] allowsSubObjects] == NO) {
        return NO;
    }else if ([item class] == _lowestHierarchyClass||[[item class] isSubclassOfClass:_lowestHierarchyClass]) {
        return NO;
    }else{
        return YES;
    }
}

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item{
    if (!_rootObject) {
        return 0;
    }
    if (item == nil) {
        return (_showRootObject) ? 1 : _rootObject.subObjects.count;
    }else{
        NSUInteger i = ((LynOutlineObject*)item).subObjects.count;
        return i;
    }
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item{
    return item;
}

#pragma mark Selection

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
}

#pragma mark Undo/Redo

- (void)addSubObjectAtSuggestedPossition: (LynOutlineObject*)subObject{
    [self addSubObjectsAtSuggestedPossition:@[subObject]];
}

- (void)addSubObjectsAtSuggestedPossition: (NSArray*)subObjects{
    LynOutlineObject *object;
    NSUInteger index;
    if (_outlineView.numberOfSelectedRows == 0) {
        object = _rootObject;
        index = _rootObject.subObjects.count;
    }else if (_outlineView.numberOfSelectedRows == 1) {
        LynOutlineObject *selectedObject = [_outlineView itemAtRow:_outlineView.selectedRow];
        if ([self outlineView:_outlineView isItemExpandable:selectedObject]) {
            object = selectedObject;
            index = selectedObject.subObjects.count;
        }else{
            object = selectedObject.parent;
            index = [object.subObjects indexOfObject:selectedObject] + 1;
        }
    }else{
        LynOutlineObject *lastSelectedObject = [_outlineView itemAtRow:_outlineView.selectedRowIndexes.lastIndex];
        object = [_outlineView parentForItem:lastSelectedObject];
        index = [object.subObjects indexOfObject:lastSelectedObject] + 1;
    }
    [self addSubObjects:subObjects toObject:object atIndex:index];
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

- (void)renameSubObject:(LynOutlineObject *)subObject newName:(NSString *)newName{
    [self undoableRenameSubObject:@{@"subObject": subObject, @"newName" : newName}];
}

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
            object = objects[index.unsignedIntegerValue];
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
        if (![object isKindOfClass:[LynProject class]]) {
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
    }
    
    [_outlineView reloadData];
    [_document.undoManager registerUndoWithTarget:self
                                         selector:@selector(undoableAddSubObjectsToObjectsAtIndexes:)
                                           object:@{@"subObjects" : subObjects, @"objects" : objects, @"indexes" : indexes}];
}

- (void)undoableRenameSubObject: (NSDictionary*)info{
    LynOutlineObject *subObject = info[@"subObject"];
    NSString *newName = info[@"newName"];
    if (!subObject||!newName||![subObject conformsToProtocol:@protocol(LynNamedOutlineObject)]) {
        return;
    }
    
    NSString *oldName = [(LynOutlineObject<LynNamedOutlineObject>*)subObject name];
    [(LynOutlineObject<LynNamedOutlineObject>*)subObject setName: newName];
    [_outlineView reloadData];
    [_document.undoManager registerUndoWithTarget:self
                                         selector:@selector(undoableRenameSubObject:)
                                           object:@{@"subObject": subObject, @"newName" : oldName}];
}

#pragma mark Types

- (NSString *)dragType{
    return LynOutlineItemsDragType;
}

- (NSString *)pasteboardType{
    return LynOutlineItemsPasteboardType;
}

#pragma mark Drag & Drop

- (NSArray*)simplifiedSubObjectsCollectionForArchiving: (NSArray*)subObjectsCollection{
    NSMutableArray *simplifiedCollection = [NSMutableArray arrayWithArray:subObjectsCollection];
    if ([simplifiedCollection indexOfObject:_rootObject] != NSNotFound) {
        [simplifiedCollection removeObject:_rootObject];
    }
    for (LynOutlineObject *subObject in subObjectsCollection) {
        BOOL hasParentInCollection = NO;
        LynOutlineObject *parent = subObject.parent;
        while (parent != nil) {
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

- (BOOL)outlineView:(NSOutlineView *)outlineView
         writeItems:(NSArray *)items
       toPasteboard:(NSPasteboard *)pasteboard{
    NSArray *simplifiedItems = [self simplifiedSubObjectsCollectionForArchiving:items];
    if (simplifiedItems.count < 1) {
        return NO;
    }
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:simplifiedItems];
    [pasteboard declareTypes:@[self.dragType] owner:self];
    [pasteboard setData:data forType:self.dragType];
    if (!_document.isInViewingMode) {
        [self performSelector:@selector(removeDragObjects:) withObject:simplifiedItems afterDelay:.01];
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
    if (!item&&_showRootObject) {
        return NSDragOperationNone;
    }else if (_document.isInViewingMode) {
        return NSDragOperationNone;
    }else if ([item isKindOfClass:_lowestHierarchyClass]){
        return NSDragOperationNone;
    }else if (item&&![[item class] allowsSubObjects]) {
        return NSDragOperationNone;
    }else{
        return NSDragOperationMove;
    }
}

- (BOOL)outlineView:(NSOutlineView *)outlineView
         acceptDrop:(id<NSDraggingInfo>)info
               item:(id)item
         childIndex:(NSInteger)index{
    if (_document.isInViewingMode) return NO;
    if (item == nil&&!_showRootObject) {
        item = _rootObject;
    }
    if (index > ((LynOutlineObject*)item).subObjects.count) {
        index = ((LynOutlineObject*)item).subObjects.count;
    }
    NSData *data = [[info draggingPasteboard] dataForType:self.dragType];
    NSArray *newSubObjects = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    [self addSubObjects:newSubObjects toObject:item atIndex:index];
    [self selectObjects:newSubObjects];
    [_document.undoManager setActionName:@"Dropping"];
    return YES;
}

#pragma Menu Actions Validation

- (BOOL)canCut{
    BOOL mayChangeDocument = !_document.isInViewingMode;
    BOOL hasSelection = (_outlineView.selectedRow != -1);
    return (mayChangeDocument&&hasSelection);
}

- (BOOL)canCopy{
    BOOL hasSelection = (_outlineView.selectedRow != -1);
    return hasSelection;
}

- (BOOL)canPaste{
    BOOL mayChangeDocument = !_document.isInViewingMode;
    BOOL hasPasteboardContent = ([[NSPasteboard generalPasteboard] dataForType:self.pasteboardType] != nil);
    return (mayChangeDocument&&hasPasteboardContent);
}

- (BOOL)canDelete{
    BOOL mayChangeDocument = !_document.isInViewingMode;
    BOOL hasSelection = (_outlineView.selectedRow != -1);
    return (mayChangeDocument&&hasSelection);
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
    NSArray *simplifiedSubObjects = [self simplifiedSubObjectsCollectionForArchiving:subObjects];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:simplifiedSubObjects];
    NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
    [pasteboard declareTypes:@[self.pasteboardType] owner:self];
    [pasteboard setData:data forType:self.pasteboardType];
    [self removeSubObjects:simplifiedSubObjects];
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
    NSArray *simplifiedSubObjects = [self simplifiedSubObjectsCollectionForArchiving:subObjects];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:simplifiedSubObjects];
    NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
    [pasteboard declareTypes:@[self.pasteboardType] owner:self];
    [pasteboard setData:data forType:self.pasteboardType];
}

- (void)paste:(id)sender{
    if (_document.isInViewingMode) {
        return;
    }
    NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
    NSData *data = [pasteboard dataForType:self.pasteboardType];
    NSArray *subObjects = [NSKeyedUnarchiver unarchiveObjectWithData:data];
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
    subObjects = [NSMutableArray arrayWithArray:[self simplifiedSubObjectsCollectionForArchiving:subObjects]];
    for (id subObject in subObjects) {
        subObjects[[subObjects indexOfObject:subObject]] = [subObject copy];
    }
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
    NSArray *simplifiedSubObjects = [self simplifiedSubObjectsCollectionForArchiving:subObjects];
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

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem{
    if (_outlineView.window.firstResponder != _outlineView) {
        return NO;
    }
    BOOL changesDocument = (menuItem.action == @selector(cut:)||
                            menuItem.action == @selector(paste:)||
                            menuItem.action == @selector(duplicate:)||
                            menuItem.action == @selector(delete:));
    BOOL needsSelection = (menuItem.action == @selector(cut:)||
                           menuItem.action == @selector(copy:)||
                           menuItem.action == @selector(duplicate:)||
                           menuItem.action == @selector(delete:)||
                           menuItem.action == @selector(invertSelection:));
    BOOL needsPasteboardContent = (menuItem.action == @selector(paste:));
    BOOL mayChangeDocument = !_document.isInViewingMode;
    BOOL hasSelection = (_outlineView.selectedRow != -1);
    BOOL hasPasteboardContent = ([[NSPasteboard generalPasteboard] dataForType:self.pasteboardType] != nil);
    if (changesDocument&&!mayChangeDocument) {
        return NO;
    }else if (needsSelection&&!hasSelection) {
        return NO;
    }else if (needsSelection&&_outlineView.numberOfSelectedRows == 1&&[[_outlineView itemAtRow:_outlineView.selectedRow] isKindOfClass:[LynProject class]]) {
        return NO;
    }else if (needsPasteboardContent&&!hasPasteboardContent) {
        return NO;
    }else{
        return YES;
    }
}

@end
