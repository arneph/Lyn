//
//  LynCommandIf.m
//  Lyn
//
//  Created by Programmieren on 05.10.13.
//  Copyright (c) 2013 Arne Philipeit Software. All rights reserved.
//

#import "LynCommandIf.h"

@implementation LynCommandIf

- (id)init{
    self = [super init];
    if (self) {
        _rootCondition = [[LynCombiningCondition alloc] init];
        _rootCondition.delegate = self;
        [self observeRootCondition];
    }
    return self;
}

- (id)initWithAllowedClass:(Class)allowedClass{
    self = [super initWithAllowedClass:[LynCommand class]];
    if (self) {
        _rootCondition = [[LynCombiningCondition alloc] init];
        _rootCondition.delegate = self;
        [self observeRootCondition];
    }
    return self;
}

- (id)initWithAllowedClass:(Class)allowedClass andCoder:(NSCoder *)aDecoder{
    self = [super initWithAllowedClass:[LynCommand class] andCoder:aDecoder];
    if (self) {
        _rootCondition = [aDecoder decodeObjectForKey:@"rootCondition"];
        _rootCondition.delegate = self;
        [self observeRootCondition];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithAllowedClass:[LynCommand class] andCoder:aDecoder];
    if (self) {
        _rootCondition = [aDecoder decodeObjectForKey:@"rootCondition"];
        _rootCondition.delegate = self;
        [self observeRootCondition];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:_rootCondition forKey:@"rootCondition"];
}

- (id)copyWithZone:(NSZone *)zone{
    LynCommandIf *copiedCommandIf = [super copyWithZone:nil];
    [copiedCommandIf takeCopiedRootCondition:_rootCondition.copy];
    return copiedCommandIf;
}

- (void)takeCopiedRootCondition: (LynCombiningCondition*)rootCondition{
    _rootCondition = rootCondition;
    _rootCondition.delegate = self;
    [self observeRootCondition];
}

#pragma mark Properites

- (void)setParent:(LynOutlineObject *)parent{
    [super setParent:parent];
    _rootCondition.delegate = self;
}

#pragma mark Notifications

- (void)observeRootCondition{
    [NotificationCenter removeObserver:self
                                  name:LynConditionDescriptionChangedNotification
                                object:nil];
    [NotificationCenter addObserver:self
                           selector:@selector(rootConditionDescriptionChanged:)
                               name:LynConditionDescriptionChangedNotification
                             object:_rootCondition];
}

- (void)rootConditionDescriptionChanged: (NSNotification*)notification{
    if (EditMode) {
        [NotificationCenter postNotificationName:LynCommandSummaryChangedNotification
                                          object:self];
    }
}

#pragma mark General Information

+ (BOOL)allowsSubObjects{
    return YES;
}

+ (BOOL)hasScope{
    return YES;
}

+ (NSString *)name{
    return @"If";
}

+ (NSString *)description{
    return @"Executes commands if certain conditions are met.";
}

- (NSString *)summary{
    return [NSString stringWithFormat:@"If %@ Then:", _rootCondition.description];
}

- (void)executeWithDelegate:(id<LynExecutionDelegate>)delegate{
    if ([_rootCondition isConditionMet]) {
        [delegate executeObjects:self.subObjects completionHandler:^(NSArray *objects) {
            [delegate finishedExecution:self];
        }];
    }else{
        [delegate finishedExecution:self];
    }
}

@end
