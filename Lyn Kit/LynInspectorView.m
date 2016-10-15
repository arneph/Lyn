//
//  LynInspectorView.m
//  Lyn
//
//  Created by Programmieren on 23.06.13.
//  Copyright (c) 2013 Arne Philipeit Software. All rights reserved.
//

#import "LynInspectorView.h"
#import "LynDefineScopeViewController.h"
#import "LynDefineParametersViewController.h"
#import "LynFillParametersViewController.h"
#import "LynConditionsViewController.h"
#import "LynUseReturnValueViewController.h"

@interface LynInspectorView ()

@property IBOutlet NSView *subView;
@property IBOutlet NSButton *btnShowScope;
@property IBOutlet NSButton *btnShowParameters;
@property IBOutlet NSButton *btnShowConditions;
@property IBOutlet NSButton *btnShowReturnValue;
@property IBOutlet NSView *inspektorContainer;

- (IBAction)selectedInspector:(NSButton*)sender;

@end

@implementation LynInspectorView{
    NSUInteger shownInspector;
    LynDefineScopeViewController *defineScopeViewController;
    LynDefineParametersViewController *defineParametersViewController;
    LynFillParametersViewController *fillParametersViewController;
    LynConditionsViewController *conditionsViewController;
    LynUseReturnValueViewController *useReturnValueViewController;
}

@synthesize document = _document;
@synthesize delegate = _delegate;

- (id)init{
    self = [super init];
    if (self) {
        _object = nil;
        _showScopeInspector = NO;
        _showParametersInspector = NO;
        _showConditionsInspector = NO;
        _showReturnValueInspector = NO;
        shownInspector = 0;
        [[NSBundle bundleForClass:[self class]]  loadNibNamed:@"LynInspectorView" owner:self topLevelObjects:nil];
    }
    return self;
}

- (id)initWithFrame:(NSRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        _object = nil;
        _showScopeInspector = NO;
        _showParametersInspector = NO;
        _showConditionsInspector = NO;
        _showReturnValueInspector = NO;
        shownInspector = 0;
        [[NSBundle bundleForClass:[self class]]  loadNibNamed:@"LynInspectorView" owner:self topLevelObjects:nil];
    }
    return self;
}

- (void)awakeFromNib{
    _subView.frame = self.bounds;
    [self addSubview:_subView];
    _subView.nextResponder = self;
}

- (NSDocument *)document{
    return _document;
}

- (void)setDocument:(NSDocument *)document{
    _document = document;
    defineScopeViewController.document = _document;
    defineParametersViewController.document = _document;
    fillParametersViewController.document = _document;
    conditionsViewController.document = _document;
    useReturnValueViewController.document = _document;
}

- (id<LynUtilityViewDelegate>)delegate{
    return _delegate;
}

- (void)setDelegate:(id<LynUtilityViewDelegate>)delegate{
    _delegate = delegate;
    defineScopeViewController.delegate = _delegate;
}

- (void)setNoObject{
    _object = nil;
    _showScopeInspector = NO;
    _showParametersInspector = NO;
    _showConditionsInspector = NO;
    _showReturnValueInspector = NO;
    
    [_btnShowScope setEnabled:NO];
    [_btnShowParameters setEnabled:NO];
    [_btnShowConditions setEnabled:NO];
    [_btnShowReturnValue setEnabled:NO];
    
    [self selectInspector:0];
}

- (void)setObject:(LynOutlineObject*)object{
    if (!object) {
        [self setNoObject];
        return;
    }
    _object = object;
    _showScopeInspector = ([_object conformsToProtocol:@protocol(LynScopeOwner)]&&[[_object class] hasScope]);
    _showParametersInspector = ([_object isKindOfClass:[LynFunction class]]
                                ||([_object isKindOfClass:[LynCommand class]]&&[((LynCommand*)_object) parameters].count > 0));
    _showConditionsInspector = ([_object respondsToSelector:@selector(rootCondition)]);
    _showReturnValueInspector = ([_object isKindOfClass:[LynCommand class]]&&[((LynCommand*)_object) returnValueType] != LynDataTypeNone);
    
    if (_showScopeInspector) {
        defineScopeViewController.scope = _object.scope;
    }
    if (_showParametersInspector) {
        if ([_object isKindOfClass:[LynFunction class]]) {
            defineParametersViewController.function = (LynFunction*)_object;
            _parametersType = LynInspectorParametersTypeDefineParameters;
        }else{
            fillParametersViewController.command = (LynCommand*)_object;
            _parametersType = LynInspectorParametersTypeFillParameters;
        }
    }
    if (_showConditionsInspector) {
        conditionsViewController.command = (LynCommand*)_object;
        conditionsViewController.rootCondition = [((id)_object) rootCondition];
    }
    
    if (_showReturnValueInspector) {
        if ([_object isKindOfClass:[LynCommand class]]) {
            useReturnValueViewController.command = (LynCommand*)_object;
            _returnValueType = LynInspectorReturnValueTypeUseReturnValue;
        }
    }
    
    [_btnShowScope setEnabled:_showScopeInspector];
    [_btnShowParameters setEnabled:_showParametersInspector];
    [_btnShowConditions setEnabled:_showConditionsInspector];
    [_btnShowReturnValue setEnabled:_showReturnValueInspector];
    
    if (shownInspector == 0) {
        [self selectInspector:1];
    }else{
        [self selectInspector:shownInspector];
    }
}

