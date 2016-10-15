//
//  LynInspectorView.h
//  Lyn
//
//  Created by Programmieren on 23.06.13.
//  Copyright (c) 2013 Arne Philipeit Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Lyn Framework/LynCodeObjects.h>
#import "LynUtilityViewDelegate.h"

typedef enum{
    LynInspectorParametersTypeDefineParameters,
    LynInspectorParametersTypeFillParameters
}LynInspectorParametersType;

typedef enum{
    LynInspectorReturnValueTypeDefineReturnValue,
    LynInspectorReturnValueTypeUseReturnValue
}LynInspectorReturnValueType;

@interface LynInspectorView : NSView

@property (readonly) LynOutlineObject *object;
@property (readonly) NSString *objectName;

@property (readonly) BOOL showScopeInspector;
@property (readonly) BOOL showParametersInspector;
@property (readonly) BOOL showConditionsInspector;
@property (readonly) BOOL showReturnValueInspector;

@property (readonly) LynInspectorParametersType parametersType;
@property (readonly) LynInspectorReturnValueType returnValueType;

@property IBOutlet NSDocument *document;
@property IBOutlet id <LynUtilityViewDelegate> delegate;

- (void)setNoObject;
- (void)setObject: (LynOutlineObject*)object;

- (void)selectInspector: (NSUInteger)inspector;

@end
