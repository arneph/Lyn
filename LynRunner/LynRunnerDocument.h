//
//  LynRunnerDocument.h
//  Lyn
//
//  Created by Programmieren on 28.04.13.
//  Copyright (c) 2013 Arne Philipeit Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Lyn Framework/Lyn Framework.h>
#import <Lyn Kit/Lyn Kit.h>
#import "PreferencesController.h"

@interface LynRunnerScriptable : LynRunner

@property NSScriptObjectSpecifier *containerSpecifier;

@end

@interface LynRunnerDocument : NSDocument <LynRunnerConsoleViewDelegate>

@property (readonly) LynProject *project;
@property (readonly) LynRunner *runner;

@property IBOutlet LynRunnerConsoleView *consoleView;

@property IBOutlet NSToolbarItem *itemRun;
@property IBOutlet NSProgressIndicator *runningIndicator;

- (IBAction)pushedRun:(id)sender;

@end
