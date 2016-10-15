//
//  LynOutlineController.h
//  Lyn
//
//  Created by Programmieren on 28.04.13.
//  Copyright (c) 2013 Arne Philipeit Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Lyn Framework/LynCodeObjects.h>

#define LynOutlineItemsPasteboardType @"de.AP-Software.Lyn_Framework.LynOutlineItemsPasteboardType"
#define LynOutlineItemsDragType @"de.AP-Software.Lyn_Framework.LynOutlineItemsDragType"

@interface LynOutlineController : NSResponder <NSOutlineViewDataSource, NSOutlineViewDelegate>

@property IBOutlet NSOutlineView *outlineView;

@property LynOutlineObject *rootObject;
@property BOOL showRootObject;

@property Class lowestHierarchyClass;

@property IBOutlet NSDocument *document;

- (void)selectObject: (LynOutlineObject*)object;
- (void)selectObjects: (NSArray*)objects;

- (void)addSubObjectAtSuggestedPossition: (LynOutlineObject*)subObject;
- (void)addSubObjectsAtSuggestedPossition: (NSArray*)subObjects;
- (void)addSubObject: (LynOutlineObject*)subObject toObject: (LynOutlineObject*)object;
- (void)addSubObjects: (NSArray*)subObjects toObject: (LynOutlineObject*)object;
- (void)addSubObject: (LynOutlineObject*)subObject toObject: (LynOutlineObject*)object atIndex: (NSUInteger)index;
- (void)addSubObjects: (NSArray*)subObjects toObject: (LynOutlineObject*)object atIndex: (NSUInteger)index;
- (void)addSubObjects: (NSArray*)subObjects toObject: (LynOutlineObject*)object atIndexes: (NSArray*)indexess;
- (void)addSubObjects: (NSArray*)subObjects toObjects: (NSArray*)objects atIndex: (NSUInteger)index;
- (void)addSubObjects: (NSArray*)subObjects toObjects: (NSArray*)objects atIndexes: (NSArray*)indexes;

- (void)removeSubObjects: (NSArray*)subObjects;
- (void)removeSubObjects: (NSArray*)subObjects fromObjects: (NSArray*)objects;

- (void)renameSubObject: (LynOutlineObject*)subObject newName: (NSString*)newName;

- (NSString *)dragType;
- (NSString *)pasteboardType;

- (BOOL)canCut;
- (BOOL)canCopy;
- (BOOL)canPaste;
- (BOOL)canDelete;

- (IBAction)cut:(id)sender;
- (IBAction)copy:(id)sender;
- (IBAction)paste:(id)sender;
- (IBAction)duplicate:(id)sender;
- (IBAction)delete:(id)sender;

@end
