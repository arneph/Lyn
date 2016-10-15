//
//  LynComment.m
//  Lyn
//
//  Created by Programmieren on 28.09.13.
//  Copyright (c) 2013 Arne Philipeit Software. All rights reserved.
//

#import "LynComment.h"

@implementation LynComment
@synthesize comment = _comment;

- (id)init{
    self = [super init];
    if (self) {
        _comment = @"";
    }
    return self;
}

- (id)initWithAllowedClass:(Class)allowedClass{
    self = [super initWithAllowedClass:allowedClass];
    if (self) {
        _comment = @"";
    }
    return self;
}

- (id)initWithAllowedClass:(Class)allowedClass andCoder:(NSCoder *)aDecoder{
    self = [super initWithAllowedClass:allowedClass andCoder:aDecoder];
    if (self) {
        _comment = [aDecoder decodeObjectForKey:@"comment"];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        _comment = [aDecoder decodeObjectForKey:@"comment"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:_comment forKey:@"comment"];
}

- (id)copyWithZone:(NSZone *)zone{
    LynComment *copiedComment = [super copyWithZone:nil];
    copiedComment.comment = _comment.copy;
    return copiedComment;
}

#pragma mark General Information

+ (BOOL)allowsSubObjects{
    return YES;
}

+ (NSString *)name{
    return @"Comment";
}

+ (NSString*)description{
    return @"A Comment in Code that will be ignored at run time.";
}

- (NSString*)summary{
    return _comment;
}

- (NSString*)comment{
    return _comment;
}

- (void)setComment:(NSString *)comment{
    _comment = comment;
    if (EditMode) {
        [NotificationCenter postNotificationName:LynCommandSummaryChangedNotification
                                          object:self];
    }
}

@end
