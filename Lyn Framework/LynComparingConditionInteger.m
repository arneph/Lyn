//
//  LynComparingConditionInteger.m
//  Lyn
//
//  Created by Programmieren on 30.10.13.
//  Copyright (c) 2013 Arne Philipeit Software. All rights reserved.
//

#import "LynComparingConditionInteger.h"

@implementation LynComparingConditionInteger{
    LynParameterInteger *parameterA;
    LynParameterInteger *parameterB;
}
@synthesize operation = _operation;

- (id)init{
    self = [super init];
    if (self) {
        parameterA = [[LynParameterInteger alloc] initWithName:@"A"
                                                         owner:self.delegate];
        parameterA.fillType = LynParameterFillTypeStatic;
        parameterA.parameterValue = @0;
        parameterB = [[LynParameterInteger alloc] initWithName:@"B"
                                                         owner:self.delegate];
        parameterB.fillType = LynParameterFillTypeStatic;
        parameterB.parameterValue = @0;
        _operation = LynIntegerComparisonEqual;
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
        _operation = (LynIntegerComparisonOperation)[aDecoder decodeIntegerForKey:@"operation"];
        [self observeParameters];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:parameterA forKey:@"parameterA"];
    [aCoder encodeObject:parameterB forKey:@"parameterB"];
    [aCoder encodeInteger:_operation forKey:@"operation"];
}

- (id)copyWithZone:(NSZone *)zone{
    LynComparingConditionInteger *copiedCondition = [super copyWithZone:nil];
    [copiedCondition takeCopiedParameterA:parameterA.copy andB:parameterB.copy];
    copiedCondition.operation = _operation;
    return copiedCondition;
}

- (void)takeCopiedParameterA: (LynParameterInteger*)A andB: (LynParameterInteger*)B{
    parameterA = A;
    parameterA.owner = self.delegate;
    parameterB = B;
    parameterB.owner = self.delegate;
}

- (LynDataType)type{
    return LynDataTypeInteger;
}

- (LynParameterInteger*)parameterA{
    return parameterA;
}

- (LynParameterInteger*)parameterB{
    return parameterB;
}

- (NSString *)description{
    LynParameter *A = self.parameterA;
    LynParameter *B = self.parameterB;
    if (!A||!B) return nil;
    NSString *operator;
    if (_operation == LynIntegerComparisonLessThan) {
        operator = (!self.negate) ? @"<" : @">=";
    }else if (_operation == LynIntegerComparisonLessThanOrEqual) {
        operator = (!self.negate) ? @"<=" : @">";
    }else if (_operation == LynIntegerComparisonEqual) {
        operator = (!self.negate) ? @"==" : @"!=";
    }else if (_operation == LynIntegerComparisonGreaterThanOrEqual) {
        operator = (!self.negate) ? @">=" : @"<";
    }else if (_operation == LynIntegerComparisonGreaterThan) {
        operator = (!self.negate) ? @">" : @"<=";
    }
    return [NSString stringWithFormat:@"%@ %@ %@", A.parameterValueDescription, operator, B.parameterValueDescription];
}

- (LynIntegerComparisonOperation)operation{
    return _operation;
}

- (void)setOperation:(LynIntegerComparisonOperation)operation{
    BOOL sendNotification = (EditMode&&operation != _operation);
    _operation = operation;
    if (sendNotification) {
        [NotificationCenter postNotificationName:LynComparingConditionIntegerOperationChangedNotification
                                          object:self];
        [NotificationCenter postNotificationName:LynConditionDescriptionChangedNotification
                                          object:self];
    }
}

- (BOOL)isConditionMet{
    NSNumber *A = parameterA.absoluteNumberValue;
    NSNumber *B = parameterB.absoluteNumberValue;
    BOOL result;
    if (_operation == LynIntegerComparisonLessThan) {
        result = ([A isLessThan:B]);
    }else if (_operation == LynIntegerComparisonLessThanOrEqual) {
        result = ([A isLessThanOrEqualTo:B]);
    }else if (_operation == LynIntegerComparisonEqual) {
        result = ([A isEqualToNumber:B]);
    }else if (_operation == LynIntegerComparisonGreaterThanOrEqual) {
        result = ([A isGreaterThanOrEqualTo:B]);
    }else if (_operation == LynIntegerComparisonGreaterThan) {
        result = ([A isGreaterThan:B]);
    }
    if (self.negate) result = !result;
    return result;
}

@end
