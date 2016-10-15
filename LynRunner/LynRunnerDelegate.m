//
//  LynRunnerDelegate.m
//  Lyn
//
//  Created by Programmieren on 11.08.13.
//  Copyright (c) 2013 Arne Philipeit Software. All rights reserved.
//

#import "LynRunnerDelegate.h"

@implementation LynRunnerDelegate

- (void)applicationWillFinishLaunching:(NSNotification *)notification{
    [LynGeneral setCurrentMode:LynModeRunning];
    [NSUserNotificationCenter defaultUserNotificationCenter].delegate = self;
}

- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center
     shouldPresentNotification:(NSUserNotification *)notification{
    return YES;
}

@end
