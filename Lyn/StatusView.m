//
//  StatusView.m
//  Lyn
//
//  Created by Programmieren on 07.08.13.
//  Copyright (c) 2013 Arne Philipeit Software. All rights reserved.
//

#import "StatusView.h"

@implementation StatusView{
    NSUInteger warnings;
    NSUInteger errors;
    
    NSRect warningsArea;
    NSRect errorsArea;
}
@synthesize project = _project;

- (id)init{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (id)initWithFrame:(NSRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [super encodeWithCoder:aCoder];
}

- (void)awakeFromNib{
}

#pragma mark Properties

- (LynProject *)project{
    return _project;
}

- (void)setProject:(LynProject *)project{
    _project = project;
    warnings = [_project warningsIncludingSubObjects:YES].count;
    errors = [_project errorsIncludingSubObjects:YES].count;
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter removeObserver:self
                                  name:LynOutlineObjectNumberOfWarningsAndErrorsChangedNotification
                                object:nil];
    [notificationCenter removeObserver:self
                                  name:LynOutlineObjectNumberOfWarningsChangedNotification
                                object:nil];
    [notificationCenter removeObserver:self
                                  name:LynOutlineObjectNumberOfErrorsChangedNotification
                                object:nil];
    [notificationCenter addObserver:self
                           selector:@selector(numberOfWarningsAndErrorsChanged:)
                               name:LynOutlineObjectNumberOfWarningsAndErrorsChangedNotification
                             object:_project];
    [notificationCenter addObserver:self
                           selector:@selector(numberOfWarningsChanged:)
                               name:LynOutlineObjectNumberOfWarningsChangedNotification
                             object:_project];
    [notificationCenter addObserver:self
                           selector:@selector(numberOfErrorsChanged:)
                               name:LynOutlineObjectNumberOfErrorsChangedNotification
                             object:_project];
    [self setNeedsDisplay:YES];
}

#pragma mark Notifications

- (void)numberOfWarningsAndErrorsChanged: (NSNotification*)notification{
    warnings = [_project warningsIncludingSubObjects:YES].count;
    errors = [_project errorsIncludingSubObjects:YES].count;
    [self setNeedsDisplay:YES];
}

- (void)numberOfWarningsChanged: (NSNotification*)notification{
    warnings = [_project warningsIncludingSubObjects:YES].count;
    [self setNeedsDisplay:YES];
}

- (void)numberOfErrorsChanged: (NSNotification*)notification{
    errors = [_project errorsIncludingSubObjects:YES].count;
    [self setNeedsDisplay:YES];
}

#pragma mark Drawing

- (void)drawRect:(NSRect)dirtyRect{
    NSRect frameRect = NSMakeRect(.5, .5, NSWidth(self.frame) - 1, NSHeight(self.frame) - 1);
    NSBezierPath *frame = [NSBezierPath bezierPathWithRoundedRect:frameRect
                                                          xRadius:3
                                                          yRadius:3];
    
    [[NSColor colorWithCalibratedRed:.9 green:.9 blue:.9 alpha:1] set];
    [frame fill];
    [[NSColor darkGrayColor] set];
    [frame stroke];
    
    if (warnings < 1&&errors < 1) {
        NSImage *image = [NSImage imageNamed:NSImageNameStatusAvailable];
        [image drawInRect:NSMakeRect(3, 3,
                                     NSHeight(self.frame) - 6, NSHeight(self.frame) - 6)
                 fromRect:NSZeroRect
                operation:NSCompositeSourceOver
                 fraction:1];
        NSMutableAttributedString *info;
        info = [[NSMutableAttributedString alloc] initWithString:@"No Warnings or Errors"];
        [info drawInRect:NSMakeRect(NSHeight(self.frame) - 3,
                                    (NSHeight(self.frame) - info.size.height) / 2,
                                    info.size.width, info.size.height)];
        return;
    }
    if (warnings > 0) {
        NSImage *image = [NSImage imageNamed:NSImageNameStatusPartiallyAvailable];
        [image drawInRect:NSMakeRect(3, 3,
                                     NSHeight(self.frame) - 6, NSHeight(self.frame) - 6)
                 fromRect:NSZeroRect
                operation:NSCompositeSourceOver
                 fraction:1];
        NSMutableAttributedString *info;
        if (warnings == 1) {
            info = [[NSMutableAttributedString alloc]
                    initWithString: @"1 Warning"];
        }else if (warnings > 1) {
            info = [[NSMutableAttributedString alloc]
                    initWithString:[NSString stringWithFormat:@"%li Warnings", warnings]];
        }
        [info drawInRect:NSMakeRect(NSHeight(self.frame) - 3,
                                    (NSHeight(self.frame) - info.size.height) / 2,
                                    info.size.width, info.size.height)];
        warningsArea = NSMakeRect(0, 0,
                                  NSHeight(self.frame) + info.size.width,
                                  NSHeight(self.frame));
    }else{
        warningsArea = NSMakeRect(0, 0, 0, 0);
    }
    if (errors > 0) {
        if (NSWidth(warningsArea) > 0) {
            NSBezierPath *divider = [NSBezierPath bezierPath];
            [divider moveToPoint:NSMakePoint(NSWidth(warningsArea) + 1, 6)];
            [divider lineToPoint:NSMakePoint(NSWidth(warningsArea) + 1,
                                             NSHeight(self.frame) - 6)];
            [divider setLineWidth:1.0];
            [[NSColor darkGrayColor] set];
            [divider stroke];
        }
        NSImage *image = [NSImage imageNamed:NSImageNameStatusUnavailable];
        [image drawInRect:NSMakeRect(NSWidth(warningsArea) + 3, 3,
                                     NSHeight(self.frame) - 6, NSHeight(self.frame) - 6)
                 fromRect:NSZeroRect
                operation:NSCompositeSourceOver
                 fraction:1];
        NSMutableAttributedString *info;
        if (errors == 1) {
            info = [[NSMutableAttributedString alloc]
                    initWithString: @"1 Error"];
        }else if (errors > 1) {
            info = [[NSMutableAttributedString alloc]
                    initWithString:[NSString stringWithFormat:@"%li Errors", errors]];
        }
        [info drawInRect:NSMakeRect(NSWidth(warningsArea) + NSHeight(self.frame) - 3,
                                    (NSHeight(self.frame) - info.size.height) / 2,
                                    info.size.width, info.size.height)];
        errorsArea = NSMakeRect(NSWidth(warningsArea), 0,
                                NSHeight(self.frame) + info.size.width,
                                NSHeight(self.frame));
    }else{
        errorsArea = NSMakeRect(NSWidth(warningsArea), 0, 0, 0);
    }
}

#pragma mark Event Handling

- (void)mouseDown:(NSEvent *)theEvent{
    NSUInteger nWarnings = [_project warningsIncludingSubObjects:YES].count;
    NSUInteger nErrors = [_project errorsIncludingSubObjects:YES].count;
    if (nWarnings < 1&&nErrors < 1) return;
    NSPoint point = [self convertPoint:theEvent.locationInWindow fromView:nil];
    if (NSPointInRect(point, warningsArea)) {
        if (_showWarningsTarget
            &&[_showWarningsTarget respondsToSelector:_showWarningsAction]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [_showWarningsTarget performSelector:_showWarningsAction withObject:self];
#pragma clang diagnostic pop
        }
    }else if (NSPointInRect(point, errorsArea)) {
        if (_showErrorsTarget
            &&[_showErrorsTarget respondsToSelector:_showErrorsAction]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [_showErrorsTarget performSelector:_showErrorsAction withObject:self];
#pragma clang diagnostic pop
        }
    }
}

@end
