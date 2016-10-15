//
//  LynClassView.h
//  Lyn
//
//  Created by Programmieren on 23.06.13.
//  Copyright (c) 2013 Arne Philipeit Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Lyn Framework/LynCodeObjects.h>
#import "LynInspectorView.h"

#define LynClassViewSelectedObjectChangedNotification @"LynClassViewSelectedObjectChangedNotification"

@interface LynClassView : NSView <LynUtilityViewDelegate>

@property LynClass *shownClass;

@property IBOutlet LynInspectorView *inspectorView;
@property IBOutlet NSDocument *document;

- (void)focus;
- (LynOutlineObject*)selectedObject;

@end
