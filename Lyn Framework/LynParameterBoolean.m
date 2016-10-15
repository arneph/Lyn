//
//  LynParameterBoolean.m
//  Lyn
//
//  Created by Programmieren on 05.08.13.
//  Copyright (c) 2013 Arne Philipeit Software. All rights reserved.
//

#import "LynParameterBoolean.h"

@implementation LynParameterBoolean

- (id)init{
    self = [super init];
    if (self) {
        self.parameterValue = @NO;
    }
    return self;
}

- (id)initWithName:(NSString *)name owner:(id<LynParameterOwner>)owner{
    self = [super initWithName:name owner:owner];
    if (self) {
        self.parameterValue = @NO;
    }
    return self;
}

- (id)initFixedStaticWithName:(NSString *)name owner:(id<LynParameterOwner>)owner{
    self = [super initFixedStaticWithName:name owner:owner];
    if (self) {
        self.parameterValue = @NO;
    }
    return self;
}

- (void)setParameterValue:(NSObject<NSCoding, NSCopying> *)parameterValue{
    if ([parameterValue isKindOfClass:[NSNumber class]]) {
        float floatValue = ((NSNumber*)parameterValue).floatValue;
        if (floatValue != 0.0&&floatValue != 1.0) {
            @throw NSInvalidArgumentException;
            return;
        }
        [super setParameterValue:parameterValue];
    }else if([parameterValue isKindOfClass:[LynVariableBoolean class]]){
        [super setParameterValue:parameterValue];
    }else if([parameterValue isKindOfClass:[LynParameterBoolean class]]){
        [super setParameterValue:parameterValue];
    }else if(!parameterValue){
        [self setFillType:LynParameterFillTypeDynamicFromVariable];
        [super setParameterValue:nil];
    }else{
        @throw NSInvalidArgumentException;
    }
}

- (void)setFillType:(LynParameterFillType)fillType{
    if (self.fillType == fillType) return;
    [super setFillType:fillType];
    if (fillType == LynParameterFillTypeStatic) {
        if (![self.parameterValue isKindOfClass:[NSNumber class]]) {
            [super setParameterValue:@NO];
        }
    }else if (fillType == LynParameterFillTypeDynamicFromVariable) {
        if (![self.parameterValue isKindOfClass:[LynVariableBoolean class]]
            &&self.parameterValue != nil) {
            [super setParameterValue:nil];
        }
    }else if (fillType == LynParameterFillTypeDynamicFromParameter) {
        if (![self.parameterValue isKindOfClass:[LynParameterBoolean class]]
            &&self.parameterValue != nil) {
            [super setParameterValue:nil];
        }
    }
}

+ (LynDataType)parameterType{
    return LynDataTypeBoolean;
}

- (NSObject *)absoluteValue{
    if (!self.parameterValue) return @NO;
    if ([self.parameterValue isKindOfClass:[NSNumber class]]) {
        return self.parameterValue;
    }else if ([self.parameterValue isKindOfClass:[LynVariableBoolean class]]){
        LynVariableBoolean *variable = (LynVariableBoolean*)self.parameterValue;
        return @(variable.boolValue);
    }else if ([self.parameterValue isKindOfClass:[LynParameterBoolean class]]){
        LynParameterBoolean *parameter = (LynParameterBoolean*)self.parameterValue;
        return @(parameter.absoluteBoolValue);
    }else{
        return nil;
    }
}

- (BOOL)absoluteBoolValue{
    return ((NSNumber*)self.absoluteValue).boolValue;
}

- (NSString *)parameterValueDescription{
    if (!self.parameterValue) return @"<Unspecified>";
    if ([self.parameterValue isKindOfClass:[NSNumber class]]) {
        return [self stringForBool:self.absoluteBoolValue];
    }else if ([self.parameterValue isKindOfClass:[LynVariableBoolean class]]){
        return ((LynVariableBoolean*)self.parameterValue).name;
    }else if ([self.parameterValue isKindOfClass:[LynParameterBoolean class]]){
        return ((LynParameterBoolean*)self.parameterValue).name;
    }else{
        return nil;
    }
}

- (NSString*)stringForBool: (BOOL)boolean{
    return (boolean) ? @"YES" : @"NO";
}

@end
