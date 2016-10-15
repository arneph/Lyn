//
//  LynDocument.m
//  Lyn
//
//  Created by Programmieren on 27.04.13.
//  Copyright (c) 2013 Arne Philipeit Software. All rights reserved.
//

#import "LynDocument.h"

@implementation LynDocument

- (id)init{
    self = [super init];
    if (self) {
        _project = nil;
        
        _showsNavigationArea = YES;
        _showsUtilitiesArea = YES;
    }
    return self;
}

- (id)initWithType:(NSString *)typeName error:(NSError *__autoreleasing *)outError{
    self = [super initWithType:typeName error:outError];
    if (self) {
        _project = [[LynProject alloc] init];
        _project.name = self.displayName;
        
        LynFunction *mainFunction = [[LynFunction alloc] initWithName:@"main"];
        LynClass *mainClass = [[LynClass alloc] initWithName:@"main"];
        [mainClass.subObjects addObject:mainFunction];
        [_project.subObjects addObject:mainClass];
        
        _showsNavigationArea = YES;
        _showsUtilitiesArea = YES;
    }
    return self;
}

- (NSString *)windowNibName{
    return @"LynDocument";
}

- (void)awakeFromNib{
    _debugController.project = _project;
    _debugController.document = self;
    _projectOutlineView.shownProject = _project;
    _warningsView.project = _project;
    _libraryView.project = _project;
    _statusView.project = _project;
    _statusView.showWarningsTarget = self;
    _statusView.showWarningsAction =  @selector(showWarnings:);
    _statusView.showErrorsTarget = self;
    _statusView.showErrorsAction = @selector(showErrors:);
    _showsNavigationArea = YES;
    _showsUtilitiesArea = YES;
    NSImage *navigatorImage = [NSImage imageNamed:NSImageNamePathTemplate];
    if (_showsNavigationArea) navigatorImage = [self image:navigatorImage tintedWithColor:[NSColor blueColor]];
    [_btnShowNavigator setImage:navigatorImage];
    NSImage *utilitiesImage = [NSImage imageNamed:NSImageNameActionTemplate];
    if (_showsUtilitiesArea) utilitiesImage = [self image:utilitiesImage tintedWithColor:[NSColor blueColor]];
    [_btnShowUtilities setImage:utilitiesImage];
}

- (void)windowControllerDidLoadNib:(NSWindowController *)aController{
    [super windowControllerDidLoadNib:aController];
    [_editorView setShownObject:_project];
}

- (void)setDisplayName:(NSString *)displayNameOrNil{
    [super setDisplayName:displayNameOrNil];
    _project.name = self.displayName;
}

+ (BOOL)autosavesInPlace{
    return YES;
}

+ (BOOL)preservesVersions{
    return NO;
}

- (BOOL)canAsynchronouslyWriteToURL:(NSURL *)url
                             ofType:(NSString *)typeName
                   forSaveOperation:(NSSaveOperationType)saveOperation{
    return YES;
}

- (NSData *)dataOfType:(NSString *)typeName
                 error:(NSError **)outError{
    [LynGeneral setCurrentMode:LynModeSaving];
    LynProject *projectCopy = _project.copy;
    [LynGeneral setCurrentMode:LynModeEditing];
    [self unblockUserInteraction];
    return [projectCopy dataFromProject];
}

- (BOOL)readFromData:(NSData *)data
              ofType:(NSString *)typeName
               error:(NSError **)outError{
    if ([typeName isEqualToString:[@"de.AP-Software.Lyn.LynDocument" lowercaseString]]) {
        _project = [LynProject projectFromData:data];
        _project.name = self.displayName;
        return YES;
    }else if ([typeName isEqualToString:[@"de.AP-Software.Lyn.LynClassDocument" lowercaseString]]) {
        LynClass *class = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        
        if (!_project) {
            _project = [[LynProject alloc] init];
            _project.name = self.displayName;
            
            if (![class.name isEqualToString:@"main"]) {
                LynFunction *mainFunction = [[LynFunction alloc] initWithName:@"main"];
                LynClass *mainClass = [[LynClass alloc] initWithName:@"main"];
                [mainClass.subObjects addObject:mainFunction];
                [_project.subObjects addObject:mainClass];
            }
        }
        
        if ([class.name isEqualToString:@"main"]) {
            [_project.subObjects removeAllObjects];
        }
        [_project.subObjects addObject:class];
        
        self.fileURL = nil;
        self.fileType = @"de.AP-Software.Lyn.LynDocument";
        [self updateChangeCount:NSChangeDone];
        
        return YES;
    }else{
        return NO;
    }
}

