//
//  LynCommands.h
//  Lyn
//
//  Created by Programmieren on 17.08.13.
//  Copyright (c) 2013 Arne Philipeit Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LynComment.h"
#import "LynCommandCallFunction.h"
#import "LynCommandIf.h"
#import "LynCommandForLoop.h"
#import "LynCommandWhileLoop.h"
#import "LynCommandOpenApplication.h"
#import "LynCommandOpenFile.h"
#import "LynCommandOpenFileWithApplication.h"
#import "LynCommandPostNotification.h"
#import "LynCommandPlaySound.h"
#import "LynCommandWait.h"
#import "LynCommandWaitOneSecond.h"
#import "LynCommandScanBoolean.h"
#import "LynCommandScanInteger.h"
#import "LynCommandScanString.h"
#import "LynCommandWriteInteger.h"
#import "LynCommandWriteString.h"
#import "LynCommandWriteLineBreak.h"

@interface LynCommands : NSObject

+ (NSArray*)commands;

+ (NSUInteger)numberOfGroups;
+ (NSArray*)groups;
+ (NSString*)nameOfGroup: (NSUInteger)index;
+ (NSArray*)memebersOfGroup: (NSUInteger)index;

@end
