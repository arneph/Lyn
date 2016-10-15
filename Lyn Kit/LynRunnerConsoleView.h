//
//  LynRunnerConsoleView.h
//  Lyn
//
//  Created by Programmieren on 19.10.13.
//  Copyright (c) 2013 Arne Philipeit Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Lyn Framework/Lyn Framework.h>

@protocol LynRunnerConsoleViewDelegate <NSObject>

- (void)startedExecuting;
- (void)stoppedExecuting;
- (void)finishedExecuting;

- (void)reload;
- (void)enteredCommand: (NSString*)command;

- (void)settingChanged: (NSString*)key;

@end

@interface LynRunnerConsoleView : NSView <LynRunnerDelegate>

@property LynProject *project;
@property (readonly) LynRunner *runner;

@property IBOutlet id<LynRunnerConsoleViewDelegate> delegate;

@property BOOL warnOnOpeningApplication;
@property BOOL warnOnOpeningFile;
@property BOOL warnOnOpeningFileWithApplication;

@property BOOL indentProgrammOutput;
@property NSFont *programmOutputFont;
@property BOOL indentRunnerOutput;
@property NSFont *runnerOutputFont;

- (void)start;
- (void)stop;
- (void)reload;
- (void)clear;

- (IBAction)startRunning:(id)sender;
- (IBAction)stopRunning:(id)sender;
- (IBAction)reload:(id)sender;
- (IBAction)clearConsole:(id)sender;

@end
