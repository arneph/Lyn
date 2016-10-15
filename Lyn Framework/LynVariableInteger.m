//
//  LynVariableInteger.m
//  Lyn
//
//  Created by Programmieren on 07.07.13.
//  Copyright (c) 2013 Arne Philipeit Software. All rights reserved.
//

#import "LynVariableInteger.h"

@implementation LynVariableInteger

- (id)init{
    self = [super init];
    if (self) {
        self.value = @0;
    }
    return self;
}

- (void)setValue:(NSObject<NSCopying,NSCoding> *)value{
    if ([value isKindOfClass:[NSNumber class]]) {
        [super setValue:value];
    }else{
        @throw NSInvalidArgumentException;
    }
}

+ (LynDataType)variableType{
    return LynDataTypeInteger;
}

- (NSNumber *)numberValue{
    return (NSNumber*)self.value;
}

@end
