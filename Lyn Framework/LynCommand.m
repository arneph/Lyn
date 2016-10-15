//
//  LynCommand.m
//  Lyn
//
//  Created by Programmieren on 28.04.13.
//  Copyright (c) 2013 Arne Philipeit Software. All rights reserved.
//

#import "LynCommand.h"

@implementation LynCommand{
    NSArray *parameters;
    BOOL useReturnValue;
    LynParameter *returnValueParameter;
}

- (id)init{
    self = [super initWithAllowedClass:[LynCommand class]];
    if (self) {
        parameters = [[self class] parameters];
        for (LynParameter *parameter in parameters) {
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
        useReturnValue = NO;
        if (self.returnValueType == LynDataTypeBoolean) {
            returnValueParameter = [[LynParameterBoolean alloc] initFixedDynamicWithName:@"ReturnValue" owner:self];
        }else if (self.returnValueType == LynDataTypeInteger) {
            returnValueParameter = [[LynParameterInteger alloc] initFixedDynamicWithName:@"ReturnValue" owner:self];
        }else if (self.returnValueType == LynDataTypeString) {
            returnValueParameter = [[LynParameterString alloc] initFixedDynamicWithName:@"ReturnValue" owner:self];
        }
        returnValueParameter.owner = self;
        if (EditMode) {
            [NotificationCenter addObserver:self
                                   selector:@selector(returnValueParameterValueChanged:)
                                       name:LynParameterValueChangedNotification
                                     object:returnValueParameter];
            [NotificationCenter addObserver:self
                                   selector:@selector(returnValueParameterFillTypeChanged:)
                                       name:LynParameterFillTypeChangedNotification
                                     object:returnValueParameter];
            [NotificationCenter addObserver:self
                                   selector:@selector(returnValueParameterValueDescriptionChanged:)
                                       name:LynParameterDescriptionChangedNotification
                                     object:returnValueParameter];
        }
    }
    return self;
}

- (id)initWithAllowedClass:(Class)allowedClass{
    if (allowedClass != [LynCommand class]&&![allowedClass isSubclassOfClass:[LynCommand class]]) {
        @throw NSInvalidArgumentException;
        return nil;
    }
    self = [super initWithAllowedClass:allowedClass];
    if (self) {
        parameters = [[self class] parameters];
        for (LynParameter *parameter in parameters) {
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
        useReturnValue = NO;
        if (self.returnValueType == LynDataTypeBoolean) {
            returnValueParameter = [[LynParameterBoolean alloc] initFixedDynamicWithName:@"ReturnValue" owner:self];
        }else if (self.returnValueType == LynDataTypeInteger) {
            returnValueParameter = [[LynParameterInteger alloc] initFixedDynamicWithName:@"ReturnValue" owner:self];
        }else if (self.returnValueType == LynDataTypeString) {
            returnValueParameter = [[LynParameterString alloc] initFixedDynamicWithName:@"ReturnValue" owner:self];
        }
        returnValueParameter.owner = self;
        if (EditMode) {
            [NotificationCenter addObserver:self
                                   selector:@selector(returnValueParameterValueChanged:)
                                       name:LynParameterValueChangedNotification
                                     object:returnValueParameter];
            [NotificationCenter addObserver:self
                                   selector:@selector(returnValueParameterFillTypeChanged:)
                                       name:LynParameterFillTypeChangedNotification
                                     object:returnValueParameter];
            [NotificationCenter addObserver:self
                                   selector:@selector(returnValueParameterValueDescriptionChanged:)
                                       name:LynParameterDescriptionChangedNotification
                                     object:returnValueParameter];
        }
    }
    return self;
}

- (id)initWithAllowedClass:(Class)allowedClass andCoder:(NSCoder *)aDecoder{
    if (allowedClass != [LynCommand class]&&![allowedClass isSubclassOfClass:[LynCommand class]]) {
        @throw NSInvalidArgumentException;
        return nil;
    }
    self = [super initWithAllowedClass:allowedClass andCoder:aDecoder];
    if (self) {
        parameters = [aDecoder decodeObjectForKey:@"parameters"];
        for (LynParameter *parameter in parameters) {
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
        useReturnValue = [aDecoder decodeBoolForKey:@"useReturnValue"];
        returnValueParameter = [aDecoder decodeObjectForKey:@"returnValueParameter"];
        returnValueParameter.owner = self;
        if (EditMode) {
            [NotificationCenter addObserver:self
                                   selector:@selector(returnValueParameterValueChanged:)
                                       name:LynParameterValueChangedNotification
                                     object:returnValueParameter];
            [NotificationCenter addObserver:self
                                   selector:@selector(returnValueParameterFillTypeChanged:)
                                       name:LynParameterFillTypeChangedNotification
                                     object:returnValueParameter];
            [NotificationCenter addObserver:self
                                   selector:@selector(returnValueParameterValueDescriptionChanged:)
                                       name:LynParameterDescriptionChangedNotification
                                     object:returnValueParameter];
        }
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithAllowedClass:[LynCommand class] andCoder:aDecoder];
    if (self) {
        parameters = [aDecoder decodeObjectForKey:@"parameters"];
        for (LynParameter *parameter in parameters) {
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
        useReturnValue = [aDecoder decodeBoolForKey:@"useReturnValue"];
        returnValueParameter = [aDecoder decodeObjectForKey:@"returnValueParameter"];
        returnValueParameter.owner = self;
        if (EditMode) {
            [NotificationCenter addObserver:self
                                   selector:@selector(returnValueParameterValueChanged:)
                                       name:LynParameterValueChangedNotification
                                     object:returnValueParameter];
            [NotificationCenter addObserver:self
                                   selector:@selector(returnValueParameterFillTypeChanged:)
                                       name:LynParameterFillTypeChangedNotification
                                     object:returnValueParameter];
            [NotificationCenter addObserver:self
                                   selector:@selector(returnValueParameterValueDescriptionChanged:)
                                       name:LynParameterDescriptionChangedNotification
                                     object:returnValueParameter];
        }
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.standardParameters forKey:@"parameters"];
    [aCoder encodeBool:self.useReturnValue forKey:@"useReturnValue"];
    [aCoder encodeObject:returnValueParameter forKey:@"returnValueParameter"];
}

- (id)copyWithZone:(NSZone *)zone{
    LynCommand *copiedCommand = [super copyWithZone:nil];
    NSMutableArray *copiedParameters = [NSMutableArray arrayWithCapacity:self.standardParameters.count];
    for (LynParameter *parameter in self.standardParameters) {
        [copiedParameters addObject:parameter.copy];
    }
    [copiedCommand takeCopiedParameters:[NSArray arrayWithArray:copiedParameters]];
    [copiedCommand setUseReturnValue:self.useReturnValue];
    [copiedCommand takeCopiedReturnValueParameter:returnValueParameter];
    return copiedCommand;
}

- (void)takeCopiedParameters: (NSArray*)copiedParameters{
    [NotificationCenter removeObserver:self
                                  name:LynParameterValueChangedNotification
                                object:nil];
    parameters = copiedParameters;
    for (LynParameter *parameter in parameters) {
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

- (void)takeCopiedReturnValueParameter: (LynParameter*)parameter{
    returnValueParameter = parameter;
    returnValueParameter.owner = self;
    if (EditMode) {
        [NotificationCenter addObserver:self
                               selector:@selector(returnValueParameterValueChanged:)
                                   name:LynParameterValueChangedNotification
                                 object:returnValueParameter];
        [NotificationCenter addObserver:self
                               selector:@selector(returnValueParameterFillTypeChanged:)
                                   name:LynParameterFillTypeChangedNotification
                                 object:returnValueParameter];
        [NotificationCenter addObserver:self
                               selector:@selector(returnValueParameterValueDescriptionChanged:)
                                   name:LynParameterDescriptionChangedNotification
                                 object:returnValueParameter];
    }
}

#pragma mark Properties

- (void)setParent:(LynOutlineObject *)parent{
    [super setParent:parent];
    for (LynParameter *parameter in self.parameters) {
        parameter.owner = self;
    }
    if (self.useReturnValue) {
        self.returnValueParameter.owner = self;
    }
}

#pragma mark Hierarchy

+ (BOOL)allowsSubObjects{
    return NO;
}

#pragma mark Scope

+ (BOOL)hasScope{
    return NO;
}

#pragma mark Identification

+ (NSString *)uniqueTypeIdentifier{
    return @"de.AP-Software.Lyn.LynCommand";
}

#pragma mark Notifications

- (void)parameterNameChanged:(NSNotification *)notification{
    if (!EditMode) return;
    [NotificationCenter postNotificationName:LynCommandParameterNameChangedNotification
                                      object:self
                                    userInfo:@{@"parameter" : notification.object}];
}

- (void)parameterValueChanged: (NSNotification*)notification{
    if (!EditMode) return;
    [NotificationCenter postNotificationName:LynCommandParameterValueChangedNotification
                                      object:self
                                    userInfo:@{@"parameter" : notification.object}];
}

- (void)parameterFillTypeChanged: (NSNotification*)notification{
    if (!EditMode) return;
    [NotificationCenter postNotificationName:LynCommandParameterFillTypeChangedNotification
                                      object:self
                                    userInfo:@{@"parameter" : notification.object}];
}

- (void)parameterValueDescriptionChanged: (NSNotification*)notification{
    if (!EditMode) return;
    [NotificationCenter postNotificationName:LynCommandParameterValueDescriptionChangedNotification
                                      object:self
                                    userInfo:@{@"parameter" : notification.object}];
}

- (void)returnValueParameterValueChanged:(NSNotification *)notification{
    if (!EditMode) return;
    [NotificationCenter postNotificationName:LynCommandReturnValueParameterValueChangedNotification
                                      object:self];
}

- (void)returnValueParameterFillTypeChanged:(NSNotification *)notification{
    if (!EditMode) return;
    [NotificationCenter postNotificationName:LynCommandReturnValueParameterFillTypeChangedNotification
                                      object:self];
}

- (void)returnValueParameterValueDescriptionChanged:(NSNotification *)notification{
    if (!EditMode) return;
    [NotificationCenter postNotificationName:LynCommandReturnValueParameterValueDescriptionChangedNotification
                                      object:self];
}

#pragma mark General Information

+ (NSString *)name{
    @throw [[NSException alloc] initWithName:@"Unimplemented Method" reason:@"The Method name of LynCommand must be implemented!" userInfo:nil];
    return nil;
}

+ (NSString *)description{
    @throw [[NSException alloc] initWithName:@"Unimplemented Method" reason:@"The Method description of LynCommand must be implemented!" userInfo:nil];
    return nil;
}

- (NSString *)summary{
    @throw [[NSException alloc] initWithName:@"Unimplemented Method" reason:@"The Method summary of LynCommand must be implemented!" userInfo:nil];
    return nil;
}

#pragma mark Parameters

+ (NSArray *)parameters{
    return @[];
}

- (NSArray *)standardParameters{
    if (!parameters) {
        NSArray *defaultParameters = [[self class] parameters];
        NSMutableArray *copiedParameters = [NSMutableArray arrayWithCapacity:defaultParameters.count];
        for (LynParameter *parameter in defaultParameters) {
            LynParameter *copiedParameter = parameter.copy;
            copiedParameter.owner = self;
            [copiedParameters addObject:copiedParameter];
            
            [NotificationCenter addObserver:self
                                   selector:@selector(parameterValueChanged:)
                                       name:LynParameterValueChangedNotification
                                     object:copiedParameter];
        }
        parameters = [NSArray arrayWithArray:copiedParameters];
    }
    return parameters;
}

- (NSArray *)parameters{
    return parameters;
}

#pragma mark Return Value

- (LynDataType)returnValueType{
    return LynDataTypeNone;
}

- (BOOL)useReturnValue{
    return useReturnValue;
}

- (void)setUseReturnValue:(BOOL)use{
    useReturnValue = use;
    if (!useReturnValue) returnValueParameter.parameterValue = nil;
}

- (LynParameter *)returnValueParameter{
    if (!useReturnValue) return nil;
    return returnValueParameter;
}

- (void)processReturnValue:(NSObject<NSCoding,NSCopying> *)returnValue{
    if (!returnValue) return;
    if (self.returnValueType == LynDataTypeNone||self.useReturnValue == NO) return;
    if (!returnValueParameter.parameterValue) return;
    if ([returnValueParameter.parameterValue isKindOfClass:[LynVariable class]]) {
        LynVariable *variable = (LynVariable*)returnValueParameter.parameterValue;
        [variable setValue:returnValue];
    }else if ([returnValueParameter.parameterValue isKindOfClass:[LynParameter class]]) {
        LynParameter *parameter = (LynParameter*)returnValueParameter.parameterValue;
        [parameter setParameterValue:returnValue];
    }
}

#pragma mark ParameterOwner

- (LynVariable *)variableNamed:(NSString *)name{
    LynOutlineObject *parentWithScope = self.parent;
    while (parentWithScope&&![[parentWithScope class] hasScope]) {
        parentWithScope = parentWithScope.parent;
    }
    return [[parentWithScope scope] variableNamed:name inSuperScopes:YES];
}

- (LynParameter *)parameterNamed:(NSString *)name{
    LynOutlineObject *parentWithParameters = self.parent;
    while (parentWithParameters) {
        
        if ([parentWithParameters respondsToSelector:@selector(parameters)]) {
            
            NSArray *parametersOfParent = [(id)parentWithParameters parameters];
            for (LynParameter *parameter in parametersOfParent) {
                if ([parameter.name isEqualToString:name]) return parameter;
            }
            
        }
        
        parentWithParameters = parentWithParameters.parent;
    }
    return nil;
}

#pragma mark Execution

- (LynParameter *)ownParameterNamed:(NSString *)parameterName{
    for (LynParameter *parameter in [self parameters]) {
        if ([parameter.name isEqualToString:parameterName]) {
            return parameter;
        }
    }
    return nil;
}

- (void)executeWithDelegate:(id<LynExecutionDelegate>)delegate{
    if (!delegate) {
        @throw NSInvalidArgumentException;
    }else{
        [delegate finishedExecution:self];
    }
}

@end
