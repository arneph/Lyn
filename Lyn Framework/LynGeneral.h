//
//  LynGeneral.h
//  Lyn
//
//  Created by Programmieren on 20.08.13.
//  Copyright (c) 2013 Arne Philipeit Software. All rights reserved.
//

#import <Foundation/Foundation.h>

#define CurrentMode [LynGeneral currentMode]

#define EditMode ([LynGeneral currentMode] == LynModeEditing)
#define SaveMode (LynGeneral currentMode] == LynModeSaving)
#define RunningMode ([LynGeneral currentMode] == LynModeRunning)

#define NotificationCenter [NSNotificationCenter defaultCenter]

#define LynSettingChangedNotification @"LynSettingChangedNotification"

typedef enum{
    LynModeEditing,
    LynModeSaving,
    LynModeRunning
}LynMode;

typedef enum{
    LynDataTypeNone,
    LynDataTypeBoolean,
    LynDataTypeInteger,
    LynDataTypeString
}LynDataType;

typedef enum{
    LynSettingTypeBoolean,
    LynSettingTypeInteger,
    LynSettingTypeString,
    LynSettingTypeColor
}LynSettingType;

@interface LynSetting : NSObject <NSCoding>

@property (readonly) NSString *key;
@property (readonly) LynSettingType type;
@property id value;

+ (id)newWithK: (NSString*)key T: (LynSettingType)type V: (id)value;

- (id)initK: (NSString*)key T: (LynSettingType)type V: (id)value;

@end

@interface LynGeneral : NSObject

+ (LynMode)currentMode;
+ (void)setCurrentMode: (LynMode)mode;

+ (NSArray*)settings;
+ (LynSetting*)settingForKey: (NSString*)key;

+ (void)setSettings: (NSArray*)settings;
+ (void)setSetting: (LynSetting*)setting;

@end
