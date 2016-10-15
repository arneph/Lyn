//
//  LynGeneral.m
//  Lyn
//
//  Created by Programmieren on 20.08.13.
//  Copyright (c) 2013 Arne Philipeit Software. All rights reserved.
//

#import "LynGeneral.h"

LynMode currentMode;

NSArray *settings;

@implementation LynSetting

- (id)init{
    self = [super init];
    if (self) {
        _key = @"";
        _type = LynSettingTypeString;
        _value = @"";
    }
    return self;
}

+ (id)newWithK: (NSString*)key T: (LynSettingType)type V: (id)value{
    return [[LynSetting alloc] initK:key T:type V:value];
}

- (id)initK: (NSString*)key T: (LynSettingType)type V: (id)value{
    self = [super init];
    if (self) {
        _key = key;
        _type = type;
        _value = value;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super init];
    if (self) {
        _key = [aDecoder decodeObjectForKey:@"key"];
        _type = (LynSettingType)[aDecoder decodeIntegerForKey:@"type"];
        _value = [aDecoder decodeObjectForKey:@"value"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:_key forKey:@"key"];
    [aCoder encodeInteger:_type forKey:@"type"];
    [aCoder encodeObject:_value forKey:@"value"];
}

@end

@implementation LynGeneral

+ (LynMode)currentMode{
    return currentMode;
}

+ (void)setCurrentMode:(LynMode)mode{
    currentMode = mode;
}

+ (NSArray *)settings{
    [LynGeneral initializeSettings];
    return settings;
}

+ (LynSetting *)settingForKey:(NSString *)key{
    [LynGeneral initializeSettings];
    __block LynSetting *result = nil;
    [settings enumerateObjectsUsingBlock:^(LynSetting *setting, NSUInteger idx, BOOL *stop){
        if ([setting.key isEqualToString:key]) {
            result = setting;
            BOOL stp = YES;
            stop = &stp;
        }
    }];
    return result;
}

+ (void)setSettings:(NSArray *)newSettings{
    if (!newSettings) return;
    settings = newSettings;
    [NotificationCenter postNotificationName:LynSettingChangedNotification
                                      object:settings];
}

+ (void)setSetting:(LynSetting *)setting{
    if (!setting) return;
    [self initializeSettings];
    LynSetting *oldSetting = [LynGeneral settingForKey:setting.key];
    NSMutableArray *tmpSettings = [NSMutableArray arrayWithArray:settings];
    if (oldSetting) {
        [tmpSettings replaceObjectAtIndex:[tmpSettings indexOfObject:oldSetting] withObject:setting];
    }else{
        [tmpSettings addObject:setting];
    }
    settings = [NSArray arrayWithArray:tmpSettings];
    [NotificationCenter postNotificationName:LynSettingChangedNotification
                                      object:setting
                                    userInfo:@{@"key" : setting.key}];
}

+ (void)initializeSettings{
    if (settings) return;
    settings = @[[LynSetting newWithK:@"variables.boolean.color"
                                    T:LynSettingTypeColor
                                    V:@[@255, @255, @255]],
                 [LynSetting newWithK:@"variables.integer.color"
                                    T:LynSettingTypeColor
                                    V:@[@255, @255, @255]],
                 [LynSetting newWithK:@"variables.string.color"
                                    T:LynSettingTypeColor
                                    V:@[@255, @255, @255]]];
}

@end
