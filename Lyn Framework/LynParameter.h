//
//  LynParameter.h
//  Lyn
//
//  Created by Programmieren on 19.05.13.
//  Copyright (c) 2013 Arne Philipeit Software. All rights reserved.
//

#define LynParameterNameChangedNotification @"LynParameterNameChangedNotification"
#define LynParameterValueChangedNotification @"LynParameterValueChangedNotification"
#define LynParameterFillTypeChangedNotification @"LynParameterFillTypeChangedNotification"

#define LynParameterDescriptionChangedNotification @"LynParameterDescriptionChangedNotification"

#define LynParameterReferenceCountChangedNotification @"LynParameterReferenceCountChangedNotification"
#define LynParameterAddedReferenceNotification @"LynParameterAddedReferenceNotification"
#define LynParameterRemovedReferenceNotification @"LynParameterRemovedReferenceNotification"

#import <Foundation/Foundation.h>
#import "LynGeneral.h"
#import "LynVariable.h"

@class LynParameter;

@protocol LynParameterOwner <NSObject>

- (LynVariable*)variableNamed: (NSString*)name;
- (LynParameter*)parameterNamed: (NSString*)name;

@end

typedef enum{
    LynParameterFillTypeStatic,
    LynParameterFillTypeDynamicFromVariable,
    LynParameterFillTypeDynamicFromParameter
}LynParameterFillType;

@interface LynParameter : NSObject <NSCoding, NSCopying>

@property NSString *name;
@property NSObject<NSCoding, NSCopying> *parameterValue;
@property LynParameterFillType fillType;

@property (readonly) BOOL fixedStatic;
@property (readonly) BOOL fixedDynamic;

@property id <LynParameterOwner> owner;

- (id)initWithName: (NSString*)name owner: (id<LynParameterOwner>)owner;
- (id)initFixedStaticWithName: (NSString*)name owner: (id<LynParameterOwner>)owner;
- (id)initFixedDynamicWithName: (NSString*)name owner: (id<LynParameterOwner>)owner;

+ (LynDataType)parameterType;
- (LynDataType)parameterType;

- (NSObject*)absoluteValue;

- (NSString*)parameterValueDescription;

#pragma mark Refrencing

- (NSUInteger)referenceCount;

- (void)addReference: (id)refrencer;
- (void)removeReference: (id)refrencer;

#pragma mark Detecting Errors

- (BOOL)isDynamicValueNotSpecified;

@end
