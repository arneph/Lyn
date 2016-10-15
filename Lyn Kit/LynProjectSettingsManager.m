//
//  LynKitProjectSettingsManager.m
//  Lyn
//
//  Created by Programmieren on 29.09.13.
//  Copyright (c) 2013 Arne Philipeit Software. All rights reserved.
//

#import "LynProjectSettingsManager.h"

@implementation LynProjectSettingsManager

+ (LynProjectSettingsManager *)managerForProject:(LynProject *)project{
    if (!project) {
        @throw NSInvalidArgumentException;
    }
    return [[LynProjectSettingsManager alloc] initForProject:project];
}

- (id)initForProject: (LynProject*)project{
    self = [super init];
    if (self) {
        if (!project) {
            @throw NSInvalidArgumentException;
        }
        _project = project;
    }
    return self;
}

#pragma mark Colors

- (NSColor *)colorForType:(NSString *)type{
    NSMutableDictionary *settings = _project.settings;
    NSDictionary *colors = settings[@"colors"];
    if (!colors) {
        NSColor *newColor = [NSColor colorWithSRGBRed:1 green:1 blue:1 alpha:1];
        if ([type isEqualToString:@"Function"]) newColor = [NSColor colorWithCalibratedWhite:.9 alpha:1];
        if ([type isEqualToString:@"Comment"]) newColor = [NSColor colorWithSRGBRed:1 green:1 blue:0 alpha:1];
        [settings setValue:@{type : newColor}
                    forKey:@"colors"];
        return newColor;
    }
    NSColor *color = colors[type];
    if (!color) {
        NSColor *newColor = [NSColor colorWithSRGBRed:1 green:1 blue:1 alpha:1];
        if ([type isEqualToString:@"Function"]) newColor = [NSColor colorWithCalibratedWhite:.9 alpha:1];
        if ([type isEqualToString:@"Comment"]) newColor = [NSColor colorWithSRGBRed:1 green:1 blue:0 alpha:1];
        NSMutableDictionary *newColors = [NSMutableDictionary dictionaryWithDictionary:colors];
        [newColors setValue: newColor
                     forKey:type];
        
        [settings setValue:[NSDictionary dictionaryWithDictionary:newColors]
                    forKey:@"colors"];
        return newColor;
    }
    return color;
}

- (void)setColor:(NSColor *)color forType:(NSString *)type{
    NSMutableDictionary *settings = _project.settings;
    NSDictionary *colors = settings[@"colors"];
    if (!colors) {
        [settings setValue:@{type : color}
                    forKey:@"colors"];
    }else{
        NSMutableDictionary *newColors = [NSMutableDictionary dictionaryWithDictionary:colors];
        [newColors setValue:color
                     forKey:type];
        
        [settings setValue:[NSDictionary dictionaryWithDictionary:newColors]
                    forKey:@"colors"];
    }
    [NotificationCenter postNotificationName:LynProjectManagerColorsChangedNotification
                                      object:self
                                    userInfo:@{@"project" : _project, @"type" : type}];
}

- (void)resetColors{
    NSMutableDictionary *settings = _project.settings;
    NSDictionary *colors = settings[@"colors"];
    NSMutableDictionary *newColors = [NSMutableDictionary dictionaryWithDictionary:colors];
    if (!colors) return;
    [colors enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop){
        NSString *strKey = key;
        if ([strKey isEqualToString:@"Function"]) {
            newColors[strKey] = [NSColor colorWithCalibratedWhite:.9 alpha:1];
        }else if ([strKey isEqualToString:@"Comment"]) {
            newColors[strKey] = [NSColor colorWithSRGBRed:1 green:1 blue:0 alpha:1];
        }else{
            newColors[strKey] = [NSColor colorWithSRGBRed:1 green:1 blue:1 alpha:1];
        }
    }];
    [settings setValue:[NSDictionary dictionaryWithDictionary:newColors]
                forKey:@"colors"];
    [NotificationCenter postNotificationName:LynProjectManagerColorsChangedNotification
                                      object:self
                                    userInfo:@{@"project" : _project}];
}

@end
