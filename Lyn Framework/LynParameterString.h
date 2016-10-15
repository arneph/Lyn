//
//  LynParameterString.h
//  Lyn
//
//  Created by Programmieren on 19.05.13.
//  Copyright (c) 2013 Arne Philipeit Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LynParameter.h"
#import "LynVariableString.h"

@interface LynParameterString : LynParameter

- (NSString*)absoluteStringValue;

- (BOOL)isStaticValueEmpty;

@end
