//
//  PawPrintsAppDelegate.m
//  PawPrints
//
//  Created by Rafferty, Joseph on 1/24/11.
//  Copyright 2011 Baylor University. All rights reserved.
//

#import "PawPrintsAppDelegate.h"
#import "PreferenceController.h"
#import "Printer.h"
#import "PrinterData.h"
#import "PrinterController.h"
#import "PMLoginItemController.h"

@implementation PawPrintsAppDelegate

@synthesize window;

+ (void)initialize
{
		// Create a dictionary
	NSMutableDictionary *defaultValues = [NSMutableDictionary dictionary];
	
		// Put defaults in the dictionary
	[defaultValues setObject:[NSNumber numberWithBool:YES] forKey:PMDuplexByDefault];
	[defaultValues setObject:[NSNumber numberWithBool:YES] forKey:PMNewPrintersAlwaysDefault];
    [defaultValues setObject:[NSNumber numberWithBool:YES] forKey:PMFirstLaunch];
		// Register the defaults
	[[NSUserDefaults standardUserDefaults] registerDefaults:defaultValues];
	
		// Load the printer data to prevent UI blocking if they click the menu quickly
	[PrinterData instance];
}

	
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // If this is the first launch, make sure to install the login item    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:PMFirstLaunch])
    {
        NSAlert *alert = [NSAlert alertWithMessageText:@"Do you want the PawPrints printer app to start automatically when you login to your computer?" defaultButton:@"Yes" alternateButton:@"No" otherButton:nil informativeTextWithFormat:@""];
        
        if ([alert runModal] == NSAlertDefaultReturn) {
            [PMLoginItemController setStartAtLogin:[[PreferenceController alloc] appURL] enabled:YES];
        }
    }
}

-(void)awakeFromNib{
		
	NSImage *image = [NSImage imageNamed:@"printer.png"];
	NSImage *altimage = [NSImage imageNamed:@"printer-white.png"];
    statusItem = [[[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength] retain];
	[statusItem setImage:image];
	[statusItem setAlternateImage:altimage];
    [statusItem setHighlightMode:YES];
	
	printerController = [[PrinterController alloc] initWithMenu:statusMenu];

	[statusItem setAction:@selector(statusItemClicked)];
	
	// Set up the prefs controller
	preferenceController = [[PreferenceController alloc] initWithPrinterController:printerController];
}

-(void)statusItemClicked
{
    [statusItem popUpStatusItemMenu:nil];
    NSMenu *tempMenu = [printerController getMenu];
    [statusItem popUpStatusItemMenu:tempMenu];
}


-(IBAction)goToWebRelease:(id)sender {
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://www.baylor.edu/pawprints/release"]];
}

-(IBAction)goToCheckBalance:(id)sender {
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://www.baylor.edu/pawprints/balance"]];
}

-(IBAction)goToPawPrintsHome:(id)sender {
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://www.baylor.edu/pawprints"]];
}
-(IBAction)showPreferencePanel:(id)sender {
	[[PreferenceController sharedPrefsWindowController] showWindow:nil];
	[NSApp activateIgnoringOtherApps:YES];	
}

-(void) applicationWillTerminate:(NSNotification *)notification 
{
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:PMFirstLaunch];
    [[NSUserDefaults standardUserDefaults] synchronize];

}

- (void)dealloc
{
	[super dealloc];
}

@end
