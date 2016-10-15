//
//  PrefrencesController.m
//  Lyn
//
//  Created by Programmieren on 19.08.13.
//  Copyright (c) 2013 Arne Philipeit Software. All rights reserved.
//

#import "PreferencesController.h"

BOOL sendChangedNotifications;

@interface PreferencesController ()

@property IBOutlet NSToolbar *toolbar;
@property IBOutlet NSTabView *tabView;

@property IBOutlet NSButton *chkAutomaticallyStartAfterOpening;
@property IBOutlet NSButton *chkClearConsoleBeforeReload;

@property IBOutlet NSButton *chkWarnOnOpeningApplications;
@property IBOutlet NSButton *chkWarnOnOpeningFiles;
@property IBOutlet NSButton *chkWarnOnOpeningFilesWithApplications;

@property IBOutlet NSButton *chkIndentRunnerOutput;
@property IBOutlet NSTextView *runnerOutputView;
@property IBOutlet NSButton *chkIndentProgrammOutput;
@property IBOutlet NSTextView *programmOutputView;

- (IBAction)showSettingsGroup:(NSToolbarItem*)sender;

- (IBAction)pushedCancel:(id)sender;
- (IBAction)pushedOkay:(id)sender;

- (IBAction)resetRunnerOutputFont:(id)sender;
- (IBAction)changeRunnerOutputFont:(id)sender;

- (IBAction)resetProgrammOutputFont:(id)sender;
- (IBAction)changeProgrammOutputFont:(id)sender;

@end

@implementation PreferencesController{
    NSFont *runnerOutputFont;
    NSFont *programmOutputFont;
    
    NSFontManager *fontManager;
}

#pragma mark Accessing Preferences

+ (void)stopSendingChangeNotifications{
    sendChangedNotifications = NO;
}

+ (void)continueSendingChangedNotificationsWithNotification:(BOOL)sendChangeNotfication{
    sendChangedNotifications = YES;
    if (sendChangedNotifications) {
        [[NSNotificationCenter defaultCenter] postNotificationName:LynRunnerPreferencesChangedNotification object:nil];
    }
}

+ (BOOL)automaticallyStartAfterOpening{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults boolForKey:@"automaticallyStartAfterOpening"];
}

+ (void)setAutomaticallyStartAfterOpening: (BOOL)autoStart{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:autoStart forKey:@"automaticallyStartAfterOpening"];
}

+ (BOOL)clearConsoleBeforeReload{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults boolForKey:@"clearConsoleBeforeReload"];
}

+ (void)setClearConsoleBeforeReload: (BOOL)clear{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:clear forKey:@"clearConsoleBeforeReload"];
}

+ (BOOL)warnOnOpeningApplications{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults boolForKey:@"warnOnOpeningApplications"];
}

+ (void)setWarnOnOpeningApplications: (BOOL)warn{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:warn forKey:@"warnOnOpeningApplications"];
}

+ (BOOL)warnOnOpeningFiles{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults boolForKey:@"warnOnOpeningFiles"];
}

+ (void)setWarnOnOpeningFiles: (BOOL)warn{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:warn forKey:@"warnOnOpeningFiles"];
}

+ (BOOL)warnOnOpeningFilesWithApplications{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults boolForKey:@"warnOnOpeningFilesWithApplications"];
}

+ (void)setWarnOnOpeningFilesWithApplications: (BOOL)warn{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:warn forKey:@"warnOnOpeningFilesWithApplications"];
}

+ (NSFont *)runnerOutputFont{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSData *data = [userDefaults dataForKey:@"runnerOutputFont"];
    NSFont *runnerOutputFont;
    if (!data) {
        runnerOutputFont = [NSFont boldSystemFontOfSize:12];
    }else{
        runnerOutputFont = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    return runnerOutputFont;
}

+ (void)setRunnerOutputFont:(NSFont *)font{
    if (!font) @throw NSInvalidArgumentException;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:font];
    [userDefaults setObject:data forKey:@"runnerOutputFont"];
}

+ (BOOL)indentRunnerOutput{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults boolForKey:@"indentRunnerOutput"];
}

+ (void)setIndentRunnerOutput:(BOOL)indent{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:indent forKey:@"indentRunnerOutput"];
}

