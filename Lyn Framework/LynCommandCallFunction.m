//
//  LynCommandCallFunction.m
//  Lyn
//
//  Created by Programmieren on 04.07.13.
//  Copyright (c) 2013 Arne Philipeit Software. All rights reserved.
//

#import "LynCommandCallFunction.h"

@implementation LynCommandCallFunction{
    NSMutableArray *additionalParameters;
    
    LynFunction *specifiedFunction;
}

- (id)init{
    self = [super init];
    if (self) {
        additionalParameters = [[NSMutableArray alloc] init];
    }
    return self;
}

- (id)initWithAllowedClass:(Class)allowedClass{
    self = [super init];
    if (self) {
        additionalParameters = [[NSMutableArray alloc] init];
    }
    return self;
}

- (id)initWithAllowedClass:(Class)allowedClass andCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        additionalParameters = [[NSMutableArray alloc] initWithArray:[aDecoder decodeObjectForKey:@"additionalParameters"]];
        for (LynParameter *parameter in additionalParameters) {
            parameter.owner = self;
            if (EditMode) {
                [NotificationCenter addObserver:self
                                       selector:@selector(parameterNameChanged:)
                                           name:LynParameterNameChangedNotification
                                         object:parameter];
                [NotificationCenter addObserver:self
                                       selector:@selector(parameterValueChanged:)
                                           name:LynParameterValueChangedNotification
                                         object:parameter];
                [NotificationCenter addObserver:self
                                       selector:@selector(parameterFillTypeChanged:)
                                           name:LynParameterFillTypeChangedNotification
                                         object:parameter];
                [NotificationCenter addObserver:self
                                       selector:@selector(parameterValueDescriptionChanged:)
                                           name:LynParameterDescriptionChangedNotification
                                         object:parameter];
            }
        }
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        additionalParameters = [[NSMutableArray alloc] initWithArray:[aDecoder decodeObjectForKey:@"additionalParameters"]];
        for (LynParameter *parameter in additionalParameters) {
            parameter.owner = self;
            if (EditMode) {
                [NotificationCenter addObserver:self
                                       selector:@selector(parameterNameChanged:)
                                           name:LynParameterNameChangedNotification
                                         object:parameter];
                [NotificationCenter addObserver:self
                                       selector:@selector(parameterValueChanged:)
                                           name:LynParameterValueChangedNotification
                                         object:parameter];
                [NotificationCenter addObserver:self
                                       selector:@selector(parameterFillTypeChanged:)
                                           name:LynParameterFillTypeChangedNotification
                                         object:parameter];
                [NotificationCenter addObserver:self
                                       selector:@selector(parameterValueDescriptionChanged:)
                                           name:LynParameterDescriptionChangedNotification
                                         object:parameter];
            }
        }
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:additionalParameters forKey:@"additionalParameters"];
}

- (id)copyWithZone:(NSZone *)zone{
    LynCommandCallFunction *copiedCommandCallFunction = [super copyWithZone:nil];
    [copiedCommandCallFunction takeCopiedAdditionalParameters:additionalParameters];
    return copiedCommandCallFunction;
}

- (void)takeCopiedAdditionalParameters: (NSArray*)parameters{
    additionalParameters = [NSMutableArray arrayWithArray:parameters];
    for (LynParameter *parameter in additionalParameters) {
        parameter.owner = self;
        if (EditMode) {
            [NotificationCenter addObserver:self
                                   selector:@selector(parameterNameChanged:)
                                       name:LynParameterNameChangedNotification
                                     object:parameter];
            [NotificationCenter addObserver:self
                                   selector:@selector(parameterValueChanged:)
                                       name:LynParameterValueChangedNotification
                                     object:parameter];
            [NotificationCenter addObserver:self
                                   selector:@selector(parameterFillTypeChanged:)
                                       name:LynParameterFillTypeChangedNotification
                                     object:parameter];
            [NotificationCenter addObserver:self
                                   selector:@selector(parameterValueDescriptionChanged:)
                                       name:LynParameterDescriptionChangedNotification
                                     object:parameter];
        }
    }
}

#pragma mark Warnings & Errors

