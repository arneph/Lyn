//
//  LynProject.m
//  Lyn
//
//  Created by Programmieren on 28.04.13.
//  Copyright (c) 2013 Arne Philipeit Software. All rights reserved.
//

#import "LynProject.h"

@implementation LynProject{
    NSString *password;
}

- (id)init{
    self = [super initWithAllowedClass:[LynProjectOutlineObject class]];
    if (self) {
        _author = NSUserName();
        _eMail = @"";
        _comment = @"";
        _secureState = LynProjectNotSecured;
        _unlocked = YES;
        password = nil;
        _loop = NO;
        _settings = [[NSMutableDictionary alloc] init];
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
        _author = NSUserName();
        _eMail = @"";
        _comment = @"";
        _secureState = LynProjectNotSecured;
        _unlocked = YES;
        password = nil;
        _loop = NO;
        _settings = [[NSMutableDictionary alloc] init];
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
        _author = [aDecoder decodeObjectForKey:@"author"];
        _eMail = [aDecoder decodeObjectForKey:@"eMail"];
        _comment = [aDecoder decodeObjectForKey:@"comment"];
        _secureState = (LynProjectSecureState)[aDecoder decodeIntegerForKey:@"secureState"];
        _unlocked = (_secureState == LynProjectNotSecured||(_secureState == LynProjectPasswordSecuredForEditing&&RunningMode));
        password = [aDecoder decodeObjectForKey:@"password"];
        _loop = [aDecoder decodeBoolForKey:@"loop"];
        _settings = [NSMutableDictionary dictionaryWithDictionary:[aDecoder decodeObjectForKey:@"settings"]];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithAllowedClass:[LynProjectOutlineObject class] andCoder:aDecoder];
    if (self) {
        _author = [aDecoder decodeObjectForKey:@"author"];
        _eMail = [aDecoder decodeObjectForKey:@"eMail"];
        _comment = [aDecoder decodeObjectForKey:@"comment"];
        _secureState = (LynProjectSecureState)[aDecoder decodeIntegerForKey:@"secureState"];
        _unlocked = (_secureState == LynProjectNotSecured||(_secureState == LynProjectPasswordSecuredForEditing&&RunningMode));
        password = [aDecoder decodeObjectForKey:@"password"];
        _loop = [aDecoder decodeBoolForKey:@"loop"];
        _settings = [NSMutableDictionary dictionaryWithDictionary:[aDecoder decodeObjectForKey:@"settings"]];
        if (!_settings) _settings = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    if (!_unlocked) return;
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:_author forKey:@"author"];
    [aCoder encodeObject:_eMail forKey:@"eMail"];
    [aCoder encodeObject:_comment forKey:@"comment"];
    [aCoder encodeInteger:_secureState forKey:@"secureState"];
    [aCoder encodeObject:password forKey:@"password"];
    [aCoder encodeBool:_loop forKey:@"loop"];
    [aCoder encodeObject:_settings forKey:@"settings"];
}

- (id)copyWithZone:(NSZone *)zone{
    if (!_unlocked) return nil;
    LynProject *copiedProject = [super copyWithZone:nil];
    [copiedProject setAuthor:_author.copy];
    [copiedProject setEMail:_eMail.copy];
    [copiedProject setComment:_comment.copy];
    [copiedProject takeCopiedSecureState:_secureState andPassword:password.copy];
    [copiedProject setLoop:_loop];
    [copiedProject takeCopiedSettings:_settings.copy];
    return copiedProject;
}

- (void)takeCopiedSecureState: (LynProjectSecureState)secureState andPassword: (NSString*)pw{
    _secureState = secureState;
    password = pw;
}

- (void)takeCopiedSettings: (NSMutableDictionary*)settings{
    _settings = settings;
}

- (NSMutableArray *)subObjects{
    if (!_unlocked) return nil;
    else return [super subObjects];
}

- (LynScope *)scope{
    if (!_unlocked) return nil;
    else return [super scope];
}

- (LynScope *)superScope{
    if (!_unlocked) return nil;
    return [super superScope];
}

- (id)superScopeOwner{
    if (!_unlocked) return nil;
    else return [super superScopeOwner];
}

- (NSArray *)warningsIncludingSubObjects:(BOOL)includeSubObjects{
    if (!_unlocked) return @[];
    else return [super warningsIncludingSubObjects:includeSubObjects];
}

- (NSArray *)errorsIncludingSubObjects:(BOOL)includeSubObjects{
    if (!_unlocked) return @[];
    else return [super errorsIncludingSubObjects:includeSubObjects];
}

- (NSArray *)errors{
    if (!_unlocked) return @[];
    NSMutableArray *errors = [[NSMutableArray alloc] init];
    if (![self hasClassNamed:@"main"]) {
        [errors addObject:[[LynError alloc] initWithObject:self
                                            andMessageText:@"The project has no main class, which is needed as starting point for the program."]];
    }
    return [NSArray arrayWithArray:errors];
}

+ (NSString *)uniqueTypeIdentifier{
    return @"de.AP-Software.Lyn.LynProject";
}

- (void)numberOfSubObjectsChanged:(NSNotification *)notification{
    [super numberOfSubObjectsChanged:notification];
    if (EditMode) {
        [NotificationCenter postNotificationName:LynOutlineObjectNumberOfErrorsChangedNotification
                                          object:self];
    }    
}

- (BOOL)hasClassNamed:(NSString *)className{
    if (!_unlocked) return NO;
    else return [super hasClassNamed:className];
}

- (LynClass *)classNamed:(NSString *)className{
    if (!_unlocked) return nil;
    else return [super classNamed:className];
}

+ (LynProject*)projectFromData:(NSData *)data{
    LynProject *project = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    return project;
}

- (NSData *)dataFromProject{
    return [NSKeyedArchiver archivedDataWithRootObject:self];
}

#pragma mark Security

- (BOOL)unlockProject:(NSString *)pw{
    if (_unlocked) return YES;
    if ([password isEqualToString:pw]) {
        _unlocked = YES;
        return YES;
    }else{
        return NO;
    }
}

- (void)setSecureState:(LynProjectSecureState)state{
    if (!_unlocked) return;
    _secureState = state;
}

- (BOOL)setPassword:(NSString *)pw repeat:(NSString *)repeat{
    if (![pw isEqualToString:repeat]) return NO;
    if (!_unlocked) return NO;
    password = pw.copy;
    return YES;
}

@end
