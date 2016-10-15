//
//  LynCommandScanString.m
//  Lyn
//
//  Created by Programmieren on 10.11.13.
//  Copyright (c) 2013 Arne Philipeit Software. All rights reserved.
//

#import "LynCommandScanString.h"

@implementation LynCommandScanString

- (id)init{
    self = [super init];
    if (self) {
    }
    return self;
}

- (id)initWithAllowedClass:(Class)allowedClass{
    self = [super init];
    if (self) {
    }
    return self;
}

- (id)initWithAllowedClass:(Class)allowedClass andCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
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
    LynCommandScanString *copiedCommandScanString = [super copyWithZone:nil];
    return copiedCommandScanString;
}

+ (NSString *)name{
    return @"Scan String";
}

+ (NSString *)description{
    return @"Returns a string, the user entered.";
}

- (NSString *)summary{
    if (!self.useReturnValue) return @"Scan String";
    return [NSString stringWithFormat:@"Set %@ to scaned string.", self.returnValueParameter.parameterValueDescription];
}

- (LynDataType)returnValueType{
    return LynDataTypeString;
}

- (void)setUseReturnValue:(BOOL)useReturnValue{
    [super setUseReturnValue:useReturnValue];
    if (EditMode) {
        [NotificationCenter postNotificationName:LynCommandSummaryChangedNotification
                                          object:self];
    }
}

- (void)returnValueParameterValueDescriptionChanged:(NSNotification *)notification{
    [super returnValueParameterValueDescriptionChanged:notification];
    if (EditMode) {
        [NotificationCenter postNotificationName:LynCommandSummaryChangedNotification
                                          object:self];
    }
}

- (void)executeWithDelegate:(id<LynExecutionDelegate>)delegate{
    [delegate scanString:^(NSString *result){
        [self processReturnValue:result];
        [delegate finishedExecution:self];
    }];
}

@end
