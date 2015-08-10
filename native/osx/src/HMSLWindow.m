//
//  HMSLWindow.m
//  HMSL-OSX
//
//  Created by Andrew C Smith on 8/7/15.
//  Copyright (c) 2015 3DO. All rights reserved.
//

#import "HMSLWindow.h"

@implementation HMSLWindow

- (void)keyDown:(NSEvent *)event {
  [hmslEventBuffer addObject:[NSNumber numberWithInt:EV_KEY]];
}

@end
