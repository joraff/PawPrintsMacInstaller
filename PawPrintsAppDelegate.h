//
//  PawPrintsAppDelegate.h
//  PawPrints
//
//  Created by Rafferty, Joseph on 1/24/11.
//  Copyright 2011 Baylor University. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PrinterController.h"
#import "PreferenceController.h"

@interface PawPrintsAppDelegate : NSObject <NSApplicationDelegate> {
    NSWindow		*window;
	BOOL			mouseDown;
	IBOutlet NSMenu *statusMenu;
	NSStatusItem	*statusItem;
	
	PrinterController *printerController;
	
	PreferenceController *preferenceController;
}

- (IBAction)goToWebRelease:(id)sender;
- (IBAction)goToCheckBalance:(id)sender;
- (IBAction)goToPawPrintsHome:(id)sender;
- (IBAction)showPreferencePanel:(id)sender;

- (void)statusItemClicked;


@property (assign) IBOutlet NSWindow *window;

@end
