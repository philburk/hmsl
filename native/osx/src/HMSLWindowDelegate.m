//
//  HMSLWindowDelegate.m
//  HMSL-OSX
//
//  Created by Andrew C Smith on 2/22/15.
//  Copyright (c) 2015 3DO. All rights reserved.
//

#import "HMSLWindowDelegate.h"

@implementation HMSLWindowDelegate

-(void)windowWillClose:(NSNotification *)notification {
  [hmslEventBuffer addObject:[NSNumber numberWithInt:EV_CLOSE_WINDOW]];
}

@end
