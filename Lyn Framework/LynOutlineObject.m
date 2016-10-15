//
//  LynOutlineObject.m
//  Lyn
//
//  Created by Programmieren on 27.04.13.
//  Copyright (c) 2013 Arne Philipeit Software. All rights reserved.
//

#import "LynOutlineObject.h"

@interface LynOutlineObjectSubObjectsArray : NSMutableArray

@property LynOutlineObject *owner;

@property (readonly) Class allowedClass;

- (id)initWithAllowedClass: (Class)allowedClass;

@end

@implementation LynOutlineObjectSubObjectsArray{
    NSMutableArray *objects;
}

- (id)init{
    self = [super init];
    if (self) {
        _allowedClass = [LynOutlineObject class];
        objects = [[NSMutableArray alloc] init];
    }
    return self;
}

- (id)initWithAllowedClass:(Class)allowedClass{
    self = [super init];
    if (self) {
        if (allowedClass == [LynOutlineObject class]||[allowedClass isSubclassOfClass:[LynOutlineObject class]]) {
            _allowedClass = allowedClass;
        }else{
            @throw NSInvalidArgumentException;
        }
        objects = [[NSMutableArray alloc] init];
    }
    return self;
}

- (NSUInteger)count{
    return objects.count;
}

- (id)objectAtIndex:(NSUInteger)index{
    return objects[index];
}

- (void)insertObject:(id)anObject atIndex:(NSUInteger)index{
    if ([anObject isKindOfClass:_allowedClass]) {
        LynOutlineObject *newSubObject = anObject;
        
        [self postWillAddSubObjectNotificationWithSubObjects:newSubObject];
        
        [objects insertObject:anObject atIndex:index];
        newSubObject.parent = _owner;
        
        [self postDidAddSubObjectNotificationWithSubObjects:newSubObject];
        [self postNumberOfSubObjectsChangedNotification];
    }else{
        @throw NSInvalidArgumentException;
    }
}

- (void)removeObjectAtIndex:(NSUInteger)index{
    LynOutlineObject *oldSubObject = self[index];
    [self postWillRemoveSubObjectNotificationWithSubObjects:oldSubObject];
    
    [objects removeObjectAtIndex:index];
    oldSubObject.parent = nil;
    
    [self postDidRemoveSubObjectNotificationWithSubObjects:oldSubObject];
    [self postNumberOfSubObjectsChangedNotification];
}

- (void)addObject:(id)anObject{
    if ([anObject isKindOfClass:_allowedClass]) {
        LynOutlineObject *newSubObject = anObject;
        
        [self postWillAddSubObjectNotificationWithSubObjects:newSubObject];
        
        [objects addObject:anObject];
        newSubObject.parent = _owner;
        
        [self postDidAddSubObjectNotificationWithSubObjects:newSubObject];
        [self postNumberOfSubObjectsChangedNotification];
    }else{
        @throw NSInvalidArgumentException;
    }
}

- (void)removeLastObject{
    LynOutlineObject *oldSubObject = self.lastObject;
    
    [self postWillRemoveSubObjectNotificationWithSubObjects:oldSubObject];
    
    [objects removeLastObject];
    oldSubObject.parent = nil;
    
    [self postDidRemoveSubObjectNotificationWithSubObjects:oldSubObject];
    [self postNumberOfSubObjectsChangedNotification];
}

- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject{
    if ([anObject isKindOfClass:_allowedClass]) {
        LynOutlineObject *oldSubObject = self[index];
        LynOutlineObject *newSubObject = anObject;
        
        [self postWillRemoveSubObjectNotificationWithSubObjects:oldSubObject];
        [self postWillAddSubObjectNotificationWithSubObjects:newSubObject];
        
        objects[index] = anObject;
        oldSubObject.parent = nil;
        newSubObject.parent = _owner;
        
        [self postDidRemoveSubObjectNotificationWithSubObjects:oldSubObject];
        [self postDidAddSubObjectNotificationWithSubObjects:newSubObject];
        [self postNumberOfSubObjectsChangedNotification];
    }else{
        @throw NSInvalidArgumentException;
    }
}

