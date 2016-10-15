//
//  LynScope.m
//  Lyn
//
//  Created by Programmieren on 05.07.13.
//  Copyright (c) 2013 Arne Philipeit Software. All rights reserved.
//

#import "LynScope.h"

@interface LynScopeVariablesArray : NSMutableArray

@property LynScope *owner;

@end

@implementation LynScopeVariablesArray{
    NSMutableArray *variables;
}

- (id)init{
    self = [super init];
    if (self) {
        variables = [[NSMutableArray alloc] init];
    }
    return self;
}

- (NSUInteger)count{
    return variables.count;
}

- (id)objectAtIndex:(NSUInteger)index{
    return variables[index];
}

- (void)insertObject:(id)anObject atIndex:(NSUInteger)index{
    if ([anObject isKindOfClass:[LynVariable class]]) {
        LynVariable *newVariable = anObject;
        
        [self postWillAddVariableNotificationWithVariable:newVariable];
        
        [variables insertObject:anObject atIndex:index];
        
        [self postDidAddVariableNotificationWithVariable:newVariable];
        [self postNumberOfVariablesChangedNotification];
    }else{
        @throw NSInvalidArgumentException;
    }
}

- (void)removeObjectAtIndex:(NSUInteger)index{
    LynVariable *oldVarible = self[index];
    if (oldVarible.referenceCount > 0) {
        @throw NSInvalidArgumentException;
        return;
    }
    [self postWillRemoveVariableNotificationWithVariable:oldVarible];
    
    [variables removeObjectAtIndex:index];
    
    [self postDidRemoveVariableNotificationWithVariable:oldVarible];
    [self postNumberOfVariablesChangedNotification];
}

- (void)addObject:(id)anObject{
    if ([anObject isKindOfClass:[LynVariable class]]) {
        LynVariable *newVariable = anObject;
        
        [self postWillAddVariableNotificationWithVariable:newVariable];
        
        [variables addObject:anObject];
        
        [self postDidAddVariableNotificationWithVariable:newVariable];
        [self postNumberOfVariablesChangedNotification];
    }else{
        @throw NSInvalidArgumentException;
    }
}

- (void)removeLastObject{
    LynVariable *oldVariable = self.lastObject;
    if (oldVariable.referenceCount > 0) {
        @throw NSInvalidArgumentException;
        return;
    }
    
    [self postWillRemoveVariableNotificationWithVariable:oldVariable];
    
    [variables removeLastObject];
    
    [self postDidRemoveVariableNotificationWithVariable:oldVariable];
    [self postNumberOfVariablesChangedNotification];
}

- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject{
    if ([anObject isKindOfClass:[LynVariable class]]) {
        LynVariable *oldVariable = self[index];
        LynVariable *newVariable = anObject;
        
        if (oldVariable.referenceCount > 0) {
            @throw NSInvalidArgumentException;
            return;
        }
        
        [self postWillRemoveVariableNotificationWithVariable:oldVariable];
        [self postWillAddVariableNotificationWithVariable:newVariable];
        
        variables[index] = anObject;
        
        [self postDidRemoveVariableNotificationWithVariable:oldVariable];
        [self postDidAddVariableNotificationWithVariable:newVariable];
        [self postNumberOfVariablesChangedNotification];
    }else{
        @throw NSInvalidArgumentException;
    }
}

- (void)postNumberOfVariablesChangedNotification{
    if (EditMode) {
        [NotificationCenter postNotificationName:LynScopeNumberOfVariablesChangedNotification
                                          object:_owner];
    }
}

- (void)postWillAddVariableNotificationWithVariable: (LynVariable *)variable{
    if (EditMode) {
        [NotificationCenter postNotificationName:LynScopeWillAddVariableNotification
                                          object:_owner
                                        userInfo:@{@"variable" : variable}];
    }
}

- (void)postDidAddVariableNotificationWithVariable: (LynVariable *)variable{
    if (EditMode) {
        [NotificationCenter postNotificationName:LynScopeDidAddVariableNotification
                                          object:_owner
                                        userInfo:@{@"variable" : variable}];
    }
}

- (void)postWillRemoveVariableNotificationWithVariable: (LynVariable *)variable{
    if (EditMode) {
        [NotificationCenter postNotificationName:LynScopeWillRemoveVariableNotification
                                          object:_owner
                                        userInfo:@{@"variable" : variable}];
    }
}

