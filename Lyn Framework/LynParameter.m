//
//  LynParameter.m
//  Lyn
//
//  Created by Programmieren on 19.05.13.
//  Copyright (c) 2013 Arne Philipeit Software. All rights reserved.
//

#import "LynParameter.h"

@implementation LynParameter{
    NSObject <NSCoding, NSCopying> *value;
    
    NSMutableArray *referencers;
}

@synthesize name = _name;
@synthesize parameterValue = _parameterValue;
@synthesize fillType = _fillType;
@synthesize owner = _owner;

- (id)init{
    self = [super init];
    if (self) {
        self = [super init];
        if (self) {
            _name = @"";
            value = nil;
            _parameterValue = nil;
            _fillType = LynParameterFillTypeStatic;
            
            _fixedStatic = NO;
            _fixedDynamic = NO;
            _owner = nil;
            referencers = [[NSMutableArray alloc] init];
        }
        return self;
    }
    return self;
}

- (id)initWithName:(NSString *)name owner:(id<LynParameterOwner>)owner{
    if (!name) {
        @throw NSInvalidArgumentException;
    }
    self = [super init];
    if (self) {
        _name = name;
        value = nil;
        _parameterValue = nil;
        _fillType = LynParameterFillTypeStatic;
        
        _fixedStatic = NO;
        _fixedDynamic = NO;
        _owner = owner;
        referencers = [[NSMutableArray alloc] init];
    }
    return self;
}

- (id)initFixedStaticWithName:(NSString *)name owner:(id<LynParameterOwner>)owner{
    if (!name) {
        @throw NSInvalidArgumentException;
    }
    self = [super init];
    if (self) {
        _name = name;
        value = nil;
        _parameterValue = nil;
        _fillType = LynParameterFillTypeStatic;
        
        _fixedStatic = YES;
        _fixedDynamic = NO;
        _owner = owner;
        referencers = [[NSMutableArray alloc] init];
    }
    return self;
}

- (id)initFixedDynamicWithName:(NSString *)name owner:(id<LynParameterOwner>)owner{
    if (!name) {
        @throw NSInvalidArgumentException;
    }
    self = [super init];
    if (self) {
        _name = name;
        value = nil;
        _parameterValue = nil;
        _fillType = LynParameterFillTypeDynamicFromVariable;
        
        _fixedStatic = NO;
        _fixedDynamic = YES;
        _owner = owner;
        referencers = [[NSMutableArray alloc] init];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super init];
    if (self) {
        _name = [aDecoder decodeObjectForKey:@"name"];
        value = [aDecoder decodeObjectForKey:@"value"];
        _fillType = (LynParameterFillType)[aDecoder decodeIntegerForKey:@"fillType"];
        _parameterValue = (_fillType == LynParameterFillTypeStatic) ? value : nil;
        
        _fixedStatic = [aDecoder decodeBoolForKey:@"fixedStatic"];
        _fixedDynamic = [aDecoder decodeBoolForKey:@"fixedDynamic"];
        _owner = nil;
        referencers = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:_name forKey:@"name"];
    [aCoder encodeObject:value forKey:@"value"];
    [aCoder encodeInteger:_fillType forKey:@"fillType"];
    [aCoder encodeBool:_fixedStatic forKey:@"fixedStatic"];
    [aCoder encodeBool:_fixedDynamic forKey:@"fixedDynamic"];
}

- (id)copyWithZone:(NSZone *)zone{
    LynParameter *parameterCopy;
    if (_fixedStatic) {
        parameterCopy = [[[self class] alloc] initFixedStaticWithName:_name.copy owner:nil];
    }else if (_fixedDynamic) {
        parameterCopy = [[[self class] alloc] initFixedDynamicWithName:_name.copy owner:nil];
    }else{
        parameterCopy = [[[self class] alloc] initWithName:_name.copy owner:nil];
    }
    if (_fillType == LynParameterFillTypeStatic) {
        parameterCopy.parameterValue = [self parameterValue].copy;
    }else{
        id parameterValue = [self parameterValue];
        if (parameterValue) {
            parameterCopy.parameterValue = parameterValue;
        }else if (value) {
            [parameterCopy takeCopiedValue:value.copy andFillType:_fillType];
        }else{
            parameterCopy.parameterValue = nil;
        }
    }
    return parameterCopy;
}

- (void)takeCopiedValue: (NSObject <NSCoding, NSCopying>*)val andFillType: (LynParameterFillType)fillType{
    value = val;
    _fillType = fillType;
    _parameterValue = nil;
}

- (void)dealloc{
    if ([_parameterValue isKindOfClass:[LynVariable class]]) {
        [(LynVariable*)_parameterValue removeReference:self];
    }else if ([_parameterValue isKindOfClass:[LynParameter class]]) {
        [(LynParameter*)_parameterValue removeReference:self];
    }
}

