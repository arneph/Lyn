//
//  LynWarningsView.m
//  Lyn
//
//  Created by Programmieren on 10.07.13.
//  Copyright (c) 2013 Arne Philipeit Software. All rights reserved.
//

#import "LynWarningsView.h"

@interface LynWarningsView () <NSTableViewDataSource, NSTableViewDelegate>

@property IBOutlet NSView *subView;

@property IBOutlet NSButton *btnShowWarnings;
@property IBOutlet NSButton *btnShowErrors;

@property IBOutlet NSTableView *tableView;

@property IBOutlet NSSlider *sldlDetails;

- (IBAction)refresh:(id)sender;
- (IBAction)showWarning:(id)sender;
- (IBAction)rowHeightChanged:(id)sender;

@end

@implementation LynWarningsView{
    NSUInteger rowHeight;
}

@synthesize project = _project;
@synthesize showWarnings = _showWarnings;
@synthesize showErrors = _showErrors;

- (id)init{
    self = [super init];
    if (self) {
        _showWarnings = YES;
        _showErrors = YES;
        rowHeight = 36;
        [[NSBundle bundleForClass:[self class]]  loadNibNamed:@"LynWarningsView" owner:self topLevelObjects:nil];
    }
    return self;
}

- (id)initWithFrame:(NSRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        _showWarnings = YES;
        _showErrors = YES;
        rowHeight = 36;
        [[NSBundle bundleForClass:[self class]]  loadNibNamed:@"LynWarningsView" owner:self topLevelObjects:nil];
    }
    return self;
}

- (void)awakeFromNib{
    _subView.frame = self.bounds;
    [self addSubview:_subView];
}

#pragma mark Properties

- (LynProject *)project{
    return _project;
}

- (void)setProject:(LynProject *)project{
    _project = project;
    [NotificationCenter removeObserver:self
                                  name:LynOutlineObjectNumberOfWarningsAndErrorsChangedNotification
                                object:nil];
    [NotificationCenter removeObserver:self
                                  name:LynOutlineObjectNumberOfWarningsChangedNotification
                                object:nil];
    [NotificationCenter removeObserver:self
                                  name:LynOutlineObjectNumberOfErrorsChangedNotification
                                object:nil];
    [NotificationCenter addObserver:self
                           selector:@selector(numberOfWarningsAndErrorsChanged:)
                               name:LynOutlineObjectNumberOfWarningsAndErrorsChangedNotification
                             object:_project];
    [NotificationCenter addObserver:self
                           selector:@selector(numberOfWarningsChanged:)
                               name:LynOutlineObjectNumberOfWarningsChangedNotification
                             object:_project];
    [NotificationCenter addObserver:self
                           selector:@selector(numberOfErrorsChanged:)
                               name:LynOutlineObjectNumberOfErrorsChangedNotification
                             object:_project];
    [_tableView reloadData];
}

- (BOOL)showWarnings{
    return _showWarnings;
}

- (void)setShowWarnings:(BOOL)showWarnings{
    _showWarnings = showWarnings;
    [_tableView reloadData];
}

- (BOOL)showErrors{
    return _showErrors;
}

- (void)setShowErrors:(BOOL)showErrors{
    _showErrors = showErrors;
    [_tableView reloadData];
}

#pragma mark TableView Datasource

- (NSArray*)warningsAndErrors{
    NSMutableArray *warningsAndErrors = [[NSMutableArray alloc] init];
    if (_showErrors) {
        [warningsAndErrors addObjectsFromArray:[_project errorsIncludingSubObjects:YES]];
    }
    if (_showWarnings) {
        [warningsAndErrors addObjectsFromArray:[_project warningsIncludingSubObjects:YES]];
    }
    return [NSArray arrayWithArray:warningsAndErrors];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    NSUInteger warningsAndErrors = [self warningsAndErrors].count;
    return (warningsAndErrors < 1&&(_showWarnings||_showErrors)) ? 1 : warningsAndErrors;
}

#pragma mark TableView Delegate

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row{
    return rowHeight;
}

- (NSView *)tableView:(NSTableView *)tableView
   viewForTableColumn:(NSTableColumn *)tableColumn
                  row:(NSInteger)row{
    
    NSTableCellView *cellView = [_tableView makeViewWithIdentifier:@"LynWarningCell"
                                                             owner:self];
    if ([self warningsAndErrors].count < 1) {
        cellView.imageView.image = [NSImage imageNamed:NSImageNameStatusAvailable];
        if (_showWarnings&&!_showErrors) {
            cellView.textField.stringValue = @"No Warninga";
        }else if (!_showWarnings&&_showErrors) {
            cellView.textField.stringValue = @"No Errors";
        }else if (_showWarnings&&_showErrors){
            cellView.textField.stringValue = @"No Warnings or Errors";
        }else{
            return nil;
        }
    }else{
        LynWarning *warning = [self warningsAndErrors][row];
        cellView.textField.stringValue = warning.messageText;
        if ([warning isKindOfClass:[LynError class]]) {
            cellView.imageView.image = [NSImage imageNamed:NSImageNameStatusUnavailable];
        }else{
            cellView.imageView.image = [NSImage imageNamed:NSImageNameStatusPartiallyAvailable];
        }
    }
    return cellView;
}

- (BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row{
    if ([self warningsAndErrors].count > 0) {
        [_delegate selectObject:((LynWarning*)[self warningsAndErrors][row]).object];
        [_tableView.window makeFirstResponder:_tableView];
        return YES;
    }else{
        return NO;
    }
}

#pragma mark Notifications

- (void)numberOfWarningsAndErrorsChanged: (NSNotification*)notification{
    if (_showWarnings||_showErrors) [_tableView reloadData];
}

- (void)numberOfWarningsChanged: (NSNotification*)notification{
    if (_showWarnings) [_tableView reloadData];
}

- (void)numberOfErrorsChanged: (NSNotification*)notification{
    if (_showErrors) [_tableView reloadData];
}

#pragma mark Actions

- (void)refresh:(id)sender{
    [_tableView reloadData];
}

- (void)showWarning:(NSButton*)sender{
    NSUInteger row = [_tableView rowForView:sender.superview];
    if ([self warningsAndErrors].count > 0) {
        [_delegate selectObject:((LynWarning*)[self warningsAndErrors][row]).object];
        [_tableView selectRowIndexes:[NSIndexSet indexSetWithIndex:row]
                byExtendingSelection:NO];
        [_tableView.window makeFirstResponder:_tableView];
    }
}

- (void)rowHeightChanged:(id)sender{
    NSUInteger tick = round(_sldlDetails.doubleValue);
    rowHeight = (tick * 17) + 2;
    _sldlDetails.integerValue = tick;
    NSIndexSet *indexSet = _tableView.selectedRowIndexes;
    [_tableView setRowHeight:rowHeight];
    [_tableView reloadData];
    [_tableView selectRowIndexes:indexSet byExtendingSelection:YES];
}

@end
