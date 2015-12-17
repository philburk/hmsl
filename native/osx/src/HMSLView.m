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
  HMSLPoint loc = [self flipEventCoordinates:event];
  hmslAddMouseEvent(EV_MOUSE_DOWN, loc);
}

- (void)mouseUp:(NSEvent *)event {
  HMSLPoint loc = [self flipEventCoordinates:event];
  hmslAddMouseEvent(EV_MOUSE_UP, loc);
}

- (void)mouseDragged:(NSEvent *)event {
  HMSLPoint loc = [self flipEventCoordinates:event];
  hmslAddMouseEvent(EV_MOUSE_MOVE, loc);
}

- (void)keyDown:(NSEvent *)event {
  hmslAddEvent(EV_KEY);
}

- (void)drawRect:(NSRect)dirtyRect {
  hmslAddEvent(EV_REFRESH);
  [super drawRect:dirtyRect];
}

- (HMSLPoint)flipEventCoordinates:(NSEvent *)event {
  HMSLPoint loc;
  loc.x = event.locationInWindow.x;
  loc.y = self.frame.size.height - event.locationInWindow.y;
  return loc;
}

@end
