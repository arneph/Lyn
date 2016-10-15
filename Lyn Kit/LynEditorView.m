//
//  LynEditorView.m
//  Lyn
//
//  Created by Programmieren on 28.06.13.
//  Copyright (c) 2013 Arne Philipeit Software. All rights reserved.
//

#import "LynEditorView.h"

@interface LynEditorTabView : NSView

@property NSArray *tabs;
@property NSUInteger selectedTab;

@end

@implementation LynEditorTabView

- (void)drawRect:(NSRect)dirtyRect{
    [[NSColor windowBackgroundColor] set];
    [NSBezierPath fillRect:dirtyRect];
    NSBezierPath *path = [NSBezierPath bezierPath];
    [path moveToPoint:NSMakePoint(-1, -1)];
    [path lineToPoint:NSMakePoint(-1, NSHeight(self.bounds) + 1)];
    [path lineToPoint:NSMakePoint(200, NSHeight(self.bounds) + 1)];
    [path lineToPoint:NSMakePoint(210, -1)];
    [path lineToPoint:NSMakePoint(-1, -1)];
    [[NSColor whiteColor] set];
    [path fill];
    [[NSColor windowFrameColor] set];
    [path stroke];
    [[NSColor blackColor] set];
    NSMutableAttributedString *title = [[NSMutableAttributedString alloc] initWithString:@"Project - Settings"];
    [title setAttributes:@{NSFontAttributeName : [NSFont systemFontOfSize:12]}
                   range:NSMakeRange(0, title.length)];
    [title drawInRect:NSMakeRect(4, (NSHeight(self.bounds) - title.size.height) / 2,
                                 194, title.size.height)];
    [[NSColor windowFrameColor] set];
    [NSBezierPath fillRect:NSMakeRect(0, 0, NSWidth(self.bounds), 1)];
}

@end

@interface LynEditorView ()

@property IBOutlet NSView *subView;
@property IBOutlet NSView *editorContainer;

@property IBOutlet NSButton *btnBack;
@property IBOutlet NSButton *btnForward;

@property IBOutlet NSPopUpButton *popProject;

- (IBAction)selectProject:(id)sender;

@end

@implementation LynEditorView{
    NSMutableArray *history;
    NSUInteger indexInHistory;
    
    id displayedObject;
    
    LynProjectView *projectView;
    LynClassView *classView;
    
    NSMutableArray *popNavigationMenus;
}

@synthesize project = _project;
@synthesize inspectorView = _inspectorView;
@synthesize document = _document;

- (id)init{
    self = [super init];
    if (self) {
        history = [[NSMutableArray alloc] init];
        indexInHistory = NSNotFound;
        popNavigationMenus = [[NSMutableArray alloc] init];
        [[NSBundle bundleForClass:[self class]]  loadNibNamed:@"LynEditorView" owner:self topLevelObjects:nil];
    }
    return self;
}

- (id)initWithFrame:(NSRect)frameRect{
    self = [super initWithFrame:frameRect];
    if (self) {
        history = [[NSMutableArray alloc] init];
        indexInHistory = NSNotFound;
        popNavigationMenus = [[NSMutableArray alloc] init];
        [[NSBundle bundleForClass:[self class]]  loadNibNamed:@"LynEditorView" owner:self topLevelObjects:nil];
    }
    return self;
}

- (void)awakeFromNib{
    _subView.frame = self.bounds;
    [self addSubview:_subView];
    [self updateNavigateButtons];
    [self updateNavigationPopUpMenus];
}

#pragma mark Properties

- (LynProject *)project{
    return _project;
}

- (void)setProject:(LynProject *)project{
    _project = project;
    [self updateNavigationPopUpMenus];
}

- (id)shownObject{
    if (indexInHistory == NSNotFound) return nil;
    return history[indexInHistory];
}

- (void)setShownObject: (id)shownObject{
    if (!shownObject) return;
    if (history.count > 0&&history[0] == shownObject) return;
    indexInHistory = 0;
    [history insertObject:shownObject atIndex:0];
    [self displayObject:shownObject];
    [self updateNavigateButtons];
    [self updateNavigationPopUpMenus];
}

