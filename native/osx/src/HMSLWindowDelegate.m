//
//  HMSLWindowDelegate.m
//  HMSL-OSX
//
//  Created by Andrew C Smith on 2/22/15.
//  Copyright (c) 2015 Andrew C Smith. All rights reserved.
//

#import "HMSLWindowDelegate.h"
#import "hmsl.h"

@implementation HMSLWindowDelegate

-(void)windowWillClose:(NSNotification *)notification {
  hmslAddEvent(EV_CLOSE_WINDOW);
  HMSLWindow *window = (HMSLWindow*)[notification object];
}

@end
