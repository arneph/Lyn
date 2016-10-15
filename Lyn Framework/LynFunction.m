//
//  LynFunction.m
//  Lyn
//
//  Created by Programmieren on 28.04.13.
//  Copyright (c) 2013 Arne Philipeit Software. All rights reserved.
//

#import "LynFunction.h"

@interface LynFunctionParametersArray : NSMutableArray

@property LynFunction *function;

@end

@implementation LynFunctionParametersArray{
    NSMutableArray *parameters;
}

- (id)init{
    self = [super init];
    if (self) {
        parameters = [[NSMutableArray alloc] init];
    }
    return self;
}

- (NSUInteger)count{
    return parameters.count;
}

- (id)objectAtIndex:(NSUInteger)index{
    return parameters[index];
}

- (void)insertObject:(id)anObject atIndex:(NSUInteger)index{
    if ([anObject isKindOfClass:[LynParameter class]]) {
        LynParameter *newParameter = (LynParameter*)anObject;
        [self postWillAddParameterNotification:newParameter];
        
        [parameters insertObject:anObject atIndex:index];
        
        [self postDidAddParameterNotification:newParameter];
        [self postNumberOfParametersChangedNotification];
    }else{
        @throw NSInvalidArgumentException;
    }
}

- (void)removeObjectAtIndex:(NSUInteger)index{
    LynParameter *oldParameter = parameters[index];
    [self postWillRemoveParameterNotification:oldParameter];
    
    [parameters removeObjectAtIndex:index];
    
    [self postDidRemoveParameterNotification:oldParameter];
    [self postNumberOfParametersChangedNotification];
}

- (void)addObject:(id)anObject{
    if ([anObject isKindOfClass:[LynParameter class]]) {
        LynParameter *newParameter = anObject;
        [self postWillAddParameterNotification:newParameter];
        
        [parameters addObject:anObject];
        
        [self postDidAddParameterNotification:newParameter];
        [self postNumberOfParametersChangedNotification];
    }else{
        @throw NSInvalidArgumentException;
    }
}

- (void)removeLastObject{
    LynParameter *oldParameter;
    [self postWillRemoveParameterNotification:oldParameter];
    
    [parameters removeLastObject];
    
    [self postDidRemoveParameterNotification:oldParameter];
    [self postNumberOfParametersChangedNotification];
}

- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject{
    if ([anObject isKindOfClass:[LynParameter class]]) {
        LynParameter *oldParameter = parameters[index];
        LynParameter *newParameter = (LynParameter*)anObject;
        [self postWillRemoveParameterNotification:oldParameter];
        [self postWillAddParameterNotification:newParameter];
        
        parameters[index] = anObject;
        
        [self postDidRemoveParameterNotification:oldParameter];
        [self postDidAddParameterNotification:newParameter];
        [self postNumberOfParametersChangedNotification];
    }else{
        @throw NSInvalidArgumentException;
    }
}

- (void)postNumberOfParametersChangedNotification{
    if (EditMode) {
        [NotificationCenter postNotificationName:LynFunctionNumberOfParametersChangedNotification
                                          object:_function];
    }
}

- (void)postWillAddParameterNotification: (LynParameter*)parameter{
    if (EditMode) {
        [NotificationCenter postNotificationName:LynFunctionWillAddParameterNotification
                                          object:_function
                                        userInfo:@{@"parameter" : parameter}];
    }
}

- (void)postDidAddParameterNotification: (LynParameter*)parameter{
    if (EditMode) {
        [NotificationCenter postNotificationName:LynFunctionDidAddParameterNotification
                                          object:_function
                                        userInfo:@{@"parameter" : parameter}];
    }
}

- (void)postWillRemoveParameterNotification: (LynParameter*)parameter{
    if (EditMode) {
        [NotificationCenter postNotificationName:LynFunctionWillRemoveParameterNotification
                                          object:_function
                                        userInfo:@{@"parameter" : parameter}];
    }
}
- (void)postDidRemoveParameterNotification: (LynParameter*)parameter{
    if (EditMode) {
        [NotificationCenter postNotificationName:LynFunctionDidRemoveParameterNotification
                                          object:_function
                                        userInfo:@{@"parameter" : parameter}];
    }
}

@end

@implementation LynFunction
@synthesize name = _name;

- (id)init{
    self = [super initWithAllowedClass:[LynCommand class]];
    if (self) {
        _name = @"";
        _parameters = [[LynFunctionParametersArray alloc] init];
        [(LynFunctionParametersArray*)_parameters setFunction:self];
        [self _prepareForNotifications];
    }
    return self;
}

- (id)initWithName:(NSString *)name{
    self = [super initWithAllowedClass:[LynCommand class]];
    if (self) {
        _name = name;
        _parameters = [[LynFunctionParametersArray alloc] init];
        [(LynFunctionParametersArray*)_parameters setFunction:self];
        [self _prepareForNotifications];
    }
    return self;
}

- (id)initWithAllowedClass:(Class)allowedClass{
    if (allowedClass != [LynCommand class]&&![allowedClass isSubclassOfClass:[LynCommand class]]) {
        @throw NSInvalidArgumentException;
        return nil;
    }
    self = [super initWithAllowedClass:allowedClass];
    if (self) {
        _name = @"";
        _parameters = [[LynFunctionParametersArray alloc] init];
        [(LynFunctionParametersArray*)_parameters setFunction:self];
        [self _prepareForNotifications];
    }
    return self;
}

