//
//  LynConditionsViewController.m
//  Lyn
//
//  Created by Programmieren on 05.10.13.
//  Copyright (c) 2013 Arne Philipeit Software. All rights reserved.
//

#import "LynConditionsViewController.h"

#define LynConditionDragType @"de.AP-Software.Lyn.LynConditionDragType"
#define LynConditionPBoardType @"de.AP-Sotware.Lyn.LynConditionDragType"

typedef enum{
    A,
    B
}parameterIndex;

@interface LynConditionsViewController () <NSOutlineViewDataSource, NSOutlineViewDelegate>

@property IBOutlet NSOutlineView *outlineView;

- (IBAction)pushedAddAndCondition:(id)sender;
- (IBAction)pushedAddOrCondition:(id)sender;
- (IBAction)pushedAddComparingConditionBoolean:(id)sender;
- (IBAction)pushedAddComparingConditionInteger:(id)sender;
- (IBAction)pushedAddComparingConditionString:(id)sender;
- (IBAction)pushedRemove:(id)sender;

- (IBAction)combinationTypeChanged:(id)sender;

- (IBAction)parameterFillTypeChanged:(id)sender;
- (IBAction)staticBooleanCheckBoxChanged:(id)sender;
- (IBAction)staticIntegerTextFieldChanged:(id)sender;
- (IBAction)staticIntegerStepperChanged:(id)sender;
- (IBAction)integerComparisonOperationChanged:(id)sender;
- (IBAction)staticStringTextFieldChanged:(id)sender;

- (IBAction)negationChanged:(id)sender;

@end

@implementation LynConditionsViewController
@synthesize command = _command;
@synthesize rootCondition = _rootCondition;

- (id)init {
    self = [super initWithNibName:@"LynConditionsView"
                           bundle:[NSBundle bundleForClass:self.class]];
    if (self) {
        [NotificationCenter addObserver:self
                               selector:@selector(colorsChanged:)
                                   name:LynSettingChangedNotification
                                 object:nil];
    }
    return self;
}

- (void)awakeFromNib{
    if (_outlineView&&_outlineView.nextResponder != self) {
        self.nextResponder = _outlineView.nextResponder;
        _outlineView.nextResponder = self;
        [_outlineView expandItem:nil expandChildren:YES];
        [_outlineView registerForDraggedTypes:@[LynConditionDragType]];
    }
}

- (void)colorsChanged: (NSNotification*)notification{
    [_outlineView reloadData];
}

#pragma mark Properties

- (LynCommand *)command{
    return _command;
}

- (void)setCommand:(LynCommand *)command{
    _command = command;
    [_outlineView reloadData];
    [_outlineView expandItem:nil expandChildren:YES];
}

- (LynCombiningCondition *)rootCondition{
    return _rootCondition;
}

- (void)setRootCondition:(LynCombiningCondition *)rootCondition{
    _rootCondition = rootCondition;
    [_outlineView reloadData];
    [_outlineView expandItem:nil expandChildren:YES];
}