- (LynInspectorView *)inspectorView{
    return _inspectorView;
}

- (void)setInspectorView:(LynInspectorView *)inspectorView{
    _inspectorView = inspectorView;
    projectView.inspectorView = _inspectorView;
    classView.inspectorView = _inspectorView;
}

- (NSDocument *)document{
    return _document;
}

- (void)setDocument:(NSDocument *)document{
    _document = document;
    projectView.document = _document;
    classView.document = _document;
}

#pragma mark Public Methods

- (NSArray *)historyOfShownObjects{
    return [NSArray arrayWithArray:history];
}

- (NSUInteger)indexOfShownObjectInHistory{
    return indexInHistory;
}

- (BOOL)canGoBack{
    return (history.count > 1&&indexInHistory != history.count - 1);
}

- (BOOL)canGoForward{
    return (history.count > 1&&indexInHistory != 0);
}

- (void)goBack{
    if (history.count > 1&&indexInHistory != history.count - 1) {
        indexInHistory++;
        [self displayObject:history[indexInHistory]];
        [self updateNavigateButtons];
        [self updateNavigationPopUpMenus];
    }
}

- (void)goForward{
    if (history.count > 1&&indexInHistory != 0) {
        indexInHistory--;
        [self displayObject:history[indexInHistory]];
        [self updateNavigateButtons];
        [self updateNavigationPopUpMenus];
    }
}

- (void)goBack:(id)sender{
    [self goBack];
}

- (void)goForward: (id)sender{
    [self goForward];
}

- (LynProjectView *)projectView{
    return projectView;
}

- (LynClassView *)classView{
    return classView;
}

#pragma mark Core

- (void)updateNavigateButtons{
    [_btnBack setEnabled:[self canGoBack]];
    [_btnForward setEnabled:[self canGoForward]];
}

- (void)selectObjectByMenuItem: (NSMenuItem*)sender{
    [_delegate selectObject:sender.representedObject];
    [self updateNavigateButtons];
}

- (void)numberOfSubObjectsChanged: (NSNotification*)notification{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:LynOutlineObjectNumberOfSubObjectsChangedNotification
                                                  object:nil];
    [self updateNavigationPopUpMenus];
}

- (NSMenu*)menuForSubObjectsOfObject: (LynOutlineObject*)object{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(numberOfSubObjectsChanged:)
                                                 name:LynOutlineObjectNumberOfSubObjectsChangedNotification
                                               object:object];
    
    NSMenu *menu = [[NSMenu alloc] init];
    menu.autoenablesItems = NO;
    menu.showsStateColumn = NO;
    for (LynOutlineObject *subObject in object.subObjects) {
        NSMenuItem *item = [[NSMenuItem alloc] init];
        item.title = [subObject name];
        item.tag = [object.subObjects indexOfObject:subObject];
        item.representedObject = subObject;
        if ([[subObject class] allowsSubObjects]&&[subObject class] != [LynFunction class]) {
            item.submenu = [self menuForSubObjectsOfObject:subObject];
        }
        item.target = self;
        item.action = @selector(selectObjectByMenuItem:);
        
        [menu addItem:item];
    }
    return menu;
}

