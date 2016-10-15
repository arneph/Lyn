//
//  LynClassOutlineController.h
//  Lyn
//
//  Created by Programmieren on 23.06.13.
//  Copyright (c) 2013 Arne Philipeit Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Lyn Framework/LynCodeObjects.h>
#import "LynClassRowView.h"
#import "LynInspectorView.h"
#import "LynProjectSettingsManager.h"

@interface LynClassOutlineController : NSResponder <NSOutlineViewDataSource, NSOutlineViewDelegate>

@property LynClass *shownClass;
@property LynInspectorView *inspectorView;

@property IBOutlet NSOutlineView *outlineView;
@property NSDocument *document;

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

- (void)renameFunction: (LynFunction*)function newName: (NSString*)newName;

- (IBAction)nameChanged:(id)sender;
- (IBAction)commentChanged:(id)sender;

- (IBAction)addFunction:(id)sender;
- (IBAction)addMainFunction:(id)sender;

- (IBAction)moveSelectionUp:(id)sender;
- (IBAction)moveSelectionDown:(id)sender;

@end
