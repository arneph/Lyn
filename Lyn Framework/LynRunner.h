//
//  LynRunner.h
//  Lyn
//
//  Created by Programmieren on 28.04.13.
//  Copyright (c) 2013 Arne Philipeit Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LynCodeObjects.h"
#import "LynRunnerDelegate.h"
#import "LynRunnerDebugDelegate.h"

#define LynRunnerStartedNotification @"LynRunnerStartedNotification"
#define LynRunnerStoppedNotification @"LynRunnerStoppedNotification"

#define MinimumWaitTimeForCommands .001

@interface LynRunner : NSObject <LynExecutionDelegate>

@property (readonly)id executedObject;
@property (readonly)BOOL running;

@property id<LynRunnerDelegate> delegate;
@property id<LynRunnerDebugDelegate> debugDelegate;

- (id)initWithExecutedObject: (id)object;
- (id)initWithExecutedObject: (id)object andDelegate: (id<LynRunnerDelegate>)delegate;

- (void)start;
- (void)stop;

- (void)startWithoutMessage;
- (void)stopWithoutMessage;

@end
