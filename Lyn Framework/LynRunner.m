//
//  LynRunner.m
//  Lyn
//
//  Created by Programmieren on 28.04.13.
//  Copyright (c) 2013 Arne Philipeit Software. All rights reserved.
//

#import "LynRunner.h"

@interface LynRunnerAwaitedObjectStore : NSObject;

@property id awaitedObject;
@property void (^handler)(id object);

@end

@implementation LynRunnerAwaitedObjectStore{
    void (^handler)(id object);
}

- (void (^)(id object))handler{
    return handler;
}

- (void)setHandler:(void (^)(id))block{
    handler = block;
}

@end

@implementation LynRunner{
    NSMutableArray *executionStack;
    NSMutableArray *executionStates;
    NSMutableArray *awaitedObjectStores;
    BOOL shouldStop;
    BOOL sendMessageOnStop;
}

- (id)init{
    self = [super init];
    if (self) {
        [self initialize];
    }
    return self;
}

- (id)initWithExecutedObject:(id)object{
    self = [super init];
    if (self) {
        [self initialize];
        [self prepareExecutedObject:object];
    }
    return self;
}

- (id)initWithExecutedObject:(id)object andDelegate:(id<LynRunnerDelegate>)delegate{
    self = [super init];
    if (self) {
        [self initialize];
        [self prepareExecutedObject:object];
        _delegate = delegate;
    }
    return self;
}

- (void)initialize{
    _executedObject = nil;
    _running = NO;
    _delegate = nil;
    executionStack = [[NSMutableArray alloc] init];
    executionStates = [[NSMutableArray alloc] init];
    awaitedObjectStores = [[NSMutableArray alloc] init];
    shouldStop = NO;
    sendMessageOnStop = YES;
}

- (void)prepareExecutedObject: (id)object{
    if (_executedObject) @throw NSInvalidArgumentException;
    if ([object isKindOfClass:[LynProject class]]) {
        LynProject *project = object;
        LynClass *mainClass = [project classNamed:@"main"];
        if (!mainClass) {
            [_delegate writeByRunner:@"No main class found!"];
            return;
        }
        LynFunction *mainFunction = [mainClass functionNamed:@"main"];
        if (!mainFunction) {
            [_delegate writeByRunner:@"No main function found in main class!"];
        }else{
            _executedObject = project;
            [self addObjectToStack:mainFunction];
        }
        return;
    }else if (![object conformsToProtocol:@protocol(LynExecutableObject)]){
        @throw NSInvalidArgumentException;
        return;
    }
    _executedObject = object;
    [self addObjectToStack:object];
}

#pragma mark Core Execution

- (void)addObjectToStack: (id<LynExecutableObject>)object{
    id <LynExecutableObject> copy = [object copyWithZone:NSDefaultMallocZone()];
    if ([copy isKindOfClass:[LynOutlineObject class]]) {
        LynOutlineObject *originalObject = (LynOutlineObject*)object;
        LynOutlineObject *copiedObject = (LynOutlineObject*)copy;
        copiedObject.parent = originalObject.parent;
        [executionStack addObject:copiedObject];
    }else{
        [executionStack addObject:copy];
    }
    [executionStates addObject:@NO];
}

- (void)startExecutingObject: (id<LynExecutableObject>)object{
    if ([executionStack indexOfObject:object] == NSNotFound) @throw NSInvalidArgumentException;
    NSUInteger index = [executionStack indexOfObject:object];
    if (((NSNumber*)executionStates[index]).boolValue == YES) return;
    executionStates[index] = @YES;
    [object executeWithDelegate:self];
}

- (void)awaitFinishedObject: (id)object handler: (void(^)(id object))handler{
    if ([executionStack indexOfObject:object] == NSNotFound) @throw NSInvalidArgumentException;
    LynRunnerAwaitedObjectStore *awaitedObjectStore = [[LynRunnerAwaitedObjectStore alloc] init];
    awaitedObjectStore.awaitedObject = object;
    awaitedObjectStore.handler = handler;
    [awaitedObjectStores addObject:awaitedObjectStore];
}

- (void)objectFinished: (id)object{
    if ([executionStack indexOfObject:object] == NSNotFound
        ||[executionStack indexOfObject:object] != executionStack.count - 1) {
        @throw NSInvalidArgumentException;
    }
    [executionStack removeLastObject];
    [executionStates removeLastObject];
    for (NSUInteger i = 0; i < awaitedObjectStores.count; i++) {
        LynRunnerAwaitedObjectStore *awaitedObjectStore = awaitedObjectStores[i];
        if (awaitedObjectStore.awaitedObject == object) {
            [awaitedObjectStores removeObject:awaitedObjectStore];
            awaitedObjectStore.handler(object);
        }
    }
    if (executionStack.count < 1&&([_delegate canUseTimer]||_running)) {
        if ([_executedObject isKindOfClass:[LynProject class]]) {
            LynProject *project = _executedObject;
            if (project.loop) {
                _executedObject = nil;
                [self prepareExecutedObject:project];
                [self startExecutingObject:executionStack.lastObject];
                return;
            }
        }
        _running = NO;
        shouldStop = NO;
        [_debugDelegate runnerDidFinish];
        [_delegate finishedExecuting];
        [_delegate writeByRunner:@"Ended"];
    }else if (shouldStop) {
        _running = NO;
        shouldStop = NO;
        [_debugDelegate runnerDidStop];
        [_delegate stoppedExecuting];
        if (sendMessageOnStop) [_delegate writeByRunner:@"Stopped"];
    }
}

