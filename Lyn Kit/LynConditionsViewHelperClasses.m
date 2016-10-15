//
//  LynConditionsViewHelperClasses.m
//  Lyn
//
//  Created by Programmieren on 05.10.13.
//  Copyright (c) 2013 Arne Philipeit Software. All rights reserved.
//

#import "LynConditionsViewHelperClasses.h"

@implementation LynComparingConditionTableCellView

- (void)setBackgroundStyle:(NSBackgroundStyle)backgroundStyle{
    [super setBackgroundStyle:backgroundStyle];
    NSColor *textColor;
    if (self.backgroundStyle == NSBackgroundStyleLight) {
        textColor = [NSColor blackColor];
    }else if (self.backgroundStyle == NSBackgroundStyleDark) {
        textColor = [NSColor whiteColor];
    }
    NSButtonCell *cellA1 = [_fillTypeMatrixA cellAtRow:0 column:0];
    NSMutableAttributedString *title = [[NSMutableAttributedString alloc] initWithAttributedString:cellA1.attributedTitle];
    [title addAttribute:NSForegroundColorAttributeName value:textColor range:NSMakeRange(0, title.length)];
    [cellA1 setAttributedTitle:title];
    NSButtonCell *cellA2 = [_fillTypeMatrixA cellAtRow:1 column:0];
    title = [[NSMutableAttributedString alloc] initWithAttributedString:cellA2.attributedTitle];
    [title addAttribute:NSForegroundColorAttributeName value:textColor range:NSMakeRange(0, title.length)];
    [cellA2 setAttributedTitle:title];
    NSButtonCell *cellB1 = [_fillTypeMatrixB cellAtRow:0 column:0];
    title = [[NSMutableAttributedString alloc] initWithAttributedString:cellB1.attributedTitle];
    [title addAttribute:NSForegroundColorAttributeName value:textColor range:NSMakeRange(0, title.length)];
    [cellB1 setAttributedTitle:title];
    NSButtonCell *cellB2 = [_fillTypeMatrixB cellAtRow:1 column:0];
    title = [[NSMutableAttributedString alloc] initWithAttributedString:cellB2.attributedTitle];
    [title addAttribute:NSForegroundColorAttributeName value:textColor range:NSMakeRange(0, title.length)];
    [cellB2 setAttributedTitle:title];
    [_separator1 setBorderColor:textColor];
    [_separator2 setBorderColor:textColor];
}

- (void)showDataTypeSpecificControlsForParameterA{
    [_variableChooserA setHidden:YES];
}

- (void)showDataTypeSpecificControlsForParameterB{
    [_variableChooserB setHidden:YES];
}

- (void)hideDataTypeSpecificControlsForParameterA{
    [_variableChooserA setHidden:NO];
}

- (void)hideDataTypeSpecificControlsForParameterB{
    [_variableChooserB setHidden:NO];
}

@end

@implementation LynComparingConditionBooleanTableCellView

- (void)showDataTypeSpecificControlsForParameterA{
    [super showDataTypeSpecificControlsForParameterA];
    [_staticBooleanCheckBoxA setHidden:NO];
}

- (void)showDataTypeSpecificControlsForParameterB{
    [super showDataTypeSpecificControlsForParameterB];
    [_staticBooleanCheckBoxB setHidden:NO];
}

- (void)hideDataTypeSpecificControlsForParameterA{
    [super hideDataTypeSpecificControlsForParameterA];
    [_staticBooleanCheckBoxA setHidden:YES];
}

- (void)hideDataTypeSpecificControlsForParameterB{
    [super hideDataTypeSpecificControlsForParameterB];
    [_staticBooleanCheckBoxB setHidden:YES];
}

@end

@implementation LynComparingConditionIntegerTableCellView

- (void)showDataTypeSpecificControlsForParameterA{
    [super showDataTypeSpecificControlsForParameterA];
    [_staticIntegerTextFieldA setHidden:NO];
    [_staticIntegerStepperA setHidden:NO];
}

- (void)showDataTypeSpecificControlsForParameterB{
    [super showDataTypeSpecificControlsForParameterB];
    [_staticIntegerTextFieldB setHidden:NO];
    [_staticIntegerStepperB setHidden:NO];
}

- (void)hideDataTypeSpecificControlsForParameterA{
    [super hideDataTypeSpecificControlsForParameterA];
    [_staticIntegerTextFieldA setHidden:YES];
    [_staticIntegerStepperA setHidden:YES];
}

- (void)hideDataTypeSpecificControlsForParameterB{
    [super hideDataTypeSpecificControlsForParameterB];
    [_staticIntegerTextFieldB setHidden:YES];
    [_staticIntegerStepperB setHidden:YES];
}

@end

@implementation LynComparingConditionStringTableCellView

- (void)showDataTypeSpecificControlsForParameterA{
    [super showDataTypeSpecificControlsForParameterA];
    [_staticStringTextFieldA setHidden:NO];
}

- (void)showDataTypeSpecificControlsForParameterB{
    [super showDataTypeSpecificControlsForParameterB];
    [_staticStringTextFieldB setHidden:NO];
}

- (void)hideDataTypeSpecificControlsForParameterA{
    [super hideDataTypeSpecificControlsForParameterA];
    [_staticStringTextFieldA setHidden:YES];
}

- (void)hideDataTypeSpecificControlsForParameterB{
    [super hideDataTypeSpecificControlsForParameterB];
    [_staticStringTextFieldB setHidden:YES];
}

@end

@implementation LynCombiningConditionTableCellView

@end

@implementation LynConditionNegationTableCellView

@end

@implementation LynConditionParameterSeparator{
    NSColor *color;
}

- (id)init{
    self = [super init];
    if (self) {
        color = [NSColor blackColor];
    }
    return self;
}

- (id)initWithFrame:(NSRect)frameRect{
    self = [super initWithFrame:frameRect];
    if (self) {
        color = [NSColor blackColor];
    }
    return self;
}

- (void)setBorderColor:(NSColor *)borderColor{
    color = borderColor;
    [self setNeedsDisplay:YES];
}

- (void)drawRect:(NSRect)dirtyRect{
    [color set];
    CGFloat y = NSHeight(self.bounds) / 2;
    [NSBezierPath fillRect:NSMakeRect(0, y, NSWidth(self.bounds), .6)];
}

@end

@implementation LynComparingConditionTableRowView

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

@implementation LynConditionsOutlineView

- (BOOL)validateProposedFirstResponder:(NSResponder *)responder forEvent:(NSEvent *)event{
    return YES;
}

@end
