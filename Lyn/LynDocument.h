//
//  LynDocument.h
//  Lyn
//
//  Created by Programmieren on 27.04.13.
//  Copyright (c) 2013 Arne Philipeit Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Lyn Kit/Lyn Kit.h>
#import "DebugController.h"
#import "StatusView.h"

@interface LynDocument : NSDocument <NSSplitViewDelegate>

@property (readonly) LynProject *project;

@property IBOutlet DebugController *debugController;

@property IBOutlet StatusView *statusView;
@property IBOutlet NSToolbarItem *itmShowNavigator;
@property IBOutlet NSButton *btnShowNavigator;
@property IBOutlet NSToolbarItem *itmShowUtilities;
@property IBOutlet NSButton *btnShowUtilities;

@property IBOutlet NSSplitView *splitView;

@property IBOutlet NSView *navigatorsView;
@property IBOutlet NSButton *btnProjectNavigator;
@property IBOutlet NSButton *btnWarningsNavigator;
@property IBOutlet NSTabView *navigatorsTabView;
@property IBOutlet LynProjectOutlineView *projectOutlineView;
@property IBOutlet LynWarningsView *warningsView;

@property IBOutlet LynEditorView *editorView;

@property IBOutlet NSSplitView *utilitiesView;
@property IBOutlet LynInspectorView *inspectorView;
@property IBOutlet LynLibraryView *libraryView;

@property (readonly) BOOL showsNavigationArea;
@property (readonly) BOOL showsUtilitiesArea;

- (IBAction)showProjectNavigator:(id)sender;
- (IBAction)showWarningsNavigator:(id)sender;

- (IBAction)toggleNavigationArea:(id)sender;
- (IBAction)toggleUtilitiesArea:(id)sender;

- (IBAction)goBack:(id)sender;
- (IBAction)goForward:(id)sender;

- (IBAction)showHistory:(id)sender;
- (IBAction)showProject:(id)sender;

- (IBAction)focusNavigationArea:(id)sender;
- (IBAction)focusEditorArea:(id)sender;

@end
