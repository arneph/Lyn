//
//  LynWarning.m
//  Lyn
//
//  Created by Programmieren on 09.07.13.
//  Copyright (c) 2013 Arne Philipeit Software. All rights reserved.
//

#import "LynWarning.h"

@implementation LynWarning{
    id object;
    NSString *messageText;
}

- (id)initWithObject:(id)obj andMessageText:(NSString *)text{
    if (!obj||!text) @throw NSInvalidArchiveOperationException;
    self = [super init];
    if (self) {
        object = obj;
        messageText = text;
    }
    return self;
}

- (id)object{
    return object;
}

- (NSString *)messageText{
    return messageText;
}

@end
