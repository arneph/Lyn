//
//  LynClassRowView.m
//  Lyn
//
//  Created by Programmieren on 01.10.13.
//  Copyright (c) 2013 Arne Philipeit Software. All rights reserved.
//

#import "LynClassRowView.h"

@implementation LynClassRowView

- (void)drawSelectionInRect:(NSRect)dirtyRect{
    if (self.window.firstResponder == self.superview&&self.window.isKeyWindow) {
        [[NSColor alternateSelectedControlColor] set];
    }else{
        [[NSColor secondarySelectedControlColor] set];
    }
    [NSBezierPath fillRect:dirtyRect];
}

- (void)drawBackgroundInRect:(NSRect)dirtyRect{
    [self.backgroundColor set];
    [NSBezierPath fillRect:dirtyRect];
}

@end
