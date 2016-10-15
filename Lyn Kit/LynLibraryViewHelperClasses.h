//
//  LynLibraryViewHelperClasses.h
//  Lyn
//
//  Created by Programmieren on 03.10.13.
//  Copyright (c) 2013 Arne Philipeit Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface LynSmallColorWell : NSColorWell

@end

@interface LynCommandTableCellView : NSTableCellView

@property BOOL mayHideInfoButton;

@property IBOutlet NSButton *infoButton;
@property IBOutlet LynSmallColorWell *colorCodeColorWell;

@end

@interface LynCommandGroupTableRowView : NSTableRowView

@property BOOL drawTopSeparator;
@property BOOL drawBottomSeparator;

@end
