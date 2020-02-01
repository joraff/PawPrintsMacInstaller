//
//  PrinterController.h
//  PawPrints
//
//  Created by Rafferty, Joseph on 1/25/11.
//  Copyright 2011 Baylor University. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Printer.h"

@interface PrinterController : NSObject {
	NSMenu * statusMenu;
}

+ (PrinterController *) instance;
+ (id)allocWithZone:(NSZone *)zone;

- (id)initWithMenu:(NSMenu *)m;

- (NSMenu *)getMenu;
- (void)drawMenu;

- (IBAction)toggleInstall:(id)sender;


@end
