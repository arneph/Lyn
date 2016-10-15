//
//  LynCommandScanInteger.m
//  Lyn
//
//  Created by Programmieren on 24.11.13.
//  Copyright (c) 2013 Arne Philipeit Software. All rights reserved.
//

#import "LynCommandScanInteger.h"

@implementation LynCommandScanInteger

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
    LynCommandScanInteger *copiedCommandScanInteger = [super copyWithZone:nil];
    return copiedCommandScanInteger;
}

+ (NSString *)name{
    return @"Scan Integer";
}

+ (NSString *)description{
    return @"Returns an integer, the user entered.";
}

- (NSString *)summary{
    if (!self.useReturnValue) return @"Scan Integer";
    return [NSString stringWithFormat:@"Set %@ to scaned integer.", self.returnValueParameter.parameterValueDescription];
}

- (LynDataType)returnValueType{
    return LynDataTypeInteger;
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
    [delegate scanInteger:^(NSNumber *result){
        [self processReturnValue:result];
        [delegate finishedExecution:self];
    }];
}

@end
