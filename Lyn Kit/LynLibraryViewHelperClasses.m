//
//  LynLibraryViewHelperClasses.m
//  Lyn
//
//  Created by Programmieren on 03.10.13.
//  Copyright (c) 2013 Arne Philipeit Software. All rights reserved.
//

#import "LynLibraryViewHelperClasses.h"

@implementation LynSmallColorWell{
    BOOL isOpaque;
}

- (void)mouseDown:(NSEvent *)theEvent{
    [self activate:!self.isActive];
    [self.window makeFirstResponder:self];
}

- (void)drawRect:(NSRect)dirtyRect{
    [self.color set];
    [NSBezierPath fillRect: dirtyRect];
    [[NSColor blackColor] set];
    if (self.window.firstResponder == self) {
        [NSBezierPath setDefaultLineWidth:3.0];
    }else{
        [NSBezierPath setDefaultLineWidth:1.0];
    }
    [NSBezierPath strokeRect:self.bounds];
}

@end

@implementation LynCommandTableCellView{
    BOOL mouseInside;
}
@synthesize mayHideInfoButton = _mayHideInfoButton;

- (BOOL)mayHideInfoButton{
    return _mayHideInfoButton;
}

- (void)setMayHideInfoButton:(BOOL)mayHideInfoButton{
    _mayHideInfoButton = mayHideInfoButton;
    if (!_mayHideInfoButton) [_infoButton setHidden:NO];
    if (_mayHideInfoButton&&!mouseInside) [_infoButton setHidden:YES];
}

- (void)viewDidMoveToWindow {
    NSTrackingArea *trackingArea = [[NSTrackingArea alloc] initWithRect:self.bounds
                                                                options:NSTrackingMouseEnteredAndExited|NSTrackingMouseMoved|NSTrackingActiveAlways
                                                                  owner:self
                                                               userInfo:nil];
    [self addTrackingArea:trackingArea];
}

- (void)mouseEntered:(NSEvent *)theEvent{
    [_infoButton setHidden:NO];
    mouseInside = YES;
    [super mouseEntered:theEvent];
}

- (void) mouseExited:(NSEvent *)theEvent{
    if (_mayHideInfoButton) [_infoButton setHidden:YES];
    mouseInside = NO;
    [super mouseExited:theEvent];
}

@end

@implementation LynCommandGroupTableRowView
@synthesize drawTopSeparator = _drawTopSeparator;
@synthesize drawBottomSeparator = _drawBottomSeparator;

- (BOOL)isFlipped{
    return NO;
}

- (BOOL)isOpaque{
    return YES;
}

- (BOOL)drawTopSeparator{
    return _drawTopSeparator;
}

- (void)setDrawTopSeparator:(BOOL)drawTopSeparator{
    _drawTopSeparator = drawTopSeparator;
    [self setNeedsDisplayInRect:NSMakeRect(0, NSHeight(self.bounds) - 2, NSWidth(self.bounds), 2)];
}

- (BOOL)drawBottomSeparator{
    return _drawBottomSeparator;
}

- (void)setDrawBottomSeparator:(BOOL)drawBottomSeparator{
    _drawBottomSeparator = drawBottomSeparator;
    [self setNeedsDisplayInRect:NSMakeRect(0, 0, NSWidth(self.bounds), 2)];
}

- (void)drawRect:(NSRect)dirtyRect{
    [[NSColor colorWithCalibratedWhite:.9 alpha:1] set];
    [NSBezierPath fillRect:dirtyRect];
    [[NSColor gridColor] set];
    if (_drawTopSeparator) [NSBezierPath strokeLineFromPoint:NSMakePoint(0, NSHeight(self.bounds))
                                                     toPoint:NSMakePoint(NSWidth(self.bounds), NSHeight(self.bounds))];
    if (_drawBottomSeparator) [NSBezierPath strokeLineFromPoint:NSMakePoint(0, 0)
                                                        toPoint:NSMakePoint(NSWidth(self.bounds), 0)];
}

@end
