//
//  LynProjectOutlineViewHelperClasses.h
//  Lyn
//
//  Created by Programmieren on 30.11.13.
//  Copyright (c) 2013 Arne Philipeit Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Lyn Framework/LynCodeObjects.h>

@interface LynProjectOutlineOutlineView : NSOutlineView

@property IBOutlet NSMenu *outlineViewContextMenu;
@property IBOutlet NSMenu *projectContextMenu;
@property IBOutlet NSMenu *folderContextMenu;
@property IBOutlet NSMenu *classContextMenu;

@end
