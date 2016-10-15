//
//  LynCombiningCondition.m
//  Lyn
//
//  Created by Programmieren on 05.10.13.
//  Copyright (c) 2013 Arne Philipeit Software. All rights reserved.
//

#import "LynCombiningCondition.h"

@interface LynCombiningConditionSubConditionsArray : NSMutableArray

@property LynCombiningCondition *owner;

- (id)initWithOwner: (LynCombiningCondition*)owner;

@end

@implementation LynCombiningConditionSubConditionsArray{
    NSMutableArray *subConditions;
}

- (id)init{
    self = [super init];
    if (self) {
        subConditions = [[NSMutableArray alloc] init];
    }
    return self;
}

- (id)initWithOwner:(LynCombiningCondition *)owner{
    self = [super init];
    if (self) {
        _owner = owner;
        subConditions = [[NSMutableArray alloc] init];
    }
    return self;
}

- (NSUInteger)count{
    return subConditions.count;
}

- (id)objectAtIndex:(NSUInteger)index{
    return subConditions[index];
}

- (void)insertObject:(id)anObject atIndex:(NSUInteger)index{
    if (![anObject isKindOfClass:[LynCondition class]]) {
        @throw NSInvalidArgumentException;
        return;
    }
    LynCondition *newCondition = anObject;
    [self postWillAddSubConditionNotification:newCondition];
    
    [subConditions insertObject:newCondition atIndex:index];
    
    newCondition.parentCondition = _owner;
    [self postDidAddSubConditionNotification:newCondition];
    [self postNumberOfSubConditionsChangedNotification];
}

- (void)removeObjectAtIndex:(NSUInteger)index{
    LynCondition *oldCondition = subConditions[index];
    [self postWillRemoveSubConditionNotification:oldCondition];
    
    [subConditions removeObject:oldCondition];
    
    oldCondition.parentCondition = nil;
    [self postDidRemoveSubConditionNotification:oldCondition];
    [self postNumberOfSubConditionsChangedNotification];
}

- (void)addObject:(id)anObject{
    if (![anObject isKindOfClass:[LynCondition class]]) {
        @throw NSInvalidArgumentException;
        return;
    }
    LynCondition *newCondition = anObject;
    [self postWillAddSubConditionNotification:newCondition];
    
    [subConditions addObject:newCondition];
    
    newCondition.parentCondition = _owner;
    [self postDidAddSubConditionNotification:newCondition];
    [self postNumberOfSubConditionsChangedNotification];
}

- (void)removeLastObject{
    LynCondition *oldCondition = subConditions.lastObject;
    [self postWillRemoveSubConditionNotification:oldCondition];
    
    [subConditions removeObject:oldCondition];
    
    oldCondition.parentCondition = nil;
    [self postDidRemoveSubConditionNotification:oldCondition];
    [self postNumberOfSubConditionsChangedNotification];
}

- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject{
    if (![anObject isKindOfClass:[LynCondition class]]) {
        @throw NSInvalidArgumentException;
        return;
    }
    LynCondition *oldCondition = subConditions[index];
    LynCondition *newCondition = anObject;
    [self postWillRemoveSubConditionNotification:oldCondition];
    [self postWillAddSubConditionNotification:newCondition];
    
    subConditions[index] = newCondition;
    
    oldCondition.parentCondition = nil;
    newCondition.parentCondition = _owner;
    [self postDidRemoveSubConditionNotification:oldCondition];
    [self postDidAddSubConditionNotification:newCondition];
    [self postNumberOfSubConditionsChangedNotification];
}

- (void)postWillAddSubConditionNotification: (LynCondition*)subCondition{
    [NotificationCenter postNotificationName:LynCombiningConditionWillAddSubCondition
                                      object:_owner
                                    userInfo:@{@"subCondition": subCondition}];
}

- (void)postDidAddSubConditionNotification: (LynCondition*)subCondition{
    [NotificationCenter postNotificationName:LynCombiningConditionDidAddSubCondition
                                      object:_owner
                                    userInfo:@{@"subCondition": subCondition}];
}

- (void)postWillRemoveSubConditionNotification: (LynCondition*)subCondition{
    [NotificationCenter postNotificationName:LynCombiningConditionWillRemoveSubCondition
                                      object:_owner
                                    userInfo:@{@"subCondition": subCondition}];
}

- (void)postDidRemoveSubConditionNotification: (LynCondition*)subCondition{
    [NotificationCenter postNotificationName:LynCombiningConditionDidRemoveSubCondition
                                      object:_owner
                                    userInfo:@{@"subCondition": subCondition}];
}

- (void)postNumberOfSubConditionsChangedNotification{
    [NotificationCenter postNotificationName:LynCombiningConditionNumberOfSubConditionsChanged
                                      object:_owner];
}

@end

@implementation LynCombiningCondition
@synthesize combinationType = _combinationType;