#pragma mark Execution Control

- (void)start{
    if (_running) return;
    _running = YES;
    [_debugDelegate runnerDidStart];
    [_delegate startedExecuting];
    [_delegate writeByRunner:@"Started"];
    if (executionStack.count > 0) {
        [self startExecutingObject:executionStack.lastObject];
    }else{
        if ([_executedObject isKindOfClass:[LynProject class]]) {
            LynProject *project = _executedObject;
            if (project.loop) {
                _executedObject = nil;
                [self prepareExecutedObject:project];
                [self startExecutingObject:executionStack.lastObject];
            }
        }
    }
}

- (void)stop{
    if (!_running) return;
    shouldStop = YES;
    sendMessageOnStop = YES;
}

- (void)startWithoutMessage{
    if (_running) return;
    _running = YES;
    [_debugDelegate runnerDidStart];
    [_delegate startedExecuting];
    if (executionStack.count > 0) {
        [self startExecutingObject:executionStack.lastObject];
    }else{
        if ([_executedObject isKindOfClass:[LynProject class]]) {
            LynProject *project = _executedObject;
            if (project.loop) {
                _executedObject = nil;
                [self prepareExecutedObject:project];
                [self startExecutingObject:executionStack.lastObject];
            }
        }
    }
}

- (void)stopWithoutMessage{
    if (!_running) return;
    shouldStop = YES;
    sendMessageOnStop = NO;
}

#pragma mark ExecutionDelegate

- (void)finishedExecution:(id)sender{
    if ([_delegate canUseTimer]) {
        [self performSelector:@selector(objectFinished:)
                   withObject:sender
                   afterDelay:MinimumWaitTimeForCommands];
    }else{
        //sleep(MinimumWaitTimeForCommands);
        [self objectFinished:sender];
    }
}

- (void)executeObject:(id)object completionHandler:(void (^)(id))completionHandler{
    [self addObjectToStack:object];
    [self awaitFinishedObject:executionStack.lastObject handler:^(id copiedObject){
        completionHandler(object);
    }];
    if (_running&&!shouldStop) [self startExecutingObject:executionStack.lastObject];
}

- (void)executeObjects:(NSArray *)objects completionHandler:(void (^)(NSArray *objects))completionHandler{
    if (!objects) @throw NSInvalidArgumentException;
    if (objects.count < 1) {
        completionHandler(objects);
        return;
    }
    
    [self executeObject:objects[0]
      completionHandler:^(id object){
        if (object == objects.lastObject) {
            completionHandler(objects);
        }else{
            NSArray *newObjects = [objects objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, objects.count - 1)]];
            [self executeObjects:newObjects completionHandler:completionHandler];
        }
    }];
}

- (void)repeatExecutingObjects:(NSArray *)objects validationHandler:(BOOL (^)(void))validationHandler completionHandler:(void (^)(NSArray *objects))completionHandler{
    if (!objects) @throw NSInvalidArgumentException;
    if (objects.count < 1) {
        completionHandler(objects);
        return;
    }
    
    __block LynRunner *slf = self;
    __block NSArray *objs = objects;
    
    [self executeObjects:objects completionHandler:^(NSArray *objects){
        if (validationHandler()) {
            [slf repeatExecutingObjects:objs validationHandler:validationHandler completionHandler:completionHandler];
        }else{
            completionHandler(objs);
        }
    }];
}

- (BOOL)canUseTimers{
    return [_delegate canUseTimer];
}

#pragma mark Other ExecutionDelegate Methods

- (void)openApplication: (NSString*)application{
    [_delegate openApplication:application];
}

- (void)openFile: (NSString*)file{
    [_delegate openFile:file];
}

- (void)openFile: (NSString*)file withApplication: (NSString*)application{
    [_delegate openFile:file withApplication:application];
}

- (void)playSound:(NSString *)sound atVolume:(float)volume complete:(BOOL)complete{
    [_delegate playSound:sound atVolume:volume complete: complete];
}

- (void)postNotification: (NSString*)text{
    [_delegate postNotification:text];
}

- (void)scanBoolean:(void (^)(NSNumber *))completionHandler{
    [_delegate scanBoolean:^(NSNumber *result){
        completionHandler(result);
    }];
}

- (void)scanInteger:(void (^)(NSNumber *))completionHandler{
    [_delegate scanInteger:^(NSNumber *result){
        completionHandler(result);
    }];
}

- (void)scanString:(void (^)(NSString *))completionHandler{
    [_delegate scanString:^(NSString *result){
        completionHandler(result);
    }];
}

- (void)write:(NSString *)string{
    [_delegate write:string];
}

@end
