//
//  LynFolder.m
//  Lyn
//
//  Created by Programmieren on 28.04.13.
//  Copyright (c) 2013 Arne Philipeit Software. All rights reserved.
//

#import "LynFolder.h"

@implementation LynFolder

- (id)init{
    self = [super initWithAllowedClass:[LynProjectOutlineObject class]];
    if (self) {
        
    }
    return self;
}

- (id)initWithAllowedClass:(Class)allowedClass{
    if (allowedClass != [LynProjectOutlineObject class]&&![allowedClass isSubclassOfClass:[LynProjectOutlineObject class]]) {
        @throw NSInvalidArgumentException;
        return nil;
    }
    self = [super initWithAllowedClass:allowedClass];
    if (self) {
        
    }
    return self;
}

- (id)initWithAllowedClass:(Class)allowedClass andCoder:(NSCoder *)aDecoder{
    if (allowedClass != [LynProjectOutlineObject class]&&![allowedClass isSubclassOfClass:[LynProjectOutlineObject class]]) {
        @throw NSInvalidArgumentException;
        return nil;
    }
    self = [super initWithAllowedClass:allowedClass andCoder:aDecoder];
    if (self) {
        
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithAllowedClass:[LynProjectOutlineObject class] andCoder:aDecoder];
    if (self) {
        
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [super encodeWithCoder:aCoder];
    
}

- (id)copyWithZone:(NSZone *)zone{
    LynFolder *copiedFolder = [super copyWithZone:nil];
    
    return copiedFolder;
}

+ (NSString *)uniqueTypeIdentifier{
    return @"de.AP-Software.Lyn.LynFolder";
}

- (BOOL)hasClassNamed:(NSString *)className{
    return ([self classNamed:className] != nil);
}

- (LynClass *)classNamed:(NSString *)className{
    for (LynProjectOutlineObject *subObject in self.subObjects) {
        if ([subObject isKindOfClass:[LynClass class]]) {
            LynClass *class = (LynClass*)subObject;
            if ([class.name isEqualToString:className]) {
                return class;
            }
        }else if ([subObject isKindOfClass:[LynFolder class]]) {
            LynFolder *folder = (LynFolder*)subObject;
            LynClass *result = [folder classNamed:className];
            if (result) {
                return result;
            }
        }
    }
    return nil;
}

@end
