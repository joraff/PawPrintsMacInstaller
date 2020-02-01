//
//  PreferencesController.m
//  PawPrints
//
//  Created by Rafferty, Joseph on 2/7/11.
//  Copyright 2011 Baylor University. All rights reserved.
//

#import "PreferenceController.h"
#import "PrinterData.h"
#import "PMLoginItemController.h"

@implementation PreferenceController


- (id)initWithPrinterController:(id)pc
{
	if(![super initWithWindowNibName:@"Preferences"])
		return nil;
	[printerTable setSelectionHighlightStyle:NSTableViewSelectionHighlightStyleSourceList];
	printerController = pc;
	return self;
}

- (void)awakeFromNib
{
	NSInteger row = 0;
	if ([[[PrinterData instance] favoritePrinters] count]) {
		row = 1;
	} else {
		row = 2;
	}
	[printerTable selectRowIndexes:[NSIndexSet indexSetWithIndex:row] byExtendingSelection:NO];
}

- (void)windowDidLoad {
	[super windowDidLoad];
	//[openAtLogin setState:[self appDoesOpenAtLogin]];
}

- (void)setupToolbar
{
	[self addView:generalPrefsView label:@"General" image:[NSImage imageNamed:@"General"]];
	[self addView:favoritesPrefsView label:@"Favorites" image:[NSImage imageNamed:@"FavoritePrinter"]];
	[self addView:autoUpdatePrefsView label:@"Auto Update" image:[NSImage imageNamed:@"Updates"]];
}

- (int)numberOfRowsInTableView:(NSTableView *)tableView
{
	return [[[PrinterData instance] printers] count] +2;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(int)row
{
	
	NSString *identifier = [tableColumn identifier];
	if (row == 0)
		return @"Favorite Printers";
	if (row <= [[[PrinterData instance] favoritePrinters] count])
		return [NSString stringWithFormat:@"  %@", [[[[PrinterData instance] sortedPrinters] objectAtIndex:row-1] valueForKey:identifier]];
	if (row == [[[PrinterData instance] favoritePrinters] count]+1)
		return @"More Printers";
	if (row > [[[PrinterData instance] favoritePrinters] count]+1)
		return [NSString stringWithFormat:@"  %@", [[[[PrinterData instance] sortedPrinters] objectAtIndex:row-2] valueForKey:identifier]];

	return nil;
}

- (void)tableView:(NSTableView *)tableView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn row:(int)row
{
	if (row == 0 || row == [[[PrinterData instance] favoritePrinters] count]+1) {
		// group cell
	} else {
		// normal cell
	}

}

- (BOOL)tableView:(NSTableView*)tableView isGroupRow:(NSInteger)row
{
	if (row == 0 || row == [[[PrinterData instance] favoritePrinters] count]+1)
		return YES;
	return NO;
}

- (BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row
{
	if (row == 0 || row == [[[PrinterData instance] favoritePrinters] count]+1)
		return NO;
	return YES;
}

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
	NSInteger row = [printerTable selectedRow];
	if (row <= [[[PrinterData instance] favoritePrinters] count] && [[[PrinterData instance] favoritePrinters] count]) {
		row -= 1;
	} else {
		row -= 2;
	}


	if (row >= 0) {
		Printer* selectedPrinter = [[[PrinterData instance] sortedPrinters] objectAtIndex:row];
		[selectedPrinterName setStringValue:[selectedPrinter displayName]];
		[selectedPrinterLocation setStringValue:[selectedPrinter locationName]];
		[selectedPrinterFavorite setIntegerValue:[selectedPrinter favorite]];
	}
}

- (IBAction)toggleFavorite:(id)sender {
	PrinterData *printerData = [PrinterData instance];
	NSInteger row = [printerTable selectedRow];
	if (row <= [[printerData favoritePrinters] count] && [[printerData favoritePrinters] count]) {
		row -= 1;
	} else {
		row -= 2;
	}
	if (row >= 0) {
			// User defaults
		NSUserDefaults* prefs = [NSUserDefaults standardUserDefaults];
		NSMutableArray *favoritePrinters = [NSMutableArray arrayWithArray:[prefs objectForKey:@"favoritePrinters"]];

		Printer* selectedPrinter = [[printerData sortedPrinters] objectAtIndex:row];
		if ([sender state] == YES) {
			[selectedPrinter setFavorite:YES];
			row = [[printerData sortedPrinters] indexOfObject:selectedPrinter] + 1;
			// Prevent duplicates
			if (![favoritePrinters containsObject:[selectedPrinter queueName]]) {
				[favoritePrinters addObject:[selectedPrinter queueName]];
			}
		} else {
			[selectedPrinter setFavorite:NO];
			row = [[printerData sortedPrinters] indexOfObject:selectedPrinter] + 2;
			// Prevent removing an object that doesn't exist.			
			if ([favoritePrinters containsObject:[selectedPrinter queueName]]) {
				[favoritePrinters removeObject:[selectedPrinter queueName]];
			}
		}
		[prefs setObject:favoritePrinters forKey:@"favoritePrinters"];
		[prefs synchronize];

	}
	
	[printerTable reloadData];
	[printerTable selectRowIndexes:[NSIndexSet indexSetWithIndex:row] byExtendingSelection:NO];
	
	printerController = [[PrinterController alloc] init];
	[printerController drawMenu];
}

- (NSURL *)appURL
{
    return [NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]];
}

- (BOOL)startAtLogin
{
    return [PMLoginItemController willStartAtLogin:[self appURL]];
}

- (void)setStartAtLogin:(BOOL)enabled
{
    [self willChangeValueForKey:@"startAtLogin"];
    [PMLoginItemController setStartAtLogin:[self appURL] enabled:enabled];
    [self didChangeValueForKey:@"startAtLogin"];
}

- (NSString *) bundleVersionNumber
{
    NSString *buildNum = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    NSString *version  = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    return [NSString stringWithFormat:@"Current Version: %@ (%@)", version, buildNum];
}

@end
