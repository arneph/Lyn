//
//  LynLibraryView.m
//  Lyn
//
//  Created by Programmieren on 17.08.13.
//  Copyright (c) 2013 Arne Philipeit Software. All rights reserved.
//

#import "LynLibraryView.h"
#import "LynLibraryViewHelperClasses.h"

@interface LynLibraryView () <NSOutlineViewDataSource, NSOutlineViewDelegate, NSTextFieldDelegate>

@property IBOutlet NSView *subView;
@property IBOutlet NSOutlineView *outlineView;

@property IBOutlet NSSearchField *searchField;

@property IBOutlet NSView  *infoView;
@property IBOutlet NSTextView *infoField;

- (IBAction)searchTermChanged:(id)sender;

- (IBAction)showInfo:(id)sender;
- (IBAction)colorCodeColorChanged:(id)sender;

@end

@implementation LynLibraryView{
    BOOL activeSearch;
    NSArray *searchResults;
    
    LynProjectSettingsManager *projectSettingsManager;
    NSPopover *popover;
    id popoverItem;
    
    BOOL ignoreNextColorsChangedNotification;
}
@synthesize project = _project;

- (id)init{
    self = [super init];
    if (self) {
        [[NSBundle bundleForClass:[self class]]  loadNibNamed:@"LynLibraryView" owner:self topLevelObjects:nil];
        [NotificationCenter addObserver:self
                               selector:@selector(colorsChanged:)
                                   name:LynProjectManagerColorsChangedNotification
                                 object:nil];
    }
    return self;
}

- (id)initWithFrame:(NSRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [[NSBundle bundleForClass:[self class]]  loadNibNamed:@"LynLibraryView" owner:self topLevelObjects:nil];
        [NotificationCenter addObserver:self
                               selector:@selector(colorsChanged:)
                                   name:LynProjectManagerColorsChangedNotification
                                 object:nil];
    }
    return self;
}

- (void)awakeFromNib{
    if (_subView&&_subView.superview != self) {
        [self setAutoresizesSubviews:YES];
        _subView.frame = self.bounds;
        [self addSubview:_subView];
    }
    if (_outlineView) {
        _outlineView.floatsGroupRows = YES;
    }
    if (_searchField) {
        [NotificationCenter addObserver:self
                               selector:@selector(searchTermDidChange:)
                                   name:NSControlTextDidChangeNotification
                                 object:_searchField];
    }
}

#pragma mark Notifications

- (void)colorsChanged: (NSNotification*)notification{
    if (ignoreNextColorsChangedNotification) {
        ignoreNextColorsChangedNotification = NO;
        return;
    }
    if (notification.userInfo[@"project"] == _project) {
        [_outlineView reloadData];
    }
}

#pragma mark Properties

- (LynProject *)project{
    return _project;
}

- (void)setProject:(LynProject *)project{
    _project = project;
    projectSettingsManager = [LynProjectSettingsManager managerForProject:project];
    [_outlineView reloadData];
}

