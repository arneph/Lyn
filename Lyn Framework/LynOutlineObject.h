//
//  LynOutlineObject.h
//  Lyn
//
//  Created by Programmieren on 27.04.13.
//  Copyright (c) 2013 Arne Philipeit Software. All rights reserved.
//

#define LynOutlineObjectParentChangedNotification @"LynOutlineObjectParentChangedNotification"

#define LynOutlineObjectNumberOfSubObjectsChangedNotification @"LynOutlineObjectNumberOfSubObjectsChangedNotification"
#define LynOutlineObjectWillAddSubObjectNotification @"LynOutlineObjectWillAddSubObjectsNotification"
#define LynOutlineObjectDidAddSubObjectNotification @"LynOutlineObjectDidAddSubObjectsNotification"
#define LynOutlineObjectWillRemoveSubObjectNotification @"LynOutlineObjectWillRemoveSubObjectsNotification"
#define LynOutlineObjectDidRemoveSubObjectNotification @"LynOutlineObjectDidRemoveSubObjectsNotification"

#define LynOutlineObjectNumberOfWarningsAndErrorsChangedNotification @"LynOutlineObjectNumberOfWarningsAndErrorsChangedNotification"
#define LynOutlineObjectNumberOfWarningsChangedNotification @"LynOutlineObjectNumberOfWarningsChangedNotification"
#define LynOutlineObjectNumberOfErrorsChangedNotification @"LynOutlineObjectNumberOfErrorsChangedNotification"

#import <Foundation/Foundation.h>
#import "LynGeneral.h"
#import "LynNamedOutlineObject.h"
#import "LynScope.h"
#import "LynWarning.h"
#import "LynError.h"

@interface LynOutlineObject : NSObject <NSCoding, NSCopying, LynScopeOwner>

@property (weak) LynOutlineObject *parent;
@property (readonly) NSMutableArray *subObjects;

@property (readonly) Class allowedSubObjectClass;

@property (readonly) LynScope *scope;

- (id)initWithAllowedClass: (Class)allowedClass;
- (id)initWithAllowedClass: (Class)allowedClass andCoder: (NSCoder*)aDecoder;

+ (BOOL)allowsSubObjects;

- (NSArray*)parents;

#pragma mark Scope

+ (BOOL)hasScope;

#pragma mark Warnings & Errors

- (BOOL)hasWarnings;
- (BOOL)hasErrors;

- (BOOL)hasWarningsIncludingSubObjects: (BOOL)includeSubObjects;
- (BOOL)hasErrorsIncludingSubObjects: (BOOL)includeSubObjects;

- (NSArray*)warnings;
- (NSArray*)errors;

- (NSArray*)warningsIncludingSubObjects: (BOOL)includeSubObjects;
- (NSArray*)errorsIncludingSubObjects: (BOOL)includeSubObjects;

#pragma mark Identification

+ (NSString*)uniqueTypeIdentifier;

#pragma mark Notifications

- (void)numberOfSubObjectsChanged: (NSNotification*)notification;

- (void)willAddSubObject: (NSNotification*)notification;
- (void)didAddSubObject: (NSNotification*)notification;

- (void)willRemoveSubObject: (NSNotification*)notification;
- (void)didRemoveSubObject: (NSNotification*)notification;

- (void)numberOfWarningsAndErrorsChanged:(NSNotification *)notification;
- (void)numberOfWarningsChanged: (NSNotification*)notification;
- (void)numberOfErrorsChanged: (NSNotification*)notification;

@end
