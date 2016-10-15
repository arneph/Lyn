//
//  LynComparingCondition.h
//  Lyn
//
//  Created by Programmieren on 05.10.13.
//  Copyright (c) 2013 Arne Philipeit Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LynGeneral.h"
#import "LynCondition.h"
#import "LynParameter.h"

#define LynConditionParameterNameChangedNotification @"LynConditionParameterNameChangedNotification"
#define LynConditionParameterValueChangedNotification @"LynConditionParameterValueChangedNotification"
#define LynConditionParameterFillTypeChangedNotification @"LynConditionParameterFillTypeChangedNotification"
#define LynConditionParameterValueDescriptionChangedNotification @"LynConditionParameterValueDescriptionChangedNotification"

@interface LynComparingCondition : LynCondition <NSCoding, NSCopying>

- (LynDataType)type;

- (LynParameter*)parameterA;
- (LynParameter*)parameterB;

- (void)observeParameters;

@end
