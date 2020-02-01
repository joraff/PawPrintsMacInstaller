//
//  Printer.m
//  PawPrints
//
//  Created by admin on 1/25/11.
//  Copyright 2011 Baylor University. All rights reserved.
//

#import "Printer.h"

@implementation Printer

@synthesize queueName;
@synthesize customQueueName;
@synthesize displayName;
@synthesize lpURI;
@synthesize locationName;
@synthesize	driver;
@synthesize duplex;
@synthesize favorite;
@synthesize installed;


- (id)   initWithDictionary:(NSDictionary*) p
{
	self = [super init];
	if ( self ) {
		// queueName is our primary key. Also won't be able to construct a URI without it. MUST BE PRESET!!!
		if (![p valueForKey:@"queueName"] || ![[p valueForKey:@"queueName"] length]) {
			return nil;
		}
        self.queueName = [p valueForKey:@"queueName"];
		self.displayName =  [p valueForKey:@"displayName"]  ? [p valueForKey:@"displayName"]  : @"";
		self.locationName = [p valueForKey:@"locationName"] ? [p valueForKey:@"locationName"] : @"";
		self.lpURI  = [p valueForKey:@"lpURI"]  ? [p valueForKey:@"lpURI"]  : [NSString stringWithFormat:@"lpd://pawprints.baylor.edu/%@", queueName];
		self.driver = [p valueForKey:@"driver"] ? [p valueForKey:@"driver"] : @"";
		self.duplex = [p valueForKey:@"duplex"] ? [[p valueForKey:@"duplex"] integerValue] : NO;
		self.favorite = NO;
		self.installed = [p valueForKey:@"installed"] ? [[p valueForKey:@"installed"] integerValue] : NO;
    }
	return self;
}

- (id) initWithPrinter:(Printer *)other
{
	self = [super init];
	if (other) {
		[self setQueueName: [other queueName]];
		[self setDisplayName: [other displayName]];
		[self setLocationName: [other locationName]];
		[self setLpURI: [other lpURI]];
		[self setDriver: [other driver]];
		[self setDuplex: [other duplex]];
		[self setFavorite: [other favorite]];
        [self setInstalled: [other installed]];
	}
	return self;
}

- (BOOL) install {
	if (![self queryInstalled]) {
		NSFileManager* fileManager = [[NSFileManager alloc] init];
		
		// Define path to the lpadmin utility
		NSString *path = @"/usr/sbin/lpadmin";
		
		NSString *driverPath = nil;
		// Test to see if the discrete driver exists on this system. If not present, use the system bundled generic PCL driver
		if (driver.length > 0 && [fileManager fileExistsAtPath:[NSString stringWithFormat:@"/Library/Printers/PPDs/Contents/Resources/%@", driver]]) {
			driverPath = [NSString stringWithFormat:@"/Library/Printers/PPDs/Contents/Resources/%@", driver];
		} else {
			driverPath = @"/System/Library/Frameworks/ApplicationServices.framework/Versions/A/Frameworks/PrintCore.framework/Resources/Generic.ppd";
		}
		
		// Set the default lpadmin flags
		NSMutableArray *args = [NSMutableArray arrayWithObjects:
								@"-p", queueName,
								@"-v", lpURI,
								@"-D", displayName,
								@"-P", driverPath,
								@"-o", @"printer-is-shared=false",
								@"-E",
								nil ];
		// Set the duplex-specific flags
		// First check if the user even wants duplexing enabled. Then see if the printer is duplex-capable
		if([[NSUserDefaults standardUserDefaults] objectForKey:PMDuplexByDefault] == [NSNumber numberWithBool:YES] && duplex) {
			[args addObjectsFromArray:[NSArray arrayWithObjects:
									   @"-o", @"HPOption_Duplexer=True",
									   @"-o", @"Duplex=DuplexNoTumble",
									   nil]];
		}
		// Install the printer
		NSLog(@"Installing printer: %@", queueName);
		[[NSTask launchedTaskWithLaunchPath:path arguments:args] waitUntilExit];
        
        // Check the user's preferences to see if they want it set as the default
        
	}
    if ([self queryInstalled]) {
        installed = YES;
    }
	return installed;
}

- (BOOL) uninstall {
    NSLog(@"Uninstalling printer: %@", (customQueueName ? customQueueName:queueName));

	NSString *path = @"/usr/sbin/lpadmin";
    
    // Be sure to use the customQueueName in case it differs from our standard
    NSArray *args = [NSArray arrayWithObjects:
                @"-x", (customQueueName ? customQueueName:queueName),
                         nil ];
	
	[[NSTask launchedTaskWithLaunchPath:path arguments:args] waitUntilExit];
	
    if (![self queryInstalled]) {
        installed = NO;
        return true;
    }

	return false;
}

-(BOOL) queryInstalled {
	NSTask *lpstat = [NSTask new];
	[lpstat setLaunchPath:@"/usr/bin/lpstat"];
	[lpstat setArguments:[NSArray arrayWithObject:@"-p"]];
	
	NSPipe *outputPipe = [NSPipe pipe];
	[lpstat setStandardInput:[NSPipe pipe]];
	[lpstat setStandardOutput:outputPipe];
	
	[lpstat launch];
	[lpstat waitUntilExit]; // Alternatively, make it asynchronous.
	[lpstat release];
	
	NSData *outputData = [[outputPipe fileHandleForReading] readDataToEndOfFile];
	NSString *outputString = [[[NSString alloc] initWithData:outputData encoding:NSUTF8StringEncoding] autorelease];
	BOOL found = ([outputString rangeOfString:[self queueName]].location != NSNotFound);
	return found;
}


@end
