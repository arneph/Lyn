//
//  LynCombiningCondition.h
//  Lyn
//
//  Created by Programmieren on 05.10.13.
//  Copyright (c) 2013 Arne Philipeit Software. All rights reserved.
//

#import "LynCondition.h"

#define LynCombiningConditionTypeChanged @"LynCombiningConditionTypeChanged"

#define LynCombiningConditionWillAddSubCondition @"LynCombiningConditionWillAddSubCondition"
#define LynCombiningConditionDidAddSubCondition @"LynCombinignConditionDidAddSubCondition"
#define LynCombiningConditionWillRemoveSubCondition @"LynCombiningConditionWillRemoveSubCondition"
#define LynCombiningConditionDidRemoveSubCondition @"LynCombiningConditionDidRemoveSubCondition"
#define LynCombiningConditionNumberOfSubConditionsChanged @"LynCombiningConditionNumberOfSubConditionsChanged"

typedef enum{
    LynConditionCombinationAnd,
    LynConditionCombinationOr
}LynConditionCombinationType;

@interface LynCombiningCondition : LynCondition <NSCopying, NSCoding>

@property LynConditionCombinationType combinationType;

@property (readonly) NSMutableArray *subConditions;

@end
