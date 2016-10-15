//
//  LynCommandWaitOneSecond.m
//  Lyn
//
//  Created by Programmieren on 15.06.13.
//  Copyright (c) 2013 Arne Philipeit Software. All rights reserved.
//

#import "LynCommandWaitOneSecond.h"

@implementation LynCommandWaitOneSecond{
    NSTimer *timer;
    id <LynExecutionDelegate> delegate;
}

- (id)init{
    self = [super init];
    if (self) {
    }
    return self;
}

- (id)initWithAllowedClass:(Class)allowedClass{
    self = [super init];
    if (self) {
    }
    return self;
}

- (id)initWithAllowedClass:(Class)allowedClass andCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [super encodeWithCoder:aCoder];
}

- (id)copyWithZone:(NSZone *)zone{
    LynCommandWaitOneSecond *copiedCommandWaitOneSecond = [super copyWithZone:nil];
    return copiedCommandWaitOneSecond;
}

+ (NSString *)name{
    return @"Wait 1 Second";
}

+ (NSString *)description{
    return @"Makes the programm wait 1 second before continuing.";
}

- (NSString *)summary{
    return @"Wait 1 Second";
}

- (void)executeWithDelegate:(id<LynExecutionDelegate>)del{
    [timer invalidate];
    timer = nil;
    delegate = nil;
    if ([del canUseTimers]) {
        timer = [NSTimer scheduledTimerWithTimeInterval:1
                                                 target:self
                                               selector:@selector(timerEnded)
                                               userInfo:nil
                                                repeats:NO];
        delegate = del;
    }else{
        sleep(1);
        [del finishedExecution:self];
    }
}

- (void)timerEnded{
    [timer invalidate];
    timer = nil;
    [delegate finishedExecution:self];
    delegate = nil;
}

@end