- (void)postNumberOfSubObjectsChangedNotification{
    if (EditMode) {
        [NotificationCenter postNotificationName:LynOutlineObjectNumberOfSubObjectsChangedNotification
                                          object:_owner];
    }
}

- (void)postWillAddSubObjectNotificationWithSubObjects: (id)subObject{
    if (EditMode) {
        [NotificationCenter postNotificationName:LynOutlineObjectWillAddSubObjectNotification
                                          object:_owner
                                        userInfo:@{@"subObject" : subObject}];
    }
}

- (void)postDidAddSubObjectNotificationWithSubObjects: (id)subObject{
    if (EditMode) {
        [NotificationCenter postNotificationName:LynOutlineObjectDidAddSubObjectNotification
                                          object:_owner
                                        userInfo:@{@"subObject" : subObject}];
    }
}

- (void)postWillRemoveSubObjectNotificationWithSubObjects: (id)subObject{
    if (EditMode) {
        [NotificationCenter postNotificationName:LynOutlineObjectWillRemoveSubObjectNotification
                                          object:_owner
                                        userInfo:@{@"subObject" : subObject}];
    }
}
- (void)postDidRemoveSubObjectNotificationWithSubObjects: (id)subObject{
    if (EditMode) {
        [NotificationCenter postNotificationName:LynOutlineObjectDidRemoveSubObjectNotification
                                          object:_owner
                                        userInfo:@{@"subObject" : subObject}];
    }
}

@end

@implementation LynOutlineObject
@synthesize parent = _parent;
@synthesize subObjects = _subObjects;
@synthesize scope = _scope;

- (id)init{
    self = [super init];
    if (self) {
        _parent = nil;
        
        LynOutlineObjectSubObjectsArray *subObjects;
        subObjects = [[LynOutlineObjectSubObjectsArray alloc] initWithAllowedClass:[LynOutlineObject class]];
        subObjects.owner = self;
        _subObjects = subObjects;
        
        _allowedSubObjectClass = [LynOutlineObject class];
        
        if ([[self class] hasScope]) {
            _scope = [[LynScope alloc] initWithOwner:self superScope:nil];
        }
        
        [self prepareForNotifications];
    }
    return self;
}

- (id)initWithAllowedClass: (Class)allowedClass{
    self = [super init];
    if (self) {
        if (allowedClass != [LynOutlineObject class]&&![allowedClass isSubclassOfClass:[LynOutlineObject class]]) {
            @throw NSInvalidArgumentException;
            return nil;
        }
        _parent = nil;
        
        LynOutlineObjectSubObjectsArray *subObjects;
        subObjects = [[LynOutlineObjectSubObjectsArray alloc] initWithAllowedClass:allowedClass];
        subObjects.owner = self;
        _subObjects = subObjects;
        
        _allowedSubObjectClass = allowedClass;
        
        if ([[self class] hasScope]) {
            _scope = [[LynScope alloc] initWithOwner:self superScope:nil];
        }
        
        [self prepareForNotifications];
    }
    return self;
}

- (id)initWithAllowedClass: (Class)allowedClass andCoder: (NSCoder*)aDecoder{
    self = [super init];
    if (self) {
        if (allowedClass != [LynOutlineObject class]&&![allowedClass isSubclassOfClass:[LynOutlineObject class]]) {
            @throw NSInvalidArgumentException;
            return nil;
        }
        _parent = nil;
        
        LynOutlineObjectSubObjectsArray *subObjects;
        subObjects = [[LynOutlineObjectSubObjectsArray alloc] initWithAllowedClass:allowedClass];
        subObjects.owner = self;
        [subObjects addObjectsFromArray:[aDecoder decodeObjectForKey:@"SubObjects"]];
        _subObjects = subObjects;
        
        _allowedSubObjectClass = allowedClass;
        
        if ([[self class] hasScope]) {
            _scope = [aDecoder decodeObjectForKey:@"scope"];
            _scope.scopeOwner = self;
            
            for (LynOutlineObject *subObject in _subObjects) {
                if ([[subObject class] hasScope]) {
                    subObject.scope.superScope = _scope;
                }
            }
        }
        
        [self prepareForNotifications];
    }
    return self;
}