#pragma mark OutlineView Datasource

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(LynCondition*)item{
    if (!item) {
        return _rootCondition;
    }else{
        return ([item isKindOfClass:[LynCombiningCondition class]]) ? [((LynCombiningCondition*)item) subConditions][index] : nil;
    }
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(LynCondition*)item{
    return [item isKindOfClass:[LynCombiningCondition class]];
}

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(LynCondition*)item{
    if (!item) {
        return 1;
    }else{
        return ([item isKindOfClass:[LynCombiningCondition class]]) ? [((LynCombiningCondition*)item) subConditions].count : 0;
    }
}

#pragma mark OutlineView Delegate

- (NSView *)outlineView:(NSOutlineView *)outlineView viewForTableColumn:(NSTableColumn *)tableColumn item:(LynCondition*)item{
    if ([tableColumn.identifier isEqualToString:@"Condition"]) {
        if ([item isKindOfClass:[LynCombiningCondition class]]) {
            LynCombiningConditionTableCellView *cellView = [_outlineView makeViewWithIdentifier:@"CombiningConditionCell"
                                                                                          owner:self];
            [cellView.typeChooser selectItemAtIndex:((LynCombiningCondition*)item).combinationType];
            return cellView;
        }else if([item isKindOfClass:[LynComparingCondition class]]) {
            LynComparingCondition *condition = (LynComparingCondition*)item;
            LynComparingConditionTableCellView *cellView;
            if (condition.type == LynDataTypeBoolean) {
                LynComparingConditionBooleanTableCellView *booleanCellView = [_outlineView makeViewWithIdentifier:@"ComparingConditionBooleanCell"
                                                                                                            owner:self];
                cellView = booleanCellView;
            }else if (condition.type == LynDataTypeInteger) {
                LynComparingConditionIntegerTableCellView *integerCellView = [_outlineView makeViewWithIdentifier:@"ComparingConditionIntegerCell"
                                                                                                            owner:self];
                LynIntegerComparisonOperation operation = ((LynComparingConditionInteger*)condition).operation;
                if (operation == LynIntegerComparisonLessThan) {
                    integerCellView.operationTextField.stringValue = @"<";
                }else if (operation == LynIntegerComparisonLessThanOrEqual) {
                    integerCellView.operationTextField.stringValue = @"<=";
                }else if (operation == LynIntegerComparisonEqual) {
                    integerCellView.operationTextField.stringValue = @"==";
                }else if (operation == LynIntegerComparisonGreaterThanOrEqual) {
                    integerCellView.operationTextField.stringValue = @">=";
                }else if (operation == LynIntegerComparisonGreaterThan) {
                    integerCellView.operationTextField.stringValue = @">";
                }
                cellView = integerCellView;
            }else if (condition.type == LynDataTypeString) {
                LynComparingConditionStringTableCellView *stringCellView = [_outlineView makeViewWithIdentifier:@"ComparingConditionStringCell"
                                                                                                          owner:self];
                cellView = stringCellView;
            }
            LynParameterFillType fillTypeA = condition.parameterA.fillType;
            [cellView.fillTypeMatrixA selectCellAtRow:(fillTypeA == LynParameterFillTypeStatic) ? 0 : 1
                                               column:0];
            if (fillTypeA == LynParameterFillTypeStatic) {
                [cellView showDataTypeSpecificControlsForParameterA];
                if (condition.type == LynDataTypeBoolean) {
                    BOOL parameterValue = ((NSNumber*)condition.parameterA.parameterValue).boolValue;
                    ((LynComparingConditionBooleanTableCellView*) cellView).staticBooleanCheckBoxA.state = parameterValue;
                }else if (condition.type == LynDataTypeInteger) {
                    NSNumber *parameterValue = (NSNumber*)condition.parameterA.parameterValue;
                    [((LynComparingConditionIntegerTableCellView*) cellView).staticIntegerTextFieldA setObjectValue:parameterValue];
                    [((LynComparingConditionIntegerTableCellView*) cellView).staticIntegerStepperA setObjectValue:parameterValue];
                }else if (condition.type == LynDataTypeString) {
                    NSString *parameterValue = (NSString*)condition.parameterA.parameterValue;
                    [((LynComparingConditionStringTableCellView*) cellView).staticStringTextFieldA setStringValue:parameterValue];
                }
            }else{
                [cellView hideDataTypeSpecificControlsForParameterA];
                LynFunction *function;
                for (LynOutlineObject *object in _command.parents) {
                    if ([object isKindOfClass:[LynFunction class]]) {
                        function = (LynFunction*)object;
                    }
                }
                
                [cellView.variableChooserA beginUpdates];
                [cellView.variableChooserA setType:condition.parameterA.parameterType];
                [cellView.variableChooserA setScope:_command.scope.superScope];
                [cellView.variableChooserA setParameters:function.parameters];
                [cellView.variableChooserA selectVariable:condition.parameterA.parameterValue];
                [cellView.variableChooserA endUpdates];
                
                [cellView.variableChooserA setTarget:self];
                [cellView.variableChooserA setAction:@selector(variableChooserChanged:)];
                
                if (!condition.parameterA.parameterValue&&cellView.variableChooserA.selectedVariable) {
                     [condition.parameterA setParameterValue:cellView.variableChooserA.selectedVariable];
                }
            }
            LynParameterFillType fillTypeB = condition.parameterB.fillType;
            [cellView.fillTypeMatrixB selectCellAtRow:(fillTypeB == LynParameterFillTypeStatic) ? 0 : 1
                                               column:0];
            if (fillTypeB == LynParameterFillTypeStatic) {
                [cellView showDataTypeSpecificControlsForParameterB];
                if (condition.type == LynDataTypeBoolean) {
                    BOOL parameterValue = ((NSNumber*)condition.parameterB.parameterValue).boolValue;
                    ((LynComparingConditionBooleanTableCellView*) cellView).staticBooleanCheckBoxB.state = parameterValue;
                }else if (condition.type == LynDataTypeInteger) {
                    NSNumber *parameterValue = (NSNumber*)condition.parameterB.parameterValue;
                    [((LynComparingConditionIntegerTableCellView*) cellView).staticIntegerTextFieldB setObjectValue:parameterValue];
                    [((LynComparingConditionIntegerTableCellView*) cellView).staticIntegerStepperB setObjectValue:parameterValue];
                }else if (condition.type == LynDataTypeString) {
                    NSString *parameterValue = (NSString*)condition.parameterB.parameterValue;
                    [((LynComparingConditionStringTableCellView*) cellView).staticStringTextFieldB setStringValue:parameterValue];
                }
            }else{
                [cellView hideDataTypeSpecificControlsForParameterB];
                LynFunction *function;
                for (LynOutlineObject *object in _command.parents) {
                    if ([object isKindOfClass:[LynFunction class]]) {
                        function = (LynFunction*)object;
                    }
                }
                
                [cellView.variableChooserB beginUpdates];
                [cellView.variableChooserB setType:condition.parameterB.parameterType];
                [cellView.variableChooserB setScope:_command.scope.superScope];
                [cellView.variableChooserB setParameters:function.parameters];
                [cellView.variableChooserB selectVariable:condition.parameterB.parameterValue];
                [cellView.variableChooserB endUpdates];
                
                [cellView.variableChooserB setTarget:self];
                [cellView.variableChooserB setAction:@selector(variableChooserChanged:)];
                
                if (!condition.parameterB.parameterValue&&cellView.variableChooserB.selectedVariable) {
                    [condition.parameterB setParameterValue:cellView.variableChooserB.selectedVariable];
                }
            }
            return cellView;
        }else{
            return nil;
        }
    }else if ([tableColumn.identifier isEqualToString:@"Negate"]) {
        LynConditionNegationTableCellView *cellView = [_outlineView makeViewWithIdentifier:@"NegationCell"
                                                                                     owner:self];
        cellView.chkNegate.state = item.negate;
        return cellView;
    }
    return nil;
}

- (NSTableRowView*)outlineView:(NSOutlineView *)outlineView rowViewForItem:(id)item{
    if (![item isKindOfClass:[LynComparingCondition class]]) return [[NSTableRowView alloc] init];
    return [[LynComparingConditionTableRowView alloc] init];
}

- (void)outlineView:(NSOutlineView *)outlineView
      didAddRowView:(NSTableRowView *)rowView
             forRow:(NSInteger)row{
    if (![[_outlineView itemAtRow:row] isKindOfClass:[LynComparingCondition class]]) return;
    LynComparingCondition *condition = [_outlineView itemAtRow:row];
    LynSetting *colorSetting;
    if (condition.type == LynDataTypeBoolean) {
        colorSetting = [LynGeneral settingForKey:@"variables.boolean.color"];
    }else if (condition.type == LynDataTypeInteger) {
        colorSetting = [LynGeneral settingForKey:@"variables.integer.color"];
    }else if (condition.type == LynDataTypeString) {
        colorSetting = [LynGeneral settingForKey:@"variables.string.color"];
    }else {
        return;
    }
    NSArray *value = colorSetting.value;
    NSNumber *red = value[0];
    NSNumber *green = value[1];
    NSNumber *blue = value[2];
    NSColor *color = [NSColor colorWithCalibratedRed:red.unsignedIntegerValue / 255.0
                                               green:green.unsignedIntegerValue / 255.0
                                                blue:blue.unsignedIntegerValue / 255.0
                                               alpha:1];
    rowView.backgroundColor = color;
}

- (CGFloat)outlineView:(NSOutlineView *)outlineView heightOfRowByItem:(id)item{
    if ([item isKindOfClass:[LynCombiningCondition class]]) {
        return 17;
    }else if ([item isKindOfClass:[LynComparingCondition class]]) {
        return 67;
    }else{
        return 0;
    }
}

#pragma mark Undo / Redo

- (void)addSubConditionsToConditionsAtIndexes: (NSDictionary*)info{
    NSArray *subConditions = info[@"subConditions"];
    NSArray *conditions = info[@"conditions"];
    NSArray *indexes = info[@"indexes"];
    
    if (!subConditions||!conditions||!indexes||
        subConditions.count < 1||subConditions.count != indexes.count||
        !(conditions.count == 1||conditions.count == subConditions.count)) {
        return;
    }
    
    for (LynCondition *subCondition in subConditions) {
        NSNumber *index = indexes[[subConditions indexOfObject:subCondition]];
        LynCombiningCondition *condition;
        if (conditions.count == 1) {
            condition = conditions[0];
        }else{
            condition = conditions[index.unsignedIntegerValue];
        }
        if (index.unsignedIntegerValue > condition.subConditions.count) index = @(condition.subConditions.count);
        
        [condition.subConditions insertObject:subCondition atIndex:index.unsignedIntegerValue];
    }
    
    [_outlineView reloadData];
    [_document.undoManager registerUndoWithTarget:self
                                         selector:@selector(removeSubConditionsFromConditions:)
                                           object:@{@"subConditions" : subConditions, @"conditions" : conditions}];
}

- (void)removeSubConditionsFromConditions: (NSDictionary*)info{
    NSArray *subConditions = info[@"subConditions"];
    NSArray *conditions = info[@"conditions"];
    
    if (!subConditions||!conditions||
        subConditions.count < 1||
        !(conditions.count == 1||conditions.count == subConditions.count)) {
        return;
    }
    
    NSMutableArray *indexes = [NSMutableArray arrayWithCapacity:subConditions.count];
    for (LynCondition *subCondition in subConditions) {
        LynCombiningCondition *condition;
        
        if (subCondition.parentCondition) {
            if (conditions.count == 1) {
                condition = conditions [0];
            }else{
                condition = conditions[[subConditions indexOfObject:subCondition]];
            }
            NSUInteger index = [condition.subConditions indexOfObject:subCondition];
            
            if (index == NSNotFound) {
                @throw NSInvalidArgumentException;
                return;
            }
        
            [condition.subConditions removeObject:subCondition];
        
            [indexes addObject:@(index)];
        }
    }
    
    [_outlineView reloadData];
    [_document.undoManager registerUndoWithTarget:self
                                         selector:@selector(addSubConditionsToConditionsAtIndexes:)
                                           object:@{@"subConditions" : subConditions, @"conditions" : conditions, @"indexes" : indexes}];
}

- (void)setCombinationType: (NSDictionary*)info{
    LynCombiningCondition *condition = info[@"condition"];
    NSNumber *combinationType = info[@"combinationType"];
    if (!condition||!combinationType) {
        return;
    }
    LynConditionCombinationType oldCombinationType = condition.combinationType;
    condition.combinationType = (LynConditionCombinationType)combinationType.unsignedIntegerValue;
    [_document.undoManager registerUndoWithTarget:self
                                         selector:@selector(setCombinationType:)
                                           object:@{@"condition" : condition, @"combinationType" : @(oldCombinationType)}];
    NSInteger row = [_outlineView rowForItem:condition];
    NSInteger column = [_outlineView columnWithIdentifier:@"Condition"];
    if (row > -1&&column > -1) {
        [_outlineView reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:row]
                                columnIndexes:[NSIndexSet indexSetWithIndex:column]];
    }
}

