//
//  LynCondition.h
//  Lyn
//
//  Created by Programmieren on 05.10.13.
//  Copyright (c) 2013 Arne Philipeit Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LynGeneral.h"
#import "LynParameter.h"

#define LynConditionNegationChangedNotification @"LynConditionNegationChangedNotification"
#define LynConditionParentChangedNotification @"LynConditionParentChangedNotification"
#define LynConditionDescriptionChangedNotification @"LynConditionDescriptionChangedNotification"

@interface LynCondition : NSObject <NSCopying, NSCoding>

@property id<LynParameterOwner> delegate;

@property BOOL negate;

@property (weak) LynCondition *parentCondition;

- (NSString*)description;

- (BOOL)isConditionMet;

@end
