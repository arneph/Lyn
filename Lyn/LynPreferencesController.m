//
//  LynPreferencesWindowController.m
//  Lyn
//
//  Created by Programmieren on 01.12.13.
//  Copyright (c) 2013 Arne Philipeit Software. All rights reserved.
//

#import "LynPreferencesController.h"
#import "LynPreferencesHelperClasses.h"

@interface LynPreferencesController () <NSTableViewDataSource, NSTableViewDelegate>

@property IBOutlet NSToolbar *toolbar;
@property IBOutlet NSTabView *tabView;

@property IBOutlet NSTableView *tableView;

- (IBAction)booleanValueChanged:(id)sender;
- (IBAction)integerValueChanged:(id)sender;
- (IBAction)stringValueChanged:(id)sender;
- (IBAction)colorValueChanged:(id)sender;

@end

@implementation LynPreferencesController

- (void)showWindow:(id)sender{
    if (!self.window) {
        [[NSBundle bundleForClass:[self class]]  loadNibNamed:@"LynPreferencesWindow"
                                                        owner:self
                                              topLevelObjects:nil];
    }
    [super showWindow:sender];
}

- (void)awakeFromNib{
    if (self.window) {
        [_toolbar setSelectedItemIdentifier:@"Advanced"];
        [_tabView selectTabViewItemWithIdentifier:@"Advanced"];
    }
}


#pragma mark Notifications

- (void)beginObserving{
    [NotificationCenter addObserver:self
                           selector:@selector(settingChanged:)
                               name:LynSettingChangedNotification
                             object:nil];
}

- (void)settingChanged: (NSNotification*)notification{
    if (_tableView) {
        [_tableView reloadData];
    }
}

#pragma mark TableView Datasource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    return [LynGeneral settings].count;
}

#pragma mark TableView Delegate

- (NSView *)tableView:(NSTableView *)tableView
   viewForTableColumn:(NSTableColumn *)tableColumn
                  row:(NSInteger)row{
    LynSetting *setting = [LynGeneral settings][row];
    if ([tableColumn.identifier isEqualToString:@"Key"]) {
        NSTableCellView *cellView = [_tableView makeViewWithIdentifier:@"KeyCell"
                                                                 owner:self];
        cellView.textField.stringValue = setting.key;
        return cellView;
    }else if ([tableColumn.identifier isEqualToString:@"Type"]) {
        NSTableCellView *cellView = [_tableView makeViewWithIdentifier:@"TypeCell"
                                                                 owner:self];
        if (setting.type == LynSettingTypeBoolean) {
            cellView.textField.stringValue = @"Boolean";
        }else if (setting.type == LynSettingTypeInteger) {
            cellView.textField.stringValue = @"Integer";
        }else if(setting.type == LynSettingTypeString) {
            cellView.textField.stringValue = @"String";
        }else if (setting.type == LynSettingTypeColor) {
            cellView.textField.stringValue = @"Color";
        }
        return cellView;
    }else if ([tableColumn.identifier isEqualToString:@"Value"]) {
        if (setting.type == LynSettingTypeBoolean) {
            LynPreferenecesBooleanValueCell *cellView = [_tableView makeViewWithIdentifier:@"BooleanValueCell"
                                                                                     owner:self];
            [cellView.boolValueSelector selectItemAtIndex:((NSNumber*)setting.value).unsignedIntegerValue];
            return cellView;
        }else if (setting.type == LynSettingTypeInteger) {
            NSTableCellView *cellView = [_tableView makeViewWithIdentifier:@"IntegerValueCell"
                                                                     owner:self];
            cellView.textField.objectValue = setting.value;
            return cellView;
        }else if(setting.type == LynSettingTypeString) {
            NSTableCellView *cellView = [_tableView makeViewWithIdentifier:@"StringValueCell"
                                                                     owner:self];
            cellView.textField.stringValue = setting.value;
            return cellView;
        }else if (setting.type == LynSettingTypeColor) {
            LynPreferenecesColorValueCell *cellView = [_tableView makeViewWithIdentifier:@"ColorValueCell"
                                                                                   owner:self];
            NSArray *value = setting.value;
            NSNumber *red = value[0];
            NSNumber *green = value[1];
            NSNumber *blue = value[2];
            NSColor *color = [NSColor colorWithCalibratedRed:red.unsignedIntegerValue / 255.0
                                                       green:green.unsignedIntegerValue / 255.0
                                                        blue:blue.unsignedIntegerValue / 255.0
                                                       alpha:1];
            cellView.colorSelector.color = color;
            return cellView;
        }
    }
    return nil;
}

- (void)booleanValueChanged:(NSPopUpButton*)sender{
    NSUInteger row = [_tableView rowForView:sender.superview];
    LynSetting *setting = [LynGeneral settings][row];
    if (setting.type != LynSettingTypeBoolean) return;
    setting.value = @(sender.indexOfSelectedItem);
    [NotificationCenter postNotificationName:LynSettingChangedNotification
                                      object:setting
                                    userInfo:@{@"key" : setting.key}];
    [_tableView reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:row]
                          columnIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 3)]];
}

- (void)integerValueChanged:(NSTextField*)sender{
    NSUInteger row = [_tableView rowForView:sender.superview];
    LynSetting *setting = [LynGeneral settings][row];
    if (setting.type != LynSettingTypeInteger) return;
    setting.value = sender.objectValue;
    [NotificationCenter postNotificationName:LynSettingChangedNotification
                                      object:setting
                                    userInfo:@{@"key" : setting.key}];
    [_tableView reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:row]
                          columnIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 3)]];
}

- (void)stringValueChanged:(NSTextField*)sender{
    NSUInteger row = [_tableView rowForView:sender.superview];
    LynSetting *setting = [LynGeneral settings][row];
    if (setting.type != LynSettingTypeString) return;
    setting.value = sender.stringValue;
    [NotificationCenter postNotificationName:LynSettingChangedNotification
                                      object:setting
                                    userInfo:@{@"key" : setting.key}];
    [_tableView reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:row]
                          columnIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 3)]];
}

- (void)colorValueChanged:(NSColorWell*)sender{
    NSUInteger row = [_tableView rowForView:sender.superview];
    LynSetting *setting = [LynGeneral settings][row];
    if (setting.type != LynSettingTypeColor) return;
    NSColor *color = sender.color;
    NSUInteger red = color.redComponent * 255;
    NSUInteger green = color.greenComponent * 255;
    NSUInteger blue = color.blueComponent * 255;
    setting.value = @[@(red), @(green), @(blue)];
    [NotificationCenter postNotificationName:LynSettingChangedNotification
                                      object:setting
                                    userInfo:@{@"key" : setting.key}];
    [_tableView reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:row]
                          columnIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 3)]];
}

@end
