//
//  LynRunnerConsoleView.m
//  Lyn
//
//  Created by Programmieren on 19.10.13.
//  Copyright (c) 2013 Arne Philipeit Software. All rights reserved.
//

#import "LynRunnerConsoleView.h"

@interface LynRunnerConsoleView () <NSSoundDelegate>

@property IBOutlet NSView *subView;

@property IBOutlet NSTextView *textView;
@property IBOutlet NSScrollView *scrollView;
@property IBOutlet NSTextField *textField;

- (IBAction)enterdText:(id)sender;

@end

@implementation LynRunnerConsoleView{
    BOOL lastWriteByRunner;
    BOOL finished;
    
    NSArray *confirmedObjects;
    
    LynDataType scanType;
    void (^scanCompletionHandler)(id);
}
@synthesize project = _project;

- (id)init{
    self = [super init];
    if (self) {
        lastWriteByRunner = YES;
        finished = NO;
        scanType = LynDataTypeNone;
        scanCompletionHandler = NULL;
        [[NSBundle bundleForClass:[self class]]  loadNibNamed:@"LynRunnerConsoleView" owner:self topLevelObjects:nil];
    }
    return self;
}

- (id)initWithFrame:(NSRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        lastWriteByRunner = YES;
        finished = NO;
        scanType = LynDataTypeNone;
        scanCompletionHandler = NULL;
        [[NSBundle bundleForClass:[self class]]  loadNibNamed:@"LynRunnerConsoleView" owner:self topLevelObjects:nil];
    }
    return self;
}

- (void)awakeFromNib{
    if (_subView&&!_subView.superview) {
        _subView.frame = self.bounds;
        _subView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
        [self addSubview:_subView];
    }
}

#pragma mark Properties

- (LynProject *)project{
    return _project;
}

- (void)setProject:(LynProject *)project{
    if (project == _project||!project) return;
    [_runner stop];
    _runner = nil;
    finished = NO;
    _project = project;
    _runner = [[LynRunner alloc] initWithExecutedObject:_project andDelegate:self];
}

#pragma mark Execution

- (void)start{
    if (finished) {
        [_delegate reload];
    }else{
        [_runner start];
    }
}

- (void)stop{
    [_runner stop];
}

- (void)reload{
    [_delegate reload];
}

- (void)clear{
    [_textView.textStorage setAttributedString:[[NSAttributedString alloc] initWithString:@""]];
}

- (void)scanInfo{
    if (scanType == LynDataTypeNone) {
        [self writeByRunner:@"The programm doesn't ask you for anything at the moment."];
    }else if (scanType == LynDataTypeBoolean) {
        [self writeByRunner:@"You are supposed to enter a boolean value (yes / no)."];
    }else if (scanType == LynDataTypeInteger) {
        [self writeByRunner:@"You are supposed to enter a number value (3,41 / 2,71 / 42 / ...)."];
    }else if (scanType == LynDataTypeString) {
        [self writeByRunner:@"You are supposed to enter a string value ('Hello World' / 'I love Ice Cream' / ...)."];
    }
}

#pragma mark Execution Delegate

- (BOOL)canUseTimer{
    return YES;
}

- (void)startedExecuting{
    [_delegate startedExecuting];
}

- (void)stoppedExecuting{
    [_delegate stoppedExecuting];
}

- (void)finishedExecuting{
    finished = YES;
    [_delegate finishedExecuting];
}

- (NSAlert*)preparedAlertForOpening{
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"Allow"];
    [alert addButtonWithTitle:@"Cancel"];
    [alert setShowsSuppressionButton:YES];
    [alert.suppressionButton setTitle:@"Don't warn me again"];
    [alert setAlertStyle:NSCriticalAlertStyle];
    return alert;
}

