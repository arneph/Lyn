//
//  LynNamedOutlineObject.h
//  Lyn
//
//  Created by Programmieren on 09.05.13.
//  Copyright (c) 2013 Arne Philipeit Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol LynNamedOutlineObject <NSObject>

@property NSString *name;

- (id)initWithName: (NSString*)name;

@end
