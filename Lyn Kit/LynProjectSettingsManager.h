//
//  LynKitProjectSettingsManager.h
//  Lyn
//
//  Created by Programmieren on 29.09.13.
//  Copyright (c) 2013 Arne Philipeit Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Lyn Framework/Lyn Framework.h>

#define LynProjectManagerColorsChangedNotification @"LynColorManagerColorsChangedNotification"

@interface LynProjectSettingsManager : NSObject

@property (readonly) LynProject *project;

+ (LynProjectSettingsManager*)managerForProject: (LynProject*)project;

#pragma mark Colors

- (NSColor*)colorForType: (NSString*)type;
- (void)setColor: (NSColor*)color forType: (NSString*)type;

- (void)resetColors;

@end
