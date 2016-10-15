//
//  LynCommands.m
//  Lyn
//
//  Created by Programmieren on 17.08.13.
//  Copyright (c) 2013 Arne Philipeit Software. All rights reserved.
//

#import "LynCommands.h"

NSArray *commands;

@implementation LynCommands

+ (void)initialize{
    if (commands) return;
    NSArray *comments = @[[[LynComment alloc] init]];
    NSArray *calls = @[[[LynCommandCallFunction alloc] init]];
    NSArray *branches = @[[[LynCommandIf alloc] init],
                          [[LynCommandForLoop alloc] init],
                          [[LynCommandWhileLoop alloc] init]];
    NSArray *open = @[[[LynCommandOpenApplication alloc] init],
                      [[LynCommandOpenFile alloc] init],
                      [[LynCommandOpenFileWithApplication alloc] init]];
    NSArray *notifications = @[[[LynCommandPostNotification alloc] init]];
    NSArray *sound = @[[[LynCommandPlaySound alloc] init]];
    NSArray *wait = @[[[LynCommandWait alloc] init],
                      [[LynCommandWaitOneSecond alloc] init]];
    NSArray *scan = @[[[LynCommandScanBoolean alloc] init],
                      [[LynCommandScanInteger alloc] init],
                      [[LynCommandScanString alloc] init]];
    NSArray *write = @[[[LynCommandWriteInteger alloc] init],
                       [[LynCommandWriteString alloc] init],
                       [[LynCommandWriteLineBreak alloc] init]];
    commands = @[comments, calls, branches, open, notifications, sound, wait, scan, write];
}

+ (NSArray *)commands{
    if (!commands) [LynCommands initialize];
    NSMutableArray *allCommands = [[NSMutableArray alloc] init];
    for (NSArray *array in commands) {
        [allCommands addObjectsFromArray:array];
    }
    return [NSArray arrayWithArray:allCommands];
}

+ (NSUInteger)numberOfGroups{
    if (!commands) [LynCommands initialize];
    return commands.count;
}

+ (NSArray*)groups{
    if (!commands) [LynCommands initialize];
    return commands;
}

+ (NSString *)nameOfGroup:(NSUInteger)index{
    if (index == 0) {
        return @"Comments";
    }else if (index == 1) {
        return @"Calls";
    }else if (index == 2) {
        return @"Branches";
    }else if (index == 3) {
        return @"Open";
    }else if (index == 4) {
        return @"Notifications";
    }else if (index == 5) {
        return @"Sound";
    }else if (index == 6) {
        return @"Wait";
    }else if (index == 7) {
        return @"Scan";
    }else if (index == 8) {
        return @"Write";
    }else{
        return nil;
    }
}

+ (NSArray *)memebersOfGroup: (NSUInteger)index{
    if (!commands) [LynCommands initialize];
    if (index >= commands.count) return nil;
    return commands[index];
}

@end
