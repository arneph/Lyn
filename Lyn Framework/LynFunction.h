//
//  LynFunction.h
//  Lyn
//
//  Created by Programmieren on 28.04.13.
//  Copyright (c) 2013 Arne Philipeit Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LynOutlineObject.h"
#import "LynCommand.h"
#import "LynParameter.h"

#define LynFunctionNameChangedNotification @"LynFunctionNameChangedNotification"

#define LynFunctionNumberOfParametersChangedNotification @"LynFunctionNumberOfParametersChangedNotification"
#define LynFunctionWillAddParameterNotification @"LynFunctionWillAddParameterNotification"
#define LynFunctionDidAddParameterNotification @"LynFunctionDidAddParameterNotification"
#define LynFunctionWillRemoveParameterNotification @"LynFunctionWillRemoveParameterNotification"
#define LynFunctionDidRemoveParameterNotification @"LynFunctionDidRemoveParameterNotification"

#define LynFunctionParameterNameChanged @"LynFunctionParameterNameChanged"

@interface LynFunction : LynOutlineObject <NSCoding, NSCopying, LynNamedOutlineObject,  LynExecutableObject>

@property NSString *name;
@property (readonly) NSMutableArray *parameters;

- (id)initWithName: (NSString*)name;

- (LynParameter*)parameterNamed: (NSString*)parameterName;

@end
