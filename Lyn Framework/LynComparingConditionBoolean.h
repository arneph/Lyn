//
//  LynComparingConditionBoolean.h
//  Lyn
//
//  Created by Programmieren on 20.10.13.
//  Copyright (c) 2013 Arne Philipeit Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LynComparingCondition.h"
#import "LynParameterBoolean.h"

@interface LynComparingConditionBoolean : LynComparingCondition

- (LynParameterBoolean*)parameterA;
- (LynParameterBoolean*)parameterB;

@end
