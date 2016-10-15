//
//  LynCommandOpenApplication.m
//  Lyn
//
//  Created by Programmieren on 05.08.13.
//  Copyright (c) 2013 Arne Philipeit Software. All rights reserved.
//

#import "LynCommandOpenApplication.h"

@implementation LynCommandOpenApplication

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
    LynCommandOpenApplication *copiedCommandOpenApp = [super copyWithZone:nil];
    return copiedCommandOpenApp;
}

- (NSArray *)warnings{
    NSMutableArray *warnings = [[NSMutableArray alloc] init];
    LynParameterString *appParameter = (LynParameterString*)[self ownParameterNamed:@"Application"];
    if (appParameter.isStaticValueEmpty) {
        [warnings addObject:[[LynWarning alloc] initWithObject:self
                                                andMessageText:@"There is no specified application."]];
    }else if (appParameter.isDynamicValueNotSpecified) {
        [warnings addObject:[[LynWarning alloc] initWithObject:self
                                                andMessageText:@"There is no specified Variable."]];
    }
    return [NSArray arrayWithArray:warnings];
}

- (void)parameterValueChanged: (NSNotification *)notification{
    if (EditMode) {
        [NotificationCenter postNotificationName:LynOutlineObjectNumberOfWarningsChangedNotification
                                      object:self];
    }
    [super parameterValueChanged:notification];
}

- (void)parameterValueDescriptionChanged: (NSNotification *)notification{
    if (EditMode) {
        [NotificationCenter postNotificationName:LynCommandSummaryChangedNotification
                                          object:self];
    }
    [super parameterValueDescriptionChanged:notification];
}

+ (NSString *)name{
    return @"Open Application";
}

+ (NSString *)description{
    return @"Tries to open an application referd by name.";
}

- (NSString *)summary{
    LynParameterString *appParameter = (LynParameterString*)[self ownParameterNamed:@"Application"];
    NSString *appParameterDescription = [appParameter parameterValueDescription];
    return [NSString stringWithFormat:@"Open Application: %@", appParameterDescription];
}

+ (NSArray *)parameters{
    LynParameterString *appParameter = [[LynParameterString alloc] initWithName:@"Application" owner:nil];
    appParameter.fillType = LynParameterFillTypeStatic;
    appParameter.parameterValue = @"TextEdit";
    return @[appParameter];
}

- (void)executeWithDelegate:(id<LynExecutionDelegate>)delegate{
    NSString *app = (NSString*)[self ownParameterNamed:@"Application"].absoluteValue;
    [delegate openApplication:app];
    [delegate finishedExecution:self];
}

@end
