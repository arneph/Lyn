//
//  main.m
//  LynRunnerUtility
//
//  Created by Programmieren on 04.10.13.
//  Copyright (c) 2013 Arne Philipeit Software. All rights reserved.
//

#import <stdio.h>
#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import <Lyn Framework/Lyn Framework.h>

@interface RunnerController : NSObject <LynRunnerDelegate>

- (id)initWithURL: (NSURL*)url;

- (void)start;

@property (readonly) LynProject *project;
@property (readonly) LynRunner *runner;

@end

@implementation RunnerController

- (id)initWithURL:(NSURL *)url{
    self = [super init];
    if (self) {
        NSURL *tmpURL = [NSURL fileURLWithPath:url.absoluteString];
        NSData *data = [NSData dataWithContentsOfURL:tmpURL];
        _project = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        _runner = [[LynRunner alloc] initWithExecutedObject:_project andDelegate:self];
    }
    return self;
}

- (void)start{
    [_runner start];
}

- (BOOL)canUseTimer{
    return NO;
}

- (void)startedExecuting{}
    
- (void)stoppedExecuting{}

- (void)finishedExecuting{}

- (void)openApplication:(NSString *)application{
    [[NSWorkspace sharedWorkspace] launchApplication:application];
}

- (void)openFile:(NSString *)file{
    [[NSWorkspace sharedWorkspace] openFile:file];
}

- (void)openFile:(NSString *)file withApplication:(NSString *)application{
    [[NSWorkspace sharedWorkspace] openFile:file withApplication:application];
}

- (void)playSound:(NSString *)soundName atVolume:(float)volume complete:(BOOL)complete{
    NSSound *sound = [NSSound soundNamed:soundName];
    if (sound) {
        if (volume < 0) {
            volume = 1.0;
        }else if (volume > 1) {
            volume = 1.0;
        }
        sound.volume = volume;
        [sound play];
        if (complete) sleep(sound.duration);
    }
}

- (void)scanBoolean:(void (^)(NSNumber *))completionHandler{
    char input[256];
    fgets(input, 256, stdin);
    int lenght = (int)strlen(input);
    input[lenght - 1] = 0;
    NSString *text = [NSString stringWithUTF8String:input];
    if ([text.lowercaseString isEqualToString:@"/scaninfo"]) {
        [self writeByRunner:@"You are supposed to enter a boolean value (yes / no)."];
        [self scanBoolean:completionHandler];
        return;
    }
    if ([text.lowercaseString rangeOfString:@"!"].location == 0) {
        text = [text substringFromIndex:1];
        if (text.length == 0) {
            [self writeByRunner:@"That's not a boolean value (yes / no)."];
            [self scanBoolean:completionHandler];
            return;
        }
    }
    if ([text.lowercaseString isEqualToString:@"y"]||
        [text.lowercaseString isEqualToString:@"t"]||
        [text.lowercaseString isEqualToString:@"yes"]||
        [text.lowercaseString isEqualToString:@"true"]||
        [text isEqualToString:@"1"]) {
        completionHandler(@1);
    }else if ([text.lowercaseString isEqualToString:@"n"]||
              [text.lowercaseString isEqualToString:@"f"]||
              [text.lowercaseString isEqualToString:@"no"]||
              [text.lowercaseString isEqualToString:@"false"]||
              [text isEqualToString:@"0"]) {
        completionHandler(@0);
    }else{
        [self writeByRunner:@"That's not a boolean value (yes / no)."];
        [self scanBoolean:completionHandler];
        return;
    }
}

- (void)scanInteger:(void (^)(NSNumber *))completionHandler{
    char input[256];
    fgets(input, 256, stdin);
    int lenght = (int)strlen(input);
    input[lenght - 1] = 0;
    NSString *text = [NSString stringWithUTF8String:input];
    if ([text.lowercaseString isEqualToString:@"/scaninfo"]) {
        [self writeByRunner:@"You are supposed to enter a number value (3,41 / 2,71 / 42 / ...)."];
        [self scanInteger:completionHandler];
        return;
    }
    if ([text.lowercaseString rangeOfString:@"!"].location == 0) {
        text = [text substringFromIndex:1];
        if (text.length == 0) {
            [self writeByRunner:@"That's not an integer value (3.41 / 2.71 / 42 / ...)."];
            [self scanInteger:completionHandler];
            return;
        }
    }
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = NSNumberFormatterDecimalStyle;
    formatter.localizesFormat = NO;
    NSNumber *number = [formatter numberFromString:text];
    if (number) {
        completionHandler(number);
    }else{
        [self writeByRunner:@"That's not an integer value (3.41 / 2.71 / 42 / ...)."];
        [self scanInteger:completionHandler];
        return;
    }
}

- (void)scanString:(void (^)(NSString *))completionHandler{
    char input[256];
    fgets(input, 256, stdin);
    int lenght = (int)strlen(input);
    input[lenght - 1] = 0;
    NSString *text = [NSString stringWithUTF8String:input];
    if ([text.lowercaseString isEqualToString:@"/scaninfo"]) {
        [self writeByRunner:@"You are supposed to enter a string value ('Hello World' / 'I love Ice Cream' / ...)."];
        [self scanString:completionHandler];
        return;
    }
    if ([text.lowercaseString rangeOfString:@"!"].location == 0) {
        text = [text substringFromIndex:1];
        if (text.length == 0) {
            [self writeByRunner:@"That's not a string value ('Hello World' / 'I love Ice Cream' / ...)."];
            [self scanString:completionHandler];
            return;
        }
    }
    completionHandler(text);
}

- (void)write:(NSString *)string{
    printf("%s", string.UTF8String);
}

- (void)writeByRunner:(NSString *)string{
    printf("\nLynRunner: %s\n", string.UTF8String);
}

@end

NSURL *url;

bool isFileValid(char *file) {
    NSString *fileString = [NSString stringWithUTF8String:file];
    fileString = [fileString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([[NSFileManager defaultManager] fileExistsAtPath:fileString]) {
        if ([[fileString pathExtension] isEqualToString:@"lyn"]) {
            return true;
        }
    }
    return false;
}

void getFile() {
    bool fileIsNotValid = YES;
    while (fileIsNotValid) {
        char file[256];
        int lenght;
        printf("Which programm (.lyn file) should be executed?\n");
        fgets(file, 256, stdin);
        lenght = (int)strlen(file);
        file[lenght - 1] = 0;
        if (isFileValid(file)) {
            fileIsNotValid = NO;
            NSString *fileString = [NSString stringWithUTF8String:file];
            fileString = [fileString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            url = [NSURL URLWithString:fileString];
        }else{
            printf("%s couldn't be found.\n", file);
        }
    }
}

void execute() {
    RunnerController *runnerController = [[RunnerController alloc] initWithURL:url];
    @try {
        [runnerController start];
    }
    @catch (NSException *exception) {
        printf("Execution was cancled because an error occured.");
    }
    @finally {
        
    }
}

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        if (argc < 2) {
            getFile();
        }else if (argc == 2) {
            if (isFileValid((char*)argv[1])) {
                NSString *file = [NSString stringWithUTF8String:argv[1]];
                url = [NSURL URLWithString:file];
            }else{
                printf("%s couldn't be found.\n", argv[1]);
                getFile();
            }
        }
        printf("%s will be executed...", url.absoluteString.UTF8String);
        system("clear");
        execute();
    }
    return 0;
}

