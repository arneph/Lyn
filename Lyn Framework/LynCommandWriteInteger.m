//
//  LynCommandWriteInteger.m
//  Lyn
//
//  Created by Programmieren on 09.11.13.
//  Copyright (c) 2013 Arne Philipeit Software. All rights reserved.
//

#import "LynCommandWriteInteger.h"

@implementation LynCommandWriteInteger

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
    self = [super initWithAllowedClass:allowedClass andCoder:aDecoder];
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
    LynCommandWriteInteger *copiedCommandWriteInteger = [super copyWithZone:nil];
    return copiedCommandWriteInteger;
}

- (NSArray *)warnings{
    NSMutableArray *warnings = [[NSMutableArray alloc] init];
    LynParameterInteger *integerParameter = (LynParameterInteger*)[self ownParameterNamed:@"Integer"];
    if (integerParameter.isDynamicValueNotSpecified) {
        [warnings addObject:[[LynWarning alloc] initWithObject:self
                                                andMessageText:@"There is no specified Variable."]];
    }
    return [NSArray arrayWithArray:warnings];
}

- (void)parameterValueChanged:(NSNotification *)notification{
    if (EditMode) {
        [NotificationCenter postNotificationName:LynOutlineObjectNumberOfWarningsChangedNotification
                                          object:self];
    }
    [super parameterValueChanged:notification];
}

- (void)parameterValueDescriptionChanged: (NSNotification*)notification{
    if (EditMode) {
        [NotificationCenter postNotificationName:LynCommandSummaryChangedNotification
                                          object:self];
    }
    [super parameterValueDescriptionChanged:notification];
}

+ (NSString *)name{
    return @"Write Integer";
}

+ (NSString *)description{
    return @"Writes an Integer.";
}

- (NSString *)summary{
    LynParameterInteger *integerParameter = (LynParameterInteger*)[self ownParameterNamed:@"Integer"];
    NSString *integerParameterDescription = [integerParameter parameterValueDescription];
    return [NSString stringWithFormat:@"Write Integer: %@", integerParameterDescription];
}

+ (NSArray *)parameters{
    LynParameterInteger *integerParameter = [[LynParameterInteger alloc] initWithName:@"Integer" owner:nil];
    integerParameter.fillType = LynParameterFillTypeStatic;
    integerParameter.parameterValue = @1;
    return @[integerParameter];
}

- (void)executeWithDelegate:(id<LynExecutionDelegate>)delegate{
    [delegate write:((NSNumber*)[self ownParameterNamed:@"Integer"].absoluteValue).stringValue];
    [delegate finishedExecution:self];
}

@end