- (void)postDidRemoveVariableNotificationWithVariable: (LynVariable *)variable{
    if (EditMode) {
        [NotificationCenter postNotificationName:LynScopeDidRemoveVariableNotification
                                          object:_owner
                                        userInfo:@{@"variable" : variable}];
    }
}

@end

@implementation LynScope
@synthesize superScope = _superScope;
@synthesize scopeOwner = _scopeOwner;

- (id)init{
    self = [super init];
    if (self) {
        _superScope = nil;
        _scopeOwner = nil;
        LynScopeVariablesArray *variables = [[LynScopeVariablesArray alloc] init];
        variables.owner = self;
        _variables = variables;
        [self prepareForNotifications];
    }
    return self;
}

- (id)initWithOwner:(id<LynScopeOwner>)owner superScope:(LynScope *)superScope{
    self = [super init];
    if (self) {
        _superScope = superScope;
        _scopeOwner = owner;
        LynScopeVariablesArray *variables = [[LynScopeVariablesArray alloc] init];
        variables.owner = self;
        _variables = variables;
        [self prepareForNotifications];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super init];
    if (self) {
        _superScope = nil;
        _scopeOwner = nil;
        LynScopeVariablesArray *variables = [[LynScopeVariablesArray alloc] init];
        variables.owner = self;
        [variables addObjectsFromArray:[aDecoder decodeObjectForKey:@"variables"]];
        _variables = variables;
        [self prepareForNotifications];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:_variables forKey:@"variables"];
}

- (id)copyWithZone:(NSZone *)zone{
    LynScope *copiedScope = [[[self class] alloc] init];
    for (LynVariable *variable in _variables) {
        [copiedScope.variables addObject:variable.copy];
    }
    return copiedScope;
}

#pragma mark Properties

- (LynScope*)superScope{
    return _superScope;
}

- (void)setSuperScope:(LynScope *)superScope{
    _superScope = superScope;
    
    [self prepareForNotifications];
    [self checkAllVariableNames];
    
    if (EditMode) {
        [NotificationCenter postNotificationName:LynScopeSuperScopeChangedNotification
                                          object:self];
    }
}

#pragma mark Notifications

- (void)prepareForNotifications{
    if (!EditMode) return;
    [NotificationCenter removeObserver:self
                                  name:LynScopeDidAddVariableNotification
                                object:nil];
    [NotificationCenter removeObserver:self
                                  name:LynScopeWillRemoveVariableNotification
                                object:nil];
    [NotificationCenter removeObserver:self
                                  name:LynScopeVariableNameChangedNotification
                                object:nil];
    [NotificationCenter removeObserver:self
                                  name:LynScopeSuperScopeChangedNotification
                                object:nil];
    [NotificationCenter removeObserver:self
                                  name:LynVariableNameChangedNotification
                                object:nil];
    [NotificationCenter removeObserver:self
                                  name:LynVariableValueChangedNotification
                                object:nil];
    
    [NotificationCenter addObserver:self
                           selector:@selector(didAddVariable:)
                               name:LynScopeDidAddVariableNotification
                             object:self];
    [NotificationCenter addObserver:self
                           selector:@selector(willRemoveVariable:)
                               name:LynScopeWillRemoveVariableNotification
                             object:self];
    for (LynVariable *variable in _variables) {
        [NotificationCenter addObserver:self
                               selector:@selector(nameOfVariableChanged:)
                                   name:LynVariableNameChangedNotification
                                 object:variable];
        [NotificationCenter addObserver:self
                               selector:@selector(valueOfVariableChanged:)
                                   name:LynVariableValueChangedNotification
                                 object:variable];
    }
    
    if (_superScope) {
        LynScope *superScope = _superScope;
        while (superScope) {
            [NotificationCenter addObserver:self
                                   selector:@selector(didAddVariableToSuperScope:)
                                       name:LynScopeDidAddVariableNotification
                                     object:superScope];
            [NotificationCenter addObserver:self
                                   selector:@selector(willRemoveVariableFromSuperScope:)
                                       name:LynScopeWillRemoveVariableNotification
                                     object:superScope];
            [NotificationCenter addObserver:self
                                   selector:@selector(nameOfVariableInSuperScopeChanged:)
                                       name:LynScopeVariableNameChangedNotification
                                     object:superScope];
            [NotificationCenter addObserver:self
                                   selector:@selector(superScopeOfSuperScopeChanged:)
                                       name:LynScopeSuperScopeChangedNotification
                                     object:superScope];
            superScope = superScope.superScope;
        }
        
    }
}

