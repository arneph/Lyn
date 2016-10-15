//
//  LynCommandOpenFile.m
//  Lyn
//
//  Created by Programmieren on 06.08.13.
//  Copyright (c) 2013 Arne Philipeit Software. All rights reserved.
//

#import "LynCommandOpenFile.h"

@implementation LynCommandOpenFile

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
    LynCommandOpenFile *copiedCommandOpenFile = [super copyWithZone:nil];
    return copiedCommandOpenFile;
}

- (NSArray *)warnings{
    NSMutableArray *warnings = [[NSMutableArray alloc] init];
    LynParameterString *fileParameter = (LynParameterString*)[self ownParameterNamed:@"File"];
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
    return @"Open File";
}

+ (NSString *)description{
    return @"Tries to open a file with the default application.";
}

- (NSString *)summary{
    LynParameterString *fileParameter = (LynParameterString*)[self ownParameterNamed:@"File"];
    NSString *fileParameterDescription = [fileParameter parameterValueDescription];
    return [NSString stringWithFormat:@"Open File: %@", fileParameterDescription];
}

+ (NSArray *)parameters{
    LynParameterString *fileParameter = [[LynParameterString alloc] initWithName:@"File" owner:nil];
    fileParameter.fillType = LynParameterFillTypeStatic;
    fileParameter.parameterValue = @"~/Documents";
    return @[fileParameter];
}

- (void)executeWithDelegate:(id<LynExecutionDelegate>)delegate{
    NSString *file = (NSString*)[self ownParameterNamed:@"File"].absoluteValue;
    [delegate openFile:file];
    [delegate finishedExecution:self];
}

@end