- (NSArray *)errors{
    NSMutableArray *errors = [[NSMutableArray alloc] init];
    LynParameterString *functionParameter = (LynParameterString*)[self ownParameterNamed:@"Function"];
    [self update];
    if ([functionParameter.absoluteStringValue isEqualToString:@""]) {
        [errors addObject:[[LynError alloc] initWithObject:self andMessageText:@"The function is not specified!"]];
    }else if (!specifiedFunction) {
        [errors addObject:[[LynError alloc] initWithObject:self andMessageText:@"The specified function couldn't be found!"]];
    }
    return errors;
}

#pragma mark Update

- (void)update{
    LynParameterString *classParameter = (LynParameterString*)[self ownParameterNamed:@"Class"];
    LynParameterString *functionParameter = (LynParameterString*)[self ownParameterNamed:@"Function"];
    if (![[self parents].lastObject isKindOfClass:[LynProject class]]) return;
    LynProject *project = (LynProject*)[self parents].lastObject;
    if (!project) return;
    LynClass *class;
    if ([classParameter.absoluteStringValue isEqualToString:@""]) {
        for (LynOutlineObject *parent in self.parents) {
            if ([parent isKindOfClass:[LynClass class]]) class = (LynClass*)parent;
            if (class) break;
        }
    }else{
        class = [project classNamed:classParameter.absoluteStringValue];
    }
    if (!class){
        specifiedFunction = nil;
        [additionalParameters removeAllObjects];
        [self observeSpecifiedFunction];
        if (EditMode) {
            [NotificationCenter postNotificationName:LynCommandNumberOfParametersChangedNotification
                                              object:self];
        }
        return;
    }
    LynFunction *function = [class functionNamed:functionParameter.absoluteStringValue];
    if (!function) {
        specifiedFunction = nil;
        [additionalParameters removeAllObjects];
        [self observeSpecifiedFunction];
        if (EditMode) {
            [NotificationCenter postNotificationName:LynCommandNumberOfParametersChangedNotification
                                              object:self];
        }
        return;
    }else if (specifiedFunction != function){
        specifiedFunction = function;
        [self observeSpecifiedFunction];
    }
    [self updateAdditionalParameters];
    if (EditMode) {
        [NotificationCenter postNotificationName:LynCommandNumberOfParametersChangedNotification
                                          object:self];
    }
}

- (void)updateAdditionalParameters{
    NSMutableArray *confirmedAdditionalParameters = [NSMutableArray arrayWithCapacity:additionalParameters.count];
    
    for (LynParameter *parameter in specifiedFunction.parameters) {
        LynParameter *matchingParameter = [self ownParameterNamed:parameter.name];
        if (!matchingParameter||parameter.fillType != matchingParameter.fillType) {
            if (parameter.fillType != matchingParameter.fillType) {
                [additionalParameters removeObject:matchingParameter];
            }
            LynParameter *copy = parameter.copy;
            [additionalParameters addObject:copy];
            [confirmedAdditionalParameters addObject:copy];
        }else{
            [confirmedAdditionalParameters addObject:matchingParameter];
        }
    }
    
    NSMutableArray *unconfirmdAdditionalParameters = [NSMutableArray arrayWithArray:additionalParameters];
    [unconfirmdAdditionalParameters removeObjectsInArray:confirmedAdditionalParameters];
    
    [additionalParameters removeObjectsInArray:unconfirmdAdditionalParameters];
}

#pragma mark Notifications

- (void)parameterValueChanged: (NSNotification*)notification{
    LynParameter *parameter = notification.object;
    if ([parameter.name isEqualToString:@"Class"]||[parameter.name isEqualToString:@"Function"]) {
        [NotificationCenter removeObserver:self
                                      name:LynParameterValueChangedNotification
                                    object:nil];
        [self update];
        if (EditMode) {
            [NotificationCenter postNotificationName:LynCommandSummaryChangedNotification
                                              object:self];
            [NotificationCenter postNotificationName:LynOutlineObjectNumberOfErrorsChangedNotification
                                              object:self];
            for (LynParameter *parameter in self.parameters) {
                [NotificationCenter addObserver:self
                                       selector:@selector(parameterValueChanged:)
                                           name:LynParameterValueChangedNotification
                                         object:parameter];
            }
        }
    }
    [super parameterValueChanged:notification];
}

