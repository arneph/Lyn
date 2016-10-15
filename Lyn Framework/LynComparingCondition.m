//
//  LynComparingCondition.m
//  Lyn
//
//  Created by Programmieren on 05.10.13.
//  Copyright (c) 2013 Arne Philipeit Software. All rights reserved.
//

#import "LynComparingCondition.h"

@implementation LynComparingCondition

- (id)init{
    self = [super init];
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
    LynComparingCondition *copiedCondition = [super copyWithZone:nil];
    return copiedCondition;
}

- (LynDataType)type{
    return LynDataTypeNone;
}

- (LynParameter *)parameterA{
    @throw NSInvalidArgumentException;
    return nil;
}

- (LynParameter *)parameterB{
    @throw NSInvalidArgumentException;
    return nil;
}

- (void)observeParameters{
    [NotificationCenter removeObserver:self name:nil object:nil];
    LynParameter *A = self.parameterA;
    LynParameter *B = self.parameterB;
    if (A) {
        [NotificationCenter addObserver:self
                               selector:@selector(parameterNameChanged:)
                                   name:LynParameterNameChangedNotification
                                 object:A];
        [NotificationCenter addObserver:self
                               selector:@selector(parameterValueChanged:)
                                   name:LynParameterValueChangedNotification
                                 object:A];
        [NotificationCenter addObserver:self
                               selector:@selector(parameterFillTypeChanged:)
                                   name:LynParameterFillTypeChangedNotification
                                 object:A];
        [NotificationCenter addObserver:self
                               selector:@selector(parameterValueDescriptionChanged:)
                                   name:LynParameterDescriptionChangedNotification
                                 object:A];
    }
    if (B) {
        [NotificationCenter addObserver:self
                               selector:@selector(parameterNameChanged:)
                                   name:LynParameterNameChangedNotification
                                 object:B];
        [NotificationCenter addObserver:self
                               selector:@selector(parameterValueChanged:)
                                   name:LynParameterValueChangedNotification
                                 object:B];
        [NotificationCenter addObserver:self
                               selector:@selector(parameterFillTypeChanged:)
                                   name:LynParameterFillTypeChangedNotification
                                 object:B];
        [NotificationCenter addObserver:self
                               selector:@selector(parameterValueDescriptionChanged:)
                                   name:LynParameterDescriptionChangedNotification
                                 object:B];
    }
}

- (void)parameterNameChanged: (NSNotification*)notification{
    [NotificationCenter postNotificationName:LynConditionParameterNameChangedNotification
                                      object:self
                                    userInfo:@{@"parameter" : notification.object}];
}

- (void)parameterValueChanged: (NSNotification*)notification{
    [NotificationCenter postNotificationName:LynConditionParameterValueChangedNotification
                                      object:self
                                    userInfo:@{@"parameter" : notification.object}];
}

- (void)parameterFillTypeChanged: (NSNotification*)notification{
    [NotificationCenter postNotificationName:LynConditionParameterFillTypeChangedNotification
                                      object:self
                                    userInfo:@{@"parameter" : notification.object}];
}

- (void)parameterValueDescriptionChanged: (NSNotification*)notification{
    [NotificationCenter postNotificationName:LynConditionParameterValueDescriptionChangedNotification
                                      object:self
                                    userInfo:@{@"parameter" : notification.object}];
    [NotificationCenter postNotificationName:LynConditionDescriptionChangedNotification
                                      object:self
                                    userInfo:@{@"parameter" : notification.object}];
}

- (void)setDelegate:(id<LynParameterOwner>)delegate{
    BOOL dontUpdate = (!self.delegate&&!delegate);
    [super setDelegate:delegate];
    if (dontUpdate) return;
    LynParameter *A = self.parameterA;
    LynParameter *B = self.parameterB;
    if (A) A.owner = self.delegate;
    if (B) B.owner = self.delegate;
}

#pragma mark Description

- (NSString *)description{
    LynParameter *A = self.parameterA;
    LynParameter *B = self.parameterB;
    if (!A||!B) return nil;
    NSString *operator = (self.negate) ? @"!=" : @"==";
    return [NSString stringWithFormat:@"%@ %@ %@", A.parameterValueDescription, operator, B.parameterValueDescription];
}

#pragma mark Evalutation

- (BOOL)isConditionMet{
    LynParameter *A = self.parameterA;
    LynParameter *B = self.parameterB;
    BOOL isEqual = [A.absoluteValue isEqualTo:B.absoluteValue];
    if (self.negate) isEqual = !isEqual;
    return isEqual;
}

@end
