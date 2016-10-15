//
//  LynProject.h
//  Lyn
//
//  Created by Programmieren on 28.04.13.
//  Copyright (c) 2013 Arne Philipeit Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LynFolder.h"

typedef enum{
    LynProjectNotSecured,
    LynProjectPasswordSecuredForEditing,
    LynProjectPasswordSecuredForRunning
}LynProjectSecureState;

@interface LynProject : LynFolder <NSCoding, NSCopying>

@property NSString *author;
@property NSString *eMail;
@property NSString *comment;
@property (readonly) LynProjectSecureState secureState;
@property (readonly) BOOL unlocked;

@property BOOL loop;

@property (readonly) NSMutableDictionary *settings;

+ (LynProject*)projectFromData: (NSData*)data;
- (NSData*)dataFromProject;

- (BOOL)unlockProject: (NSString*)password;
- (void)setSecureState: (LynProjectSecureState)state;
- (BOOL)setPassword: (NSString*)password repeat: (NSString*)repeat;

@end