#pragma mark Actions

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem{
    if (menuItem.action == @selector(toggleNavigationArea:)) {
        if (_showsNavigationArea) {
            menuItem.title = @"Hide Navigator";
        }else{
            menuItem.title = @"Show Navigator";
        }
        return YES;
    }else if (menuItem.action == @selector(toggleUtilitiesArea:)) {
        if (_showsUtilitiesArea) {
            menuItem.title = @"Hide Utilities";
        }else{
            menuItem.title = @"Show Utilities";
        }
        return YES;
    }else if (menuItem.action == @selector(showScopeInspector:)) {
        return _inspectorView.showScopeInspector;
    }else if (menuItem.action == @selector(showParametersInspector:)) {
        return _inspectorView.showParametersInspector;
    }else if (menuItem.action == @selector(showConditionsInspector:)) {
        return _inspectorView.showConditionsInspector;
    }else if (menuItem.action == @selector(showReturnValueInspector:)) {
        return _inspectorView.showReturnValueInspector;
    }else if (menuItem.action == @selector(goBack:)) {
        return _editorView.canGoBack;
    }else if (menuItem.action == @selector(goForward:)) {
        return _editorView.canGoForward;
    }else if (menuItem.action == @selector(showHistory:)) {
        menuItem.submenu = [self historyMenu];
        return YES;
    }else if (menuItem.action == @selector(focusNavigationArea:)) {
        return _showsNavigationArea;
    }else if (menuItem.action == @selector(focusEditorArea:)) {
        return YES;
    }else if (menuItem.action == @selector(showProject:)) {
        menuItem.submenu = [self menuForSubObjectsOfObject:_project];
        return YES;
    }else{
        return [super validateMenuItem:menuItem];
    }
}

- (void)selectObjectByMenuItem: (NSMenuItem*)sender{
    [_projectOutlineView selectObject:sender.representedObject];
}

- (NSMenu*)historyMenu{
    NSMenu *menu = [[NSMenu alloc] init];
    menu.autoenablesItems = NO;
    if (_editorView.historyOfShownObjects.count < 1) return menu;
    NSMutableArray *entries = [[NSMutableArray alloc] init];
    for (NSUInteger i = 0; i < _editorView.historyOfShownObjects.count; i++) {
        LynOutlineObject *entry = _editorView.historyOfShownObjects[i];
        if ([entries indexOfObject:entry] == NSNotFound) {
            NSMenuItem *item = [[NSMenuItem alloc] init];
            item.title = [entry name];
            if (entry == _editorView.historyOfShownObjects[_editorView.indexOfShownObjectInHistory]){
                item.state = NSOnState;
            }
            item.tag = [_editorView.historyOfShownObjects indexOfObject:entry];
            item.representedObject = entry;
            item.target = self;
            item.action = @selector(selectObjectByMenuItem:);
            [menu addItem:item];
            [entries addObject:entry];
        }
    }
    return menu;
}

