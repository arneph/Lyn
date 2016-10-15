//
//  LynVariableString.m
//  Lyn
//
//  Created by Programmieren on 05.07.13.
//  Copyright (c) 2013 Arne Philipeit Software. All rights reserved.
//

#import "LynVariableString.h"

@implementation LynVariableString

- (id)init{
    self = [super init];
    if (self) {
        self.value = @"";
    }
    return self;
}

- (void)setValue:(NSObject <NSCopying,NSCoding>*)value{
    if ([value isKindOfClass:[NSString class]]) {
        [super setValue:value];
    }else{
        @throw NSInvalidArgumentException;
    }
}

+ (LynDataType)variableType{
    return LynDataTypeString;
}

- (NSString *)stringValue{
    return (NSString*)self.value;
}

@end
