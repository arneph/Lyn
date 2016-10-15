//
//  LynComparingConditionString.m
//  Lyn
//
//  Created by Programmieren on 30.10.13.
//  Copyright (c) 2013 Arne Philipeit Software. All rights reserved.
//

#import "LynComparingConditionString.h"

@implementation LynComparingConditionString{
    LynParameterString *parameterA;
    LynParameterString *parameterB;
}

- (id)init{
    self = [super init];
    if (self) {
        parameterA = [[LynParameterString alloc] initWithName:@"A"
                                                        owner:self.delegate];
        parameterA.fillType = LynParameterFillTypeStatic;
        parameterA.parameterValue = @"";
        parameterB = [[LynParameterString alloc] initWithName:@"B"
                                                        owner:self.delegate];
        parameterB.fillType = LynParameterFillTypeStatic;
        parameterB.parameterValue = @"";
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
    LynComparingConditionString *copiedCondition = [super copyWithZone:nil];
    [copiedCondition takeCopiedParameterA:parameterA.copy andB:parameterB.copy];
    return copiedCondition;
}

- (void)takeCopiedParameterA: (LynParameterString*)A andB: (LynParameterString*)B{
    parameterA = A;
    parameterA.owner = self.delegate;
    parameterB = B;
    parameterB.owner = self.delegate;
}

- (LynDataType)type{
    return LynDataTypeString;
}

- (LynParameterString*)parameterA{
    return parameterA;
}

- (LynParameterString*)parameterB{
    return parameterB;
}

- (BOOL)isConditionMet{
    NSString *A = parameterA.absoluteStringValue;
    NSString *B = parameterB.absoluteStringValue;
    BOOL result = ([A isEqualToString:B]);
    if (self.negate) result = !result;
    return result;
}

@end
