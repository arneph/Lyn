//
//  LynDefineScopeViewController.h
//  Lyn
//
//  Created by Programmieren on 05.07.13.
//  Copyright (c) 2013 Arne Philipeit Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Lyn Framework/LynCodeObjects.h>
#import "LynDefineScopeViewHelperClasses.h"
#import "LynUtilityViewDelegate.h"

@interface LynDefineScopeViewController : NSViewController

@property LynScope *scope;

@property id <LynUtilityViewDelegate> delegate;

@property NSDocument *document;

@end
