//
//  PrinterData.m
//  PawPrints
//
//  Created by Rafferty, Joseph on 2/7/11.
//  Copyright 2011 Baylor University. All rights reserved.
//

#import "PrinterData.h"

static PrinterData *instance = nil;

@implementation PrinterData

#pragma mark -
#pragma mark class instance methods

#pragma mark -
#pragma mark Singleton methods


// Start singleton mumbo jumbo

+ (PrinterData*) instance
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

- (oneway void)release
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

// End singleton mumbo jumbo

- (id) init
{
	if (![super init]) {
		return nil;
	}
	[self populateFromPropertyList];
	
	return self;
}

// Populates our data instance with known printers from Printers.plist. Checks if they're installed or favorites (stored in user prefs) and falgs then accordingly.

- (void)populateFromPropertyList
{
	NSString *nodePath = [[NSBundle mainBundle] pathForResource:@"Printers" ofType:@"plist"];
	NSDictionary *printerDict = [NSDictionary dictionaryWithContentsOfFile:nodePath];
	
	// Get the user defaults favorite printers
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	NSArray *favorites = [prefs arrayForKey:@"favoritePrinters"];
    NSArray *installedPrinters = [self installedPrinters];
    
    printers = [[NSMutableArray alloc] initWithCapacity:0];
    
	// Populate the printer dictionary with Printer objects
	if (printerDict) {		
		for (id key in printerDict) {
            
			Printer *p = [Printer alloc];
			[p initWithDictionary:[printerDict objectForKey:key]];
            
            // p1 will be nil if the object didn't init properly
			if (p) {
				// Check if the printer is currently already installed
                for(NSDictionary *installedPrinter in installedPrinters) {
                    // Queue names could vary widely, so check the URI of the printer if it contains our queue identifier
                    if ([[installedPrinter valueForKey:@"printerURI"] rangeOfString:[p valueForKey:@"queueName"] options:(NSCaseInsensitiveSearch)].location != NSNotFound) {
                        // If found, mark the printer as installed
                        [p setInstalled:YES];
                        // Also update the customQueueName so we can remove it if the user requests
                        [p setCustomQueueName:[installedPrinter valueForKey:@"printerID"]];
                    }
                }
                
                
                if ([favorites containsObject:[p queueName]]) {
                    [p setFavorite:1];
                }
                     
                [printers addObject:p];
			}
		}
	}
}

- (NSMutableArray*)printers {
	return printers;
}

- (NSArray*)sortedPrinters {
    NSSortDescriptor *favoriteDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"favorite"
																		ascending:NO
																		 selector:@selector(compare:)] autorelease];
	
	NSSortDescriptor *nameDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"displayName"
																	ascending:YES
																	 selector:@selector(localizedCaseInsensitiveCompare:)] autorelease];
	NSArray *descriptors = [NSArray arrayWithObjects:favoriteDescriptor, nameDescriptor, nil];
	NSArray *sortedArray = [printers sortedArrayUsingDescriptors:descriptors];
	return sortedArray;
}
	
	
- (void)setPrinters:(NSMutableArray *)a
{
	if (a == printers) {
		return;
	}
	[a retain];
	[printers release];
	printers = a;
}

- (NSArray *)otherPrinters
{
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"favorite == NO"];
	NSArray * filteredPrinters = [printers filteredArrayUsingPredicate:predicate];
	NSSortDescriptor *nameDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"displayName"
																	ascending:YES
																	 selector:@selector(localizedCaseInsensitiveCompare:)] autorelease];
	return [filteredPrinters sortedArrayUsingDescriptors:[NSArray arrayWithObject:nameDescriptor]];
}


// Returns array of currently installed printers. Useful for "checking" printers that were not installed by this app, or from a previous instance. Also useful for verifying an install - faster and easier than using lpstat & parsing the return.
// Rewritten to use CorePrinting

- (NSArray *)installedPrinters
{
    //  Make an array to hold our printer info dictionaries
    NSMutableArray *printerInfoArray = [NSMutableArray array];
    //  First, grab a list of available printers
    CFArrayRef printerList;
    // Don't forget to check for errors in production code!
    PMServerCreatePrinterList(kPMServerLocal, &printerList);
    
    UInt32 numberOfPrinters = CFArrayGetCount(printerList);
    UInt32 printerIndex;
    
    //  For each printer in the list
    for(printerIndex = 0; printerIndex < numberOfPrinters; printerIndex++)
    {
        //  Make a dictionary to hold our printer info
        NSMutableDictionary *printerInfo = [NSMutableDictionary dictionary];
        
        //  Get a reference to the printer
        PMPrinter printer =(PMPrinter)CFArrayGetValueAtIndex(printerList, printerIndex);
        
        //  Find out its name
        CFStringRef printerName = PMPrinterGetName(printer);
        [printerInfo setObject:(id)printerName forKey:@"printerName"];
        
        //  Note the Printer Name is different from the queue name.
        CFStringRef printerID = PMPrinterGetID(printer);
        [printerInfo setObject:(id)printerID forKey:@"printerID"];
        
        // Get the URI (Uniform Resource Identifier).
        // A URI is much like an URL, as it defines the location and protocol of a device.
        CFURLRef printerURI;
        int result = PMPrinterCopyDeviceURI(printer, (CFURLRef *)&printerURI);
        
        if (result == 0) {
            [printerInfo setObject:(NSString*)CFURLGetString(printerURI) forKey:@"printerURI"];
            CFRelease(printerURI);
            // Add our printer info dictionary to the array
            [printerInfoArray addObject:printerInfo];
        }
        
        
        
    }
    CFRelease(printerList);
    return printerInfoArray;
}

- (NSArray *)favoritePrinters
{
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"favorite == YES"];
	NSArray * filteredPrinters = [printers filteredArrayUsingPredicate:predicate];
	NSSortDescriptor *nameDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"displayName"
																	ascending:YES
																	 selector:@selector(localizedCaseInsensitiveCompare:)] autorelease];
	return [filteredPrinters sortedArrayUsingDescriptors:[NSArray arrayWithObject:nameDescriptor]];
}

- (void)updateInstalledStatus
{
    NSArray *installedPrinters = [self installedPrinters];
    
    for(Printer *p in printers)
    {
        p.installed = NO;
        for(NSDictionary *installedPrinter in installedPrinters) {
            if ([[installedPrinter valueForKey:@"printerURI"] isEqualToString:[p valueForKey:@"lpURI"]]) {
                p.installed = YES;
            }
        } 
    }
}
@end
