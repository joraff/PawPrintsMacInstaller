#import <Cocoa/Cocoa.h>


@interface PMLoginItemController : NSObject {
	//IBOutlet NSButton *btnToggleLoginItem;
}

+ (BOOL) willStartAtLogin:(NSURL *)itemURL;
+ (void) setStartAtLogin:(NSURL *)itemURL enabled:(BOOL)enabled;

@end