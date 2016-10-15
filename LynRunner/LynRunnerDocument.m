//
//  LynRunnerDocument.m
//  Lyn
//
//  Created by Programmieren on 28.04.13.
//  Copyright (c) 2013 Arne Philipeit Software. All rights reserved.
//

#import "LynRunnerDocument.h"

@implementation LynRunnerScriptable

- (NSScriptObjectSpecifier *)objectSpecifier{
    NSScriptObjectSpecifier *specifier = [[NSScriptObjectSpecifier alloc] initWithContainerSpecifier:_containerSpecifier
                                                                                                 key:@"Runner"];
    return specifier;
}

@end

@implementation LynRunnerDocument
@synthesize runner;

- (id)init{
    self = [super init];
    if (self) {
        [NotificationCenter addObserver:self
                               selector:@selector(preferencesChanged:)
                                   name:LynRunnerPreferencesChangedNotification
                                 object:nil];
    }
    return self;
}

- (void)awakeFromNib{
    if (_consoleView) {
        _consoleView.project = _project;
        _consoleView.warnOnOpeningApplication = WarnOnOpeningApplications;
        _consoleView.warnOnOpeningFile = WarnOnOpeningFiles;
        _consoleView.warnOnOpeningFileWithApplication = WarnOnOpeningFilesWithApplications;
        _consoleView.indentProgrammOutput = IndentProgrammOutput;
        _consoleView.programmOutputFont = ProgrammOutputFont;
        _consoleView.indentRunnerOutput = IndentRunnerOutput;
        _consoleView.runnerOutputFont = RunnerOutputFont;
    }
}

- (NSString *)windowNibName{
    return @"LynRunner";
}

- (void)windowControllerDidLoadNib:(NSWindowController *)aController{
    [super windowControllerDidLoadNib:aController];
    if (AutomaticallyStartAfterOpening) {
        _itemRun.image = [NSImage imageNamed:NSImageNameRightFacingTriangleTemplate];
        [_consoleView start];
    }
}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError{
    _project = [LynProject projectFromData:data];
    _consoleView.project = _project;
    return YES;
}

- (LynRunner *)runner{
    return _consoleView.runner;
}

- (void)preferencesChanged: (NSNotification*)notification{
    if (_consoleView) {
        _consoleView.project = _project;
        _consoleView.warnOnOpeningApplication = WarnOnOpeningApplications;
        _consoleView.warnOnOpeningFile = WarnOnOpeningFiles;
        _consoleView.warnOnOpeningFileWithApplication = WarnOnOpeningFilesWithApplications;
        _consoleView.indentProgrammOutput = IndentProgrammOutput;
        _consoleView.programmOutputFont = ProgrammOutputFont;
        _consoleView.indentRunnerOutput = IndentRunnerOutput;
        _consoleView.runnerOutputFont = RunnerOutputFont;
    }
}

- (void)reload{
    [self readFromURL:self.fileURL ofType:self.fileType error:nil];
    if (ClearConsoleBeforeReload) [_consoleView clear];
    [_consoleView start];
}

- (void)startedExecuting{
    _itemRun.image = [NSImage imageNamed:NSImageNameStopProgressFreestandingTemplate];
    [_runningIndicator startAnimation:nil];
}

- (void)stoppedExecuting{
    _itemRun.image = [NSImage imageNamed:NSImageNameRightFacingTriangleTemplate];
    [_runningIndicator stopAnimation:nil];
}

- (void)finishedExecuting{
    _itemRun.image = [NSImage imageNamed:NSImageNameRefreshFreestandingTemplate];
    [_runningIndicator stopAnimation:nil];
}

- (void)pushedRun:(id)sender{
    if (self.runner.running) {
        [_consoleView stop];
    }else{
        if ([_itemRun.image isEqual:[NSImage imageNamed:NSImageNameRefreshFreestandingTemplate]]) {
            [self reload];
        }else{
            [_consoleView start];
        }
    }
}

- (void)settingChanged:(NSString *)key{
    if ([key isEqualToString:@"warnOnOpeningApplication"]) {
        [PreferencesController setWarnOnOpeningApplications:_consoleView.warnOnOpeningApplication];
    }else if ([key isEqualToString:@"warnOnOpeningFile"]) {
        [PreferencesController setWarnOnOpeningFiles:_consoleView.warnOnOpeningFile];
    }else if ([key isEqualToString:@"warnOnOpeningFileWithApplication"]) {
        [PreferencesController setWarnOnOpeningFilesWithApplications:_consoleView.warnOnOpeningFileWithApplication];
    }
}

- (void)enteredCommand:(NSString *)command{
    if ([command isEqualToString:@"easteregg"]) {
        [_consoleView writeByRunner:@"You just found an easteregg! Congratulations."];
    }
}

- (void)handleStart:(NSScriptCommand *)commad{
    [_consoleView start];
}

- (void)handleStop:(NSScriptCommand *)commad{
    [_consoleView stop];
}

- (void)handleReload:(NSScriptCommand *)commad{
    [self reload];
}

- (id)valueForKey:(NSString *)key{
    if ([key isEqualToString:@"runner"]) {
        return self.runner;
    }else{
        return [super valueForKey:key];
    }
}

@end