- (void)setNegate: (NSDictionary*)info{
    LynCondition *condition = info[@"condition"];
    NSNumber *negate = info[@"negate"];
    if (!condition||!negate) {
        return;
    }
    BOOL oldNegate = condition.negate;
    condition.negate = negate.boolValue;
    [_document.undoManager registerUndoWithTarget:self
                                         selector:@selector(setNegate:)
                                           object:@{@"condition" : condition, @"negate" : @(oldNegate)}];
    NSInteger row = [_outlineView rowForItem:condition];
    NSInteger column = [_outlineView columnWithIdentifier:@"Negate"];
    if (row > -1&&column > -1) {
        [_outlineView reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:row]
                                columnIndexes:[NSIndexSet indexSetWithIndex:column]];
    }
}

- (void)setParameterFillType: (NSDictionary*)info{
    LynParameter *parameter = info[@"parameter"];
    LynCommand *command = info[@"command"];
    LynCombiningCondition *condition = info[@"condition"];
    NSNumber *nFillType = info[@"fillType"];
    NSObject *newValue = info[@"parameterValue"];
    if (!parameter||!nFillType||!condition||
        !(nFillType.unsignedIntegerValue == 0||nFillType.unsignedIntegerValue == 1||nFillType.unsignedIntegerValue == 2)) {
        return;
    }
    if (newValue == [NSNull null]) newValue = nil;
    LynParameterFillType fillType = (LynParameterFillType)nFillType.unsignedIntegerValue;
    LynParameterFillType oldFillType = parameter.fillType;
    NSObject *oldValue = parameter.parameterValue;
    [parameter setFillType:fillType];
    if (!parameter.parameterValue&&!newValue&&parameter.fillType != LynParameterFillTypeStatic&&condition) {
        LynScope *scope = command.scope;
        LynFunction *function;
        for (LynOutlineObject *parent in command.parents) {
            if (!function&&[parent isKindOfClass:[LynFunction class]]) function = (LynFunction*)parent;
        }
        NSArray *possibleObjects = [LynVariableChooserView objectsForScope:scope
                                                        includeSuperScopes:YES
                                                                parameters:function.parameters
                                                                  withType:parameter.parameterType];
        if (possibleObjects.count > 0) parameter.parameterValue = possibleObjects[0];
    }else if (newValue) {
        [parameter setParameterValue:(NSObject<NSCoding, NSCopying>*)newValue];
    }
    if (!oldValue) oldValue = [NSNull null];
    [_outlineView reloadData];
    [_document.undoManager registerUndoWithTarget:self
                                         selector:@selector(setParameterFillType:)
                                           object:@{@"parameter" : parameter,
                                                    @"command" : command,
                                                    @"condition" : condition,
                                                    @"fillType": @(oldFillType),
                                                    @"parameterValue" : oldValue}];
}

