//
//  LynCommandWriteLineBreak.m
//  Lyn
//
//  Created by Programmieren on 19.05.13.
//  Copyright (c) 2013 Arne Philipeit Software. All rights reserved.
//

#import "LynCommandWriteLineBreak.h"

@implementation LynCommandWriteLineBreak

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
    LynCommandWriteLineBreak *copiedCommandWriteLineBreak = [super copyWithZone:nil];
    return copiedCommandWriteLineBreak;
}

+ (NSString *)name{
    return @"Write Line Break";
}

+ (NSString *)description{
    return @"Writes a line break.";
}

- (NSString *)summary{
    return @"Write Line Break";
}

- (void)executeWithDelegate:(id<LynExecutionDelegate>)delegate{
    [delegate write:@"\n"];
    [delegate finishedExecution:self];
}

@end
