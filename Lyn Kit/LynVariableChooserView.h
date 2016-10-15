//
//  LynVariableChooserView.h
//  Lyn
//
//  Created by Programmieren on 18.07.13.
//  Copyright (c) 2013 Arne Philipeit Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Lyn Framework/LynCodeObjects.h>

@interface LynVariableChooserView : NSView

@property LynScope *scope;
@property NSArray *parameters;

@property LynDataType type;
@property BOOL includeSuperScopes;

@property SEL action;
@property id target;

@property (getter = isEnabled) BOOL enabled;

- (NSArray*)displayedObjects;

- (id)selectedVariable;
- (void)selectVariable: (id)object;

- (void)beginUpdates;
- (void)endUpdates;

//General
+ (NSArray*)objectsForScope: (LynScope*)scope
         includeSuperScopes: (BOOL)includeSuperScopes
                 parameters: (NSArray*)parameters
                   withType: (LynDataType)type;

@end
