//
//  LynEditorView.h
//  Lyn
//
//  Created by Programmieren on 28.06.13.
//  Copyright (c) 2013 Arne Philipeit Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Lyn Framework/LynCodeObjects.h>
#import "LynProjectView.h"
#import "LynClassView.h"
#import "LynInspectorView.h"

@interface LynEditorView : NSView <LynUtilityViewDelegate>

@property LynProject *project;

@property IBOutlet LynInspectorView *inspectorView;
@property IBOutlet NSDocument *document;

@property IBOutlet id <LynUtilityViewDelegate> delegate;

- (id)shownObject;
- (void)setShownObject: (id)shownObject;

- (NSArray*)historyOfShownObjects;
- (NSUInteger)indexOfShownObjectInHistory;

- (BOOL)canGoBack;
- (BOOL)canGoForward;

- (void)goBack;
- (void)goForward;

- (IBAction)goBack:(id)sender;
- (IBAction)goForward:(id)sender;

- (LynProjectView *)projectView;
- (LynClassView *)classView;

- (void)focus;

@end
