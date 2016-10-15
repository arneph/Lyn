//
//  LynWarning.h
//  Lyn
//
//  Created by Programmieren on 09.07.13.
//  Copyright (c) 2013 Arne Philipeit Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LynWarning : NSObject

- (id)initWithObject: (id)object andMessageText: (NSString*)messageText;

- (id)object;
- (NSString*)messageText;

@end