- (void)observeSpecifiedFunction{
    [NotificationCenter removeObserver:self
                                  name:LynFunctionNameChangedNotification
                                object:nil];
    [NotificationCenter removeObserver:self
                                  name:LynFunctionDidAddParameterNotification
                                object:nil];
    [NotificationCenter removeObserver:self
                                  name:LynFunctionDidRemoveParameterNotification
                                object:nil];
    if (specifiedFunction&&EditMode) {
        [NotificationCenter addObserver:self
                               selector:@selector(nameOfFunctionChanged:)
                                   name:LynFunctionNameChangedNotification
                                 object:specifiedFunction];
        [NotificationCenter addObserver:self
                               selector:@selector(didAddParameterToFunction:)
                                   name:LynFunctionDidAddParameterNotification
                                 object:specifiedFunction];
        [NotificationCenter addObserver:self
                               selector:@selector(didRemoveParameterFromFunction:)
                                   name:LynFunctionDidRemoveParameterNotification
                                 object:specifiedFunction];
        [NotificationCenter addObserver:self
                               selector:@selector(nameOfParameterOfFunctionChanged:)
                                   name:LynFunctionParameterNameChanged
                                 object:specifiedFunction];
    }
}

- (void)nameOfFunctionChanged: (NSNotification*)notification{
    LynParameterString *functionParameter = (LynParameterString*)[self ownParameterNamed:@"Function"];
    functionParameter.parameterValue = specifiedFunction.name;
    [self update];
}

- (void)didAddParameterToFunction: (NSNotification*)notification{
    LynParameter *newParameter = notification.userInfo[@"parameter"];
    [additionalParameters addObject:newParameter.copy];
    [self update];
}

- (void)didRemoveParameterFromFunction: (NSNotification*)notification{
    LynParameter *oldParameter = notification.userInfo[@"parameter"];
    LynParameter *matchingParameter = [self ownParameterNamed:oldParameter.name];
    [additionalParameters removeObject:matchingParameter];
    [self update];
}

- (void)nameOfParameterOfFunctionChanged: (NSNotification*)notification{
    NSString *oldName = notification.userInfo[@"oldName"];
    NSString *newName = notification.userInfo[@"newName"];
    LynParameter *matchingParameter = [self ownParameterNamed:oldName];
    matchingParameter.name = newName;
    [self update];
}

#pragma mark General Information

+ (NSString *)name{
    return @"Call Function";
}

+ (NSString *)description{
    return @"Calls a function, and gives it some parameter values.";
}

- (NSString *)summary{
    LynParameterString *classParameter = (LynParameterString*)[self ownParameterNamed:@"Class"];
    LynParameterString *functionParameter = (LynParameterString*)[self ownParameterNamed:@"Function"];
    NSString *classValue = [classParameter parameterValueDescription];
    NSString *functionValue = [functionParameter parameterValueDescription];
    if ([@"" isEqualToString:(NSString*)classParameter.parameterValue]) {
        classValue = @"self";
    }else{
        classValue = [NSString stringWithFormat:@"'%@'", classValue];
    }
    functionValue = [NSString stringWithFormat:@"'%@'", functionValue];
    return [NSString stringWithFormat:@"Call Function: %@ in Class: %@", functionValue, classValue];
}

#pragma mark Parameters

+ (NSArray *)parameters{
    LynParameterString *classParameter = [[LynParameterString alloc] initFixedStaticWithName:@"Class" owner:nil];
    LynParameterString *functionParameter = [[LynParameterString alloc] initFixedStaticWithName:@"Function" owner:nil];
    classParameter.fillType = LynParameterFillTypeStatic;
    classParameter.parameterValue = @"";
    functionParameter.fillType = LynParameterFillTypeStatic;
    functionParameter.parameterValue = @"";
    return @[classParameter, functionParameter];
}

-(NSArray *)parameters{
    NSMutableArray *parameters = [[NSMutableArray alloc] initWithArray:[super parameters]];
    [parameters addObjectsFromArray:additionalParameters];
    return parameters;
}

#pragma mark Execution

- (void)executeWithDelegate:(id<LynExecutionDelegate>)delegate{
    [self  update];
    if (specifiedFunction) {
        for (LynParameter *parameter in additionalParameters) {
            LynParameter *matchingParameter = [specifiedFunction parameterNamed:parameter.name];
            if (matchingParameter) {
                matchingParameter.parameterValue = (NSObject<NSCoding, NSCopying>*)parameter.absoluteValue;
            }
        }
        [delegate executeObject:specifiedFunction completionHandler:^(id object) {
            [delegate finishedExecution:self];
        }];
    }else{
        [delegate finishedExecution:self];
    }
}

@end
