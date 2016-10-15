//
//  StatusView.h
//  Lyn
//
//  Created by Programmieren on 07.08.13.
//  Copyright (c) 2013 Arne Philipeit Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Lyn Kit/Lyn Kit.h>

@interface StatusView : NSBox <NSCoding>

@property LynProject *project;

@property id showWarningsTarget;
@property SEL showWarningsAction;

@property id showErrorsTarget;
@property SEL showErrorsAction;

@end