- (id)initWithCoder: (NSCoder*)aDecoder{
    self = [super init];
    if (self) {
        _parent = nil;
        
        LynOutlineObjectSubObjectsArray *subObjects;
        subObjects = [[LynOutlineObjectSubObjectsArray alloc] initWithAllowedClass:[LynOutlineObject class]];
        subObjects.owner = self;
        [subObjects addObjectsFromArray:[aDecoder decodeObjectForKey:@"SubObjects"]];
        _subObjects = subObjects;
        
        _allowedSubObjectClass = [LynOutlineObject class];
        
        if ([[self class] hasScope]) {
            _scope = [aDecoder decodeObjectForKey:@"scope"];
            _scope.scopeOwner = self;
            
            for (LynOutlineObject *subObject in _subObjects) {
                if ([[subObject class] hasScope]) {
                    subObject.scope.superScope = _scope;
                }
            }
        }
        
        [self prepareForNotifications];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:_subObjects forKey:@"SubObjects"];
    if ([[self class] hasScope]) [aCoder encodeObject:_scope forKey:@"scope"];
}

- (id)copyWithZone:(NSZone *)zone{
    LynOutlineObject *copiedObject = [[[self class] alloc] initWithAllowedClass:self.allowedSubObjectClass];
    for (LynOutlineObject *subObject in _subObjects) {
        [copiedObject.subObjects addObject:subObject.copy];    
    }
    if ([[self class] hasScope]) [copiedObject takeCopiedScope:_scope.copy];
    return copiedObject;
}

- (void)takeCopiedScope: (LynScope*)scope{
    _scope = scope;
}

#pragma mark Properties

- (LynOutlineObject *)parent{
    return _parent;
}

- (void)setParent:(LynOutlineObject *)parent{
    BOOL sendNotification = (_parent != parent&&EditMode);
    _parent = parent;
    if ([[self class] hasScope]) {
        if (_parent&&[_parent conformsToProtocol:@protocol(LynScopeOwner)]) {
            _scope.superScope = [_parent scope];
        }else{
            _scope.superScope = nil;
        }
    }
    if (sendNotification) {
        [NotificationCenter postNotificationName:LynOutlineObjectParentChangedNotification
                                          object:self];
    }
}

- (NSMutableArray *)subObjects{
    return ([[self class] allowsSubObjects]) ? _subObjects : nil;
}

#pragma mark Hierarchy

+ (BOOL)allowsSubObjects{
    return YES;
}

- (NSArray*)parents{
    NSMutableArray *parents = [[NSMutableArray alloc] init];
    LynOutlineObject *parent = self.parent;
    while (parent) {
        [parents addObject:parent];
        parent = parent.parent;
    }
    return [NSArray arrayWithArray:parents];
}

#pragma mark Scope

+ (BOOL)hasScope{
    return YES;
}

- (LynScope *)scope{
    return ([[self class] hasScope]) ? _scope : nil;
}

#pragma mark ScopeOwner

- (LynScope *)superScope{
    return ([[self class] hasScope]) ? _scope.superScope : nil;
}

- (id)superScopeOwner{
    return ([[self class] hasScope]) ? _scope.superScope.scopeOwner : nil;
}

- (NSString *)name{
    return ([[self class] hasScope]) ? @"" : nil;
}

#pragma mark Warnings & Errors

