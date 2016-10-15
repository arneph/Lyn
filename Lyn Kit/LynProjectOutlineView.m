//
//  LynProjectOutlineView.m
//  Lyn
//
//  Created by Programmieren on 28.06.13.
//  Copyright (c) 2013 Arne Philipeit Software. All rights reserved.
//

#import "LynProjectOutlineView.h"
#import "LynProjectOutlineController.h"

@interface LynProjectOutlineView ()

@property IBOutlet NSView *subView;

@property IBOutlet LynProjectOutlineController *projectOutlineController;

@end

@implementation LynProjectOutlineView
@synthesize shownProject = _shownProject;
@synthesize editorView = _editorView;
@synthesize inspectorView = _inspectorView;
@synthesize document = _document;

- (id)init{
    self = [super init];
    if (self) {
        [[NSBundle bundleForClass:[self class]]  loadNibNamed:@"LynProjectOutlineView" owner:self topLevelObjects:nil];
    }
    return self;
}

- (id)initWithFrame:(NSRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [[NSBundle bundleForClass:[self class]]  loadNibNamed:@"LynProjectOutlineView" owner:self topLevelObjects:nil];
    }
    return self;
}

- (void)awakeFromNib{
    if (_projectOutlineController) {
        _projectOutlineController.project = _shownProject;
        _projectOutlineController.editorView = _editorView;
        _projectOutlineController.inspectorView = _inspectorView;
        _projectOutlineController.document = _document;
    }
    if (_subView) {
        _subView.frame = self.bounds;
        [self addSubview:_subView];
        [_subView setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable];
    }
}

- (LynProject *)shownProject{
    return _shownProject;
}

- (void)setShownProject:(LynProject *)shownProject{
    _shownProject = shownProject;
    _projectOutlineController.project = _shownProject;
    _editorView.project = _shownProject;
}

- (LynEditorView *)editorView{
    return _editorView;
}

- (void)setEditorView:(LynEditorView *)editorView{
    _editorView = editorView;
    _projectOutlineController.editorView = _editorView;
}

- (LynInspectorView *)inspectorView{
    return _inspectorView;
}

- (void)setInspectorView:(LynInspectorView *)inspectorView{
    _inspectorView = inspectorView;
    _projectOutlineController.inspectorView = _inspectorView;
}

- (NSDocument *)document{
    return _document;
}

- (void)setDocument:(NSDocument *)document{
    _document = document;
    _projectOutlineController.document = _document;
}

- (void)focus{
    [self.window makeFirstResponder:_projectOutlineController.outlineView];
}

- (void)selectObject:(id)object{
    [_projectOutlineController selectObject:object];
    if ([object isKindOfClass:[LynProjectOutlineObject class]]) [self focus];
}

@end
