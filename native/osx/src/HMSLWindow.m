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

@implementation HMSLWindow

@synthesize font = _font;
@synthesize fontAttributes = _fontAttributes;
@synthesize graphicsContext = _graphicsContext;

+ (NSMutableDictionary*)windowDictionary {
  static NSMutableDictionary *_windowDictionary = nil;
  if (_windowDictionary == nil) {
    _windowDictionary = [NSMutableDictionary dictionaryWithCapacity:32];
  }
  return _windowDictionary;
}

+ (HMSLWindow*)hmslWindowWithTitle:(NSString *)title frame:(NSRect)frame {
  HMSLWindow* hmslWindow = [[HMSLWindow alloc]
                            initWithContentRect: frame
                            styleMask: NSMiniaturizableWindowMask | NSTitledWindowMask | NSClosableWindowMask
                            backing: NSBackingStoreBuffered
                            defer: YES];
  
  hmslWindow.title = [title retain];
  hmslWindow.contentView = [[HMSLView alloc] init];
  hmslWindow.delegate = [[HMSLWindowDelegate alloc] init];
  [hmslWindow cascadeTopLeftFromPoint:NSZeroPoint];
  [hmslWindow makeKeyAndOrderFront:self];
  
  // Initialize the font-related instance variables
  hmslWindow.font = [NSFont fontWithName:@"Helvetica" size:(CGFloat)14.0];
  hmslWindow.fontAttributes = [NSDictionary dictionaryWithObject:hmslWindow.font forKey:NSFontAttributeName];
  [[HMSLWindow windowDictionary] setObject:hmslWindow forKey:[NSNumber numberWithInteger:hmslWindow.windowNumber]];
  
  return hmslWindow;
}

- (void)close {
  [[HMSLWindow windowDictionary]
   removeObjectForKey:[NSNumber numberWithInteger:self.windowNumber]];
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

@end
