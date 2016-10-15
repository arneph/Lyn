//
//  LynPreferencesHelperClasses.h
//  Lyn
//
//  Created by Programmieren on 01.12.13.
//  Copyright (c) 2013 Arne Philipeit Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface LynPreferenecesBooleanValueCell : NSTableCellView

@property IBOutlet NSPopUpButton *boolValueSelector;

@end

@interface LynPreferenecesColorValueCell : NSTableCellView

@property IBOutlet NSColorWell *colorSelector;

@end

@interface LynPreferenecesTableView : NSTableView

@end
