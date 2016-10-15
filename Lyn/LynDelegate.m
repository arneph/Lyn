//
//  LynDelegate.m
//  Lyn
//
//  Created by Programmieren on 20.08.13.
//  Copyright (c) 2013 Arne Philipeit Software. All rights reserved.
//

#import "LynDelegate.h"

@implementation LynDelegate

- (void)applicationWillFinishLaunching:(NSNotification *)notification{
    [LynGeneral setCurrentMode:LynModeEditing];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *data = [defaults dataForKey:@"de.AP-Softare.Lyn.Settings"];
    [LynGeneral setSettings:[NSKeyedUnarchiver unarchiveObjectWithData:data]];
}

- (void)applicationWillTerminate:(NSNotification *)notification{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:[LynGeneral settings]];
    [defaults setObject:data forKey:@"de.AP-Softare.Lyn.Settings"];
}

@end
