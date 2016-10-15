//
//  LynRunnerDebugDelegate.h
//  Lyn
//
//  Created by Programmieren on 12.08.13.
//  Copyright (c) 2013 Arne Philipeit Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol LynRunnerDebugDelegate <NSObject>

- (void)runnerDidStart;
- (void)runnerDidStop;
- (void)runnerDidFinish;

@end