#pragma mark OutlineView DataSource

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item{
    if (!item) {
        return (activeSearch) ? searchResults.count : [LynCommands numberOfGroups];
    }else{
        if (activeSearch) return 0;
        NSArray *group = item;
        return group.count;
    }
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item{
    if (!item) {
        return (activeSearch) ? searchResults[index] : [LynCommands groups][index];
    }else{
        return (activeSearch) ? nil : ((NSArray*) item)[index];
    }
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item{
    return (activeSearch) ? NO : [item isKindOfClass:[NSArray class]];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView
         writeItems:(NSArray *)items
       toPasteboard:(NSPasteboard *)pboard{
    NSMutableArray *commands = [[NSMutableArray alloc] init];
    for (id item in items) {
        if ([_outlineView parentForItem:item])
            [commands addObject:item];
    }
    if (commands.count < 1) return NO;
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:commands];
    [pboard declareTypes:@[@"de.AP-Software.Lyn.CommandDragType"]
                   owner:self];
    [pboard setData:data forType:@"de.AP-Software.Lyn.CommandDragType"];
    return YES;
}

#pragma mark OutlineView Delegate

-(NSView *)outlineView:(NSOutlineView *)outlineView
    viewForTableColumn:(NSTableColumn *)tableColumn
                  item:(id)item{
    if ([item isKindOfClass:[NSArray class]]) {
        NSTableCellView *headerCell = [_outlineView makeViewWithIdentifier:@"HeaderCell" owner:self];
        headerCell.textField.stringValue = [LynCommands nameOfGroup:[[LynCommands groups] indexOfObject:item]];
        return headerCell;
    }else{
        LynCommandTableCellView *tableCell = [_outlineView makeViewWithIdentifier:@"TableCell"
                                                                            owner:self];
        tableCell.textField.stringValue = [[((LynCommand*) item) class] name];
        if (projectSettingsManager) {
            tableCell.colorCodeColorWell.color = [projectSettingsManager colorForType:[[((LynCommand*) item) class] name]];
        }
        tableCell.mayHideInfoButton = YES;
        return tableCell;
    }
}

- (NSTableRowView *)outlineView:(NSOutlineView *)outlineView rowViewForItem:(id)item{
    if (![_outlineView parentForItem:item]&&!activeSearch) {
        LynCommandGroupTableRowView *rowView = [[LynCommandGroupTableRowView alloc] init];
        if ([LynCommands groups].firstObject != item) {
            rowView.drawTopSeparator = YES;
        }else{
            rowView.drawTopSeparator = NO;
        }
        if ([LynCommands groups].lastObject != item&&![_outlineView isItemExpanded:item]) {
            rowView.drawBottomSeparator = NO;
        }else{
            rowView.drawBottomSeparator = YES;
        }
        return rowView;
    }else{
        return [[NSTableRowView alloc] init];
    }
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isGroupItem:(id)item{
    return (![_outlineView parentForItem:item]&&!activeSearch);
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldSelectItem:(id)item{
    return ([_outlineView parentForItem:item] != nil||activeSearch);
}

- (CGFloat)outlineView:(NSOutlineView *)outlineView heightOfRowByItem:(id)item{
    return 20;
}

- (void)outlineViewItemDidCollapse:(NSNotification *)notification{
    LynCommandGroupTableRowView *rowView = [_outlineView rowViewAtRow:[_outlineView rowForItem:notification.userInfo[@"NSObject"]]
                                                      makeIfNecessary:NO];
    if ([LynCommands groups].lastObject != notification.userInfo[@"NSObject"]) {
        rowView.drawBottomSeparator = NO;
    }
}

- (void)outlineViewItemDidExpand:(NSNotification *)notification{
    LynCommandGroupTableRowView *rowView = [_outlineView rowViewAtRow:[_outlineView rowForItem:notification.userInfo[@"NSObject"]]
                                                      makeIfNecessary:NO];
    rowView.drawBottomSeparator = YES;
}

#pragma mark Search

- (void)updateSearchResults{
    NSString *searchTerm = _searchField.stringValue.lowercaseString;
    NSMutableArray *tmpResults = [[NSMutableArray alloc] init];
    for (LynCommand *command in [LynCommands commands]) {
        NSString *name = [[command class] name].lowercaseString;
        NSString *description = [[command class] description].lowercaseString;
        if ([name rangeOfString:searchTerm].location != NSNotFound||
            [searchTerm rangeOfString:name].location != NSNotFound||
            [description rangeOfString:searchTerm].location != NSNotFound||
            [searchTerm rangeOfString:description].location != NSNotFound) {
            [tmpResults addObject:command];
        }
    }
    searchResults = [NSArray arrayWithArray:tmpResults];
    activeSearch = YES;
    [_outlineView reloadData];
}

- (void)endSearch{
    searchResults = @[];
    activeSearch = NO;
    [_outlineView reloadData];
}

#pragma mark Actions

- (void)searchTermChanged:(id)sender{
    if (_searchField.stringValue.length > 0) {
        [self updateSearchResults];
    }else{
        [self endSearch];
    }
}

- (void)searchTermDidChange: (NSNotification*)notification{
    if (_searchField.stringValue.length > 0) {
        [self updateSearchResults];
    }else{
        [self endSearch];
    }
}

- (void)showInfo:(NSButton*)sender{
    if ([_outlineView rowForView:sender.superview.superview] == -1) return;
    LynCommand *command = [_outlineView itemAtRow:[_outlineView rowForView:sender.superview]];
    if ([_outlineView rowViewAtRow:[_outlineView rowForView:sender.superview]
                   makeIfNecessary:NO]) {
        _infoField.string = [[command class] description];
        
        NSViewController *viewController = [[NSViewController alloc] init];
        viewController.view = _infoView;
        
        if (popover.isShown) {
            LynCommandTableCellView *cellView = (LynCommandTableCellView*) [_outlineView viewAtColumn:0
                                                                                                  row:[_outlineView rowForItem:popoverItem]
                                                                                      makeIfNecessary:NO];
            cellView.mayHideInfoButton = YES;
            [popover close];
            popover = nil;
            [NotificationCenter removeObserver:self name:NSPopoverDidCloseNotification object:popover];
        }
        
        popover = [[NSPopover alloc] init];
        popover.contentViewController = viewController;
        popover.behavior = NSPopoverBehaviorTransient;
        popover.appearance = NSPopoverAppearanceMinimal;
        popover.animates = YES;
        [NotificationCenter addObserver:self
                               selector:@selector(popoverDidClose:)
                                   name:NSPopoverDidCloseNotification
                                 object:popover];
        
        [popover showRelativeToRect:sender.bounds
                             ofView:sender
                      preferredEdge:NSMinYEdge];
        
        LynCommandTableCellView *cellView = (LynCommandTableCellView*)sender.superview;
        cellView.mayHideInfoButton = NO;
        
        popoverItem = command;
    }
}

- (void)popoverDidClose: (NSNotification*)notification {
    LynCommandTableCellView *cellView = (LynCommandTableCellView*) [_outlineView viewAtColumn:0
                                                                                          row:[_outlineView rowForItem:popoverItem]
                                                                              makeIfNecessary:NO];
    cellView.mayHideInfoButton = YES;
    popover = nil;
    [NotificationCenter removeObserver:self name:NSPopoverDidCloseNotification object:popover];
}

- (void)colorCodeColorChanged:(LynSmallColorWell*)sender{
    if ([_outlineView rowForView:sender.superview.superview] == -1) return;
    LynCommand *command = [_outlineView itemAtRow:[_outlineView rowForView:sender.superview]];
    if (![[projectSettingsManager colorForType:[[command class] name]] isEqualTo:sender.color]) {
        ignoreNextColorsChangedNotification = YES;
        [projectSettingsManager setColor:sender.color forType:[[command class] name]];
        [_document updateChangeCount:NSChangeDone];
    }
}

#pragma mark Menu Items

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem{
    if (menuItem.action == @selector(copy:)) {
        NSMutableIndexSet *indexes = [[NSMutableIndexSet alloc] initWithIndexSet:_outlineView.selectedRowIndexes];
        [indexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
            if ([[_outlineView itemAtRow:idx] isKindOfClass:[NSArray class]]) [indexes removeIndex:idx];
        }];
        return (indexes.count > 0);
    }else{
        return NO;
    }
}

- (void)copy: (id)sender{
    NSMutableIndexSet *indexes = [[NSMutableIndexSet alloc] initWithIndexSet:_outlineView.selectedRowIndexes];
    [indexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        if ([[_outlineView itemAtRow:idx] isKindOfClass:[NSArray class]]) [indexes removeIndex:idx];
    }];
    if (indexes.count < 1) {
        return;
    }
    NSMutableArray *commands = [NSMutableArray arrayWithCapacity:indexes.count];
    [indexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        [commands addObject:[_outlineView itemAtRow:idx]];
    }];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:commands];
    NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
    [pasteboard declareTypes:@[@"de.AP-Software.Lyn.CommandPboardType"] owner:self];
    [pasteboard setData:data forType:@"de.AP-Software.Lyn.CommandPboardType"];
}

@end
