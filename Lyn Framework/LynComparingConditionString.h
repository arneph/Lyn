//
//  LynComparingConditionString.h
//  Lyn
//
//  Created by Programmieren on 30.10.13.
//  Copyright (c) 2013 Arne Philipeit Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LynComparingCondition.h"
#import "LynParameterString.h"

@interface LynComparingConditionString : LynComparingCondition

- (LynParameterString*)parameterA;
- (LynParameterString*)parameterB;

@end
