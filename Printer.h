//
//  Printer.h
//  PawPrints
//
//  Created by admin on 1/25/11.
//  Copyright 2011 Baylor University. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface Printer : NSCollectionViewItem {
	NSString *queueName;
    NSString *customQueueName;
	NSString *displayName;
	NSString *locationName;
	NSString *lpURI;
	NSString *driver;
	BOOL	  duplex;
	BOOL	  favorite;
	BOOL	  installed;
}

@property (retain) NSString* queueName;
@property (retain) NSString* customQueueName;
@property (retain) NSString* displayName;
@property (retain) NSString* locationName;
@property (retain) NSString* lpURI;
@property (retain) NSString* driver;
@property		   BOOL		 duplex;
@property		   BOOL		 favorite;
@property		   BOOL		 installed;

- (id)   initWithDictionary:(NSDictionary *)p;
- (id)	 initWithPrinter: (Printer*)other;

- (BOOL) install;
- (BOOL) uninstall;
- (BOOL) queryInstalled;



@end
