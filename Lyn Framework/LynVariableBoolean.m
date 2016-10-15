//
//  LynVariableBoolean.m
//  Lyn
//
//  Created by Programmieren on 07.07.13.
//  Copyright (c) 2013 Arne Philipeit Software. All rights reserved.
//

#import "LynVariableBoolean.h"

@implementation LynVariableBoolean

- (id)init{
    self = [super init];
    if (self) {
        self.value = @NO;
    }
    return self;
}

- (void)setValue:(NSObject<NSCopying,NSCoding> *)value{
    if ([value isKindOfClass:[NSNumber class]]) {
        float floatValue = ((NSNumber*)value).floatValue;
        if (floatValue == 0.0||floatValue == 1.0) {
            [super setValue:value];
            return;
        }
    }
    @throw NSInvalidArgumentException;
}

+ (LynDataType)variableType{
    return LynDataTypeBoolean;
}

- (BOOL)boolValue{
    if (self.value&&[self.value isKindOfClass:[NSNumber class]]) {
        return ((NSNumber*)self.value).boolValue;
    }else{
        return NO;
    }
}

@end
