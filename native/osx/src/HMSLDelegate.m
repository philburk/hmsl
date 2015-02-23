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
  NSThread *hmsl = [[NSThread alloc] initWithTarget:hmslRunner selector:@selector(goForth) object:nil];
  [hmsl start];
}

- (void)applicationWillTerminate:(NSNotification *)notification {
  
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication {
  return NO;
}

@end
