//
//  LynVariableChooserView.m
//  Lyn
//
//  Created by Programmieren on 18.07.13.
//  Copyright (c) 2013 Arne Philipeit Software. All rights reserved.
//

#import "LynVariableChooserView.h"

@interface LynVariableChooserView ()

@property IBOutlet NSPopUpButton *chooser;

- (IBAction)chooserChangedSelection:(id)sender;

@end

@implementation LynVariableChooserView{
    NSUInteger firstVariableIndex;
    NSUInteger firstSuperScopesIndex;
    
    id lastSelectedObject;
    
    BOOL updating;
}

@synthesize scope = _scope;
@synthesize parameters = _parameters;
@synthesize enabled = _enabled;

- (id)init{
    self = [super init];
    if (self) {
        _scope = nil;
        _parameters = nil;
        _type = LynDataTypeNone;
        _includeSuperScopes = YES;
        _enabled = YES;
        
        [[NSBundle bundleForClass:[self class]]  loadNibNamed:@"LynVariableChooserView" owner:self topLevelObjects:nil];
        [_chooser setAutoresizingMask:NSViewWidthSizable];
        [_chooser setFrameSize:NSMakeSize(NSWidth(self.frame) + 5, NSHeight(_chooser.frame))];
        [_chooser setFrameOrigin:NSMakePoint(-2 , -5)];
        [self addSubview:_chooser];
        [self reload];
    }
    return self;
}

- (id)initWithFrame:(NSRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        _scope = nil;
        _parameters = nil;
        _type = LynDataTypeNone;
        _includeSuperScopes = YES;
        _enabled = YES;
        
        [[NSBundle bundleForClass:[self class]]  loadNibNamed:@"LynVariableChooserView" owner:self topLevelObjects:nil];
        [_chooser setAutoresizingMask:NSViewWidthSizable];
        [_chooser setFrameSize:NSMakeSize(NSWidth(frame) + 5, NSHeight(_chooser.frame))];
        [_chooser setFrameOrigin:NSMakePoint(-2 , -5)];
        [self addSubview:_chooser];
        [self reload];
    }
    return self;
}

#pragma mark Properties

- (LynScope *)scope{
    return _scope;
}

- (void)setScope:(LynScope *)scope{
    _scope  = scope;
    if (!updating) [self reload];
}

- (NSArray *)parameters{
    return _parameters;
}

- (void)setParameters:(NSArray *)parameters{
    _parameters = parameters;
    if (!updating) [self reload];
}

- (BOOL)isEnabled{
    return _enabled;
}

- (void)setEnabled:(BOOL)enabled{
    _enabled = enabled;
    if (!updating) [self reload];
}

- (void)beginUpdates{
    updating = YES;
}

- (void)endUpdates{
    updating = NO;
    [self reload];
}

#pragma mark Core

- (NSArray*)displayedObjects{
    if ((!_scope&&(!_parameters||_parameters.count < 1))||_type == LynDataTypeNone) {
        firstVariableIndex = NSNotFound;
        firstSuperScopesIndex = NSNotFound;
        return @[];
    }
    NSMutableArray *displayedObjects = [[NSMutableArray alloc] init];
    NSUInteger index = 0;
    if (_parameters&&_parameters.count > 0) {
        for (LynParameter *parameter in _parameters) {
            if (parameter.parameterType == _type) {
                [displayedObjects addObject:parameter];
                index++;
            }
        }
    }
    if (_scope) {
        firstVariableIndex = index;
        for (LynVariable *variable in _scope.variables) {
            if (variable.variableType == _type) {
                [displayedObjects addObject:variable];
                index++;
            }
        }
        if (firstVariableIndex == index) {
            firstVariableIndex = NSNotFound;
        }
        if (_includeSuperScopes) {
            firstSuperScopesIndex = index;
            LynScope *superScope = _scope.superScope;
            while (superScope) {
                for (LynVariable *variable in superScope.variables) {
                    if (variable.variableType == _type) {
                        [displayedObjects addObject:variable];
                        index++;
                    }
                }
                superScope = superScope.superScope;
            }
            if (firstSuperScopesIndex == index) {
                firstSuperScopesIndex = NSNotFound;
            }
        }else{
            firstSuperScopesIndex = NSNotFound;
        }
    }else{
        firstVariableIndex = NSNotFound;
    }
    return [NSArray arrayWithArray:displayedObjects];
}

