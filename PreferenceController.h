//
//  PreferencesController.h
//  PawPrints
//
//  Created by Rafferty, Joseph on 2/7/11.
//  Copyright 2011 Baylor University. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DBPrefsWindowController.h"
#import "PrinterController.h"
#import "PrinterData.h"
#import "Printer.h"


@interface PreferenceController : DBPrefsWindowController {
	PrinterController *printerController;
	
	IBOutlet NSView *generalPrefsView;
	IBOutlet NSView *favoritesPrefsView;
	IBOutlet NSView *autoUpdatePrefsView;
	

	// Favorites pref pane
	IBOutlet NSTextField *selectedPrinterName;
	IBOutlet NSTextField *selectedPrinterLocation;
	IBOutlet NSButton	 *selectedPrinterFavorite;
	
	IBOutlet NSTableView *printerTable;
}

- (id)initWithPrinterController:(id)printerController;

- (int)numberOfRowsInTableView:(NSTableView *)tableView;
- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(int)row;
- (void)tableView:(NSTableView *)tableView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn row:(int)row;
- (BOOL)tableView:(NSTableView*)tableView isGroupRow:(NSInteger)row;
- (BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row;
- (void)tableViewSelectionDidChange:(NSNotification *)aNotification;

- (IBAction)toggleFavorite:(id)sender;

// Loginitem
- (NSURL *)appURL;
- (BOOL)startAtLogin;
- (void)setStartAtLogin:(BOOL)enabled;

// Application version string
- (NSString *)bundleVersionNumber;

@property BOOL startAtLogin;

@end

