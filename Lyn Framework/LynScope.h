//
//  LynScope.h
//  Lyn
//
//  Created by Programmieren on 05.07.13.
//  Copyright (c) 2013 Arne Philipeit Software. All rights reserved.
//

#define LynScopeSuperScopeChangedNotification @"LynScopeSuperScopeChangedNotification"

#define LynScopeNumberOfVariablesChangedNotification @"LynScopeNumberOfVariablesChangedNotification"
#define LynScopeWillAddVariableNotification @"LynScopeWillAddVariableNotification"
#define LynScopeDidAddVariableNotification @"LynScopeDidAddVariableNotification"
#define LynScopeWillRemoveVariableNotification @"LynScopeWillRemoveVariableNotification"
#define LynScopeDidRemoveVariableNotification @"LynScopeDidRemoveVariableNotification"

#define LynScopeVariableNameChangedNotification @"LynScopeVariableNameChangedNotification"

#define LynScopeVariableValueChangedNotification @"LynScopeVariableValueChangedNotification"

#import <Foundation/Foundation.h>
#import "LynGeneral.h"
#import "LynVariable.h"

#import "LynVariableBoolean.h"
#import "LynVariableInteger.h"
#import "LynVariableString.h"

@class LynScope;

@protocol LynScopeOwner <NSObject>

- (LynScope*)scope;

- (LynScope*)superScope;
- (id)superScopeOwner;

- (NSString*)name;

@end

@interface LynScope : NSObject <NSCoding, NSCopying>

@property (weak) LynScope *superScope;
@property (weak) id<LynScopeOwner> scopeOwner;
@property (readonly) NSMutableArray *variables;

- (id)initWithOwner: (id<LynScopeOwner>)owner superScope: (LynScope*)superScope;

- (BOOL)hasVariableNamed: (NSString*)name;
- (BOOL)hasVariableNamed: (NSString*)name inSuperScopes: (BOOL)includeSuperScope;
- (LynVariable*)variableNamed: (NSString*)name;
- (LynVariable*)variableNamed: (NSString*)name inSuperScopes: (BOOL)includeSuperScope;

@end
