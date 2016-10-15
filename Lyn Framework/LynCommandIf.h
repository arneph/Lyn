//
//  LynCommandIf.h
//  Lyn
//
//  Created by Programmieren on 05.10.13.
//  Copyright (c) 2013 Arne Philipeit Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LynCommand.h"
#import "LynCondition.h"
#import "LynCombiningCondition.h"

@interface LynCommandIf : LynCommand

@property (readonly) LynCombiningCondition *rootCondition;

@end
