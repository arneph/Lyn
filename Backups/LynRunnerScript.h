/*
 * LynRunner.h
 */

#import <AppKit/AppKit.h>
#import <ScriptingBridge/ScriptingBridge.h>


@class LynRunnerApplication, LynRunnerDocument, LynRunnerWindow;

enum LynRunnerSaveOptions {
	LynRunnerSaveOptionsYes = 'yes ' /* Save the file. */,
	LynRunnerSaveOptionsNo = 'no  ' /* Do not save the file. */,
	LynRunnerSaveOptionsAsk = 'ask ' /* Ask the user whether or not to save the file. */
};
typedef enum LynRunnerSaveOptions LynRunnerSaveOptions;

enum LynRunnerPrintingErrorHandling {
	LynRunnerPrintingErrorHandlingStandard = 'lwst' /* Standard PostScript error handling */,
	LynRunnerPrintingErrorHandlingDetailed = 'lwdt' /* print a detailed report of PostScript errors */
};
typedef enum LynRunnerPrintingErrorHandling LynRunnerPrintingErrorHandling;



/*
 * Standard Suite
 */

// The application's top-level scripting object.
@interface LynRunnerApplication : SBApplication

- (SBElementArray *) documents;
- (SBElementArray *) windows;

@property (copy, readonly) NSString *name;  // The name of the application.
@property (readonly) BOOL frontmost;  // Is this the active application?
@property (copy, readonly) NSString *version;  // The version number of the application.

- (id) open:(id)x;  // Open a document.
- (void) print:(id)x withProperties:(NSDictionary *)withProperties printDialog:(BOOL)printDialog;  // Print a document.
- (void) quitSaving:(LynRunnerSaveOptions)saving;  // Quit the application.
- (BOOL) exists:(id)x;  // Verify that an object exists.

@end

// A document.
@interface LynRunnerDocument : SBObject

@property (copy, readonly) NSString *name;  // Its name.
@property (readonly) BOOL modified;  // Has it been modified since the last save?
@property (copy, readonly) NSURL *file;  // Its location on disk, if it has one.

- (void) closeSaving:(LynRunnerSaveOptions)saving savingIn:(NSURL *)savingIn;  // Close a document.
- (void) saveIn:(NSURL *)in_ as:(id)as;  // Save a document.
- (void) printWithProperties:(NSDictionary *)withProperties printDialog:(BOOL)printDialog;  // Print a document.
- (void) delete;  // Delete an object.
- (void) duplicateTo:(SBObject *)to withProperties:(NSDictionary *)withProperties;  // Copy an object.
- (void) moveTo:(SBObject *)to;  // Move an object to a new location.

@end

// A window.
@interface LynRunnerWindow : SBObject

@property (copy, readonly) NSString *name;  // The title of the window.
- (NSInteger) id;  // The unique identifier of the window.
@property NSInteger index;  // The index of the window, ordered front to back.
@property NSRect bounds;  // The bounding rectangle of the window.
@property (readonly) BOOL closeable;  // Does the window have a close button?
@property (readonly) BOOL miniaturizable;  // Does the window have a minimize button?
@property BOOL miniaturized;  // Is the window minimized right now?
@property (readonly) BOOL resizable;  // Can the window be resized?
@property BOOL visible;  // Is the window visible right now?
@property (readonly) BOOL zoomable;  // Does the window have a zoom button?
@property BOOL zoomed;  // Is the window zoomed right now?
@property (copy, readonly) LynRunnerDocument *document;  // The document whose contents are displayed in the window.

- (void) closeSaving:(LynRunnerSaveOptions)saving savingIn:(NSURL *)savingIn;  // Close a document.
- (void) saveIn:(NSURL *)in_ as:(id)as;  // Save a document.
- (void) printWithProperties:(NSDictionary *)withProperties printDialog:(BOOL)printDialog;  // Print a document.
- (void) delete;  // Delete an object.
- (void) duplicateTo:(SBObject *)to withProperties:(NSDictionary *)withProperties;  // Copy an object.
- (void) moveTo:(SBObject *)to;  // Move an object to a new location.

@end



/*
 * LynRunner Suite
 */

// LynRunner Application
@interface LynRunnerApplication (LynRunnerSuite)

- (SBElementArray *) documents;

@end

// LynRunner Document
@interface LynRunnerApplication (LynRunnerSuite)

@property (copy, readonly) id project;  // The executed Project.

@end

