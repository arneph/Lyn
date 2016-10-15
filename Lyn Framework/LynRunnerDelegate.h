//
//  LynRunnerDelegate.h
//  Lyn
//
//  Created by Programmieren on 28.04.13.
//  Copyright (c) 2013 Arne Philipeit Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol LynRunnerDelegate <NSObject>

- (BOOL)canUseTimer;

- (void)startedExecuting;
- (void)stoppedExecuting;
- (void)finishedExecuting;

- (void)openApplication: (NSString*)application;
- (void)openFile: (NSString*)file;
- (void)openFile: (NSString*)file withApplication: (NSString*)application;

- (void)playSound: (NSString*)sound atVolume:(float)volume complete:(BOOL)complete;

- (void)postNotification: (NSString*)text;

- (void)scanBoolean: (void(^)(NSNumber *result))completionHandler;
- (void)scanInteger: (void(^)(NSNumber *result))completionHandler;
- (void)scanString: (void(^)(NSString *result))completionHandler;

- (void)write: (NSString*)string;
- (void)writeByRunner: (NSString*)string;

@end
