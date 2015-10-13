//
//  HMSLWindow.m
//  HMSL-OSX
//
//  Created by Andrew C Smith on 8/7/15.
//  Copyright (c) 2015 3DO. All rights reserved.
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
                            styleMask: NSMiniaturizableWindowMask | NSTitledWindowMask | NSClosableWindowMask
                            backing: NSBackingStoreBuffered
                            defer: YES];
  
  hmslWindow.title = [title retain];
  
  NSRect viewFrame = frame;
  viewFrame.origin.y += 30;
//  [hmslWindow.contentView addSubview:[[HMSLView alloc] initWithFrame:viewFrame]];
//  [hmslWindow.contentView addSubview:[[HMSLView alloc] initWithFrame:frame] positioned:NSWindowAbove relativeTo:];
  [hmslWindow setContentView:[[HMSLView alloc] initWithFrame:frame]];
  hmslWindow.delegate = [[HMSLWindowDelegate alloc] init];
  [hmslWindow cascadeTopLeftFromPoint:NSZeroPoint];
  [hmslWindow makeKeyAndOrderFront:self];

  [[HMSLWindow windowDictionary] setObject:hmslWindow forKey:[NSNumber numberWithInteger:hmslWindow.windowNumber]];
  
  return hmslWindow;
}

- (void)close {
  [[HMSLWindow windowDictionary]
   removeObjectForKey:[NSNumber numberWithInteger:self.windowNumber]];
  [self.contentView autorelease];
  [self.delegate autorelease];
  [self.title autorelease];
  [super close];
}

// Expects regular points
- (void)drawRectangle: (HMSLRect) rect {
  CGRect drawRect;
  drawRect.origin.x = rect.origin.x; drawRect.origin.y = rect.origin.y;
  drawRect.size.height = rect.size.h; drawRect.size.width = rect.size.w;
  
  CGContextRef drawingContext = self.graphicsContext.graphicsPort;
  CGContextFillRect(drawingContext, drawRect);
  CGContextSynchronize(drawingContext);
  return;
}

- (void)drawLineFrom:(HMSLPoint)start to:(HMSLPoint)end {
  CGContextRef drawingContext = self.graphicsContext.graphicsPort;
  CGContextBeginPath(drawingContext);
  CGContextMoveToPoint(drawingContext, start.x, start.y);
  CGContextAddLineToPoint(drawingContext, end.x, end.y);
  CGContextStrokePath(drawingContext);
  CGContextSynchronize(drawingContext);
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

- (void)hmslBackgroundColor:(const double*)rgba {
  NSColor *bgColor = [NSColor colorWithRed: rgba[0] green:rgba[1] blue:rgba[2] alpha:rgba[3]];
  [self setBackgroundColor:bgColor];
}

- (void)dealloc {
  [_graphicsContext release];
  [super dealloc];
}

@end
