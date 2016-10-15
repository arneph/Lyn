//
//  LynProjectView.m
//  Lyn
//
//  Created by Programmieren on 28.06.13.
//  Copyright (c) 2013 Arne Philipeit Software. All rights reserved.
//

#import "LynProjectView.h"

@interface LynProjectView ()

@property IBOutlet NSView *subView;

@property IBOutlet NSTextField *txtAuthor;
@property IBOutlet NSTextField *txtEMail;
@property IBOutlet NSTextField *txtComment;

@property IBOutlet NSButton *chkLoop;

- (IBAction)generalPropertyChanged:(id)sender;

- (IBAction)loopChanged:(id)sender;
- (IBAction)resetColors:(id)sender;

@end

@implementation LynProjectView
@synthesize shownProject = _shownProject;

- (id)init{
    self = [super init];
    if (self) {
        [[NSBundle bundleForClass:[self class]]  loadNibNamed:@"LynProjectView" owner:self topLevelObjects:nil];
    }
    return self;
}

- (id)initWithFrame:(NSRect)frameRect{
    self = [super initWithFrame:frameRect];
    if (self) {
        [[NSBundle bundleForClass:[self class]]  loadNibNamed:@"LynProjectView" owner:self topLevelObjects:nil];
    }
    return self;
}

- (void)awakeFromNib{
    if (_subView) {
        _subView.frame = self.bounds;
        [self addSubview:_subView];
        [_subView setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable];
        if (_shownProject) {
            _txtAuthor.stringValue = _shownProject.author;
            _txtEMail.stringValue = _shownProject.eMail;
            _txtComment.stringValue = _shownProject.comment;
            _chkLoop.state = _shownProject.loop;
        }
    }
}

- (LynProject *)shownProject{
    return _shownProject;
}

- (void)setShownProject:(LynProject *)shownProject{
    _shownProject = shownProject;
    if (_shownProject) {
        _txtAuthor.stringValue = _shownProject.author;
        _txtEMail.stringValue = _shownProject.eMail;
        _txtComment.stringValue = _shownProject.comment;
        _chkLoop.state = _shownProject.loop;
    }
}

- (void)setGeneralProperty: (NSDictionary*)info{
    NSString *key = info[@"key"];
    NSString *value = info[@"value"];
    NSString *oldValue = [_shownProject valueForKey:key];
    [_shownProject setValue:value forKey:key];
    _txtAuthor.stringValue = _shownProject.author;
    _txtEMail.stringValue = _shownProject.eMail;
    _txtComment.stringValue = _shownProject.comment;
    [_document.undoManager registerUndoWithTarget:self
                                         selector:@selector(setGeneralProperty:)
                                           object:@{@"key" : key, @"value" : oldValue}];
}

- (void)setLoop: (NSNumber *)loop{
    _shownProject.loop = loop.boolValue;
    _chkLoop.state = loop.integerValue;
    [_document.undoManager registerUndoWithTarget:self selector:@selector(setLoop:) object:@(!loop.boolValue)];
}

- (void)generalPropertyChanged:(NSTextField*)sender{
    NSString *key = sender.identifier;
    NSString *value = sender.stringValue;
    if (![[_shownProject valueForKey:key] isEqualToString:value]) {
        [self setGeneralProperty:@{@"key" : key, @"value" : value}];
    }
}

- (void)loopChanged:(id)sender{
    [self setLoop:@(_chkLoop.state)];
    [_document.undoManager setActionName:@"Changing Loop Property"];
}

- (void)resetColors:(id)sender{
    [[LynProjectSettingsManager managerForProject:_shownProject] resetColors];
    [_document updateChangeCount:NSChangeDone];
}

- (void)focus{
    [self.window makeFirstResponder:self];
}

@end