- (void)openApplication: (NSString*)application{
    if (!_warnOnOpeningApplication) {
        [[NSWorkspace sharedWorkspace] launchApplication:application];
        return;
    }
    [_runner stopWithoutMessage];
    confirmedObjects = @[application];
    NSAlert *alert = [self preparedAlertForOpening];
    [alert setMessageText:@"Allow Opening Application"];
    NSString *informativeText;
    informativeText = [NSString stringWithFormat:@"%@ wants to open the Application: '%@'.Do you allow that?", _project.name, application];
    [alert setInformativeText:informativeText];
    [alert beginSheetModalForWindow:self.window
                      modalDelegate:self
                     didEndSelector:@selector(shouldOpenAppAlertDidEnd:
                                              returnCode:contextInfo:)
                        contextInfo:NULL];
}

- (void)shouldOpenAppAlertDidEnd:(NSAlert *)alert
                      returnCode:(NSInteger)returnCode
                     contextInfo:(NSString*)contextInfo{
    if (returnCode == NSAlertFirstButtonReturn) {
        NSString *app = (NSString*)confirmedObjects[0];
        [[NSWorkspace sharedWorkspace] launchApplication:app];
    }
    if (alert.suppressionButton.state == 1) {
        _warnOnOpeningApplication = NO;
        [_delegate settingChanged:@"warnOnOpeningApplication"];
    }
    if (!_runner.running&&!finished) {
        [_runner startWithoutMessage];
    }
}

- (void)openFile: (NSString*)file{
    if (!_warnOnOpeningFile) {
        [[NSWorkspace sharedWorkspace] openFile:file];
    }
    [_runner stopWithoutMessage];
    confirmedObjects = @[file];
    NSAlert *alert = [self preparedAlertForOpening];
    [alert setMessageText:@"Allow Opening File"];
    NSString *informativeText;
    informativeText = [NSString stringWithFormat:@"%@ wants to open the File: '%@'. Do you allow that?", _project.name, file];
    [alert setInformativeText:informativeText];
    [alert beginSheetModalForWindow:self.window
                      modalDelegate:self
                     didEndSelector:@selector(shouldOpenFileAlertDidEnd:
                                              returnCode:contextInfo:)
                        contextInfo:NULL];
}

- (void)shouldOpenFileAlertDidEnd:(NSAlert *)alert
                       returnCode:(NSInteger)returnCode
                      contextInfo:(NSString*)contextInfo{
    if (returnCode == NSAlertFirstButtonReturn) {
        NSString *file = (NSString*)confirmedObjects[0];
        [[NSWorkspace sharedWorkspace] openFile:file];
    }
    if (alert.suppressionButton.state == 1) {
        _warnOnOpeningFile = NO;
        [_delegate settingChanged:@"warnOnOpeningFile"];
    }
    if (!_runner.running&&!finished) {
        [_runner startWithoutMessage];
    }
}

- (void)openFile: (NSString*)file withApplication: (NSString*)application{
    if (!_warnOnOpeningFileWithApplication) {
        [[NSWorkspace sharedWorkspace] openFile:file withApplication:application];
    }
    [_runner stopWithoutMessage];
    confirmedObjects = @[file, application];
    NSAlert *alert = [self preparedAlertForOpening];
    [alert setMessageText:@"Allow Opening File"];
    NSString *informativeText;
    informativeText = [NSString stringWithFormat:@"%@ wants to open the File: '%@' with the Application: '%@'. Do you allow that?", _project.name, file, application];
    [alert setInformativeText:informativeText];
    [alert beginSheetModalForWindow:self.window
                      modalDelegate:self
                     didEndSelector:@selector(shouldOpenFileWithAppAlertDidEnd:returnCode:contextInfo:)
                        contextInfo:NULL];
}

