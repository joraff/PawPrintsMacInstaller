//
//  PrinterController.m
//  PawPrints
//
//  Created by Rafferty, Joseph on 1/25/11.
//  Copyright 2011 Baylor University. All rights reserved.
//

#import "PrinterController.h"
#import "PrinterData.h"

static PrinterController *instance = nil;

@implementation PrinterController


- (id) initWithMenu:(NSMenu *)m
{	
	if(![super init])
		return nil;
    
    statusMenu = m;
    return self;
}

+ (PrinterController*) instance
{
	@synchronized(self)
	{
		if (instance == nil) {
			[[self alloc] init];
		}
	}
	return instance;
}

+ (id)allocWithZone:(NSZone *)zone
{
	@synchronized(self)
	{
		if (instance == nil) {
			instance = [super allocWithZone:zone];
			return instance; // assignment and return on first allocation
		}
	}
	return instance; // on subsequent allocation attempts return nil
}

- (id)copyWithZone:(NSZone *)zone
{
	return self;
}

- (id)retain
{
	return self;
}

- (void)release
{
	// do nothing
}

- (id)autorelease
{
	return self;
}

- (NSUInteger)retainCount
{
	return NSUIntegerMax; // Definitely not zero
}


- (void) drawMenu
{
	NSMenuItem *tempMenuItem = nil;

	PrinterData * printerData = [PrinterData instance];

    [printerData updateInstalledStatus];
    
	NSArray * otherPrinters = [printerData otherPrinters];

	NSArray * favoritePrinters = [printerData favoritePrinters];
	

	// Remove all printers and placeholders
	if ([[printerData printers] count]) {
		for(Printer *p in [printerData printers]) {
			if ([statusMenu indexOfItemWithTitle:[p displayName]] > 0) {
				[statusMenu removeItem:[statusMenu itemWithTitle:[p displayName]]];
			}
		}
	} 
	if ([statusMenu indexOfItemWithTitle:@"None added yet"] > 0) {
		[statusMenu removeItemAtIndex:[statusMenu indexOfItemWithTitle:@"None added yet"]];
	}

	// Remove the "More Printers separator"
	if ([statusMenu indexOfItemWithTitle:@"More Printers Separator"] > 0) {
		[statusMenu removeItemAtIndex:[statusMenu indexOfItemWithTitle:@"More Printers Separator"]];
	}
	
	// Remove the "More Printers submenu"
	if ([statusMenu indexOfItemWithTitle:@"More Printers"] > 0) {
		[statusMenu removeItemAtIndex:[statusMenu indexOfItemWithTitle:@"More Printers"]];
	}

	if ([otherPrinters count]) {
		NSMenuItem* tempSubMenuItem = [[NSMenuItem alloc] initWithTitle:@"More Printers" action:nil keyEquivalent:@""];
		[tempSubMenuItem setTitle:@"More Printers"];
		NSMenu * tempSubMenu = [[NSMenu alloc] init];
		int subMenuIndex = 0;
		for (id p in otherPrinters) {
			tempMenuItem = [[NSMenuItem alloc] initWithTitle:[p displayName] action:nil keyEquivalent:@""];
			if ([p installed]) {
				[tempMenuItem setState:1];
			}
			[tempMenuItem setToolTip:[NSString stringWithFormat:@"Location: %@", [p locationName]]];
			[tempMenuItem setAction:@selector(toggleInstall:)];
			[tempMenuItem setTarget:self];
			[tempMenuItem setRepresentedObject:p];
			[tempMenuItem setTitle:[p displayName]];
			[tempSubMenu insertItem:tempMenuItem atIndex:subMenuIndex];
			subMenuIndex++;
		}
		
		if ([otherPrinters count] > 0) {
			[tempSubMenuItem setSubmenu:tempSubMenu];
			NSMenuItem *separator = [NSMenuItem separatorItem];
			[separator setTitle:@"More Printers Separator"];
			[statusMenu insertItem:separator atIndex:[statusMenu indexOfItemWithTitle:@"bottomDivider"]];
			[statusMenu insertItem:tempSubMenuItem atIndex:[statusMenu indexOfItemWithTitle:@"bottomDivider"]];
		}
	}
		
	// Get index range for our favorite printers
	int startOfFavorite = [statusMenu indexOfItemWithTitle:@"Favorites"] + 1;

	// Now draw the new favorites
	if ([favoritePrinters count]) {
		for (id p in favoritePrinters) {
			tempMenuItem = [[NSMenuItem alloc] initWithTitle:[p displayName] action:nil keyEquivalent:@""];
			[tempMenuItem setIndentationLevel:1];
			if ([p installed]) {
				[tempMenuItem setState:1];
			}
			[tempMenuItem setToolTip:[NSString stringWithFormat:@"Location: %@", [p locationName]]];
			[tempMenuItem setAction:@selector(toggleInstall:)];
			[tempMenuItem setTarget:self];
			[tempMenuItem setRepresentedObject:p];
			[tempMenuItem setTitle:[p displayName]];
			[statusMenu insertItem:tempMenuItem atIndex:startOfFavorite];
			startOfFavorite++;
		}
	} else {
		tempMenuItem = [[NSMenuItem alloc] initWithTitle:@"None added yet" action:nil keyEquivalent:@""];
		[tempMenuItem setIndentationLevel:1];
		[statusMenu insertItem:tempMenuItem atIndex:startOfFavorite];
	}
}

-(NSMenu *)getMenu
{
    [self drawMenu];
    return statusMenu;
}


-(IBAction)toggleInstall:(id)sender {
	id printer = [sender representedObject];
	if ([sender state]) {
		if ([printer uninstall]) {
			[sender setState:0];
		} else {
			NSRunAlertPanel( @"Error", [NSString stringWithFormat:@"There was an error trying to uninstall the %@ printer.", [printer queueName]], @"OK", nil, nil );
		}

		
	} else {
		if ([printer install]) {
			[sender setState:1];
		} else {
			NSRunAlertPanel( @"Error", [NSString stringWithFormat:@"There was an error trying to install the %@ printer.", [printer queueName]], @"OK", nil, nil );
		}
	}
}
	
	


@end
