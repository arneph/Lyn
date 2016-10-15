//
//  LynParameterString.m
//  Lyn
//
//  Created by Programmieren on 19.05.13.
//  Copyright (c) 2013 Arne Philipeit Software. All rights reserved.
//

#import "LynParameterString.h"

@implementation LynParameterString

- (id)init{
    self = [super init];
    if (self) {
        self.parameterValue = @"";
    }
    return self;
}

- (id)initWithName:(NSString *)name owner:(id<LynParameterOwner>)owner{
    self = [super initWithName:name owner:owner];
    if (self) {
        self.parameterValue = @"";
    }
    return self;
}

- (id)initFixedStaticWithName:(NSString *)name owner:(id<LynParameterOwner>)owner{
    self = [super initFixedStaticWithName:name owner:owner];
    if (self) {
        self.parameterValue = @"";
    }
    return self;
}

- (void)setParameterValue:(NSObject<NSCoding, NSCopying> *)parameterValue{
    if ([parameterValue isKindOfClass:[NSString class]]) {
        [super setParameterValue:parameterValue];
    }else if([parameterValue isKindOfClass:[LynVariableString class]]){
        [super setParameterValue:parameterValue];
    }else if([parameterValue isKindOfClass:[LynParameterString class]]){
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
        if (![self.parameterValue isKindOfClass:[NSString class]]) [super setParameterValue:@""];
    }else if (fillType == LynParameterFillTypeDynamicFromVariable) {
        if (![self.parameterValue isKindOfClass:[LynVariableString class]]
            &&self.parameterValue != nil) {
            [super setParameterValue:nil];
        }
    }else if (fillType == LynParameterFillTypeDynamicFromParameter) {
        if (![self.parameterValue isKindOfClass:[LynParameterString class]]
            &&self.parameterValue != nil) {
            [super setParameterValue:nil];
        }
    }
}

+ (LynDataType)parameterType{
    return LynDataTypeString;
}

- (NSObject *)absoluteValue{
    if (!self.parameterValue) return @"";
    if ([self.parameterValue isKindOfClass:[NSString class]]) {
        return self.parameterValue;
    }else if ([self.parameterValue isKindOfClass:[LynVariableString class]]){
        LynVariableString *variable = (LynVariableString*)self.parameterValue;
        return variable.stringValue;
    }else if ([self.parameterValue isKindOfClass:[LynParameterString class]]){
        LynParameterString *parameter = (LynParameterString*)self.parameterValue;
        return parameter.absoluteStringValue;
    }else{
        return nil;
    }
}

- (NSString *)absoluteStringValue{
    return (NSString*)self.absoluteValue;
}

- (NSString *)parameterValueDescription{
    if (!self.parameterValue) return @"<Unspecified>";
    if ([self.parameterValue isKindOfClass:[NSString class]]) {
        return [NSString stringWithFormat:@"'%@'", self.absoluteStringValue];
    }else if ([self.parameterValue isKindOfClass:[LynVariableString class]]){
        return ((LynVariableString*)self.parameterValue).name;
    }else if ([self.parameterValue isKindOfClass:[LynParameterString class]]){
        return ((LynParameterString*)self.parameterValue).name;
    }else{
        return nil;
    }
}

- (BOOL)isStaticValueEmpty{
    if (self.fillType != LynParameterFillTypeStatic) return NO;
    return [self.absoluteStringValue isEqualToString:@""];
}

@end
