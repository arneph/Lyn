//
//  LynParameterInteger.m
//  Lyn
//
//  Created by Programmieren on 31.07.13.
//  Copyright (c) 2013 Arne Philipeit Software. All rights reserved.
//

#import "LynParameterInteger.h"

@implementation LynParameterInteger

- (id)init{
    self = [super init];
    if (self) {
        self.parameterValue = @0;
    }
    return self;
}

- (id)initWithName:(NSString *)name owner:(id<LynParameterOwner>)owner{
    self = [super initWithName:name owner:owner];
    if (self) {
        self.parameterValue = @0;
    }
    return self;
}

- (id)initFixedStaticWithName:(NSString *)name owner:(id<LynParameterOwner>)owner{
    self = [super initFixedStaticWithName:name owner:owner];
    if (self) {
        self.parameterValue = @0;
    }
    return self;
}

- (void)setParameterValue:(NSObject<NSCoding, NSCopying> *)parameterValue{
    if ([parameterValue isKindOfClass:[NSNumber class]]) {
        [super setParameterValue:parameterValue];
    }else if([parameterValue isKindOfClass:[LynVariableInteger class]]){
        [super setParameterValue:parameterValue];
    }else if([parameterValue isKindOfClass:[LynParameterInteger class]]){
        [super setParameterValue:parameterValue];
    }else if(!parameterValue){
        [self setFillType:LynParameterFillTypeDynamicFromVariable];
        [super setParameterValue:nil];
    }else{
        @throw NSInvalidArgumentException;
    }
}

- (void)setFillType:(LynParameterFillType)fillType{
    [super setFillType:fillType];
    if (fillType == LynParameterFillTypeStatic) {
        if (![self.parameterValue isKindOfClass:[NSNumber class]]) [super setParameterValue:@0];
    }else if (fillType == LynParameterFillTypeDynamicFromVariable) {
        if (![self.parameterValue isKindOfClass:[LynVariableInteger class]]
            &&self.parameterValue != nil) {
            [super setParameterValue:nil];
        }
    }else if (fillType == LynParameterFillTypeDynamicFromParameter) {
        if (![self.parameterValue isKindOfClass:[LynParameterInteger class]]
            &&self.parameterValue != nil) {
            [super setParameterValue:nil];
        }
    }
}

+ (LynDataType)parameterType{
    return LynDataTypeInteger;
}

- (NSObject *)absoluteValue{
    if (!self.parameterValue) return @0;
    if ([self.parameterValue isKindOfClass:[NSNumber class]]) {
        return self.parameterValue;
    }else if ([self.parameterValue isKindOfClass:[LynVariableInteger class]]){
        LynVariableInteger *variable = (LynVariableInteger*)self.parameterValue;
        return variable.numberValue;
    }else if ([self.parameterValue isKindOfClass:[LynParameterInteger class]]){
        LynParameterInteger *parameter = (LynParameterInteger*)self.parameterValue;
        return parameter.absoluteNumberValue;
    }else{
        return nil;
    }
}

- (NSNumber *)absoluteNumberValue{
    return (NSNumber*)self.absoluteValue;
}

- (NSString *)parameterValueDescription{
    if (!self.parameterValue) return @"<Unspecified>";
    if ([self.parameterValue isKindOfClass:[NSNumber class]]) {
        return self.absoluteNumberValue.stringValue;
    }else if ([self.parameterValue isKindOfClass:[LynVariableInteger class]]){
        return ((LynVariableInteger*)self.parameterValue).name;
    }else if ([self.parameterValue isKindOfClass:[LynParameterInteger class]]){
        return ((LynParameterInteger*)self.parameterValue).name;
    }else{
        return nil;
    }
}

- (BOOL)isStaticValueNegative{
    if (self.fillType != LynParameterFillTypeStatic) return NO;
    return (self.absoluteNumberValue.doubleValue < 0.0);
}

- (BOOL)isStaticValueLessThan: (NSNumber*)minimum{
    if (self.fillType != LynParameterFillTypeStatic) return NO;
    return [self.absoluteNumberValue isLessThan:minimum];
}

- (BOOL)isStaticValueLessThanOrEqual: (NSNumber*)minimum{
    if (self.fillType != LynParameterFillTypeStatic) return NO;
    return [self.absoluteNumberValue isLessThanOrEqualTo:minimum];
}

- (BOOL)isStaticValueGreaterThan: (NSNumber*)minimum{
    if (self.fillType != LynParameterFillTypeStatic) return NO;
    return [self.absoluteNumberValue isGreaterThan:minimum];
}

- (BOOL)isStaticValueGreaterThanOrEqual: (NSNumber*)minimum{
    if (self.fillType != LynParameterFillTypeStatic) return NO;
    return [self.absoluteNumberValue isGreaterThanOrEqualTo:minimum];
}

@end
