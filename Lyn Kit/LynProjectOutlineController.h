//
//  LynProjectOutlineController.h
//  Lyn
//
//  Created by Programmieren on 28.06.13.
//  Copyright (c) 2013 Arne Philipeit Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Lyn Framework/LynCodeObjects.h>
#import "LynOutlineController.h"
#import "LynEditorView.h"
#import "LynInspectorView.h"

@interface LynProjectOutlineController : LynOutlineController <NSOutlineViewDataSource, NSOutlineViewDelegate>

@property LynProject *project;

@property LynInspectorView *inspectorView;
@property IBOutlet LynEditorView *editorView;

- (void)selectObject:(LynOutlineObject *)object;

- (IBAction)selectedObject:(id)sender;

- (IBAction)nameChanged:(id)sender;

- (IBAction)pushedAddFolder:(id)sender;
- (IBAction)pushedAddClass:(id)sender;

- (IBAction)exportClass:(id)sender;
- (IBAction)importClass:(id)sender;

@end
