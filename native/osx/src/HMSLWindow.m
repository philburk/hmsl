//
//  HMSLWindow.m
//  HMSL-OSX
//
//  Created by Andrew C Smith on 8/7/15.
//  Copyright (c) 2015 Andrew C Smith. All rights reserved.
//

#import "HMSLWindow.h"
#import "HMSLView.h"
#import "HMSLWindowDelegate.h"
#import "HMSLApplication.h"

@implementation HMSLWindow

+ (NSMutableDictionary*)windowDictionary {
  return APP.windowDictionary;
}

@synthesize graphicsContext = _graphicsContext;

+ (HMSLWindow*)hmslWindowWithTitle:(NSString *)title frame:(NSRect)frame {
  HMSLWindow* hmslWindow = [[HMSLWindow alloc]
                            initWithContentRect: frame
                            styleMask:  NSTitledWindowMask | NSMiniaturizableWindowMask | NSClosableWindowMask
                            backing: NSBackingStoreBuffered
                            defer: YES];
  hmslWindow.title = title;
  NSView *titleBarView = [[NSView alloc] init];
  [[[hmslWindow contentView] superview] addSubview:titleBarView];
  /*
  NSRect viewFrame = frame;
  viewFrame.origin.y += 30;
  [hmslWindow.contentView addSubview:[[HMSLView alloc] initWithFrame:viewFrame]];
   */

  hmslWindow.contentView = [[HMSLView alloc] initWithFrame:frame];
  hmslWindow.delegate = [[HMSLWindowDelegate alloc] init];
  
  [hmslWindow cascadeTopLeftFromPoint:NSZeroPoint];
  [hmslWindow makeKeyAndOrderFront:hmslWindow];
  [[HMSLWindow windowDictionary] setObject:hmslWindow forKey:[NSNumber numberWithInteger:hmslWindow.windowNumber]];
  
  NSGraphicsContext *currentContext = [NSGraphicsContext graphicsContextWithWindow:hmslWindow];
  if (currentContext != nil) {
    NSGraphicsContext.currentContext = currentContext;
    hmslWindow.graphicsContext = currentContext;
    hmslWindow.graphicsContext.shouldAntialias = NO;
  } else {
    NSLog(@"Unable to initialize context");
  }
  return hmslWindow;
}

- (BOOL)canBecomeKeyWindow {
  return YES;
}

- (BOOL)canBecomeMainWindow {
  return YES;
}

- (void)close {
  [[HMSLWindow windowDictionary]
   removeObjectForKey:[NSNumber numberWithInteger:self.windowNumber]];
  [self.graphicsContext release];
  [super close];
}

// Expects regular points
- (void)drawRectangle: (HMSLRect) rect {
  CGRect drawRect;
  drawRect.origin.x = rect.origin.x; drawRect.origin.y = rect.origin.y;
  drawRect.size.height = rect.size.h; drawRect.size.width = rect.size.w;
  
  CGContextRef drawingContext = self.graphicsContext.graphicsPort;
  CGContextFillRect(drawingContext, drawRect);
  return;
}

- (void)drawLineFrom:(HMSLPoint)start to:(HMSLPoint)end {
  CGContextRef drawingContext = self.graphicsContext.graphicsPort;
  CGContextBeginPath(drawingContext);
  CGContextMoveToPoint(drawingContext, start.x, start.y);
  CGContextAddLineToPoint(drawingContext, end.x, end.y);
  CGContextStrokePath(drawingContext);
  return;
}

- (void) drawText: (NSString*) text atPoint: (NSPoint) point {
  [text drawAtPoint:point withAttributes:APP.fontAttributes];
}

- (void)keyDown:(NSEvent *)event {
  hmslAddEvent(EV_KEY);
}

- (void)flushCurrentContext {
  [self.graphicsContext flushGraphics];
}

- (void)hmslDrawingMode:(int32_t)mode {
  switch (mode) {
    case 0:
      CGContextSetBlendMode(self.graphicsContext.graphicsPort, kCGBlendModeNormal);
      break;
    case 1:
      CGContextSetBlendMode(self.graphicsContext.graphicsPort, kCGBlendModeExclusion);
      break;
  }
}

- (void)hmslDrawingColor:(const double*)rgba {
  CGContextRef context = self.graphicsContext.graphicsPort;
  NSColor *newColor = [NSColor colorWithRed:rgba[0] green:rgba[1] blue:rgba[2] alpha:rgba[3]];
  [newColor set];
  [APP.fontAttributes setObject:newColor forKey:NSForegroundColorAttributeName];
  CGContextSetRGBFillColor(context, rgba[0], rgba[1], rgba[2], rgba[3]);
  CGContextSetRGBStrokeColor(context, rgba[0], rgba[1], rgba[2], rgba[3]);
}

- (void)hmslBackgroundColor:(const double*)rgba {
  NSColor *bgColor = [NSColor colorWithRed: rgba[0] green:rgba[1] blue:rgba[2] alpha:rgba[3]];
  [self setBackgroundColor:bgColor];
}

@end
