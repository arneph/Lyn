//
//  LynCommandPlaySound.m
//  Lyn
//
//  Created by Programmieren on 27.09.13.
//  Copyright (c) 2013 Arne Philipeit Software. All rights reserved.
//

#import "LynCommandPlaySound.h"

@implementation LynCommandPlaySound

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
    LynCommandPlaySound *copiedCommandPlaySound = [super copyWithZone:nil];
    return copiedCommandPlaySound;
}

- (NSArray *)warnings{
    NSMutableArray *warnings = [[NSMutableArray alloc] init];
    LynParameterString *soundParameter = (LynParameterString*)[self ownParameterNamed:@"Sound Name"];
    if (soundParameter.isStaticValueEmpty) {
        [warnings addObject:[[LynWarning alloc] initWithObject:self
                                                andMessageText:@"There is no specified sound."]];
    }else if (soundParameter.isDynamicValueNotSpecified) {
        [warnings addObject:[[LynWarning alloc] initWithObject:self
                                                andMessageText:@"There is no specified Variable."]];
    }
    LynParameterInteger *volumeParameter = (LynParameterInteger*)[self ownParameterNamed:@"Volume"];
    if (volumeParameter.isStaticValueNegative) {
        [warnings addObject:[[LynWarning alloc] initWithObject:self
                                                andMessageText:@"Sound Volume can't be negative."]];
    }else if ([volumeParameter isStaticValueGreaterThan:@1.0]) {
        [warnings addObject:[[LynWarning alloc] initWithObject:self
                                                andMessageText:@"Sound Volume has a maximum of 1."]];
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
    return @"Play Sound";
}

+ (NSString *)description{
    return @"Tries to play a system sound referd by name.";
}

- (NSString *)summary{
    LynParameterString *soundParameter = (LynParameterString*)[self ownParameterNamed:@"Sound Name"];
    LynParameterInteger *volumeParameter = (LynParameterInteger*)[self ownParameterNamed:@"Volume"];
    LynParameterBoolean *completionParameter = (LynParameterBoolean*)[self ownParameterNamed:@"Complete"];
    NSString *soundParameterDescription = [soundParameter parameterValueDescription];
    NSString *volumeParameterDescription = [volumeParameter parameterValueDescription];
    NSString *completionParameterDescription = [completionParameter parameterValueDescription];
    if (volumeParameter.fillType != LynParameterFillTypeStatic||
        ((NSNumber*)volumeParameter.parameterValue).doubleValue != 1.0) {
        return [NSString stringWithFormat:@"Play Sound: %@ at Volume: %@ Complete: %@",
                                          soundParameterDescription,
                                          volumeParameterDescription,
                                          completionParameterDescription];
    }
    return [NSString stringWithFormat:@"Play Sound: %@ Complete: %@", soundParameterDescription, completionParameterDescription];
}

+ (NSArray *)parameters{
    LynParameterString *soundParameter = [[LynParameterString alloc] initWithName:@"Sound Name" owner:nil];
    soundParameter.fillType = LynParameterFillTypeStatic;
    soundParameter.parameterValue = @"Submarine";
    LynParameterInteger *volumeParameter = [[LynParameterInteger alloc] initWithName:@"Volume" owner:nil];
    volumeParameter.fillType = LynParameterFillTypeStatic;
    volumeParameter.parameterValue = @1.0;
    LynParameterBoolean *completionParameter = [[LynParameterBoolean alloc] initWithName:@"Complete" owner:nil];
    completionParameter.fillType = LynParameterFillTypeStatic;
    completionParameter.parameterValue = @NO;
    return @[soundParameter, volumeParameter, completionParameter];
}

- (void)executeWithDelegate:(id<LynExecutionDelegate>)delegate{
    NSString *sound = (NSString*)[self ownParameterNamed:@"Sound Name"].absoluteValue;
    NSNumber *volume = (NSNumber*)[self ownParameterNamed:@"Volume"].absoluteValue;
    BOOL complete = ((NSNumber*)[self ownParameterNamed:@"Complete"].absoluteValue).boolValue;
    if (volume.floatValue > 1.0||volume.floatValue < 0.0) volume = @1.0;
    [delegate playSound:sound atVolume: volume.floatValue complete:complete];
    [delegate finishedExecution:self];
}

@end