- (void)setParameterValue: (NSDictionary*)info{
    LynParameter *parameter = info[@"parameter"];
    NSObject <NSCoding, NSCopying> *value = info[@"value"];
    if (!parameter||!value) {
        return;
    }
    if (value == [NSNull null]) value = nil;
    NSObject *oldValue = parameter.parameterValue;
    [parameter setParameterValue:value];
    if (!oldValue) oldValue = [NSNull null];
    [_outlineView reloadData];
    [_document.undoManager registerUndoWithTarget:self
                                         selector:@selector(setParameterValue:)
                                           object:@{@"parameter" : parameter, @"value" : oldValue}];
}

- (void)setIntegerComparisonOperation: (NSDictionary*)info{
    LynComparingConditionInteger *condition = info[@"condition"];
    NSNumber *newOperation = info[@"operation"];
    if (!condition||!newOperation) {
        return;
    }
    NSNumber *oldOperation = @(condition.operation);
    if ([oldOperation isEqualToNumber:newOperation]) return;
    condition.operation = (LynIntegerComparisonOperation)newOperation.integerValue;
    [_document.undoManager registerUndoWithTarget:self
                                         selector:@selector(setIntegerComparisonOperation:)
                                           object:@{@"condition": condition,
                                                    @"operation" : oldOperation}];
    [_outlineView reloadData];
}

#pragma mark Helper Functions

- (NSArray*)simplifiedConditionCollection: (NSArray*)collection{
    NSMutableArray *simplifiedCollection = [[NSMutableArray alloc] init];
    for (LynCondition *condition in collection) {
        LynCondition *parentCondition = condition.parentCondition;
        BOOL contained = NO;
        while (parentCondition&&!contained) {
            if ([collection indexOfObject:parentCondition] != NSNotFound) {
                contained = YES;
            }
            parentCondition = parentCondition.parentCondition;
        }
        if (!contained) {
            [simplifiedCollection addObject:condition];
        }
    }
    return [NSArray arrayWithArray:simplifiedCollection];
}

