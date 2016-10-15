//
//  LynCommandWriteString.m
//  Lyn
//
//  Created by Programmieren on 28.04.13.
//  Copyright (c) 2013 Arne Philipeit Software. All rights reserved.
//

#import "LynCommandWriteString.h"

@implementation LynCommandWriteString

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
    LynCommandWriteString *copiedCommandWriteString = [super copyWithZone:nil];
    return copiedCommandWriteString;
}

- (NSArray *)warnings{
    NSMutableArray *warnings = [[NSMutableArray alloc] init];
    LynParameterString *stringParameter = (LynParameterString*)[self ownParameterNamed:@"String"];
    if (stringParameter.isStaticValueEmpty) {
        [warnings addObject:[[LynWarning alloc] initWithObject:self
                                                andMessageText:@"The specified static string is empty."]];
    }else if (stringParameter.isDynamicValueNotSpecified) {
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
    return @"Write String";
}

+ (NSString *)description{
    return @"Writes a specified string.";
}

- (NSString *)summary{
    LynParameterString *stringParameter = (LynParameterString*)[self ownParameterNamed:@"String"];
    NSString *stringParameterDescription = [stringParameter parameterValueDescription];
    return [NSString stringWithFormat:@"Write String: %@", stringParameterDescription];
}

+ (NSArray *)parameters{
    LynParameterString *stringParameter = [[LynParameterString alloc] initWithName:@"String" owner:nil];
    stringParameter.fillType = LynParameterFillTypeStatic;
    stringParameter.parameterValue = @"Hello World!";
    return @[stringParameter];
}

- (void)executeWithDelegate:(id<LynExecutionDelegate>)delegate{
    [delegate write:(NSString*)[self ownParameterNamed:@"String"].absoluteValue];
    [delegate finishedExecution:self];
}

@end
