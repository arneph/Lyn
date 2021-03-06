//
//  LynFillParametersViewHelperClasses.m
//  Lyn
//
//  Created by Programmieren on 11.10.13.
//  Copyright (c) 2013 Arne Philipeit Software. All rights reserved.
//

#import "LynFillParametersViewHelperClasses.h"

@implementation LynFillParameterTableCellView

@end

@implementation LynFillParameterBooleanTableCellView

@end

@implementation LynFillParameterIntegerTableCellView

@end

@implementation LynFillParameterStringTableCellView

@end

@implementation LynFillParameterTableRowView

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