- (NSMenu*)menuForSubObjectsOfObject: (LynOutlineObject*)object{
    NSMenu *menu = [[NSMenu alloc] init];
    menu.autoenablesItems = NO;
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

- (void)pushedRun:(id)sender{
    [self saveDocumentWithDelegate:self didSaveSelector:@selector(run:) contextInfo:NULL];
}

- (void)run: (void*)contextInfo{
    if (!self.fileURL) return;
    
}

#pragma mark StatusView

- (void)showWarnings: (id)sender{
    [self showWarningsNavigator:sender];
    if (!_warningsView.showWarnings) [_warningsView setShowWarnings:YES];
    [_warningsView.window makeFirstResponder:_warningsView];
}

- (void)showErrors: (id)sender{
    [self showWarningsNavigator:sender];
    [_warningsView.window makeFirstResponder:_warningsView];
}

#pragma mark SplitView

- (void)toggleNavigationArea:(id)sender{
    _showsNavigationArea = !_showsNavigationArea;
    if (_showsNavigationArea) {
        [_splitView addSubview:_navigatorsView positioned:NSWindowBelow relativeTo:_editorView];
    }else{
        CGFloat oldWidth = _utilitiesView.frame.size.width;
        [_navigatorsView removeFromSuperview];
        if (_showsUtilitiesArea) {
            [_splitView setPosition:_splitView.bounds.size.width - oldWidth - 1 ofDividerAtIndex:0];
        }
    }
    
    NSImage *image = [NSImage imageNamed:NSImageNamePathTemplate];
    if (_showsNavigationArea) image = [self image:image tintedWithColor:[NSColor blueColor]];
    [_btnShowNavigator setImage:image];
}

- (void)toggleUtilitiesArea:(id)sender{
    _showsUtilitiesArea = !_showsUtilitiesArea;
    if (_showsUtilitiesArea) {
        [_splitView addSubview:_utilitiesView positioned:NSWindowAbove relativeTo:_editorView];
    }else{
        [_utilitiesView removeFromSuperview];
    }
    
    NSImage *image = [NSImage imageNamed:NSImageNameActionTemplate];
    if (_showsUtilitiesArea) image = [self image:image tintedWithColor:[NSColor blueColor]];
    [_btnShowUtilities setImage:image];
}

- (NSImage *)image: (NSImage*)image tintedWithColor:(NSColor *)tint{
    if (image&&tint) {
        image = image.copy;
        [image setTemplate:NO];
        [image lockFocus];
        [tint set];
        NSRect imageRect = {NSZeroPoint, [image size]};
        NSRectFillUsingOperation(imageRect, NSCompositeSourceAtop);
        [image unlockFocus];
    }
    return image;
}

#pragma mark Select Navigator

- (void)showProjectNavigator:(id)sender{
    if (!_showsNavigationArea) [self toggleNavigationArea:sender];
    [_navigatorsTabView selectTabViewItemAtIndex:0];
    [_btnProjectNavigator setState:NSOnState];
    [_btnWarningsNavigator setState:NSOffState];
}

- (void)showWarningsNavigator:(id)sender{
    if (!_showsNavigationArea) [self toggleNavigationArea:sender];
    [_navigatorsTabView selectTabViewItemAtIndex:1];
    [_btnProjectNavigator setState:NSOffState];
    [_btnWarningsNavigator setState:NSOnState];
}

#pragma mark Select Inspector

- (void)showScopeInspector:(id)sender{
    if (_inspectorView.showScopeInspector) {
        [_inspectorView selectInspector:1];
    }
}
- (void)showParametersInspector:(id)sender{
    if (_inspectorView.showParametersInspector) {
        [_inspectorView selectInspector:2];
    }
}

- (void)showConditionsInspector:(id)sender{
    if (_inspectorView.showConditionsInspector) {
        [_inspectorView selectInspector:3];
    }
}

- (void)showReturnValueInspector:(id)sender{
    if (_inspectorView.showReturnValueInspector) {
        [_inspectorView selectInspector:4];
    }
}

#pragma mark Navigation

- (void)goBack:(id)sender{
    [_editorView goBack];
}

- (void)goForward:(id)sender{
    [_editorView goForward];
}

- (void)showHistory:(id)sender{}

- (void)showProject:(id)sender{
    [_projectOutlineView selectObject:_project];
}

- (void)focusNavigationArea:(id)sender{
    if (_showsNavigationArea) {
        [_projectOutlineView focus];
    }
}

- (void)focusEditorArea:(id)sender{
    [_editorView focus];
}

@end