- (void)addConditions: (NSArray*)newConditions{
    if (_outlineView.numberOfSelectedRows < 1) {
        NSMutableArray *indexes = [NSMutableArray arrayWithCapacity:newConditions.count];
        for (NSUInteger i = 0; i < newConditions.count; i++) {
            [indexes addObject:@(_rootCondition.subConditions.count + i)];
        }
        [self addSubConditionsToConditionsAtIndexes:@{@"subConditions" : newConditions,
                                                      @"conditions" : @[_rootCondition],
                                                      @"indexes" :indexes}];
    }else{
        NSUInteger row = _outlineView.selectedRow;
        LynCondition *selectedCondition = [_outlineView itemAtRow:row];
        LynCombiningCondition *parentCondition;
        NSUInteger index;
        if ([selectedCondition isKindOfClass:[LynCombiningCondition class]]) {
            parentCondition = (LynCombiningCondition*)selectedCondition;
            index = parentCondition.subConditions.count;
        }else{
            parentCondition = (LynCombiningCondition*)selectedCondition.parentCondition;
            index = [parentCondition.subConditions indexOfObject:selectedCondition] + 1;
        }
        NSMutableArray *indexes = [NSMutableArray arrayWithCapacity:newConditions.count];
        for (NSUInteger i = 0; i < newConditions.count; i++) {
            [indexes addObject:@(index + i)];
        }
        [self addSubConditionsToConditionsAtIndexes:@{@"subConditions" : newConditions,
                                                      @"conditions" : @[parentCondition],
                                                      @"indexes" : indexes}];
    }
}

- (void)addCondition: (LynCondition*)newCondition{
    if (_outlineView.numberOfSelectedRows < 1) {
        [self addSubConditionsToConditionsAtIndexes:@{@"subConditions" : @[newCondition],
                                                      @"conditions" : @[_rootCondition],
                                                      @"indexes" : @[@(_rootCondition.subConditions.count)]}];
    }else{
        NSUInteger row = _outlineView.selectedRow;
        LynCondition *selectedCondition = [_outlineView itemAtRow:row];
        LynCombiningCondition *parentCondition;
        NSUInteger index;
        if ([selectedCondition isKindOfClass:[LynCombiningCondition class]]) {
            parentCondition = (LynCombiningCondition*)selectedCondition;
            index = parentCondition.subConditions.count;
        }else{
            parentCondition = (LynCombiningCondition*)selectedCondition.parentCondition;
            index = [parentCondition.subConditions indexOfObject:selectedCondition] + 1;
        }
        [self addSubConditionsToConditionsAtIndexes:@{@"subConditions" : @[newCondition],
                                                      @"conditions" : @[parentCondition],
                                                      @"indexes" : @[@(index)]}];
    }
}

#pragma mark Drag & Drop

- (BOOL)outlineView:(NSOutlineView *)outlineView
         writeItems:(NSArray *)items
       toPasteboard:(NSPasteboard *)pasteboard{
    NSMutableArray *conditions = [NSMutableArray arrayWithArray:items];
    if ([conditions indexOfObject:_rootCondition] != NSNotFound) {
        [conditions removeObject:_rootCondition];
    }
    conditions = [NSMutableArray arrayWithArray:[self simplifiedConditionCollection:conditions]];
    if (conditions.count < 1) {
        return NO;
    }
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:conditions];
    
    [pasteboard declareTypes:@[LynConditionDragType] owner:self];
    [pasteboard setData:data forType:LynConditionDragType];
    
    [self performSelector:@selector(removeDraggedConditions:) withObject:conditions afterDelay:.01];
    return YES;
}

- (void)removeDraggedConditions: (NSArray*)subConditions{
    NSMutableArray *conditions = [NSMutableArray arrayWithCapacity:subConditions.count];
    for (LynCondition *condition in subConditions) {
        [conditions addObject:condition.parentCondition];
    }
    [self removeSubConditionsFromConditions:@{@"subConditions" : subConditions,
                                              @"conditions" : conditions}];
    [_document.undoManager setActionName:@"Dragging Conditions"];
}

- (NSDragOperation)outlineView:(NSOutlineView *)outlineView
                  validateDrop:(id<NSDraggingInfo>)info
                  proposedItem:(id)item
            proposedChildIndex:(NSInteger)index{
    if (!item||![item isKindOfClass:[LynCombiningCondition class]]) {
        return NSDragOperationNone;
    }else{
        return NSDragOperationMove;
    }
}

- (BOOL)outlineView:(NSOutlineView *)outlineView
         acceptDrop:(id<NSDraggingInfo>)info
               item:(id)item
         childIndex:(NSInteger)index{
    if (!item||![item isKindOfClass:[LynCombiningCondition class]]) return NO;
    NSPasteboard *pboard = [info draggingPasteboard];
    NSData *data = [pboard dataForType:LynConditionDragType];
    NSArray *conditions = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    LynCombiningCondition *parentCondition = (LynCombiningCondition*)item;
    NSMutableArray *indexes = [NSMutableArray arrayWithCapacity:conditions.count];
    for (NSUInteger i = 0; i < conditions.count; i++) {
        [indexes addObject:@(index + i)];
    }
    [self addSubConditionsToConditionsAtIndexes:@{@"subConditions" : conditions,
                                                  @"conditions" : @[parentCondition],
                                                  @"indexes" : indexes}];
    [_document.undoManager setActionName:@"Dropping Conditions"];
    return YES;
}