+ (NSFont *)programmOutputFont{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSData *data = [userDefaults dataForKey:@"programmOutputFont"];
    NSFont *programmOutputFont;
    if (!data) {
        programmOutputFont = [NSFont boldSystemFontOfSize:12];
    }else{
        programmOutputFont = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    return programmOutputFont;
}

+ (void)setProgrammOutputFont:(NSFont *)font{
    if (!font) @throw NSInvalidArgumentException;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:font];
    [userDefaults setObject:data forKey:@"programmOutputFont"];
}

+ (BOOL)indentProgrammOutput{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults boolForKey:@"indentProgrammOutput"];
}

+ (void)setIndentProgrammOutput:(BOOL)indent{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:indent forKey:@"indentProgrammOutput"];
}

#pragma mark PreferencesController (Window Controller)

- (id)initWithWindow:(NSWindow *)window{
    self = [super initWithWindow:window];
    if (self) {
        runnerOutputFont = RunnerOutputFont;
        programmOutputFont = ProgrammOutputFont;
        
        fontManager = [NSFontManager sharedFontManager];
    }
    
    return self;
}

- (void)showWindow: (id)sender{
    if (!self.window) {
        [[NSBundle bundleForClass:[self class]]  loadNibNamed:@"Preferences" owner:self topLevelObjects:nil];
    }
    NSRect windowFrame = [self.window contentRectForFrameRect:self.window.frame];
    NSRect newWindowFrame = [self.window frameRectForContentRect: NSMakeRect(NSMinX(windowFrame), NSMaxY(windowFrame) - 114,
                                                                             436, 114)];
    [self.window setFrame:newWindowFrame display:YES animate:NO];
    
    [_toolbar setSelectedItemIdentifier:@"itemGeneral"];
    [_tabView selectFirstTabViewItem:sender];
    
    [_chkAutomaticallyStartAfterOpening setState:AutomaticallyStartAfterOpening];
    [_chkClearConsoleBeforeReload setState:ClearConsoleBeforeReload];
    
    [_chkWarnOnOpeningApplications setState:WarnOnOpeningApplications];
    [_chkWarnOnOpeningFiles setState:WarnOnOpeningFiles];
    [_chkWarnOnOpeningFilesWithApplications setState:WarnOnOpeningFilesWithApplications];
    
    [_chkIndentRunnerOutput setState:IndentRunnerOutput];
    [_runnerOutputView.textStorage beginEditing];
    [_runnerOutputView.textStorage addAttribute:NSFontAttributeName
                                          value:runnerOutputFont
                                          range:NSMakeRange(0, _runnerOutputView.textStorage.length)];
    [_runnerOutputView.textStorage endEditing];
    
    [_chkIndentProgrammOutput setState:IndentProgrammOutput];
    [_programmOutputView.textStorage beginEditing];
    [_programmOutputView.textStorage addAttribute:NSFontAttributeName
                                            value:programmOutputFont
                                            range:NSMakeRange(0, _programmOutputView.textStorage.length)];
    [_programmOutputView.textStorage endEditing];
    [super showWindow:sender];
}

- (void)showSettingsGroup:(NSToolbarItem *)sender{
    [_tabView selectTabViewItemAtIndex:sender.tag];
    if (sender.tag == 0) {
        NSRect windowFrame = [self.window contentRectForFrameRect:[self.window frame]];
        NSRect newWindowFrame = [self.window frameRectForContentRect: NSMakeRect(NSMinX(windowFrame), NSMaxY(windowFrame) - 114,
                                                                                 436, 114)];
        [self.window setFrame:newWindowFrame display:YES animate:YES];
    }else if (sender.tag == 1) {
        NSRect windowFrame = [self.window contentRectForFrameRect:[self.window frame]];
        NSRect newWindowFrame = [self.window frameRectForContentRect: NSMakeRect(NSMinX(windowFrame), NSMaxY(windowFrame) - 199,
                                                                                 436, 199)];
        [self.window setFrame:newWindowFrame display:YES animate:YES];
    }else if (sender.tag == 2) {
        NSRect windowFrame = [self.window contentRectForFrameRect:[self.window frame]];
        NSRect newWindowFrame = [self.window frameRectForContentRect: NSMakeRect(NSMinX(windowFrame), NSMaxY(windowFrame) - 348,
                                                                                 436, 348)];
        [self.window setFrame:newWindowFrame display:YES animate:YES];
    }
}

- (void)pushedCancel:(id)sender{
    NSFontPanel *fontPanel = [fontManager fontPanel:NO];
    [fontPanel close];
    [self.window close];
}

