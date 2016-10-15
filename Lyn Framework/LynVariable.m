//
//  LynVariable.m
//  Lyn
//
//  Created by Programmieren on 05.07.13.
//  Copyright (c) 2013 Arne Philipeit Software. All rights reserved.
//

#import "LynVariable.h"

@implementation LynVariable{
    NSMutableArray *refrencers;
}

@synthesize name = _name;
@synthesize value = _value;

- (id)init{
    self = [super init];
    if (self) {
        _name = @"";
        _value = nil;
        refrencers = [[NSMutableArray alloc] init];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super init];
    if (self) {
        _name = [aDecoder decodeObjectForKey:@"name"];
        _value = [aDecoder decodeObjectForKey:@"value"];
        refrencers = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:_name forKey:@"name"];
    [aCoder encodeObject:_value forKey:@"value"];
}

- (id)copyWithZone:(NSZone *)zone{
    LynVariable *copiedVariable = [[[self class] alloc] init];
    copiedVariable.name = _name.copy;
    copiedVariable.value = _value.copy;
    return copiedVariable;
}

#pragma mark Properties

- (NSString *)name{
    return _name;
}

- (void)setName:(NSString *)name{
    if (!name||name.length < 1||
        [name rangeOfString:@" "].location != NSNotFound||
        [name rangeOfString:@"/"].location !=NSNotFound) {
        @throw NSInvalidArgumentException;
        return;
    }
    BOOL sendNotification = (_name != name&&EditMode);
    _name = name;
    if (sendNotification) {
        [NotificationCenter postNotificationName:LynVariableNameChangedNotification
                                          object:self];
    }
}

- (NSObject<NSCopying,NSCoding> *)value{
    return _value;
}

- (void)setValue:(NSObject<NSCopying,NSCoding> *)value{
    BOOL sendNotification = (_value != value&&EditMode);
    _value = value;
    if (sendNotification) {
        [NotificationCenter postNotificationName:LynVariableValueChangedNotification
                                          object:self];
    }
}

#pragma mark Variable Type

+ (LynDataType)variableType{
    return LynDataTypeNone;
}

- (LynDataType)variableType{
    return [[self class] variableType];
}

#pragma mark Refrences

- (NSUInteger)referenceCount{
    return refrencers.count;
}

- (void)addReference:(id)refrencer{
    if ([refrencers indexOfObject:refrencer] != NSNotFound) {
        @throw NSInvalidArgumentException;
        return;
    }
    [refrencers addObject:refrencer];
    if (EditMode) {
        [NotificationCenter postNotificationName:LynVariableAddedReferenceNotification
                                          object:self];
        [NotificationCenter postNotificationName:LynVariableReferenceCountChangedNotification
                                          object:self];
    }
}

- (void)removeReference:(id)refrencer{
    if ([refrencers indexOfObject:refrencer] == NSNotFound) {
        @throw NSInvalidArgumentException;
        return;
    }
    [refrencers removeObject:refrencer];
    if (EditMode) {
        [NotificationCenter postNotificationName:LynVariableRemovedReferenceNotification
                                          object:self];
        [NotificationCenter postNotificationName:LynVariableReferenceCountChangedNotification
                                          object:self];
    }
}

@end
