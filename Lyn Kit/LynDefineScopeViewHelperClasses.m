//
//  LynDefineScopeViewHelperClasses.m
//  Lyn
//
//  Created by Programmieren on 06.10.13.
//  Copyright (c) 2013 Arne Philipeit Software. All rights reserved.
//

#import "LynDefineScopeViewHelperClasses.h"

@implementation LynDefineVariableBooleanTableCellView

@end

@implementation LynDefineVariableIntegerTableCellView

@end

@implementation LynDefineVariableStringTableCellView

@end

@implementation LynDefineVariablesRowView

- (BOOL)isOpaque{
    return YES;
}

- (void)drawBackgroundInRect:(NSRect)dirtyRect{
    NSColor *backgroundColor = self.backgroundColor;
    [[NSColor whiteColor] set];
    [NSBezierPath fillRect:dirtyRect];
    
    if ([backgroundColor isEqualTo:[NSColor whiteColor]]) return;
    
    [backgroundColor set];
    
    NSInteger start = - NSHeight(self.bounds) + NSMinX(dirtyRect);
    start += ((int)NSHeight(self.bounds)) % 10;
    for (NSInteger x = start; x < NSMaxX(self.bounds); x += 10) {
        NSPoint a = NSMakePoint(x, 0);
        NSPoint b = NSMakePoint(x + NSHeight(self.bounds), NSHeight(self.bounds));
        NSBezierPath *path = [[NSBezierPath alloc] init];
        [path moveToPoint:a];
        [path lineToPoint:b];
        [path stroke];
    }
}

@end

@implementation LynDefineVariablesTableView

- (BOOL)validateProposedFirstResponder:(NSResponder *)responder forEvent:(NSEvent *)event{
    return YES;
}

@end
