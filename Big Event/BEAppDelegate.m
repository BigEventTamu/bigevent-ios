//  Big Event
//  Created by Jonathan Willing

#import "BEAppDelegate.h"

#import <PonyDebugger/PonyDebugger.h>

@implementation BEAppDelegate

- (void)applicationDidFinishLaunching:(UIApplication *)application {
#ifdef DEBUG
	PDDebugger *debugger = [PDDebugger defaultInstance];
	[debugger enableNetworkTrafficDebugging];
	[debugger forwardAllNetworkTraffic];
	
#if !TARGET_IPHONE_SIMULATOR
	[debugger autoConnect];
#else
	[debugger connectToURL:[NSURL URLWithString:@"ws://localhost:9000/device"]];
#endif
#endif
}

@end
