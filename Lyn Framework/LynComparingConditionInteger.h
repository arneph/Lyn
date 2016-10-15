//
//  LynComparingConditionInteger.h
//  Lyn
//
//  Created by Programmieren on 30.10.13.
//  Copyright (c) 2013 Arne Philipeit Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LynComparingCondition.h"
#import "LynParameterInteger.h"

#define LynComparingConditionIntegerOperationChangedNotification @"LynComparingConditionIntegerOperationChangedNotification"

typedef enum{
    LynIntegerComparisonLessThan,
    LynIntegerComparisonLessThanOrEqual,
    LynIntegerComparisonEqual,
    LynIntegerComparisonGreaterThanOrEqual,
    LynIntegerComparisonGreaterThan
}LynIntegerComparisonOperation;

@interface LynComparingConditionInteger : LynComparingCondition

@property LynIntegerComparisonOperation operation;

- (LynParameterInteger*)parameterA;
- (LynParameterInteger*)parameterB;

@end
