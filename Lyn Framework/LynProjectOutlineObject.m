//
//  LynProjectOutlineObject.m
//  Lyn
//
//  Created by Programmieren on 28.04.13.
//  Copyright (c) 2013 Arne Philipeit Software. All rights reserved.
//

#import "LynProjectOutlineObject.h"

@implementation LynProjectOutlineObject

- (id)init{
    self = [super initWithAllowedClass:[LynProjectOutlineObject class]];
    if (self) {
        _name = @"";
    }
    return self;
}

- (id)initWithName:(NSString *)name{
    self = [super initWithAllowedClass:[LynProjectOutlineObject class]];
    if (self) {
        _name = name;
    }
    return self;
}

- (id)initWithAllowedClass:(Class)allowedClass{
    self = [super initWithAllowedClass:allowedClass];
    if (self) {
        _name = @"";
    }
    return self;
}

- (id)initWithAllowedClass:(Class)allowedClass andCoder:(NSCoder *)aDecoder{
    self = [super initWithAllowedClass:allowedClass andCoder:aDecoder];
    if (self) {
        _name = [aDecoder decodeObjectForKey:@"Name"];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithAllowedClass:[LynProjectOutlineObject class] andCoder:aDecoder];
    if (self) {
        _name = [aDecoder decodeObjectForKey:@"Name"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:_name forKey:@"Name"];
}

- (id)copyWithZone:(NSZone *)zone{
    LynProjectOutlineObject *copiedProjectOutlineObject = [super copyWithZone:nil];
    copiedProjectOutlineObject.name = _name.copy;
    return copiedProjectOutlineObject;
}

+ (BOOL)hasScope{
    return NO;
}

@end
