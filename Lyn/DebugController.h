//
//  DebugController.h
//  Lyn
//
//  Created by Programmieren on 12.08.13.
//  Copyright (c) 2013 Arne Philipeit Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Lyn Framework/Lyn Framework.h>
#import <Lyn Kit/Lyn Kit.h>
#import "LynRunnerScript.h"

@interface DebugController : NSObject <LynRunnerDebugDelegate>

@property LynProject *project;
@property NSDocument *document;

@property (readonly) BOOL isRunning;

@property IBOutlet NSButton *btnRun;

- (void)run;
- (void)stop;

- (IBAction)pushedRun:(id)sender;

@end