- (void)shouldOpenFileWithAppAlertDidEnd:(NSAlert *)alert
                              returnCode:(NSInteger)returnCode
                             contextInfo:(NSData*)contextData{
    if (returnCode == NSAlertFirstButtonReturn) {
        NSString *file = (NSString*)confirmedObjects[0];
        NSString *app = (NSString*)confirmedObjects[1];
        [[NSWorkspace sharedWorkspace] openFile:file withApplication:app];
    }
    if (alert.suppressionButton.state == 1) {
        _warnOnOpeningFileWithApplication = NO;
        [_delegate settingChanged:@"warnOnOpeningFileWithApplication"];
    }
    if (!_runner.running&&!finished) {
        [_runner startWithoutMessage];
    }
}

- (void)playSound: (NSString*)soundName atVolume:(float)volume complete:(BOOL)complete{
    NSSound *sound = [NSSound soundNamed:soundName];
    if (sound) {
        [sound setVolume:volume];
        if (complete) {
            [sound setDelegate:(id<NSSoundDelegate>)self];
            [_runner stopWithoutMessage];
        }
        [sound play];
    }
}

- (void)sound: (NSSound*)sound didFinishPlaying: (BOOL)finishedPlaying{
    if (!_runner.running&&!finished) {
        [_runner startWithoutMessage];
    }
}

- (void)postNotification: (NSString*)text{
    NSUserNotificationCenter *notificationCenter = [NSUserNotificationCenter defaultUserNotificationCenter];
    NSUserNotification *notification = [[NSUserNotification alloc] init];
    notification.title = _project.name;
    notification.informativeText = text;
    notification.hasActionButton = NO;
    [notificationCenter deliverNotification:notification];
}

- (void)scanBoolean:(void (^)(NSNumber *))completionHandler{
    scanType = LynDataTypeBoolean;
    scanCompletionHandler = completionHandler;
    [_textField.window makeFirstResponder:_textField];
}

- (void)scanInteger:(void (^)(NSNumber *))completionHandler{
    scanType = LynDataTypeInteger;
    scanCompletionHandler = completionHandler;
    [_textField.window makeFirstResponder:_textField];
}

- (void)scanString:(void (^)(NSString *))completionHandler{
    scanType = LynDataTypeString;
    scanCompletionHandler = completionHandler;
    [_textField.window makeFirstResponder:_textField];
}

- (void)write:(NSString *)string{
    NSString *newString;
    if (lastWriteByRunner&&_textView.string.length > 0) {
        newString = @"\n\n";
    }else{
        newString = @"";
    }
    newString = [newString stringByAppendingString:string];
    if (_indentProgrammOutput) {
        newString = [newString stringByReplacingOccurrencesOfString:@"\n" withString:@"\n    "];
    }
    NSMutableAttributedString *newAttributedString = [[NSMutableAttributedString alloc] initWithString:newString];
    [newAttributedString beginEditing];
    [newAttributedString addAttribute:NSFontAttributeName
                                value:(_programmOutputFont) ? _programmOutputFont : [NSFont systemFontOfSize:12]
                                range:NSMakeRange(0, newString.length)];
    [newAttributedString endEditing];
    BOOL scrollDown = (_scrollView.verticalScroller.floatValue == 1.0);
    [_textView.textStorage appendAttributedString:newAttributedString];
    lastWriteByRunner = NO;
    if (scrollDown) [_textView scrollToEndOfDocument:self];
    [_scrollView flashScrollers];
}

- (void)writeByRunner:(NSString*)string{
    NSString *newString;
    if (!lastWriteByRunner&&_textView.string.length > 0) {
        newString = (_indentRunnerOutput) ? @"\n\n    LynRunner: " : @"\n\nLynRunner: ";
    }else if(_textView.string.length > 0) {
        newString = (_indentRunnerOutput) ? @"\n    LynRunner: " : @"\nLynRunner: ";
    }else{
        newString = (_indentRunnerOutput) ? @"    LynRunner: " : @"LynRunner: ";
    }
    newString = [newString stringByAppendingString:string];
    NSMutableAttributedString *newAttributedString = [[NSMutableAttributedString alloc] initWithString:newString];
    [newAttributedString beginEditing];
    [newAttributedString addAttribute:NSFontAttributeName
                                value:(_runnerOutputFont) ? _runnerOutputFont : [NSFont boldSystemFontOfSize:12]
                                range:NSMakeRange(0, newString.length)];
    [newAttributedString endEditing];
    BOOL scrollDown = (_scrollView.verticalScroller.floatValue == 1.0);
    [_textView.textStorage appendAttributedString:newAttributedString];
    lastWriteByRunner = YES;
    if (scrollDown) [_textView scrollToEndOfDocument:self];
    [_scrollView flashScrollers];
}

