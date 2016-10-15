//
//  LynCommandPostNotification.m
//  Lyn
//
//  Created by Programmieren on 06.12.13.
//  Copyright (c) 2013 Arne Philipeit Software. All rights reserved.
//

#import "LynCommandPostNotification.h"

@implementation LynCommandPostNotification

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
    LynCommandPostNotification *copiedCommandPostNotification = [super copyWithZone:nil];
    return copiedCommandPostNotification;
}

- (NSArray *)warnings{
    NSMutableArray *warnings = [[NSMutableArray alloc] init];
    LynParameterString *textParameter = (LynParameterString*)[self ownParameterNamed:@"Text"];
    if (textParameter.isStaticValueEmpty) {
        [warnings addObject:[[LynWarning alloc] initWithObject:self
                                                andMessageText:@"The specified static string is empty."]];
    }else if (textParameter.isDynamicValueNotSpecified) {
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
    return @"Post Notification";
}

+ (NSString *)description{
    return @"Posts a Notification in the Notification Center with a specified text.";
}

- (NSString *)summary{
    LynParameterString *textParameter = (LynParameterString*)[self ownParameterNamed:@"Text"];
    NSString *textParameterDescription = [textParameter parameterValueDescription];
    return [NSString stringWithFormat:@"Post Notification: %@", textParameterDescription];
}

+ (NSArray *)parameters{
    LynParameterString *textParameter = [[LynParameterString alloc] initWithName:@"Text" owner:nil];
    textParameter.fillType = LynParameterFillTypeStatic;
    textParameter.parameterValue = @"Hey! Hey Apple!";
    return @[textParameter];
}

- (void)executeWithDelegate:(id<LynExecutionDelegate>)delegate{
    [delegate postNotification:(NSString*)[self ownParameterNamed:@"Text"].absoluteValue];
    [delegate finishedExecution:self];
}


@end