- (void)pushedOkay:(id)sender{
    [PreferencesController stopSendingChangeNotifications];
    [PreferencesController setAutomaticallyStartAfterOpening:_chkAutomaticallyStartAfterOpening.state];
    [PreferencesController setClearConsoleBeforeReload:_chkClearConsoleBeforeReload.state];
    
    [PreferencesController setWarnOnOpeningApplications:_chkWarnOnOpeningApplications.state];
    [PreferencesController setWarnOnOpeningFiles:_chkWarnOnOpeningFiles.state];
    [PreferencesController setWarnOnOpeningFilesWithApplications:_chkWarnOnOpeningFilesWithApplications.state];
    
    [PreferencesController setIndentRunnerOutput:_chkIndentRunnerOutput.state];
    [PreferencesController setRunnerOutputFont:runnerOutputFont];
    [PreferencesController setIndentProgrammOutput:_chkIndentProgrammOutput.state];
    [PreferencesController setProgrammOutputFont:programmOutputFont];
    [PreferencesController continueSendingChangedNotificationsWithNotification:YES];
    
    NSFontPanel *fontPanel = [fontManager fontPanel:NO];
    [fontPanel close];
    [self.window close];
}

- (void)resetRunnerOutputFont:(id)sender{
    runnerOutputFont = [NSFont boldSystemFontOfSize:12];
    NSFontPanel *fontPanel = [fontManager fontPanel:NO];
    if (fontManager.target == self&&fontManager.action == @selector(selectedRunnerOutputFont:)) {
        [fontManager setSelectedFont:runnerOutputFont isMultiple:NO];
        [fontPanel setPanelFont:runnerOutputFont isMultiple:NO];
    }
    [_runnerOutputView.textStorage beginEditing];
    [_runnerOutputView.textStorage addAttribute:NSFontAttributeName
                                          value:runnerOutputFont
                                          range:NSMakeRange(0, _runnerOutputView.textStorage.length)];
    [_runnerOutputView.textStorage endEditing];
}

- (void)changeRunnerOutputFont:(id)sender{
    [fontManager setSelectedFont:runnerOutputFont isMultiple:NO];
    [fontManager setTarget:self];
    [fontManager setAction:@selector(selectedRunnerOutputFont:)];
    NSFontPanel *fontPanel = [fontManager fontPanel:YES];
    [fontPanel setPanelFont:runnerOutputFont isMultiple:NO];
    [fontPanel makeKeyAndOrderFront:sender];
}

- (void)resetProgrammOutputFont:(id)sender{
    programmOutputFont = [NSFont systemFontOfSize:12];
    NSFontPanel *fontPanel = [fontManager fontPanel:NO];
    if (fontManager.target == self&&fontManager.action == @selector(selectedProgrammOutputFont:)) {
        [fontManager setSelectedFont:programmOutputFont isMultiple:NO];
        [fontPanel setPanelFont:programmOutputFont isMultiple:NO];
    }
    [_runnerOutputView.textStorage beginEditing];
    [_runnerOutputView.textStorage addAttribute:NSFontAttributeName
                                          value:runnerOutputFont
                                          range:NSMakeRange(0, _runnerOutputView.textStorage.length)];
    [_runnerOutputView.textStorage endEditing];
}

- (void)changeProgrammOutputFont:(id)sender{
    [fontManager setSelectedFont:programmOutputFont isMultiple:NO];
    [fontManager setTarget:self];
    [fontManager setAction:@selector(selectedProgrammOutputFont:)];
    NSFontPanel *fontPanel = [fontManager fontPanel:YES];
    [fontPanel setPanelFont:programmOutputFont isMultiple:NO];
    [fontPanel makeKeyAndOrderFront:sender];
}

- (void)selectedRunnerOutputFont:(id)sender{
    runnerOutputFont = [sender convertFont:runnerOutputFont];
    [_runnerOutputView.textStorage beginEditing];
    [_runnerOutputView.textStorage addAttribute:NSFontAttributeName
                                          value:runnerOutputFont
                                          range:NSMakeRange(0, _runnerOutputView.textStorage.length)];
    [_runnerOutputView.textStorage endEditing];
}

- (void)selectedProgrammOutputFont:(id)sender{
    programmOutputFont = fontManager.selectedFont;
    [_programmOutputView.textStorage beginEditing];
    [_programmOutputView.textStorage addAttribute:NSFontAttributeName
                                            value:programmOutputFont
                                            range:NSMakeRange(0, _programmOutputView.textStorage.length)];
    [_programmOutputView.textStorage endEditing];
}
     
- (void)changeAttributes: (id)sender{}

@end
