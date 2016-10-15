//
//  LynCommand.h
//  Lyn
//
//  Created by Programmieren on 28.04.13.
//  Copyright (c) 2013 Arne Philipeit Software. All rights reserved.
//

#define LynCommandSummaryChangedNotification @"LynCommandSummaryChangedNotification"
#define LynCommandNumberOfParametersChangedNotification @"LynCommandNumberOfParametersChangedNotification"

#define LynCommandParameterNameChangedNotification @"LynCommandParameterNameChangedNotification"
#define LynCommandParameterValueChangedNotification @"LynCommandParameterValueChangedNotification"
#define LynCommandParameterFillTypeChangedNotification @"LynCommandParameterFillTypeChangedNotification"
#define LynCommandParameterValueDescriptionChangedNotification @"LynCommandParameterValueDescriptionChangedNotification"

#define LynCommandReturnValueTypeChangedNotification @"LynCommandReturnValueTypeChangedNotification"
#define LynCommandUseReturnValueChangedNotification @"LynCommandUseReturnValueChangedNotification"
#define LynCommandReturnValueParameterValueChangedNotification @"LynCommandReturnValueParameterValueChangedNotification"
#define LynCommandReturnValueParameterFillTypeChangedNotification @"LynCommandReturnValueParameterFillTypeChangedNotification"
#define LynCommandReturnValueParameterValueDescriptionChangedNotification @"LynCommandReturnValueParameterValueDescriptionChangedNotification"


#import <Foundation/Foundation.h>
#import "LynOutlineObject.h"
#import "LynExecutableObject.h"

#import "LynParameter.h"
#import "LynParameterBoolean.h"
#import "LynParameterInteger.h"
#import "LynParameterString.h"

@interface LynCommand : LynOutlineObject <NSCoding, NSCopying, LynParameterOwner, LynExecutableObject>

+ (NSString*)name;
+ (NSString*)description;
- (NSString*)summary;

+ (NSArray*)parameters;

- (NSArray*)standardParameters;
- (NSArray*)parameters;

- (LynDataType)returnValueType;
- (BOOL)useReturnValue;
- (void)setUseReturnValue: (BOOL)useReturnValue;
- (LynParameter*)returnValueParameter;

- (void)parameterNameChanged: (NSNotification*)notification;
- (void)parameterValueChanged: (NSNotification*)notification;
- (void)parameterFillTypeChanged: (NSNotification*)notification;
- (void)parameterValueDescriptionChanged: (NSNotification*)notification;

- (void)returnValueParameterValueChanged: (NSNotification*)notification;
- (void)returnValueParameterFillTypeChanged: (NSNotification*)notification;
- (void)returnValueParameterValueDescriptionChanged: (NSNotification*)notification;

- (LynParameter*)ownParameterNamed: (NSString*)parameterName;

- (void)processReturnValue: (NSObject<NSCoding, NSCopying>*)returnValue;

@end
