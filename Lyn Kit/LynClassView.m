//
//  LynClassView.m
//  Lyn
//
//  Created by Programmieren on 23.06.13.
//  Copyright (c) 2013 Arne Philipeit Software. All rights reserved.
//

#import "LynClassView.h"
#import "LynClassOutlineController.h"

@interface LynClassView ()

@property IBOutlet NSView *subView;

@property IBOutlet LynClassOutlineController *classOutlineController;

@end

@implementation LynClassView

@synthesize shownClass = _shownClass;
@synthesize inspectorView = _inspectorView;
@synthesize document = _document;

- (id)init{
    self = [super init];
    if (self) {
        [[NSBundle bundleForClass:[self class]]  loadNibNamed:@"LynClassView" owner:self topLevelObjects:nil];
    }
    return self;
}

- (id)initWithFrame:(NSRect)frameRect{
    self = [super initWithFrame:frameRect];
    if (self) {
        [[NSBundle bundleForClass:[self class]]  loadNibNamed:@"LynClassView" owner:self topLevelObjects:nil];
    }
    return self;
}

- (void)awakeFromNib{
    if (_classOutlineController) {
        _classOutlineController.shownClass = _shownClass;
        _classOutlineController.inspectorView = _inspectorView;
        _classOutlineController.document = _document;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(selectionChanged:)
                                                     name:NSOutlineViewSelectionDidChangeNotification
                                                   object:_classOutlineController.outlineView];
    }
    if (_subView) {
        _subView.frame = self.bounds;
        [self addSubview:_subView];
        [_subView setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable];
    }
}

- (LynClass *)shownClass{
    return _shownClass;
}

- (void)setShownClass:(LynClass *)shownClass{
    _shownClass = shownClass;
    _classOutlineController.shownClass = shownClass;
}

- (LynInspectorView *)inspectorView{
    return _inspectorView;
}

- (void)setInspectorView:(LynInspectorView *)inspectorView{
    _inspectorView = inspectorView;
    _classOutlineController.inspectorView = _inspectorView;
}

- (NSDocument *)document{
    return _document;
}

- (void)setDocument:(NSDocument *)document{
    _document = document;
    _classOutlineController.document = document;
}

- (void)selectionChanged: (NSNotification*)notification{
    [NotificationCenter postNotificationName:LynClassViewSelectedObjectChangedNotification
                                      object:self];
}

- (void)focus{
    [self.window makeFirstResponder:_classOutlineController.outlineView];
}

- (LynOutlineObject *)selectedObject{
    if (_classOutlineController.outlineView.selectedRow < 0) {
        return nil;
    }else{
        LynOutlineObject *selectedObject = [_classOutlineController.outlineView itemAtRow:_classOutlineController.outlineView.selectedRow];
        return selectedObject;
    }
}

- (void)selectObject:(id)object{
    [_classOutlineController selectObject:object];
}

@end