#pragma mark Properties

- (NSString *)name{
    return _name;
}

- (void)setName:(NSString *)name{
    BOOL sendNotification = (_name != name&&EditMode);
    NSString *oldName = _name;
    _name = name;
    if (sendNotification) {
        [NotificationCenter postNotificationName:LynParameterNameChangedNotification
                                          object:self
                                        userInfo:@{@"oldName" : oldName, @"newName" : _name}];
    }
}

- (NSObject<NSCoding,NSCopying> *)parameterValue{
    if (_fillType == LynParameterFillTypeStatic) return _parameterValue;
    
    if (_parameterValue) {
        return _parameterValue;
    }else if (!value) {
        return nil;
    }else if (_fillType == LynParameterFillTypeDynamicFromVariable) {
        _parameterValue = [_owner variableNamed:(NSString*)value];
        if (_parameterValue&&[(LynVariable*)_parameterValue variableType] != self.parameterType) {
            _parameterValue = nil;
            value = nil;
        }
        if (_parameterValue) {
            [(LynVariable*)_parameterValue addReference:self];
        }
        [self prepareForNotifications];
        return _parameterValue;
    }else if (_fillType == LynParameterFillTypeDynamicFromParameter) {
        _parameterValue = [_owner parameterNamed:(NSString*)value];
        if (_parameterValue&&[(LynParameter*)_parameterValue parameterType] != self.parameterType) {
            _parameterValue = nil;
            value = nil;
        }
        if (_parameterValue) {
            [(LynParameter*)_parameterValue addReference:self];
        }
        [self prepareForNotifications];
        return _parameterValue;
    }
    return nil;
}

- (void)setParameterValue:(NSObject<NSCoding,NSCopying> *)parameterValue{
    BOOL sendNotification = (parameterValue != _parameterValue&&EditMode);
    
    if ([parameterValue isKindOfClass:[LynVariable class]]||[parameterValue isKindOfClass:[LynParameter class]]) {
        if (_fixedStatic) return;
    }else{
        if (_fixedDynamic) return;
    }
    
    if ([_parameterValue isKindOfClass:[LynVariable class]]) {
        LynVariable *oldParameterValue = (LynVariable*)_parameterValue;
        [oldParameterValue removeReference: self];
    }else if ([_parameterValue isKindOfClass:[LynParameter class]]) {
        LynParameter *oldParameterValue = (LynParameter*)_parameterValue;
        [oldParameterValue removeReference: self];
    }
    
    if ([parameterValue isKindOfClass:[LynVariable class]]) {
        LynVariable *newParameterValue = (LynVariable*)parameterValue;
        [newParameterValue addReference: self];
        value = newParameterValue.name;
        _parameterValue = newParameterValue;
        _fillType = LynParameterFillTypeDynamicFromVariable;
        [self prepareForNotifications];
    }else if ([parameterValue isKindOfClass:[LynParameter class]]) {
        LynParameter *newParameterValue = (LynParameter*)parameterValue;
        [newParameterValue addReference: self];
        value = newParameterValue.name;
        _parameterValue = newParameterValue;
        _fillType = LynParameterFillTypeDynamicFromParameter;
        [self prepareForNotifications];
    }else{
        value = parameterValue;
        _parameterValue = parameterValue;
        if (parameterValue) _fillType = LynParameterFillTypeStatic;
        [self prepareForNotifications];
    }
    
    if (sendNotification) {
        [NotificationCenter postNotificationName:LynParameterValueChangedNotification
                                          object:self];
        [NotificationCenter postNotificationName:LynParameterDescriptionChangedNotification
                                          object:self];
    }
}

- (LynParameterFillType)fillType{
    return _fillType;
}

- (void)setFillType:(LynParameterFillType)fillType{
    if (_fixedStatic) return;
    if (_fixedDynamic&&fillType == LynParameterFillTypeStatic) return;
    if (_fillType != fillType) {
        value = nil;
        if ([_parameterValue isKindOfClass:[LynVariable class]]) {
            LynVariable *oldParameterValue = (LynVariable*)_parameterValue;
            [oldParameterValue removeReference: self];
        }else if ([_parameterValue isKindOfClass:[LynParameter class]]) {
            LynParameter *oldParameterValue = (LynParameter*)_parameterValue;
            [oldParameterValue removeReference: self];
        }
        
        _parameterValue = nil;
        _fillType = fillType;
        if (EditMode) {
            [NotificationCenter postNotificationName:LynParameterFillTypeChangedNotification
                                          object:self];
        }
        [self prepareForNotifications];
    }
}

- (id<LynParameterOwner>)owner{
    return _owner;
}