- (void)selectInspector: (NSUInteger)inspector{
    if (inspector == 1) {
        if (_showScopeInspector) {
            [self showScopeView];
        }else if (_showParametersInspector) {
            [self showParametersView];
            inspector = 2;
        }else if (_showConditionsInspector) {
            [self showConditionsView];
            inspector = 3;
        }else if (_showReturnValueInspector) {
            [self showReturnValueView];
            inspector = 4;
        }else{
            [self showNoView];
            inspector = 0;
        }
    }else if (inspector == 2) {
        if (_showParametersInspector) {
            [self showParametersView];
        }else if (_showScopeInspector) {
            [self showScopeView];
            inspector = 1;
        }else if (_showConditionsInspector) {
            [self showConditionsView];
            inspector = 3;
        }else if (_showReturnValueInspector) {
            [self showReturnValueView];
            inspector = 4;
        }else{
            [self showNoView];
            inspector = 0;
        }
    }else if (inspector == 3) {
        if (_showConditionsInspector) {
            [self showConditionsView];
        }else if (_showScopeInspector) {
            [self showScopeView];
            inspector = 1;
        }else if (_showParametersInspector) {
            [self showParametersView];
            inspector = 2;
        }else if (_showReturnValueInspector) {
            [self showReturnValueView];
            inspector = 4;
        }else{
            [self showNoView];
            inspector = 0;
        }
    }else if (inspector == 4) {
        if (_showReturnValueInspector) {
            [self showReturnValueView];
        }else if (_showScopeInspector) {
            [self showScopeView];
            inspector = 1;
        }else if (_showParametersInspector) {
            [self showParametersView];
            inspector = 2;
        }else if (_showConditionsInspector) {
            [self showConditionsView];
            inspector = 3;
        }else{
            [self showNoView];
            inspector = 0;
        }
    }else{
        [self showNoView];
        shownInspector = 0;
        return;
    }
    shownInspector = inspector;
    [_btnShowScope setState:(shownInspector == 1)];
    [_btnShowParameters setState:(shownInspector == 2)];
    [_btnShowConditions setState:(shownInspector == 3)];
    [_btnShowReturnValue setState:(shownInspector == 4)];
}

- (void)showView: (NSView*)view{
    [self showNoView];
    view.frame = NSMakeRect(0, 0, NSWidth(_inspektorContainer.bounds), NSHeight(_inspektorContainer.bounds));
    [_inspektorContainer addSubview:view];
}

- (void)showNoView{
    for (NSView *subview in _inspektorContainer.subviews) {
        [subview removeFromSuperview];
    }
}

- (void)showScopeView{
    if (!defineScopeViewController) {
        defineScopeViewController = [[LynDefineScopeViewController alloc] init];
        defineScopeViewController.document = _document;
        defineScopeViewController.delegate = _delegate;
        if (_object&&[[_object class] hasScope]) {
            defineScopeViewController.scope = _object.scope;
        }
    }
    [self showView:defineScopeViewController.view];
}

- (void)showParametersView{
    if (_parametersType == LynInspectorParametersTypeDefineParameters) {
        [self showDefineParametersView];
    }else if (_parametersType == LynInspectorParametersTypeFillParameters) {
        [self showFillParametersView];
    }
}

- (void)showDefineParametersView{
    if (!defineParametersViewController) {
        defineParametersViewController = [[LynDefineParametersViewController alloc] init];
        defineParametersViewController.document = _document;
        if (_object&&[_object isKindOfClass:[LynFunction class]]) {
            defineParametersViewController.function = (LynFunction*)_object;
        }
    }
    [self showView:defineParametersViewController.view];
}

- (void)showFillParametersView{
    if (!fillParametersViewController) {
        fillParametersViewController = [[LynFillParametersViewController alloc] init];
        fillParametersViewController.document = _document;
        if (_object&&[_object isKindOfClass:[LynCommand class]]) {
            fillParametersViewController.command = (LynCommand*)_object;
        }
    }
    [self showView:fillParametersViewController.view];
}

- (void)showConditionsView{
    if (!conditionsViewController) {
        conditionsViewController = [[LynConditionsViewController alloc] init];
        conditionsViewController.document = _document;
        conditionsViewController.command = (LynCommand*)_object;
        conditionsViewController.rootCondition = [((id)_object) rootCondition];
    }
    [self showView:conditionsViewController.view];
}

- (void)showReturnValueView{
    if (_returnValueType == LynInspectorReturnValueTypeDefineReturnValue) {
        [self showDefineReturnValueView];
    }else if (_returnValueType == LynInspectorReturnValueTypeUseReturnValue) {
        [self showUseReturnValueView];
    }
}

- (void)showDefineReturnValueView{
    [self showNoView];
}

- (void)showUseReturnValueView{
    if (!useReturnValueViewController) {
        useReturnValueViewController = [[LynUseReturnValueViewController alloc] init];
        useReturnValueViewController.document = _document;
        useReturnValueViewController.command = (LynCommand*)_object;
    }
    [self showView:useReturnValueViewController.view];
}

- (void)selectedInspector:(NSButton *)sender{
    [self selectInspector:sender.tag];
}

@end
