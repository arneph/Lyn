//
//  LynCommandForLoop.m
//  Lyn
//
//  Created by Programmieren on 09.11.13.
//  Copyright (c) 2013 Arne Philipeit Software. All rights reserved.
//

#import "LynCommandForLoop.h"

@implementation LynCommandForLoop{
    NSString *counterVariableName;
}

- (id)init{
    self = [super init];
    if (self) {
        LynVariableInteger *counterVariable = [[LynVariableInteger alloc] init];
        [counterVariable setName:@"i"];
        [counterVariable setValue:@0];
        [counterVariable addReference:self];
        [self.scope.variables addObject:counterVariable];
        counterVariableName = counterVariable.name;
        [self observeCounterVariable];
    }
    return self;
}

- (id)initWithAllowedClass:(Class)allowedClass{
    self = [super initWithAllowedClass:[LynCommand class]];
    if (self) {
        LynVariableInteger *counterVariable = [[LynVariableInteger alloc] init];
        [counterVariable setName:@"i"];
        [counterVariable setValue:@0];
        [counterVariable addReference:self];
        [self.scope.variables addObject:counterVariable];
        counterVariableName = counterVariable.name;
        [self observeCounterVariable];
    }
    return self;
}

- (id)initWithAllowedClass:(Class)allowedClass andCoder:(NSCoder *)aDecoder{
    self = [super initWithAllowedClass:[LynCommand class] andCoder:aDecoder];
    if (self) {
        counterVariableName = [aDecoder decodeObjectForKey:@"counterVariableName"];
        LynVariableInteger *counterVariable = (LynVariableInteger*)[self.scope variableNamed:counterVariableName];
        [counterVariable addReference:self];
        [self observeCounterVariable];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithAllowedClass:[LynCommand class] andCoder:aDecoder];
    if (self) {
        counterVariableName = [aDecoder decodeObjectForKey:@"counterVariableName"];
        LynVariableInteger *counterVariable = (LynVariableInteger*)[self.scope variableNamed:counterVariableName];
        [counterVariable addReference:self];
        [self observeCounterVariable];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:counterVariableName forKey:@"counterVariableName"];
}

- (id)copyWithZone:(NSZone *)zone{
    LynCommandForLoop *copiedCommandForLoop = [super copyWithZone:nil];
    [copiedCommandForLoop takeCopiedValueForCounterVariable:self.counterVariable.numberValue];
    return copiedCommandForLoop;
}

- (void)takeCopiedValueForCounterVariable: (NSNumber*)copiedValue{
    [self.counterVariable setValue:copiedValue];
}

- (void)dealloc{
    [self.counterVariable removeReference:self];
}

- (LynVariableInteger*)counterVariable{
    return (LynVariableInteger*)[self.scope variableNamed:counterVariableName];
}

#pragma mark Notifications

- (void)observeCounterVariable{
    [NotificationCenter addObserver:self
                           selector:@selector(counterVariableNameChanged:)
                               name:LynVariableNameChangedNotification
                             object:self.counterVariable];
}

- (void)counterVariableNameChanged: (NSNotification*)notification{
    counterVariableName = ((LynVariableInteger*)notification.object).name;
    if (EditMode) {
        [NotificationCenter postNotificationName:LynCommandSummaryChangedNotification
                                          object:self];
    }
}

- (void)parameterValueDescriptionChanged:(NSNotification *)notification{
    [super parameterValueDescriptionChanged:notification];
    if (EditMode) {
        [NotificationCenter postNotificationName:LynCommandSummaryChangedNotification
                                          object:self];
    }
}

#pragma mark General Information

+ (BOOL)allowsSubObjects{
    return YES;
}

+ (BOOL)hasScope{
    return YES;
}

+ (NSString *)name{
    return @"For Loop";
}

+ (NSString *)description{
    return @"Executes commands repeatedly until a counter reaches a value.";
}

- (NSString *)summary{
    LynParameterInteger *startParameter = (LynParameterInteger*)[self ownParameterNamed:@"Start"];
    LynParameterInteger *endParameter = (LynParameterInteger*)[self ownParameterNamed:@"End"];
    LynParameterInteger *stepParameter = (LynParameterInteger*)[self ownParameterNamed:@"Step"];
    return [NSString stringWithFormat: @"For %@ = %@ To: %@ Step: %@ Do:",
                                       self.counterVariable.name,
                                       startParameter.parameterValueDescription,
                                       endParameter.parameterValueDescription,
                                       stepParameter.parameterValueDescription];
}

+ (NSArray *)parameters{
    LynParameterInteger *startParameter = [[LynParameterInteger alloc] initWithName:@"Start" owner:nil];
    startParameter.fillType = LynParameterFillTypeStatic;
    startParameter.parameterValue = @0;
    LynParameterInteger *stepParameter = [[LynParameterInteger alloc] initWithName:@"Step" owner:nil];
    stepParameter.fillType = LynParameterFillTypeStatic;
    stepParameter.parameterValue = @1;
    LynParameterInteger *endParameter = [[LynParameterInteger alloc] initWithName:@"End" owner:nil];
    endParameter.fillType = LynParameterFillTypeStatic;
    endParameter.parameterValue = @10;
    return @[startParameter, stepParameter, endParameter];
}

- (void)executeWithDelegate:(id<LynExecutionDelegate>)delegate{
    LynParameterInteger *startParameter = (LynParameterInteger*)[self ownParameterNamed:@"Start"];
    LynParameterInteger *endParameter = (LynParameterInteger*)[self ownParameterNamed:@"End"];
    LynParameterInteger *stepParameter = (LynParameterInteger*)[self ownParameterNamed:@"Step"];
    [self.counterVariable setValue:startParameter.absoluteNumberValue];
    [delegate repeatExecutingObjects:self.subObjects
                   validationHandler:^{
                       double counter = self.counterVariable.numberValue.doubleValue;
                       double end = endParameter.absoluteNumberValue.doubleValue;
                       double step = stepParameter.absoluteNumberValue.doubleValue;
                       if (counter + step > end) {
                           return NO;
                       }else{
                           double newCoutnerValue = counter + step;
                           [self.counterVariable setValue:@(newCoutnerValue)];
                           return YES;
                       }
                   }
                   completionHandler:^(NSArray *objects){
                       [delegate finishedExecution:self];
                   }];
}

@end