- (BOOL)hasWarnings{
    return (self.warnings.count > 0);
}

- (BOOL)hasErrors{
    return (self.errors.count > 0);
}

- (BOOL)hasWarningsIncludingSubObjects: (BOOL)includeSubObjects{
    if (self.hasWarnings) return YES;
    if (!includeSubObjects) return NO;
    for (LynOutlineObject *subObject in _subObjects) {
        if ([subObject hasWarningsIncludingSubObjects:YES]) return YES;
    }
    return NO;
}

- (BOOL)hasErrorsIncludingSubObjects: (BOOL)includeSubObjects{
    if (self.hasErrors) return YES;
    if (!includeSubObjects) return NO;
    for (LynOutlineObject *subObject in _subObjects) {
        if ([subObject hasErrorsIncludingSubObjects:YES]) return YES;
    }
    return NO;
}

- (NSArray *)warnings{
    return @[];
}

- (NSArray *)errors{
    return @[];
}

- (NSArray*)warningsIncludingSubObjects: (BOOL)includeSubObjects{
    if (!includeSubObjects) return self.warnings;
    NSMutableArray *warnings = [[NSMutableArray alloc] initWithArray:self.warnings];
    for (LynOutlineObject *subObject in _subObjects) {
        [warnings addObjectsFromArray:[subObject warningsIncludingSubObjects:YES]];
    }
    return [NSArray arrayWithArray:warnings];
}

- (NSArray*)errorsIncludingSubObjects: (BOOL)includeSubObjects{
    if (!includeSubObjects) return self.errors;
    NSMutableArray *errors = [[NSMutableArray alloc] initWithArray:self.errors];
    for (LynOutlineObject *subObject in _subObjects) {
        [errors addObjectsFromArray:[subObject errorsIncludingSubObjects:YES]];
    }
    return [NSArray arrayWithArray:errors];
}

#pragma mark Identification

+ (NSString *)uniqueTypeIdentifier{
    @throw [[NSException alloc] initWithName:@"Unimplemented Method"
                                      reason:@"The Method uniqueTypeIdentifier of LynOutlineObject must be implemented!"
                                    userInfo:nil];
    return nil;
}

#pragma mark Notifications

- (void)prepareForNotifications{
    if (!EditMode) return;
    //SubObject Handling
    [NotificationCenter addObserver:self
                           selector:@selector(numberOfSubObjectsChanged:)
                               name:LynOutlineObjectNumberOfSubObjectsChangedNotification
                             object:self];
    [NotificationCenter addObserver:self
                           selector:@selector(willAddSubObject:)
                               name:LynOutlineObjectWillAddSubObjectNotification
                             object:self];
    [NotificationCenter addObserver:self
                           selector:@selector(didAddSubObject:)
                               name:LynOutlineObjectDidAddSubObjectNotification
                             object:self];
    [NotificationCenter addObserver:self
                           selector:@selector(willRemoveSubObject:)
                               name:LynOutlineObjectWillRemoveSubObjectNotification
                             object:self];
    [NotificationCenter addObserver:self
                           selector:@selector(didRemoveSubObject:)
                               name:LynOutlineObjectDidRemoveSubObjectNotification
                             object:self];
    
    //Warnings and Errors
    [NotificationCenter addObserver:self
                           selector:@selector(numberOfWarningsAndErrorsChanged:)
                               name:LynOutlineObjectNumberOfWarningsAndErrorsChangedNotification
                             object:self];
    [NotificationCenter addObserver:self
                           selector:@selector(numberOfWarningsChanged:)
                               name:LynOutlineObjectNumberOfWarningsChangedNotification
                             object:self];
    [NotificationCenter addObserver:self
                           selector:@selector(numberOfErrorsChanged:)
                               name:LynOutlineObjectNumberOfErrorsChangedNotification
                             object:self];
    for (LynOutlineObject *subObject in _subObjects) {
        [NotificationCenter addObserver:self
                               selector:@selector(numberOfWarningsAndErrorsChanged:)
                                   name:LynOutlineObjectNumberOfWarningsAndErrorsChangedNotification
                                 object:subObject];
        [NotificationCenter addObserver:self
                               selector:@selector(numberOfWarningsChanged:)
                                   name:LynOutlineObjectNumberOfWarningsChangedNotification
                                 object:subObject];
        [NotificationCenter addObserver:self
                               selector:@selector(numberOfErrorsChanged:)
                                   name:LynOutlineObjectNumberOfErrorsChangedNotification
                                 object:subObject];
    }
}

