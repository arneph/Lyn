//
//  PrefrencesController.h
//  Lyn
//
//  Created by Programmieren on 19.08.13.
//  Copyright (c) 2013 Arne Philipeit Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#define LynRunnerPreferencesChangedNotification @"LynRunnerPreferencesChangedNotification"

#define AutomaticallyStartAfterOpening [PreferencesController automaticallyStartAfterOpening]
#define ClearConsoleBeforeReload [PreferencesController clearConsoleBeforeReload]

#define WarnOnOpeningApplications [PreferencesController warnOnOpeningApplications]
#define WarnOnOpeningFiles [PreferencesController warnOnOpeningFiles]
#define WarnOnOpeningFilesWithApplications [PreferencesController warnOnOpeningFilesWithApplications]

#define RunnerOutputFont [PreferencesController runnerOutputFont]
#define IndentRunnerOutput [PreferencesController indentRunnerOutput]
#define ProgrammOutputFont [PreferencesController programmOutputFont]
#define IndentProgrammOutput [PreferencesController indentProgrammOutput]

@interface PreferencesController : NSWindowController

+ (void)stopSendingChangeNotifications;
+ (void)continueSendingChangedNotificationsWithNotification: (BOOL)sendChangeNotfication;

+ (BOOL)automaticallyStartAfterOpening;
+ (void)setAutomaticallyStartAfterOpening: (BOOL)autoStart;

+ (BOOL)clearConsoleBeforeReload;
+ (void)setClearConsoleBeforeReload: (BOOL)clear;

+ (BOOL)warnOnOpeningApplications;
+ (void)setWarnOnOpeningApplications: (BOOL)warn;

+ (BOOL)warnOnOpeningFiles;
+ (void)setWarnOnOpeningFiles: (BOOL)warn;

+ (BOOL)warnOnOpeningFilesWithApplications;
+ (void)setWarnOnOpeningFilesWithApplications: (BOOL)warn;

+ (NSFont*)runnerOutputFont;
+ (void)setRunnerOutputFont: (NSFont*)font;

+ (BOOL)indentRunnerOutput;
+ (void)setIndentRunnerOutput: (BOOL)indent;

+ (NSFont*)programmOutputFont;
+ (void)setProgrammOutputFont: (NSFont*)font;

+ (BOOL)indentProgrammOutput;
+ (void)setIndentProgrammOutput: (BOOL)indent;

@end