- (void)updateNavigationPopUpMenus{
    for (NSPopUpButton *popNavigationMenu in popNavigationMenus) {
        [popNavigationMenu removeFromSuperview];
    }
    [popNavigationMenus removeAllObjects];
    if (!_project) return;
    [_popProject itemAtIndex:0].submenu = [self menuForSubObjectsOfObject:_project];
    if (displayedObject == _project) return;
    LynClass *displayedClass = displayedObject;
    LynOutlineObject *selectedObject = displayedClass;
    if (classView.selectedObject) {
        selectedObject = classView.selectedObject;
        while (![selectedObject isKindOfClass:[LynFunction class]]) {
            selectedObject = selectedObject.parent;
        }
    }
    NSArray *parents = selectedObject.parents;
    for (NSInteger i = parents.count - 1; i > -1; i--) {
        LynOutlineObject *parent;
        if (i > 0) {
            parent = parents[i - 1];
        }else{
            parent = selectedObject;
        }
        NSPopUpButton *popNavigationMenu = [[NSPopUpButton alloc] init];
        
        popNavigationMenu.bezelStyle = NSSmallSquareBezelStyle;
        ((NSPopUpButtonCell*)popNavigationMenu.cell).arrowPosition = NSPopUpArrowAtBottom;
        popNavigationMenu.preferredEdge = NSMinYEdge;
        popNavigationMenu.imagePosition = NSNoImage;
        popNavigationMenu.image = nil;
        popNavigationMenu.autoenablesItems = NO;
        
        [popNavigationMenu addItemWithTitle:parent.name];
        
        [popNavigationMenu sizeToFit];
        [popNavigationMenu setFrameSize:NSMakeSize(NSWidth(popNavigationMenu.frame), NSHeight(_popProject.frame))];
        [popNavigationMenu setAutoresizingMask:NSViewMaxXMargin|NSViewMinYMargin];
        
        popNavigationMenu.menu = [self menuForSubObjectsOfObject:parent.parent];
        [popNavigationMenu selectItemWithTag:[parent.parent.subObjects indexOfObject:parent]];
        
        if (popNavigationMenus.count < 1) {
            [popNavigationMenu setFrameOrigin:NSMakePoint(NSMaxX(_popProject.frame) - 1, NSMinY(_popProject.frame))];
        }else{
            [popNavigationMenu setFrameOrigin:NSMakePoint(NSMaxX(((NSView*)popNavigationMenus.lastObject).frame) - 1, NSMinY(_popProject.frame))];
        }
        
        [popNavigationMenus addObject:popNavigationMenu];
        [_subView addSubview:popNavigationMenu];
    }
}

- (void)displayObject: (id)object{
    displayedObject = object;
    if ([object isKindOfClass:[LynProject class]]) {
        [self showProjectViewWithProject:object];
    }else if ([object isKindOfClass:[LynClass class]]){
        [self showClassViewWithClass:object];
    }else{
        [self showView:nil];
    }
}

- (void)showProjectViewWithProject: (LynProject*)project{
    if (!projectView) {
        projectView = [[LynProjectView alloc] initWithFrame:self.bounds];
        [projectView setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable];
        projectView.inspectorView = _inspectorView;
        projectView.document = _document;
    }
    [projectView setShownProject:project];
    [self showView:projectView];
}

- (void)showClassViewWithClass: (LynClass*)aClass{
    if (!classView) {
        classView = [[LynClassView alloc] initWithFrame:self.bounds];
        [classView setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable];
        classView.inspectorView = _inspectorView;
        classView.document = _document;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(selectionChanged:)
                                                     name:LynClassViewSelectedObjectChangedNotification
                                                   object:classView];
    }
    [classView setShownClass:aClass];
    [self showView:classView];
}

- (void)showView: (NSView*)view{
    for (NSView *subview in _editorContainer.subviews) {
        [subview removeFromSuperview];
    }
    if (!view) return;
    view.frame = _editorContainer.bounds;
    [_editorContainer addSubview:view];
}

- (void)selectionChanged: (NSNotification*)notification{
    [self updateNavigationPopUpMenus];
}

- (void)focus{
    if ([displayedObject isKindOfClass:[LynProject class]]) {
        [projectView focus];
    }else if ([displayedObject isKindOfClass:[LynClass class]]) {
        [classView focus];
    }
}

- (void)selectObject:(id)obj{
    if ([obj isKindOfClass:[LynProject class]]) {
        [self setShownObject:obj];
        return;
    }
    LynOutlineObject *object = obj;
    LynOutlineObject *parent = object;
    while (![parent isKindOfClass:[LynClass class]]) {
        if (parent.parent == nil) {
            return;
        }
        parent = parent.parent;
    }
    [self setShownObject:parent];
    [classView selectObject:object];
}

- (void)selectProject:(id)sender{
    [_delegate selectObject:_project];
    [self updateNavigateButtons];
}

@end
