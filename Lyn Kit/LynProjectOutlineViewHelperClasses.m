//
//  LynProjectOutlineViewHelperClasses.m
//  Lyn
//
//  Created by Programmieren on 30.11.13.
//  Copyright (c) 2013 Arne Philipeit Software. All rights reserved.
//

#import "LynProjectOutlineViewHelperClasses.h"

@implementation LynProjectOutlineOutlineView

- (NSMenu*)menuForEvent: (NSEvent*)event{
    NSPoint point = [self convertPoint:[event locationInWindow] fromView:nil];
    NSInteger row = [self rowAtPoint:point];
    [self.window makeFirstResponder:self];
    if (row == -1) {
        return _outlineViewContextMenu;
    }else{
        LynProjectOutlineObject *object = [self itemAtRow:row];
        NSMenu *menu;
        if ([object isKindOfClass:[LynProject class]]) {
            menu = _projectContextMenu;
        }else if ([object isKindOfClass:[LynFolder class]]) {
            menu = _folderContextMenu;
        }else if ([object isKindOfClass:[LynClass class]]) {
            menu = _classContextMenu;
        }else{
            return nil;
        }
        for (NSMenuItem *item in menu.itemArray) {
            item.representedObject = object;
        }
        return menu;
    }
}

@end
