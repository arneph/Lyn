//
//  LynUseReturnValueViewController.h
//  Lyn
//
//  Created by Programmieren on 10.11.13.
//  Copyright (c) 2013 Arne Philipeit Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Lyn Framework/LynCodeObjects.h>
#import "LynUtilityViewDelegate.h"
#import "LynVariableChooserView.h"

@interface LynUseReturnValueViewController : NSViewController

@property LynCommand *command;

@property NSDocument *document;

@end
