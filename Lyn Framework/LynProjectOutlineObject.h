//
//  LynProjectOutlineObject.h
//  Lyn
//
//  Created by Programmieren on 28.04.13.
//  Copyright (c) 2013 Arne Philipeit Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LynOutlineObject.h"

@interface LynProjectOutlineObject : LynOutlineObject <LynNamedOutlineObject>

@property NSString *name;

- (id)initWithName: (NSString*)name;

@end