- (void)reload{
    id objectForReselection = lastSelectedObject;
    lastSelectedObject = nil;
    [_chooser removeAllItems];
    [_chooser setEnabled:([self displayedObjects].count&&_enabled)];
    if (((!_parameters||_parameters.count < 1)&&!_scope)||_type == LynDataTypeNone||[self displayedObjects].count < 1) {
        NSMenuItem *item = [[NSMenuItem alloc] init];
        item.title = @"No Selection";
        [item setEnabled:NO];
        [_chooser.menu addItem:item];
    }else{
        NSArray *displayedObjects = [self displayedObjects];
        for (NSUInteger i = 0; i < displayedObjects.count; i++) {
            NSMenuItem *item = [[NSMenuItem alloc] init];
            item.representedObject = displayedObjects[i];
            item.tag = i + 1;
            item.indentationLevel = 1;
            [item setEnabled:YES];
            if (firstVariableIndex == NSNotFound||i < firstVariableIndex) {
                if (i == 0) {
                    NSMenuItem *infoItem = [[NSMenuItem alloc] init];
                    [infoItem setEnabled:NO];
                    infoItem.title = @"Parameters";
                    [_chooser.menu addItem:infoItem];
                }
                LynParameter *parameter = displayedObjects[i];
                item.title = parameter.name;
            }else{
                if ((i == firstVariableIndex||i == firstSuperScopesIndex)) {
                    if (i > 0) {
                        [_chooser.menu addItem:[NSMenuItem separatorItem]];
                    }
                    NSMenuItem *infoItem = [[NSMenuItem alloc] init];
                    [infoItem setEnabled:NO];
                    if (i == firstVariableIndex) {
                        infoItem.title = @"Variables";
                    }else if (i == firstSuperScopesIndex) {
                        infoItem.title = @"Variables from Superscopes";
                    }
                    [_chooser.menu addItem:infoItem];
                }
                LynVariable *variable = displayedObjects[i];
                item.title = variable.name;
            }
            [_chooser.menu addItem:item];
            if (objectForReselection == displayedObjects[i]) {
                [_chooser selectItemAtIndex:_chooser.menu.itemArray.count - 1];
            }
        }
        if (![_chooser selectedItem].isEnabled) {
            [_chooser selectItemWithTag:1];
            [self chooserChangedSelection:self];
        }else if ([displayedObjects indexOfObject:objectForReselection] == NSNotFound){
            [self chooserChangedSelection:self];
        }
        lastSelectedObject = _chooser.selectedItem.representedObject;
    }
}

- (id)selectedVariable{
    return lastSelectedObject;
}

- (void)selectVariable:(id)object{
    [self reload];
    if (!object&&lastSelectedObject) {
        [self chooserChangedSelection:self];
        return;
    }
    NSUInteger index = [[self displayedObjects] indexOfObject:object];
    if (index != NSNotFound) [_chooser selectItemWithTag:index + 1];
}

#pragma mark Actions

- (void)chooserChangedSelection:(id)sender{
    lastSelectedObject = _chooser.selectedItem.representedObject;
    if ([_target respondsToSelector:_action]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [_target performSelector:_action withObject:self];
#pragma clang diagnostic pop
    }
}

#pragma mark General

+ (NSArray *)objectsForScope:(LynScope *)scope
          includeSuperScopes:(BOOL)includeSuperScopes
                  parameters:(NSArray *)parameters
                    withType:(LynDataType)type{
    if ((!scope&&(!parameters||parameters.count < 1))||type == LynDataTypeNone) {
        return @[];
    }
    NSMutableArray *objects = [[NSMutableArray alloc] init];
    if (parameters&&parameters.count > 0) {
        for (LynParameter *parameter in parameters) {
            if (parameter.parameterType == type) {
                [objects addObject:parameter];
            }
        }
    }
    if (scope) {
        for (LynVariable *variable in scope.variables) {
            if (variable.variableType == type) {
                [objects addObject:variable];
            }
        }
        if (includeSuperScopes) {
            LynScope *superScope = scope.superScope;
            while (superScope) {
                for (LynVariable *variable in superScope.variables) {
                    if (variable.variableType == type) {
                        [objects addObject:variable];
                    }
                }
                superScope = superScope.superScope;
            }
        }
    }
    return [NSArray arrayWithArray:objects];
}

@end
