//
//  PrinterData.h
//  PawPrints
//
//  Created by Rafferty, Joseph on 2/7/11.
//  Copyright 2011 Baylor University. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Printer.h"

@interface PrinterData : NSObject {
	NSMutableArray * printers;
}

+ (PrinterData *) instance;
+ (id)allocWithZone:(NSZone *)zone;

- (id) init;
- (NSMutableArray *)printers;
- (NSArray *)sortedPrinters;
- (void)setPrinters:(NSMutableArray *)a;
- (void)populateFromPropertyList;
- (NSArray *)otherPrinters;
- (NSArray *)installedPrinters;
- (NSArray *)favoritePrinters;
- (void)updateInstalledStatus;

   

@end
