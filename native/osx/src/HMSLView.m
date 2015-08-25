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
  gHMSLContext.mouseEvent = [self flipEventCoordinates:event];
  hmslAddEvent(EV_MOUSE_DOWN);
}

- (void)mouseUp:(NSEvent *)event {
  gHMSLContext.mouseEvent = [self flipEventCoordinates:event];
  hmslAddEvent(EV_MOUSE_UP);
}

- (void)mouseDragged:(NSEvent *)event {
  gHMSLContext.mouseEvent = [self flipEventCoordinates:event];
  hmslAddEvent(EV_MOUSE_MOVE);
}

- (void)keyDown:(NSEvent *)event {
  hmslAddEvent(EV_KEY);
}

- (void)drawRect:(NSRect)dirtyRect {
  hmslAddEvent(EV_REFRESH);
  [super drawRect:dirtyRect];
}

- (BOOL)isFlipped {
  return YES;
}

- (HMSLPoint)flipEventCoordinates:(NSEvent *)event {
  HMSLPoint loc;
  loc.x = event.locationInWindow.x;
  loc.y = self.frame.size.height - event.locationInWindow.y;
  return loc;
}

@end
