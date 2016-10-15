//
//  LynProjectView.h
//  Lyn
//
//  Created by Programmieren on 28.06.13.
//  Copyright (c) 2013 Arne Philipeit Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Lyn Framework/LynCodeObjects.h>
#import "LynProjectSettingsManager.h"
#import "LynInspectorView.h"

@interface LynProjectView : NSView

@property LynProject *shownProject;

@property IBOutlet LynInspectorView *inspectorView;
@property IBOutlet NSDocument *document;

- (void)focus;

@end
