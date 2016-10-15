//
//  LynFolder.h
//  Lyn
//
//  Created by Programmieren on 28.04.13.
//  Copyright (c) 2013 Arne Philipeit Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LynProjectOutlineObject.h"
#import "LynClass.h"

@interface LynFolder : LynProjectOutlineObject <NSCoding, NSCopying>

- (BOOL)hasClassNamed: (NSString*)className;
- (LynClass *)classNamed: (NSString*)className;

@end