#pragma mark Actions

- (void)pushedAddAndCondition:(id)sender{
    LynCombiningCondition *newCondition = [[LynCombiningCondition alloc] init];
    newCondition.combinationType = LynConditionCombinationAnd;
    [self addCondition:newCondition];
    [_document.undoManager setActionName:@"Adding Group"];
}

- (void)pushedAddOrCondition:(id)sender{
    LynCombiningCondition *newCondition = [[LynCombiningCondition alloc] init];
    newCondition.combinationType = LynConditionCombinationOr;
    [self addCondition:newCondition];
    [_document.undoManager setActionName:@"Adding Group"];
}

- (void)pushedAddComparingConditionBoolean:(id)sender{
    LynComparingConditionBoolean *newConition = [[LynComparingConditionBoolean alloc] init];
    [self addCondition:newConition];
    [_document.undoManager setActionName:@"Adding Boolean Comparison"];
}

- (void)pushedAddComparingConditionInteger:(id)sender{
    LynComparingConditionInteger *newConition = [[LynComparingConditionInteger alloc] init];
    [self addCondition:newConition];
    [_document.undoManager setActionName:@"Adding Integer Comparison"];
}

- (void)pushedAddComparingConditionString:(id)sender{
    LynComparingConditionString *newConition = [[LynComparingConditionString alloc] init];
    [self addCondition:newConition];
    [_document.undoManager setActionName:@"Adding String Comparison"];
}

- (void)pushedRemove:(id)sender{
    if (_outlineView.numberOfSelectedRows < 1) return;
    NSIndexSet *indexes = _outlineView.selectedRowIndexes;
    NSMutableArray *subConditions = [[NSMutableArray alloc] init];
    [indexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop){
        LynCondition *condition = [_outlineView itemAtRow:idx];
        if (condition != _rootCondition) {
            [subConditions addObject:condition];
        }
    }];
    subConditions = [NSMutableArray arrayWithArray:[self simplifiedConditionCollection:subConditions]];
    NSMutableArray *conditions = [[NSMutableArray alloc] init];
    for (LynCondition *condition in subConditions) {
        [conditions addObject:condition.parentCondition];
    }
    if (conditions.count < 1) return;
    [self removeSubConditionsFromConditions:@{@"subConditions" : subConditions, @"conditions" : conditions}];
    [_document.undoManager setActionName:@"Removing Conditions"];
}

- (void)combinationTypeChanged:(NSPopUpButton*)sender{
    NSUInteger row = [_outlineView rowForView:sender.superview];
    LynCombiningCondition *condition = [_outlineView itemAtRow:row];
    if (sender.indexOfSelectedItem != condition.combinationType) {
        [self setCombinationType:@{@"condition" : condition, @"combinationType" : @(sender.indexOfSelectedItem)}];
    }
    [_document.undoManager setActionName:@"Changing Condition Type"];
}

- (void)parameterFillTypeChanged:(NSMatrix*)sender{
    LynComparingConditionTableCellView *cellView = (LynComparingConditionTableCellView*)sender.superview;
    NSUInteger row = [_outlineView rowForView:cellView];
    LynComparingCondition *condition = [_outlineView itemAtRow:row];
    parameterIndex index;
    LynParameter *parameter;
    LynParameterFillType newFillType = (sender.selectedRow == 0) ? LynParameterFillTypeStatic :
                                                                   LynParameterFillTypeDynamicFromVariable;
    if (sender == cellView.fillTypeMatrixA) {
        index = A;
        parameter = condition.parameterA;
    }else if (sender == cellView.fillTypeMatrixB) {
        index = B;
        parameter = condition.parameterB;
    }else{
        return;
    }
    [self setParameterFillType:@{@"parameter" : parameter,
                                 @"command" : _command,
                                 @"condition" : condition,
                                 @"fillType": @(newFillType)}];
    [_document.undoManager setActionName:@"Changing Condition"];
}

- (void)variableChooserChanged:(LynVariableChooserView*)sender{
    LynComparingConditionBooleanTableCellView *cellView = (LynComparingConditionBooleanTableCellView*)sender.superview;
    NSUInteger row = [_outlineView rowForView:cellView];
    LynComparingCondition *condition = [_outlineView itemAtRow:row];
    parameterIndex index;
    LynParameter *parameter;
    id newValue = sender.selectedVariable;
    if (sender == cellView.variableChooserA) {
        index = A;
        parameter = condition.parameterA;
    }else if (sender == cellView.variableChooserB) {
        index = B;
        parameter = condition.parameterB;
    }else{
        return;
    }
    if (sender.selectedVariable == parameter.parameterValue) return;
    if (!newValue) newValue = [NSNull null];
    [self setParameterValue:@{@"parameter" : parameter, @"value" : newValue}];
    [_document.undoManager setActionName:@"Changing Condition"];
}

- (void)staticBooleanCheckBoxChanged:(NSButton *)sender{
    LynComparingConditionBooleanTableCellView *cellView = (LynComparingConditionBooleanTableCellView*)sender.superview;
    NSUInteger row = [_outlineView rowForView:cellView];
    LynComparingCondition *condition = [_outlineView itemAtRow:row];
    parameterIndex index;
    LynParameter *parameter;
    NSNumber *newValue = @(sender.state);
    if (sender == cellView.staticBooleanCheckBoxA) {
        index = A;
        parameter = condition.parameterA;
    }else if (sender == cellView.staticBooleanCheckBoxB) {
        index = B;
        parameter = condition.parameterB;
    }else{
        return;
    }
    [self setParameterValue:@{@"parameter" : parameter,
                              @"value" : newValue}];
    [_document.undoManager setActionName:@"Changing Condition"];
}

