//
//  LynClass.m
//  Lyn
//
//  Created by Programmieren on 28.04.13.
//  Copyright (c) 2013 Arne Philipeit Software. All rights reserved.
//

#import "LynClass.h"

@implementation LynClass

- (id)init{
    self = [super initWithAllowedClass:[LynFunction class]];
    if (self) {
    }
    return self;
}

- (id)initWithName:(NSString *)name{
    self = [super initWithAllowedClass:[LynFunction class]];
    if (self) {
        self.name = name;
    }
    return self;
}

- (id)initWithAllowedClass:(Class)allowedClass{
    if (allowedClass != [LynFunction class]&&![allowedClass isSubclassOfClass:[LynFunction class]]) {
        @throw NSInvalidArgumentException;
        return nil;
    }
    self = [super initWithAllowedClass:allowedClass];
    if (self) {
    }
    return self;
}

- (id)initWithAllowedClass:(Class)allowedClass andCoder:(NSCoder *)aDecoder{
    if (allowedClass != [LynFunction class]&&![allowedClass isSubclassOfClass:[LynFunction class]]) {
        @throw NSInvalidArgumentException;
        return nil;
    }
    self = [super initWithAllowedClass:allowedClass andCoder:aDecoder];
    if (self) {
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithAllowedClass:[LynFunction class] andCoder:aDecoder];
    if (self) {
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [super encodeWithCoder:aCoder];
}

- (id)copyWithZone:(NSZone *)zone{
    LynClass *copiedClass = [super copyWithZone:nil];
    return copiedClass;
}

#pragma mark Scope

+ (BOOL)hasScope{
    return YES;
}

#pragma mark Identification

+ (NSString *)uniqueTypeIdentifier{
    return @"de.AP-Software.Lyn.LynClass";
}

#pragma mark Warnings & Errors

- (NSArray *)errors{
    NSMutableArray *errors = [[NSMutableArray alloc] init];
    if ([self.name isEqualToString:@"main"]&&![self hasFunctionNamed:@"main"]) {
        [errors addObject:[[LynError alloc] initWithObject:self
                                            andMessageText:@"The main class has no main function, which is needed as starting point for the program."]];
    }
    return [NSArray arrayWithArray:errors];
}

#pragma mark NamedOutlineObject

- (void)setName:(NSString *)name{
    BOOL mainFunctionInvolved = ([name isEqualToString:@"main"]||[self.name isEqualToString:@"main"]);
    [super setName:name];
    if (mainFunctionInvolved&&EditMode) {
        [NotificationCenter postNotificationName:LynOutlineObjectNumberOfWarningsAndErrorsChangedNotification
                                          object:self];
    }
}

#pragma mark Function Access

- (BOOL)hasFunctionNamed:(NSString *)functionName{
    return ([self functionNamed:functionName] != nil);
}

- (LynFunction *)functionNamed:(NSString *)functionName{
    for (LynFunction *function in self.subObjects) {
        if ([function.name isEqualToString:functionName]) {
            return function;
        }
    }
    return nil;
}

@end