- (void)numberOfSubObjectsChanged: (NSNotification*)notification{
}

- (void)willAddSubObject: (NSNotification*)notification{
}

- (void)didAddSubObject: (NSNotification*)notification{
    LynOutlineObject *subObject = notification.userInfo[@"subObject"];
    [NotificationCenter addObserver:self
                           selector:@selector(numberOfWarningsAndErrorsChanged:)
                               name:LynOutlineObjectNumberOfWarningsAndErrorsChangedNotification
                             object:subObject];
    [NotificationCenter addObserver:self
                           selector:@selector(numberOfWarningsChanged:)
                               name:LynOutlineObjectNumberOfWarningsChangedNotification
                             object:subObject];
    [NotificationCenter addObserver:self
                           selector:@selector(numberOfErrorsChanged:)
                               name:LynOutlineObjectNumberOfErrorsChangedNotification
                             object:subObject];
    if (subObject.hasWarnings&&EditMode) {
        [NotificationCenter postNotificationName:LynOutlineObjectNumberOfWarningsChangedNotification
                                          object:self];
    }
    if (subObject.hasErrors&&EditMode) {
        [NotificationCenter postNotificationName:LynOutlineObjectNumberOfErrorsChangedNotification
                                          object:self];
    }
}

- (void)willRemoveSubObject: (NSNotification*)notification{
    LynOutlineObject *subObject = notification.userInfo[@"subObject"];
    [NotificationCenter removeObserver:self
                                  name:LynOutlineObjectNumberOfWarningsAndErrorsChangedNotification
                                object:subObject];
    [NotificationCenter removeObserver:self
                                  name:LynOutlineObjectNumberOfWarningsChangedNotification
                                object:subObject];
    [NotificationCenter removeObserver:self
                                  name:LynOutlineObjectNumberOfErrorsChangedNotification
                                object:subObject];
}

- (void)didRemoveSubObject: (NSNotification*)notification{
    LynOutlineObject *subObject = notification.userInfo[@"subObject"];
    if (subObject.hasWarnings&&EditMode) {
        [NotificationCenter postNotificationName:LynOutlineObjectNumberOfWarningsChangedNotification
                                          object:self];
    }
    if (subObject.hasErrors&&EditMode) {
        [NotificationCenter postNotificationName:LynOutlineObjectNumberOfErrorsChangedNotification
                                          object:self];
    }
}

- (void)numberOfWarningsAndErrorsChanged:(NSNotification *)notification{
    if ([_subObjects indexOfObject:notification.object] != NSNotFound) {
        [NotificationCenter postNotificationName:LynOutlineObjectNumberOfWarningsAndErrorsChangedNotification
                                          object:self];
    }
}

- (void)numberOfWarningsChanged:(NSNotification *)notification{
    if ([_subObjects indexOfObject:notification.object] != NSNotFound) {
        [NotificationCenter postNotificationName:LynOutlineObjectNumberOfWarningsChangedNotification
                                          object:self];
    }
}

- (void)numberOfErrorsChanged:(NSNotification *)notification{
    if ([_subObjects indexOfObject:notification.object] != NSNotFound) {
        [NotificationCenter postNotificationName:LynOutlineObjectNumberOfErrorsChangedNotification
                                          object:self];
    }
}

@end
