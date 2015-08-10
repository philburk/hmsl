//
//  HMSLView.m
//  HMSL-OSX
//
//  Created by Andrew C Smith on 2/22/15.
//  Copyright (c) 2015 3DO. All rights reserved.
//

#import "HMSLView.h"

@implementation HMSLView

- (void)mouseDown:(NSEvent *)event {
  gHMSLContext->mouseEvent = event.locationInWindow;
  [hmslEventBuffer addObject:[NSNumber numberWithInt:EV_MOUSE_DOWN]];
}

- (void)mouseUp:(NSEvent *)event {
  gHMSLContext->mouseEvent = event.locationInWindow;
  [hmslEventBuffer addObject:[NSNumber numberWithInt:EV_MOUSE_UP]];
}

- (void)mouseDragged:(NSEvent *)event {
  gHMSLContext->mouseEvent = event.locationInWindow;
  [hmslEventBuffer addObject:[NSNumber numberWithInt:EV_MOUSE_MOVE]];
}

- (void)keyDown:(NSEvent *)event {
  [hmslEventBuffer addObject:[NSNumber numberWithInt:EV_KEY]];
}

- (void)drawRect:(NSRect)dirtyRect {
  [hmslEventBuffer addObject:[NSNumber numberWithInt:EV_REFRESH]];
  [super drawRect:dirtyRect];
}

- (BOOL)isFlipped {
  return YES;
}

@end