#pragma mark Actions

- (void)startRunning:(id)sender{
    [self start];
}

- (void)stopRunning:(id)sender{
    [self stop];
}

- (void)reload:(id)sender{
    [_delegate reload];
}

- (void)clearConsole:(id)sender{
    [self clear];
}

- (void)enterdText:(id)sender{
    if (_textField.stringValue.length < 1) return;
    if ([_textField.stringValue.lowercaseString rangeOfString:@"/"].location == 0) {
        if (_textField.stringValue.length == 1) {
            _textField.stringValue = @"";
            return;
        }
        
        NSString *command = [_textField.stringValue substringFromIndex:1];
        
        if ([command.lowercaseString isEqualToString:@"reload"]) {
            [_delegate reload];
        }else if ([command.lowercaseString isEqualToString:@"start"]) {
            [self start];
        }else if ([command.lowercaseString isEqualToString:@"stop"]) {
            [self stop];
        }else if ([command.lowercaseString isEqualToString:@"clear"]) {
            [self clear];
        }else if ([command.lowercaseString isEqualToString:@"scaninfo"]) {
            [self scanInfo];
        }else{
            [_delegate enteredCommand:[_textField.stringValue substringFromIndex:1]];
        }
    }else{
        NSString *text = _textField.stringValue;
        if ([_textField.stringValue.lowercaseString rangeOfString:@"!"].location == 0) {
            text = [_textField.stringValue substringFromIndex:1];
            _textField.stringValue = @"";
            if (text.length == 0) return;
        }else{
            text = _textField.stringValue.copy;
        }
        if (scanCompletionHandler) {
            if (scanType == LynDataTypeBoolean) {
                if ([text.lowercaseString isEqualToString:@"y"]||
                    [text.lowercaseString isEqualToString:@"t"]||
                    [text.lowercaseString isEqualToString:@"yes"]||
                    [text.lowercaseString isEqualToString:@"true"]||
                    [text isEqualToString:@"1"]) {
                    scanCompletionHandler(@1);
                }else if ([text.lowercaseString isEqualToString:@"n"]||
                          [text.lowercaseString isEqualToString:@"f"]||
                          [text.lowercaseString isEqualToString:@"no"]||
                          [text.lowercaseString isEqualToString:@"false"]||
                          [text isEqualToString:@"0"]) {
                    scanCompletionHandler(@0);
                }else{
                    NSBeep();
                    return;
                }
            }else if (scanType == LynDataTypeInteger) {
                NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
                formatter.numberStyle = NSNumberFormatterDecimalStyle;
                formatter.localizesFormat = NO;
                NSNumber *number = [formatter numberFromString:text];
                if (number) {
                    scanCompletionHandler(number);
                }else{
                    NSBeep();
                    return;
                }
            }else if (scanType == LynDataTypeString) {
                scanCompletionHandler(text);
            }
            scanType = LynDataTypeNone;
            scanCompletionHandler = NULL;
        }
    }
    _textField.stringValue = @"";
}

#pragma mark Menu Item Validation

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem{
    if (menuItem.action == @selector(startRunning:)) {
        return (!_runner.running&&!finished);
    }else if (menuItem.action == @selector(stopRunning:)) {
        return _runner.running;
    }else if (menuItem.action == @selector(reload:)) {
        return YES;
    }else if (menuItem.action == @selector(clearConsole:)) {
        return _textView.textStorage.string.length > 0;
    }else{
        return NO;
    }
}

@end