- (void)didAddVariable: (NSNotification*)notification{
    LynVariable *newVariable = notification.userInfo[@"variable"];
    [self checkNameOfVariable:newVariable];
    [NotificationCenter addObserver:self
                           selector:@selector(nameOfVariableChanged:)
                               name:LynVariableNameChangedNotification
                             object:newVariable];
}

- (void)willRemoveVariable: (NSNotification*)notification{
    LynVariable *oldVariable = notification.userInfo[@"variable"];
    [NotificationCenter removeObserver:self
                                  name:LynVariableNameChangedNotification
                                object:oldVariable];
}

- (void)nameOfVariableChanged: (NSNotification*)notification{
    LynVariable *variable = notification.object;
    [self checkNameOfVariable:variable];
    if (EditMode) {
        [NotificationCenter postNotificationName:LynScopeVariableNameChangedNotification
                                          object:self
                                        userInfo:@{@"variable" : variable}];
    }
}

- (void)valueOfVariableChanged: (NSNotification*)notification{
    LynVariable *variable = notification.object;
    if (EditMode) {
        [NotificationCenter postNotificationName:LynScopeVariableValueChangedNotification
                                          object:self
                                        userInfo:@{@"variable" : variable}];
    }
}

- (void)didAddVariableToSuperScope: (NSNotification*)notification{
    LynVariable *newVariable = notification.userInfo[@"variable"];
    LynVariable *ownVariableWithSameName = [self variableNamed:newVariable.name];
    if (ownVariableWithSameName) {
        [self checkNameOfVariable:newVariable];
    }
    [NotificationCenter addObserver:self
                           selector:@selector(nameOfVariableInSuperScopeChanged:)
                               name:LynVariableNameChangedNotification
                             object:newVariable];
}

- (void)willRemoveVariableFromSuperScope: (NSNotification*)notification{
    LynVariable *oldVariable = notification.userInfo[@"variable"];
    [NotificationCenter removeObserver:self
                                  name:LynVariableNameChangedNotification
                                object:oldVariable];
}

- (void)nameOfVariableInSuperScopeChanged: (NSNotification*)notification{
    LynVariable *variable = notification.userInfo[@"variable"];
    LynVariable *ownVariableWithSameName = [self variableNamed:variable.name];
    if (ownVariableWithSameName) {
        [self checkNameOfVariable:ownVariableWithSameName];
    }
}

- (void)superScopeOfSuperScopeChanged: (NSNotification*)notification{
    [self prepareForNotifications];
    [self checkAllVariableNames];
}

- (void)checkNameOfVariable: (LynVariable*)variable{
    if (!_superScope) return;
    
    NSString *name = variable.name;
    while ([_superScope hasVariableNamed:name inSuperScopes:YES]) {
        name = [@"_" stringByAppendingString:name];
    }
    if (![variable.name isEqualToString:name]) {
        [variable setName:name];
    }
}

- (void)checkAllVariableNames{
    if (!_superScope) return;
    
    for (LynVariable *variable in _variables) {
        NSString *name = variable.name;
        while ([_superScope hasVariableNamed:name inSuperScopes:YES]) {
            name = [@"_" stringByAppendingString:name];
        }
        [variable setName:name];
    }
}

#pragma mark Getting Variables

- (BOOL)hasVariableNamed:(NSString *)name{
    for (LynVariable *variable in _variables) {
        if ([variable.name isEqualToString:name]) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)hasVariableNamed:(NSString *)name inSuperScopes:(BOOL)includeSuperScope{
    if ([self hasVariableNamed:name]) return YES;
    if (!includeSuperScope) return NO;
    if (_superScope) {
        return [_superScope hasVariableNamed:name inSuperScopes:YES];
    }else{
        return NO;
    }
}

- (LynVariable *)variableNamed:(NSString *)name{
    for (LynVariable *variable in _variables) {
        if ([variable.name isEqualToString:name]) {
            return variable;
        }
    }
    return nil;
}

- (LynVariable *)variableNamed:(NSString *)name inSuperScopes:(BOOL)includeSuperScope{
    LynVariable *result = [self variableNamed:name];
    if (result) return result;
    if (!includeSuperScope) return nil;
    if (_superScope) {
        return [_superScope variableNamed:name inSuperScopes:YES];
    }else{
        return nil;
    }
}

@end