- (void)staticIntegerTextFieldChanged:(NSTextField*)sender{
    LynComparingConditionIntegerTableCellView *cellView = (LynComparingConditionIntegerTableCellView*)sender.superview;
    NSUInteger row = [_outlineView rowForView:cellView];
    LynComparingCondition *condition = [_outlineView itemAtRow:row];
    parameterIndex index;
    LynParameter *parameter;
    NSNumber *newValue = @(sender.doubleValue);
    if (sender == cellView.staticIntegerTextFieldA) {
        index = A;
        parameter = condition.parameterA;
    }else if (sender == cellView.staticIntegerTextFieldB) {
        index = B;
        parameter = condition.parameterB;
    }else{
        return;
    }
    [self setParameterValue:@{@"parameter" : parameter,
                              @"value" : newValue}];
    [_document.undoManager setActionName:@"Changing Condition"];
}

- (void)staticIntegerStepperChanged:(NSStepper*)sender{
    LynComparingConditionIntegerTableCellView *cellView = (LynComparingConditionIntegerTableCellView*)sender.superview;
    NSUInteger row = [_outlineView rowForView:cellView];
    LynComparingCondition *condition = [_outlineView itemAtRow:row];
    parameterIndex index;
    LynParameter *parameter;
    NSNumber *newValue = @(sender.doubleValue);
    if (sender == cellView.staticIntegerStepperA) {
        index = A;
        parameter = condition.parameterA;
    }else if (sender == cellView.staticIntegerStepperB) {
        index = B;
        parameter = condition.parameterB;
    }else{
        return;
    }
    [self setParameterValue:@{@"parameter" : parameter,
                              @"value" : newValue}];
    [_document.undoManager setActionName:@"Changing Condition"];
}

- (void)integerComparisonOperationChanged:(NSTextField*)sender{
    LynComparingConditionIntegerTableCellView *cellView = (LynComparingConditionIntegerTableCellView*)sender.superview;
    NSInteger row = [_outlineView rowForView:cellView];
    if (row == -1) return;
    LynComparingConditionInteger *condition = [_outlineView itemAtRow:row];
    LynIntegerComparisonOperation newOperation;
    if ([sender.stringValue isEqualToString:@"<"]) {
        newOperation = LynIntegerComparisonLessThan;
    }else if ([sender.stringValue isEqualToString:@"<="]) {
        newOperation = LynIntegerComparisonLessThanOrEqual;
    }else if ([sender.stringValue isEqualToString:@"=="]||[sender.stringValue isEqualToString:@"="]) {
        newOperation = LynIntegerComparisonEqual;
    }else if ([sender.stringValue isEqualToString:@">="]) {
        newOperation = LynIntegerComparisonGreaterThanOrEqual;
    }else if ([sender.stringValue isEqualToString:@">"]) {
        newOperation = LynIntegerComparisonGreaterThan;
    }else{
        NSBeep();
        [_outlineView reloadData];
        return;
    }
    if (newOperation == condition.operation) {
        [_outlineView reloadData];
        return;
    }
    [self setIntegerComparisonOperation:@{@"condition" : condition,
                                          @"operation" : @(newOperation)}];
    [_document.undoManager setActionName:@"Changing Comparison Operation"];
}

- (void)staticStringTextFieldChanged:(NSTextField*)sender{
    LynComparingConditionStringTableCellView *cellView = (LynComparingConditionStringTableCellView*)sender.superview;
    NSUInteger row = [_outlineView rowForView:cellView];
    LynComparingCondition *condition = [_outlineView itemAtRow:row];
    parameterIndex index;
    LynParameter *parameter;
    NSString *newValue = sender.stringValue;
    if (sender == cellView.staticStringTextFieldA) {
        index = A;
        parameter = condition.parameterA;
    }else if (sender == cellView.staticStringTextFieldB) {
        index = B;
        parameter = condition.parameterB;
    }else{
        return;
    }
    [self setParameterValue:@{@"parameter" : parameter,
                              @"value" : newValue}];
    [_document.undoManager setActionName:@"Changing Condition"];
}

- (void)negationChanged:(NSButton*)sender{
    NSUInteger row = [_outlineView rowForView:sender.superview];
    LynCondition *condition = [_outlineView itemAtRow:row];
    if (sender.state != condition.negate) {
        [self setNegate:@{@"condition" : condition, @"negate" : @(sender.state)}];
    }
    [_document.undoManager setActionName:@"Chaning Condition Negation"];
}

#pragma mark Menu Actions

