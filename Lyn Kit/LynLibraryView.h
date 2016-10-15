//
//  LynLibraryView.h
//  Lyn
//
//  Created by Programmieren on 17.08.13.
//  Copyright (c) 2013 Arne Philipeit Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Lyn Framework/LynCodeObjects.h>
#import "LynProjectSettingsManager.h"

@interface LynLibraryView : NSView

@property LynProject *project;

@property IBOutlet NSDocument *document;

@end
