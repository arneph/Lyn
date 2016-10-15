//
//  LynVariable.h
//  Lyn
//
//  Created by Programmieren on 05.07.13.
//  Copyright (c) 2013 Arne Philipeit Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LynGeneral.h"

#define LynVariableNameChangedNotification @"LynVariableNameChangedNotification"
#define LynVariableValueChangedNotification @"LynVariableValueChangedNotification"

#define LynVariableReferenceCountChangedNotification @"LynVariableReferenceCountChangedNotification"
#define LynVariableAddedReferenceNotification @"LynVariableAddedReferenceNotification"
#define LynVariableRemovedReferenceNotification @"LynVariableRemovedReferenceNotification"

@interface LynVariable : NSObject <NSCoding, NSCopying>

@property NSString *name;
@property NSObject <NSCopying, NSCoding> *value;

+ (LynDataType)variableType;
- (LynDataType)variableType;

- (NSUInteger)referenceCount;

- (void)addReference: (id)refrencer;
- (void)removeReference: (id)refrencer;

@end
