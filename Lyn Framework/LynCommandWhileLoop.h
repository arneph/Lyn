//
//  LynCommandWhileLoop.h
//  Lyn
//
//  Created by Programmieren on 02.11.13.
//  Copyright (c) 2013 Arne Philipeit Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LynCommand.h"
#import "LynCondition.h"
#import "LynCombiningCondition.h"

@interface LynCommandWhileLoop : LynCommand

@property (readonly) LynCombiningCondition *rootCondition;

@end
