//
//  LynCommandWait.m
//  Lyn
//
//  Created by Programmieren on 31.07.13.
//  Copyright (c) 2013 Arne Philipeit Software. All rights reserved.
//

#import "LynCommandWait.h"

@implementation LynCommandWait{
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
    LynCommandWait *copiedCommandWait = [super copyWithZone:nil];
    return copiedCommandWait;
}

- (NSArray *)warnings{
    NSMutableArray *warnings = [[NSMutableArray alloc] init];
    LynParameterInteger *timeParameter = (LynParameterInteger*)[self ownParameterNamed:@"Time"];
    if ([timeParameter isStaticValueLessThan:@0.1]) {
        [warnings addObject:[[LynWarning alloc] initWithObject:self
                                                andMessageText:@"The specified static time is to low. The minimum is 0.1."]];
    }else if ([timeParameter isStaticValueGreaterThan:@600]) {
        [warnings addObject:[[LynWarning alloc] initWithObject:self
                                                andMessageText:@"The specified static time is to low. The maximum is 600."]];
    }else if (timeParameter.isDynamicValueNotSpecified) {
        [warnings addObject:[[LynWarning alloc] initWithObject:self
                                                andMessageText:@"There is no specified Variable."]];
    }
    return [NSArray arrayWithArray:warnings];
}

- (void)parameterValueChanged: (NSNotification*)notification{
    if (EditMode) {
        [NotificationCenter postNotificationName:LynOutlineObjectNumberOfWarningsChangedNotification
                                          object:self];
    }
    [super parameterValueChanged:notification];
}

- (void)parameterValueDescriptionChanged:(NSNotification *)notification{
    if (EditMode) {
        [NotificationCenter postNotificationName:LynCommandSummaryChangedNotification
                                          object:self];
    }
    [super parameterValueDescriptionChanged:notification];
}

+ (NSString *)name{
    return @"Wait";
}

+ (NSString *)description{
    return @"Makes the programm wait x seconds before continuing.";
}

- (NSString *)summary{
    LynParameterInteger *timeParameter = (LynParameterInteger*)[self ownParameterNamed:@"Time"];
    NSString *timeParameterDescription = timeParameter.parameterValueDescription;
    return [NSString stringWithFormat:@"Wait: %@ Second(s)", timeParameterDescription];
}

+ (NSArray *)parameters{
    LynParameterInteger *timeParameter = [[LynParameterInteger alloc] initWithName:@"Time" owner:nil];
    timeParameter.fillType = LynParameterFillTypeStatic;
    timeParameter.parameterValue = @1.0;
    return @[timeParameter];
}

- (void)executeWithDelegate:(id<LynExecutionDelegate>)del{
    if ([del canUseTimers]) {
        [timer invalidate];
        timer = nil;
        delegate = nil;
    }
    LynParameterInteger *timeParameter = (LynParameterInteger*)[self ownParameterNamed:@"Time"];
    double time = timeParameter.absoluteNumberValue.doubleValue;
    if (time < 0.1||time > 600) {
        [del finishedExecution:self];
        return;
    }
    if ([del canUseTimers]) {
        timer = [NSTimer scheduledTimerWithTimeInterval:time
                                                 target:self
                                               selector:@selector(timerEnded)
                                               userInfo:nil
                                                repeats:NO];
        delegate = del;
    }else{
        [del write:@"\nTimers are disable, thus 'Wait' commands don't work!\n"];
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
