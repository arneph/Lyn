//
//  LynCommandOpenFileWithApplication.m
//  Lyn
//
//  Created by Programmieren on 06.08.13.
//  Copyright (c) 2013 Arne Philipeit Software. All rights reserved.
//

#import "LynCommandOpenFileWithApplication.h"

@implementation LynCommandOpenFileWithApplication

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
    LynCommandOpenFileWithApplication *copiedCommandOpenFileWithApp = [super copyWithZone:nil];
    return copiedCommandOpenFileWithApp;
}

- (NSArray *)warnings{
    NSMutableArray *warnings = [[NSMutableArray alloc] init];
    LynParameterString *appParameter = (LynParameterString*)[self ownParameterNamed:@"Application"];
    LynParameterString *fileParameter = (LynParameterString*)[self ownParameterNamed:@"File"];
    if (appParameter.isStaticValueEmpty) {
        [warnings addObject:[[LynWarning alloc] initWithObject:self
                                                andMessageText:@"There is no specified application."]];
    }else if (appParameter.isDynamicValueNotSpecified) {
        [warnings addObject:[[LynWarning alloc] initWithObject:self
                                                andMessageText:@"There is no specified Variable."]];
    }
    if (fileParameter.isStaticValueEmpty) {
        [warnings addObject:[[LynWarning alloc] initWithObject:self
                                                andMessageText:@"There is no specified file."]];
    }else if (fileParameter.isDynamicValueNotSpecified) {
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
    return @"Open File With Application";
}

+ (NSString *)description{
    return @"Tries to open a file with an application";
}

- (NSString *)summary{
    LynParameterString *appParameter = (LynParameterString*)[self ownParameterNamed:@"Application"];
    LynParameterString *fileParameter = (LynParameterString*)[self ownParameterNamed:@"File"];
    NSString *appParameterDescription = [appParameter parameterValueDescription];
    NSString *fileParameterDescription = [fileParameter parameterValueDescription];
    return [NSString stringWithFormat:@"Open File: %@ with Application %@", fileParameterDescription, appParameterDescription];
}

+ (NSArray *)parameters{
    LynParameterString *appParameter = [[LynParameterString alloc] initWithName:@"Application" owner:nil];
    appParameter.fillType = LynParameterFillTypeStatic;
    appParameter.parameterValue = @"TextEdit";
    
    LynParameterString *fileParameter = [[LynParameterString alloc] initWithName:@"File" owner:nil];
    fileParameter.fillType = LynParameterFillTypeStatic;
    fileParameter.parameterValue = @"~/Documents";
    
    return @[fileParameter, appParameter];
}

- (void)executeWithDelegate:(id<LynExecutionDelegate>)delegate{
    NSString *app = (NSString*)[self ownParameterNamed:@"Application"].absoluteValue;
    NSString *file = (NSString*)[self ownParameterNamed:@"File"].absoluteValue;
    [delegate openFile:file withApplication:app];
    [delegate finishedExecution:self];
}

@end
