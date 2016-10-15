//
//  LynWarningsView.h
//  Lyn
//
//  Created by Programmieren on 10.07.13.
//  Copyright (c) 2013 Arne Philipeit Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Lyn Framework/LynCodeObjects.h>
#import "LynUtilityViewDelegate.h"

@interface LynWarningsView : NSView

@property LynProject *project;

@property BOOL showWarnings;
@property BOOL showErrors;

@property IBOutlet NSDocument *document;
@property IBOutlet id <LynUtilityViewDelegate> delegate;

@end