- (id)init{
    self = [super init];
    if (self) {
        _combinationType = LynConditionCombinationAnd;
        _subConditions = [[LynCombiningConditionSubConditionsArray alloc] initWithOwner:self];
        [self observeSubConditions];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        _combinationType = (LynConditionCombinationType)[aDecoder decodeIntegerForKey:@"combinationType"];
        _subConditions = [[LynCombiningConditionSubConditionsArray alloc] initWithOwner:self];
        [_subConditions addObjectsFromArray:[aDecoder decodeObjectForKey:@"subConditions"]];
        [self observeSubConditions];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [super encodeWithCoder:aCoder];
    [aCoder encodeInteger:_combinationType forKey:@"combinationType"];
    [aCoder encodeObject:_subConditions forKey:@"subConditions"];
}

- (id)copyWithZone:(NSZone *)zone{
    LynCombiningCondition *copiedCondition = [super copyWithZone:nil];
    copiedCondition.combinationType = _combinationType;
    for (LynCondition *subCondition in _subConditions) {
        [copiedCondition.subConditions addObject:subCondition.copy];
    }
    return copiedCondition;
}

#pragma mark Notifications

- (void)observeSubConditions{
    [NotificationCenter removeObserver:self name:nil object:nil];
    [NotificationCenter addObserver:self
                           selector:@selector(willAddSubCondition:)
                               name:LynCombiningConditionWillAddSubCondition
                             object:self];
    [NotificationCenter addObserver:self
                           selector:@selector(didAddSubCondition:)
                               name:LynCombiningConditionDidAddSubCondition
                             object:self];
    [NotificationCenter addObserver:self
                           selector:@selector(didRemoveSubCondition:)
                               name:LynCombiningConditionDidRemoveSubCondition
                             object:self];
    for (LynCondition *subCondition in _subConditions) {
        [NotificationCenter addObserver:self
                               selector:@selector(descriptionOfSubConditionChanged:)
                                   name:LynConditionDescriptionChangedNotification
                                 object:subCondition];
    }
}

- (void)willAddSubCondition: (NSNotification*)notification{
    LynCondition *subCondition = notification.userInfo[@"subCondition"];
    subCondition.delegate = self.delegate;
    [NotificationCenter addObserver:self
                           selector:@selector(descriptionOfSubConditionChanged:)
                               name:LynConditionDescriptionChangedNotification
                             object:subCondition];
}

- (void)didAddSubCondition: (NSNotification*)notification{
    if (EditMode) {
        [NotificationCenter postNotificationName:LynConditionDescriptionChangedNotification
                                          object:self];
    }
}

- (void)didRemoveSubCondition: (NSNotification*)notification{
    LynCondition *subCondition = notification.userInfo[@"subCondition"];
    subCondition.delegate = nil;
    [NotificationCenter removeObserver:self
                                  name:LynConditionDescriptionChangedNotification
                                object:subCondition];
    if (EditMode) {
        [NotificationCenter postNotificationName:LynConditionDescriptionChangedNotification
                                          object:self];
    }
}

- (void)descriptionOfSubConditionChanged: (NSNotification*)notification{
    if (EditMode) {
        [NotificationCenter postNotificationName:LynConditionDescriptionChangedNotification
                                          object:self];
    }
}

#pragma mark Propterties

- (LynConditionCombinationType)combinationType{
    return _combinationType;
}

- (void)setCombinationType:(LynConditionCombinationType)combinationType{
    BOOL sendNotification = (combinationType != _combinationType&&EditMode);
    _combinationType = combinationType;
    if (sendNotification) {
        [NotificationCenter postNotificationName:LynCombiningConditionTypeChanged
                                          object:self];
        [NotificationCenter postNotificationName:LynConditionDescriptionChangedNotification
                                          object:self];
    }
}

- (void)setDelegate:(id<LynParameterOwner>)delegate{
    [super setDelegate:delegate];
    for (LynCondition *subCondition in self.subConditions) {
        subCondition.delegate = self.delegate;
    }
}

#pragma mark Description

- (NSString *)description{
    if (_subConditions.count < 1) return [super description];
    if (_subConditions.count == 1&&!self.negate) return [((LynCondition*)_subConditions.lastObject) description];
    NSMutableString *description = [NSMutableString stringWithString:(self.negate) ? @"!(" : @"("];
    for (LynCondition *subCondition in _subConditions) {
        [description appendString:subCondition.description];
        if (_subConditions.lastObject != subCondition) {
            if (_combinationType == LynConditionCombinationAnd) {
                [description appendString:@" && "];
            }else if (_combinationType == LynConditionCombinationOr) {
                [description appendString:@" || "];
            }
        }
    }
    [description appendString:@")"];
    return [NSString stringWithString:description];
}

#pragma mark Evaluation

- (BOOL)isConditionMet{
    if (_combinationType == LynConditionCombinationAnd) {
        __block BOOL allTrue = YES;
        [_subConditions enumerateObjectsUsingBlock:^(LynCondition *cond, NSUInteger idx, BOOL *stop){
            if (![cond isConditionMet]) {
                allTrue = NO;
                BOOL stp = YES;
                stop = &stp;
            }
        }];
        if (self.negate) {
            return !allTrue;
        }else{
            return allTrue;
        }
    }else if (_combinationType == LynConditionCombinationOr) {
        __block BOOL oneTrue = NO;
        [_subConditions enumerateObjectsUsingBlock:^(LynCondition *cond, NSUInteger idx, BOOL *stop){
            if ([cond isConditionMet]) {
                oneTrue = YES;
                BOOL stp = YES;
                stop = &stp;
            }
        }];
        if (self.negate) {
            return !oneTrue;
        }else{
            return oneTrue;
        }
    }else{
        return YES;
    }
}

@end
