//
//  LynCondition.m
//  Lyn
//
//  Created by Programmieren on 05.10.13.
//  Copyright (c) 2013 Arne Philipeit Software. All rights reserved.
//

#import "LynCondition.h"

@implementation LynCondition
@synthesize negate = _negate;
@synthesize parentCondition = _parentCondition;

- (id)init{
    self = [super init];
    if (self) {
        _negate = NO;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super init];
    if (self) {
        _negate = [aDecoder decodeBoolForKey:@"negate"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeBool:_negate forKey:@"negate"];
}

- (id)copyWithZone:(NSZone *)zone{
    LynCondition *copiedCondition = [[[self class] alloc] init];
    copiedCondition.negate = _negate;
    return copiedCondition;
}

#pragma mark Properties

- (BOOL)negate{
    return _negate;
}

- (void)setNegate:(BOOL)negate{
    BOOL sendNotification = (negate != _negate&&EditMode);
    _negate = negate;
    if (sendNotification) {
        [NotificationCenter postNotificationName:LynConditionNegationChangedNotification
                                      object:self];
        [NotificationCenter postNotificationName:LynConditionDescriptionChangedNotification
                                          object:self];
    }
}

- (LynCondition *)parentCondition{
    return _parentCondition;
}

-  (void)setParentCondition:(LynCondition *)parentCondition{
    BOOL sendNotification = (_parentCondition != parentCondition&&EditMode);
    _parentCondition = parentCondition;
    _delegate = _parentCondition.delegate;
    if (sendNotification) {
        [NotificationCenter postNotificationName:LynConditionParentChangedNotification
                                          object:self];
    }
}

#pragma mark Description

- (NSString *)description{
    return (_negate == NO) ? @"()" : @"!()";
}

#pragma mark Evalutation

- (BOOL)isConditionMet{
    return YES;
}

@end