- (void)cut: (id)sender{
    NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
    NSIndexSet *selectedRows = _outlineView.selectedRowIndexes;
    NSMutableArray *conditions = [NSMutableArray arrayWithCapacity:selectedRows.count];
    [selectedRows enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop){
        [conditions addObject:[_outlineView itemAtRow:idx]];
    }];
    if ([conditions indexOfObject:_rootCondition] != NSNotFound) {
        [conditions removeObject:_rootCondition];
    }
    conditions = [NSMutableArray arrayWithArray:[self simplifiedConditionCollection:conditions]];
    if (conditions.count < 1) return;
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:conditions];
    [pasteboard declareTypes:@[LynConditionPBoardType] owner:self];
    [pasteboard setData:data forType:LynConditionPBoardType];
    
    NSMutableArray *parentConditions = [[NSMutableArray alloc] init];
    for (LynCondition *condition in conditions) {
        [parentConditions addObject:condition.parentCondition];
    }
    [self removeSubConditionsFromConditions:@{@"subConditions" : conditions, @"conditions" : parentConditions}];
    [_document.undoManager setActionName:@"Cut"];
}

- (void)copy: (id)sender{
    NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
    NSIndexSet *selectedRows = _outlineView.selectedRowIndexes;
    NSMutableArray *conditions = [NSMutableArray arrayWithCapacity:selectedRows.count];
    [selectedRows enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop){
        [conditions addObject:[_outlineView itemAtRow:idx]];
    }];
    if ([conditions indexOfObject:_rootCondition] != NSNotFound) {
        [conditions removeObject:_rootCondition];
    }
    conditions = [NSMutableArray arrayWithArray:[self simplifiedConditionCollection:conditions]];
    if (conditions.count < 1) return;
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:conditions];
    [pasteboard declareTypes:@[LynConditionPBoardType] owner:self];
    [pasteboard setData:data forType:LynConditionPBoardType];
}

- (void)paste: (id)sender{
    NSPasteboard *pboard = [NSPasteboard generalPasteboard];
    NSData *data = [pboard dataForType:LynConditionPBoardType];
    if (!data) return;
    NSArray *conditions = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    [self addConditions:conditions];
    [_document.undoManager setActionName:@"Paste"];
}

- (void)duplicate: (id)sender{
    NSIndexSet *selectedRows = _outlineView.selectedRowIndexes;
    NSMutableArray *conditions = [NSMutableArray arrayWithCapacity:selectedRows.count];
    [selectedRows enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop){
        [conditions addObject:[_outlineView itemAtRow:idx]];
    }];
    if ([conditions indexOfObject:_rootCondition] != NSNotFound) {
        [conditions removeObject:_rootCondition];
    }
    conditions = [NSMutableArray arrayWithArray:[self simplifiedConditionCollection:conditions]];
    if (conditions.count < 1) return;
    for (NSUInteger i = 0; i < conditions.count; i++) {
        LynCondition *condition = conditions[i];
        conditions[i] = condition.copy;
    }
    [self addConditions:conditions];
    [_document.undoManager setActionName:@"Duplicate"];
}

- (void)delete: (id)sender{
    if (_outlineView.numberOfSelectedRows < 1) return;
    NSIndexSet *indexes = _outlineView.selectedRowIndexes;
    NSMutableArray *subConditions = [[NSMutableArray alloc] init];
    [indexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop){
        LynCondition *condition = [_outlineView itemAtRow:idx];
        if (condition != _rootCondition) {
            [subConditions addObject:condition];
        }
    }];
    subConditions = [NSMutableArray arrayWithArray:[self simplifiedConditionCollection:subConditions]];
    NSMutableArray *conditions = [[NSMutableArray alloc] init];
    for (LynCondition *condition in subConditions) {
        [conditions addObject:condition.parentCondition];
    }
    if (conditions.count < 1) return;
    [self removeSubConditionsFromConditions:@{@"subConditions" : subConditions, @"conditions" : conditions}];
    [_document.undoManager setActionName:@"Delete"];
}

- (void)invertSelection: (id)sender{
    NSMutableIndexSet *indexes = [NSMutableIndexSet indexSetWithIndexesInRange:NSMakeRange(0, _outlineView.numberOfRows)];
    [indexes removeIndexes:_outlineView.selectedRowIndexes];
    [_outlineView selectRowIndexes:indexes byExtendingSelection:NO];
}

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem{
    if (menuItem.action == @selector(cut:)) {
        return (_outlineView.numberOfSelectedRows > 0
                &&(_outlineView.numberOfSelectedRows > 1||[_outlineView itemAtRow:_outlineView.selectedRow] != _rootCondition));
    }else if (menuItem.action == @selector(copy:)) {
        return (_outlineView.numberOfSelectedRows > 0
                &&(_outlineView.numberOfSelectedRows > 1||[_outlineView itemAtRow:_outlineView.selectedRow] != _rootCondition));
    }else if (menuItem.action == @selector(paste:)) {
        NSPasteboard *pboard = [NSPasteboard generalPasteboard];
        return ([pboard dataForType:LynConditionPBoardType] != nil);
    }else if (menuItem.action == @selector(duplicate:)) {
        return (_outlineView.numberOfSelectedRows > 0
                &&(_outlineView.numberOfSelectedRows > 1||[_outlineView itemAtRow:_outlineView.selectedRow] != _rootCondition));
    }else if (menuItem.action == @selector(delete:)) {
        return (_outlineView.numberOfSelectedRows > 0
                &&(_outlineView.numberOfSelectedRows > 1||[_outlineView itemAtRow:_outlineView.selectedRow] != _rootCondition));
    }else if (menuItem.action == @selector(invertSelection:)) {
        return YES;
    }else{
        return NO;
    }
}

@end
