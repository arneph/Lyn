//
//  LynCommandScanBoolean.m
//  Lyn
//
//  Created by Programmieren on 24.11.13.
//  Copyright (c) 2013 Arne Philipeit Software. All rights reserved.
//

#import "LynCommandScanBoolean.h"

@implementation LynCommandScanBoolean

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
    LynCommandScanBoolean *copiedCommandScanBoolean = [super copyWithZone:nil];
    return copiedCommandScanBoolean;
}

+ (NSString *)name{
    return @"Scan Boolean";
}

+ (NSString *)description{
    return @"Returns a boolean value, the user entered.";
}

- (NSString *)summary{
    if (!self.useReturnValue) return @"Scan Boolean";
    return [NSString stringWithFormat:@"Set %@ to scaned boolean value.", self.returnValueParameter.parameterValueDescription];
}

- (LynDataType)returnValueType{
    return LynDataTypeBoolean;
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
    [delegate scanBoolean:^(NSNumber *result){
        [self processReturnValue:result];
        [delegate finishedExecution:self];
    }];
}

@end
