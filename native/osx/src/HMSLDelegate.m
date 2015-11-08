//
//  HMSLDelegate.m
//  HMSL-OSX
//
//  Created by Andrew C Smith on 2/22/15.
//  Copyright (c) 2015 3DO. All rights reserved.
//

#import "HMSLDelegate.h"
#import "HMSLApplication.h"
#import "HMSLRunner.h"

@interface HMSLDelegate ()

@end

@implementation HMSLDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
  HMSLRunner *hmslRunner = [[HMSLRunner alloc] init];
  [NSThread detachNewThreadSelector:@selector(goForth:) toTarget:hmslRunner withObject:[[NSProcessInfo processInfo] arguments]];
  [NSTimer scheduledTimerWithTimeInterval:0.04 target:NSApp selector:@selector(flushAllWindowDrawing) userInfo:nil repeats:YES];
  
  // Initialize the font-related instance variables
  APP.font = [NSFont fontWithName:@"ChicagoFLF" size:(CGFloat)30.0];
  APP.fontAttributes = [NSMutableDictionary
                        dictionaryWithObjects:@[APP.font, [NSColor whiteColor], [NSColor blackColor]]
                        forKeys:@[NSFontAttributeName, NSBackgroundColorAttributeName, NSForegroundColorAttributeName]];
  APP.windowDictionary = [NSMutableDictionary dictionaryWithCapacity:32];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication {
  return NO;
}

@end