- (void)setOwner:(id<LynParameterOwner>)owner{
    _owner = owner;
    
    if (_fillType == LynParameterFillTypeDynamicFromVariable) {
        LynVariable *oldParameterValue = (LynVariable*)_parameterValue;
        LynVariable *newParameterValue = [_owner variableNamed:(NSString*)value];
        
        if (newParameterValue&&newParameterValue != oldParameterValue) {
            [oldParameterValue removeReference:self];
            if (newParameterValue.variableType == self.parameterType) {
                [newParameterValue addReference:self];
                _parameterValue = newParameterValue;
            }else{
                _parameterValue = nil;
            }
            [self prepareForNotifications];
        }else if (!newParameterValue) {
            _parameterValue = nil;
            [oldParameterValue removeReference:self];
        }
        [self prepareForNotifications];
        if (oldParameterValue != newParameterValue&&EditMode) {
            [NotificationCenter postNotificationName:LynParameterValueChangedNotification
                                              object:self];
            [NotificationCenter postNotificationName:LynParameterDescriptionChangedNotification
                                              object:self];
        }
    }else if (_fillType == LynParameterFillTypeDynamicFromParameter) {
        LynParameter *oldParameterValue = (LynParameter*)_parameterValue;
        LynParameter *newParameterValue = [_owner parameterNamed:(NSString*)value];
        
        if (newParameterValue&&newParameterValue != oldParameterValue) {
            [oldParameterValue removeReference:self];
            if (newParameterValue.parameterType == self.parameterType) {
                [newParameterValue addReference:self];
                _parameterValue = newParameterValue;
            }else{
                _parameterValue = nil;
            }
        }else if (!newParameterValue) {
            _parameterValue = nil;
            [oldParameterValue removeReference:self];
        }
        [self prepareForNotifications];
        if (oldParameterValue != newParameterValue&&EditMode) {
            [NotificationCenter postNotificationName:LynParameterValueChangedNotification
                                              object:self];
            [NotificationCenter postNotificationName:LynParameterDescriptionChangedNotification
                                              object:self];
        }
    }
}

#pragma mark Parameter Type

+ (LynDataType)parameterType{
    return LynDataTypeNone;
}

- (LynDataType)parameterType{
    return [[self class] parameterType];
}

#pragma mark Parameter Value

- (NSObject *)absoluteValue{
    return (_fillType == LynParameterFillTypeStatic) ? _parameterValue : nil;
}

- (NSString *)parameterValueDescription{
    if (_fillType == LynParameterFillTypeDynamicFromVariable) {
        LynVariable *variable = (LynVariable*)_parameterValue;
        return variable.name;
    }else if (_fillType == LynParameterFillTypeDynamicFromParameter) {
        LynParameter *parameter = (LynParameter*)_parameterValue;
        return parameter.name;
    }else{
        return @"";
    }
}

#pragma mark Refrencing

- (NSUInteger)referenceCount{
    return referencers.count;
}

- (void)addReference: (id)referencer{
    if ([referencers indexOfObject:referencer] != NSNotFound) return;
    [referencers addObject:referencer];
    if (EditMode) {
        [NotificationCenter postNotificationName:LynParameterAddedReferenceNotification
                                          object:self];
        [NotificationCenter postNotificationName:LynParameterReferenceCountChangedNotification
                                          object:self];
    }
}

- (void)removeReference: (id)referencer{
    if ([referencers indexOfObject:referencer] == NSNotFound) return;
    [referencers removeObject:referencer];
    if (EditMode) {
        [NotificationCenter postNotificationName:LynParameterRemovedReferenceNotification
                                          object:self];
        [NotificationCenter postNotificationName:LynParameterReferenceCountChangedNotification
                                          object:self];
    }
}

#pragma mark Detecting Errors

- (BOOL)isDynamicValueNotSpecified{
    if (_fillType == LynParameterFillTypeStatic) return NO;
    return (!self.parameterValue);
}

#pragma mark Notifications

- (void)prepareForNotifications{
    if (!EditMode) return;
    [NotificationCenter removeObserver:self
                                  name:LynVariableNameChangedNotification
                                object:nil];
    [NotificationCenter removeObserver:self
                                  name:LynParameterNameChangedNotification
                                object:nil];
    if ([_parameterValue isKindOfClass:[LynVariable class]]) {
        [NotificationCenter addObserver:self
                               selector:@selector(nameOfRefrencedObjectChanged:)
                                   name:LynVariableNameChangedNotification
                                 object:_parameterValue];
    }else if ([_parameterValue isKindOfClass:[LynParameter class]]) {
        [NotificationCenter addObserver:self
                               selector:@selector(nameOfRefrencedObjectChanged:)
                                   name:LynParameterNameChangedNotification
                                 object:_parameterValue];
    }
}

- (void)nameOfRefrencedObjectChanged: (NSNotification*)notification{
    [NotificationCenter postNotificationName:LynParameterDescriptionChangedNotification
                                      object:self];
}

@end