- (id)initWithAllowedClass:(Class)allowedClass andCoder:(NSCoder *)aDecoder{
    if (allowedClass != [LynCommand class]&&![allowedClass isSubclassOfClass:[LynCommand class]]) {
        @throw NSInvalidArgumentException;
        return nil;
    }
    self = [super initWithAllowedClass:allowedClass andCoder:aDecoder];
    if (self) {
        _name = [aDecoder decodeObjectForKey:@"Name"];
        _parameters = [[LynFunctionParametersArray alloc] init];
        [(LynFunctionParametersArray*)_parameters setFunction:self];
        [_parameters addObjectsFromArray:[aDecoder decodeObjectForKey:@"parameters"]];
        [self _prepareForNotifications];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithAllowedClass:[LynCommand class] andCoder:aDecoder];
    if (self) {
        _name = [aDecoder decodeObjectForKey:@"Name"];
        _parameters = [[LynFunctionParametersArray alloc] init];
        [(LynFunctionParametersArray*)_parameters setFunction:self];
        [_parameters addObjectsFromArray:[aDecoder decodeObjectForKey:@"parameters"]];
        [self _prepareForNotifications];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:_name forKey:@"Name"];
    [aCoder encodeObject:_parameters forKey:@"parameters"];
}

- (id)copyWithZone:(NSZone *)zone{
    LynFunction *copiedFunction = [super copyWithZone:nil];
    copiedFunction.name = _name.copy;
    for (LynParameter *parameter in _parameters) {
        [copiedFunction.parameters addObject:parameter.copy];
    }
    return copiedFunction;
}

#pragma mark Identification

+ (NSString *)uniqueTypeIdentifier{
    return @"de.AP-Software.Lyn.LynFunction";
}

#pragma mark Properties

- (NSString *)name{
    return _name;
}

- (void)setName:(NSString *)name{
    BOOL sendNotification = (_name != name&&EditMode);
    BOOL mainFunctionInvolved = ([name isEqualToString:@"main"]||
                              [_name isEqualToString:@"main"]);
    NSString *oldName = _name;
    _name = name;
    if (sendNotification) {
        [NotificationCenter postNotificationName:LynFunctionNameChangedNotification
                                          object:self
                                        userInfo:@{@"oldName" : oldName, @"newName" : _name}];
    }
    if (mainFunctionInvolved) {
        [NotificationCenter postNotificationName:LynOutlineObjectNumberOfWarningsAndErrorsChangedNotification
                                          object:self];
    }
}

#pragma mark Parameter Access

- (LynParameter *)parameterNamed:(NSString *)parameterName{
    for (LynParameter *parameter in _parameters) {
        if ([parameter.name isEqualToString:parameterName]) {
            return parameter;
        }
    }
    return nil;
}

#pragma mark Notifications

- (void)_prepareForNotifications{
    if (!EditMode) return;
    [NotificationCenter removeObserver:self
                                  name:LynFunctionDidAddParameterNotification
                                object:nil];
    [NotificationCenter removeObserver:self
                                  name:LynFunctionWillRemoveParameterNotification
                                object:nil];
    [NotificationCenter removeObserver:self
                                  name:LynParameterNameChangedNotification
                                object:nil];
    
    [NotificationCenter addObserver:self
                           selector:@selector(didAddParameter:)
                               name:LynFunctionDidAddParameterNotification
                             object:self];
    [NotificationCenter addObserver:self
                           selector:@selector(willRemoveParameter:)
                               name:LynFunctionWillRemoveParameterNotification
                             object:self];
    for (LynParameter *parameter in _parameters) {
        [NotificationCenter addObserver:self
                               selector:@selector(parameterNameChanged:)
                                   name:LynParameterNameChangedNotification
                                 object:parameter];
    }
}

- (void)didAddParameter: (NSNotification*)notification{
    if (!EditMode) return;
    LynParameter *newParameter = notification.userInfo[@"parameter"];
    [NotificationCenter addObserver:self
                           selector:@selector(parameterNameChanged:)
                               name:LynParameterNameChangedNotification
                             object:newParameter];
}

- (void)willRemoveParameter:(NSNotification *)notification{
    if (!EditMode) return;
    LynParameter *oldParameter = notification.userInfo[@"parameter"];
    [NotificationCenter removeObserver:self
                                  name:LynParameterNameChangedNotification
                                object:oldParameter];
}

- (void)parameterNameChanged: (NSNotification*)notification{
    if (!EditMode) return;
    NSString *oldName = notification.userInfo[@"oldName"];
    NSString *newName = notification.userInfo[@"newName"];
    [NotificationCenter postNotificationName:LynFunctionParameterNameChanged
                                      object:self
                                    userInfo:@{@"parameter" : notification.object, @"oldName" : oldName, @"newName" : newName}];
}

#pragma mark Execution

- (void)executeWithDelegate:(id<LynExecutionDelegate>)delegate{
    [delegate executeObjects:self.subObjects completionHandler:^(NSArray *objects) {
        [delegate finishedExecution:self];
    }];
}

@end
