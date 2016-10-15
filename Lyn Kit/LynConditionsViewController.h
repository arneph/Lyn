//
//  LynConditionsViewController.h
//  Lyn
//
//  Created by Programmieren on 05.10.13.
//  Copyright (c) 2013 Arne Philipeit Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Lyn Framework/LynCodeObjects.h>
#import "LynUtilityViewDelegate.h"
#import "LynConditionsViewHelperClasses.h"

@interface LynConditionsViewController : NSViewController

@property LynCommand *command;
@property LynCombiningCondition *rootCondition;

@property NSDocument *document;

@end
