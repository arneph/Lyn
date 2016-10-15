//
//  LynClass.h
//  Lyn
//
//  Created by Programmieren on 28.04.13.
//  Copyright (c) 2013 Arne Philipeit Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LynProjectOutlineObject.h"
#import "LynFunction.h"
#import "LynScope.h"

@interface LynClass : LynProjectOutlineObject <NSCoding, NSCopying, LynNamedOutlineObject, LynScopeOwner>

@property (readonly) LynScope *scope;

- (BOOL)hasFunctionNamed: (NSString*)functionName;
- (LynFunction *)functionNamed: (NSString*)functionName;

@end
