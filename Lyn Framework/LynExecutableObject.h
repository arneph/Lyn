//
//  LynExecutableObject.h
//  Lyn
//
//  Created by Programmieren on 15.05.13.
//  Copyright (c) 2013 Arne Philipeit Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LynExecutionDelegate.h"

@protocol LynExecutableObject <NSObject, NSCopying>

- (void)executeWithDelegate: (id<LynExecutionDelegate>)delegate;

@end
