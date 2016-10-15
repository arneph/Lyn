//
//  LynExecutionDelegate.h
//  Lyn
//
//  Created by Programmieren on 28.04.13.
//  Copyright (c) 2013 Arne Philipeit Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LynOutlineObject.h"

@protocol LynExecutionDelegate <NSObject>

- (void)finishedExecution: (id)sender;

- (void)executeObject: (id)object
    completionHandler: (void (^)(id object))completionHandler;

- (void)executeObjects: (NSArray*)objects
     completionHandler: (void (^)(NSArray *objects))completionHandler;

- (void)repeatExecutingObjects:(NSArray *)objects
             validationHandler:(BOOL (^)(void))validationHandler
             completionHandler:(void (^)(NSArray *objects))completionHandler;

- (BOOL)canUseTimers;

- (void)openApplication: (NSString*)application;
- (void)openFile: (NSString*)file;
- (void)openFile: (NSString*)file withApplication: (NSString*)application;

- (void)playSound: (NSString*)sound atVolume: (float)volume complete: (BOOL)complete;

- (void)postNotification: (NSString*)text;

- (void)scanBoolean: (void(^)(NSNumber *result))completionHandler;
- (void)scanInteger: (void(^)(NSNumber *result))completionHandler;
- (void)scanString: (void(^)(NSString *result))completionHandler;

- (void)write: (NSString*)string;

@end
