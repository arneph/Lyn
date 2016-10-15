//
//  LynParameterInteger.h
//  Lyn
//
//  Created by Programmieren on 31.07.13.
//  Copyright (c) 2013 Arne Philipeit Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LynParameter.h"
#import "LynVariableInteger.h"

@interface LynParameterInteger : LynParameter

- (NSNumber*)absoluteNumberValue;

- (BOOL)isStaticValueNegative;
- (BOOL)isStaticValueLessThan: (NSNumber*)minimum;
- (BOOL)isStaticValueLessThanOrEqual: (NSNumber*)minimum;
- (BOOL)isStaticValueGreaterThan: (NSNumber*)minimum;
- (BOOL)isStaticValueGreaterThanOrEqual: (NSNumber*)minimum;

@end
