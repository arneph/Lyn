//
//  LynComparingConditionBoolean.m
//  Lyn
//
//  Created by Programmieren on 20.10.13.
//  Copyright (c) 2013 Arne Philipeit Software. All rights reserved.
//

#import "LynComparingConditionBoolean.h"

@implementation LynComparingConditionBoolean{
    LynParameterBoolean *parameterA;
    LynParameterBoolean *parameterB;
}

- (id)init{
    self = [super init];
    if (self) {
        parameterA = [[LynParameterBoolean alloc] initWithName:@"A"
                                                         owner:self.delegate];
        parameterA.fillType = LynParameterFillTypeStatic;
        parameterA.parameterValue = @YES;
        parameterB = [[LynParameterBoolean alloc] initWithName:@"B"
                                                         owner:self.delegate];
        parameterB.fillType = LynParameterFillTypeStatic;
        parameterB.parameterValue = @YES;
        [self observeParameters];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        parameterA = [aDecoder decodeObjectForKey:@"parameterA"];
        parameterB = [aDecoder decodeObjectForKey:@"parameterB"];
        parameterA.owner = self.delegate;
        parameterB.owner = self.delegate;
        [self observeParameters];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:parameterA forKey:@"parameterA"];
    [aCoder encodeObject:parameterB forKey:@"parameterB"];
}

- (id)copyWithZone:(NSZone *)zone{
    LynComparingConditionBoolean *copiedCondition = [super copyWithZone:nil];
    [copiedCondition takeCopiedParameterA:parameterA.copy andB:parameterB.copy];
    return copiedCondition;
}

- (void)takeCopiedParameterA: (LynParameterBoolean*)A andB: (LynParameterBoolean*)B{
    parameterA = A;
    parameterA.owner = self.delegate;
    parameterB = B;
    parameterB.owner = self.delegate;
}

- (LynDataType)type{
    return LynDataTypeBoolean;
}

- (LynParameterBoolean *)parameterA{
    return parameterA;
}

- (LynParameterBoolean *)parameterB{
    return parameterB;
}

- (BOOL)isConditionMet{
    BOOL A = parameterA.absoluteBoolValue;
    BOOL B = parameterB.absoluteBoolValue;
    BOOL result = (A == B);
    if (self.negate) result = !result;
    return result;
}

@end
