//
//  LynUseReturnValueViewController.m
//  Lyn
//
//  Created by Programmieren on 10.11.13.
//  Copyright (c) 2013 Arne Philipeit Software. All rights reserved.
//

#import "LynUseReturnValueViewController.h"

@interface LynUseReturnValueViewController ()

@property IBOutlet NSMatrix *mtxChooser;
@property IBOutlet LynVariableChooserView *variableChooser;

- (IBAction)chooserChanged:(id)sender;

@end

@implementation LynUseReturnValueViewController
@synthesize command = _command;

- (id)init {
    self = [super initWithNibName:@"LynUseReturnValueView"
                           bundle:[NSBundle bundleForClass:self.class]];
    if (self) {
    }
    return self;
}

- (void)awakeFromNib{
    [_variableChooser setEnabled:NO];
    [_variableChooser setTarget:self];
    [_variableChooser setAction:@selector(variableChooserChanged:)];
    [self update];
}

- (void)update{
    if (!_command) return;
    [_mtxChooser selectCellAtRow:_command.useReturnValue column:0];
    
    LynFunction *function;
    for (LynOutlineObject *object in _command.parents) {
        if ([object isKindOfClass:[LynFunction class]]) {
            function = (LynFunction*)object;
        }
    }
    
    [_variableChooser beginUpdates];
    [_variableChooser setEnabled:_command.useReturnValue];
    [_variableChooser setType:_command.returnValueType];
    [_variableChooser setScope:_command.parent.scope];
    [_variableChooser setParameters:function.parameters];
    [_variableChooser endUpdates];
    [_variableChooser selectVariable:_command.returnValueParameter.parameterValue];
    
    if (!_command.returnValueParameter.parameterValue&&_variableChooser.selectedVariable) {
        [_command.returnValueParameter setParameterValue:_variableChooser.selectedVariable];
    }
}

#pragma mark Properties

- (LynCommand *)command{
    return _command;
}

- (void)setCommand:(LynCommand *)command{
    _command = command;
    [self update];
}

#pragma mark Undo / Redo

- (void)undoableSetUseReturnValue: (NSDictionary*)info{
    LynCommand *command = info[@"command"];
    NSNumber *useReturnValue = info[@"useReturnValue"];
    NSObject<NSCoding, NSCopying>* variable = info[@"variable"];
    if (!command||!useReturnValue) {
        return;
    }
    BOOL use = useReturnValue.boolValue;
    BOOL oldUse = command.useReturnValue;
    if (use == oldUse) {
        return;
    }
    NSObject *oldVariable = (oldUse) ? command.returnValueParameter.parameterValue : nil;
    command.useReturnValue = use;
    if (use&&variable) {
        [command.returnValueParameter setParameterValue:variable];
    }else if (use) {
        LynFunction *function;
        for (LynOutlineObject *object in command.parents) {
            if ([object isKindOfClass:[LynFunction class]]) {
                function = (LynFunction*)object;
            }
        }
        NSArray *variables = [LynVariableChooserView objectsForScope:command.parent.scope
                                                  includeSuperScopes:YES
                                                          parameters:function.parameters
                                                            withType:command.returnValueParameter.parameterType];
        if (variables.count == 0) {
            command.returnValueParameter.parameterValue = nil;
        }else{
            command.returnValueParameter.parameterValue = variables[0];
        }
    }
    if (oldVariable) {
        [_document.undoManager registerUndoWithTarget:self
                                             selector:@selector(undoableSetUseReturnValue:)
                                               object:@{@"command" : command, @"useReturnValue" : @(oldUse), @"variable" : oldVariable}];
    }else{
        [_document.undoManager registerUndoWithTarget:self
                                             selector:@selector(undoableSetUseReturnValue:)
                                               object:@{@"command" : command, @"useReturnValue" : @(oldUse)}];
    }
    [self update];
}

- (void)undoableSetParameterValue: (NSDictionary*)info{
    LynCommand *command = info[@"command"];
    NSObject<NSCoding, NSCopying>* variable = info[@"variable"];
    if (!command||!variable) {
        return;
    }
    if (variable == [NSNull null]) {
        variable = nil;
    }
    NSObject *oldVariable = command.returnValueParameter.parameterValue;
    command.returnValueParameter.parameterValue = variable;
    if (oldVariable) {
        [_document.undoManager registerUndoWithTarget:self
                                             selector: @selector(undoableSetParameterValue:)
                                               object:@{@"command" : command, @"variable" : oldVariable}];
    }else{
        [_document.undoManager registerUndoWithTarget:self
                                             selector: @selector(undoableSetParameterValue:)
                                               object:@{@"command" : command, @"variable" : [NSNull null]}];
    }
    [self update];
}

#pragma mark Actions

- (void)chooserChanged:(id)sender{
    if (_mtxChooser.selectedRow == 0&&_command.returnValueParameter.parameterValue) {
        [self undoableSetUseReturnValue:@{@"command" : _command, @"useReturnValue" : @NO, @"variable" : _command.returnValueParameter.parameterValue}];
    }else{
        [self undoableSetUseReturnValue:@{@"command" : _command, @"useReturnValue" : @(_mtxChooser.selectedRow == 1)}];
    }
}

- (void)variableChooserChanged:(id)sender{
    if (!_command.useReturnValue) return;
    [self undoableSetParameterValue:@{@"command" : _command, @"variable" : _variableChooser.selectedVariable}];
}

@end
