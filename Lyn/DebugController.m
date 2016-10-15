//
//  DebugController.m
//  Lyn
//
//  Created by Programmieren on 12.08.13.
//  Copyright (c) 2013 Arne Philipeit Software. All rights reserved.
//

#import "DebugController.h"

@implementation DebugController{
    __block LynRunnerApplication *lynRunner;
    __block LynRunnerDocument *lynRunnerDocument;
    __block LynRunner *runner;
    
    dispatch_queue_t queue;
}


- (id)init{
    self = [super init];
    if (self) {
        queue = dispatch_queue_create("de.AP-Software.Lyn.Debuger", NULL);    }
    return self;
}

- (BOOL)prepareBridgedApplication{
    BOOL neededToPrepare = YES;
    for (NSRunningApplication *app in [NSWorkspace sharedWorkspace].runningApplications) {
        if ([app.bundleIdentifier isEqualToString:@"APS.LynRunner"]) {
            neededToPrepare = NO;
        }
    }
    if (!lynRunner) {
        lynRunner = [SBApplication applicationWithBundleIdentifier:@"APS.LynRunner"];
    }
    return neededToPrepare;
}

- (BOOL)prepareBridgedDocument{
    BOOL neededToPrepare = [self prepareBridgedApplication];
    
    lynRunnerDocument = nil;
    NSArray *fileURLArray = [[lynRunner documents] arrayByApplyingSelector:@selector(file)];
    for (NSURL *fileURL in fileURLArray) {
        if ([fileURL isEqualTo:_document.fileURL]) {
            lynRunnerDocument = [lynRunner documents][[fileURLArray indexOfObject:fileURL]];
        }
    }
    if (!lynRunnerDocument) {
        neededToPrepare = YES;
    }
    lynRunnerDocument = [lynRunner open:_document.fileURL];
    
    NSArray *documentsArray = [[lynRunner windows] arrayByApplyingSelector:@selector(document)];
    for (LynRunnerDocument *document in documentsArray) {
        if (document == lynRunnerDocument) {
            LynRunnerWindow *window = [lynRunner windows][[documentsArray indexOfObject:document]];
            [window setMiniaturized:NO];
            [window setVisible:YES];
        }
    }
    
    return neededToPrepare;
}

- (BOOL)prepareBridgedRunner{
    BOOL neededToPrepare = ([self prepareBridgedDocument]||!runner);
    if (!runner) {
        runner = (LynRunner*)[lynRunnerDocument runner];
    }
    return neededToPrepare;
}

- (BOOL)saveDocument{
    [_document saveDocument:nil];
    return (_document.fileURL != nil);
}

- (void)run{
    BOOL saved = [self saveDocument];
    if (!saved) return;
    dispatch_async(queue, ^{
        @try {
            BOOL forceReload = ![self prepareBridgedDocument];
            [lynRunner activate];
            if (forceReload) [lynRunnerDocument reload];
        }
        @catch (NSException *exception) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                NSAlert *alert = [NSAlert alertWithMessageText:@"An Error occured..."
                                                 defaultButton:@"Okay"
                                               alternateButton:nil
                                                   otherButton:nil
                                     informativeTextWithFormat:@"An error occured while Lyn tried to open LynRunner."];
                alert.icon = [NSImage imageNamed:NSImageNameCaution];
                [alert beginSheetModalForWindow:_btnRun.window
                                  modalDelegate:self
                                 didEndSelector:NULL
                                    contextInfo:NULL];
            });
        }
        @finally {
            
        }
    });
    _isRunning = YES;
}

- (void)stop{
    dispatch_async(dispatch_queue_create("de.AP-Software.Lyn", NULL), ^{
        [lynRunnerDocument stop];
    });
    _isRunning = NO;
}

#pragma mark LynRunner Debug Delegate

- (void)runnerDidStart{
    _isRunning = YES;
    [_btnRun setImage:[NSImage imageNamed:NSImageNameStopProgressFreestandingTemplate]];
}

- (void)runnerDidStop{
    _isRunning = NO;
    [_btnRun setImage:[NSImage imageNamed:NSImageNameRightFacingTriangleTemplate]];
}

- (void)runnerDidFinish{
    _isRunning = NO;
    [_btnRun setImage:[NSImage imageNamed:NSImageNameRightFacingTriangleTemplate]];
}

#pragma mark Actions

- (void)pushedRun:(id)sender{
    [self run];
}

@end
