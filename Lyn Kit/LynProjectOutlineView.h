//
//  LynProjectOutlineView.h
//  Lyn
//
//  Created by Programmieren on 28.06.13.
//  Copyright (c) 2013 Arne Philipeit Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Lyn Framework/LynCodeObjects.h>
#import "LynEditorView.h"
#import "LynInspectorView.h"

@interface LynProjectOutlineView : NSView <LynUtilityViewDelegate>

@property LynProject *shownProject;

@property IBOutlet LynEditorView *editorView;
@property IBOutlet LynInspectorView *inspectorView;

@property IBOutlet NSDocument *document;

- (void)focus;

@end
