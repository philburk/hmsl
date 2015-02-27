//
//  hmsl_gui.m
//  HMSL-OSX
//
//  Created by Andrew C Smith on 1/27/15.
//  Copyright (c) 2015 Andrew C Smith. All rights reserved.
//

#import "hmsl.h"
#import "hmsl_gui.h"
#import "pf_all.h"
#import "HMSLDelegate.h"
#import "HMSLWindowDelegate.h"
#import "HMSLView.h"

#import <Cocoa/Cocoa.h>

typedef struct HMSLContext {
  NSPoint currentPoint;
} HMSLContext;

NSArray *hmslColors;
HMSLContext *gHMSLContext;

int32_t hostInit( void ) {
  hmslWindowArray = [NSMutableArray arrayWithCapacity:32];
  gHMSLContext = malloc(sizeof(HMSLContext));
  gHMSLContext->currentPoint = NSMakePoint(0, 0);
  
  hmslColors = [[NSArray alloc] initWithObjects:
                      [NSColor whiteColor],
                      [NSColor blackColor],
                      [NSColor redColor],
                      [NSColor greenColor],
                      [NSColor blueColor],
                      [NSColor cyanColor],
                      [NSColor magentaColor],
                      [NSColor yellowColor],
                nil];

  return -1;
}

void hostTerm( void ) {
  return;
}

uint32_t hostOpenWindow( hmslWindow *window ) {
  NSRect frame = NSMakeRect(window->rect_left, window->rect_bottom, window->rect_right - window->rect_left, window->rect_bottom - window->rect_top);
  HMSLWindowDelegate *windowDelegate = [[HMSLWindowDelegate alloc] init];
  HMSLView *hmslView = [[HMSLView alloc] init];
  
  id hmslWindow = [[NSWindow alloc]
                    initWithContentRect: frame
                    styleMask: NSTitledWindowMask | NSResizableWindowMask
                    backing: NSBackingStoreRetained
                    defer: YES];
  [hmslWindow cascadeTopLeftFromPoint:NSMakePoint(20,20)];
  [hmslWindow setContentView:hmslView];
  
  //  [hmslWindow setTitle:@"HMSL"];
  [hmslWindow performSelectorOnMainThread:@selector(makeKeyAndOrderFront:) withObject:nil waitUntilDone:YES];
  [hmslWindow setDelegate:windowDelegate];
  [hmslWindowArray addObject:hmslWindow];
  
  currentContext = [NSGraphicsContext graphicsContextWithWindow:hmslWindow];
  drawingContext = [currentContext graphicsPort];
  
  if (currentContext != nil) {
    [NSGraphicsContext setCurrentContext:currentContext];
  } else {
    NSLog(@"Not able to make context happen");
  }
  
  return [hmslWindowArray indexOfObject:hmslWindow] + 1;
}

void hostCloseWindow( uint32_t window ) {
  [[hmslWindowArray objectAtIndex:(window - 1)] performSelectorOnMainThread:@selector(close) withObject:nil waitUntilDone:YES];
  return;
}

void hostSetCurrentWindow( uint32_t window ) {
  [[hmslWindowArray objectAtIndex:(window - 1)] performSelectorOnMainThread:@selector(makeMainWindow) withObject:nil waitUntilDone:YES];
  return;
}

void hostDrawLineTo( int32_t x, int32_t y ) {
  CGContextBeginPath(drawingContext);
  CGContextMoveToPoint(drawingContext, gHMSLContext->currentPoint.x, gHMSLContext->currentPoint.y);
  hostMoveTo(x, y);
  CGContextAddLineToPoint(drawingContext, gHMSLContext->currentPoint.x, gHMSLContext->currentPoint.y);
  CGContextStrokePath(drawingContext);
  [currentContext flushGraphics];
  return;
}

void hostMoveTo( int32_t x, int32_t y ) {
  gHMSLContext->currentPoint.x = x;
  // Need to invert the y value
  gHMSLContext->currentPoint.y = 386 - y;
  return;
}

void hostDrawText( uint32_t address, int32_t count ) {
  NSData *stringData = [NSData dataWithBytes:(void *)address length:count];
  NSString *textToDraw = [[NSString alloc] initWithData:stringData encoding:NSASCIIStringEncoding];
  NSAttributedString *drawText = [[NSAttributedString alloc] initWithString:textToDraw];
  [drawText drawAtPoint:gHMSLContext->currentPoint];
  return;
}

uint32_t hostGetTextLength( uint32_t addr, int32_t count ) {
  return 0;
}

void hostFillRectangle( int32_t x1, int32_t y1, int32_t x2, int32_t y2 ) {
  CGContextFillRect(drawingContext, CGRectMake(x1, 386 - y2, x2 - x1, y2 - y1));
  return;
}

void hostSetColor( int32_t color ) {
  if (currentContext != nil) {
    [[hmslColors objectAtIndex:color] set];
  }
  return;
}

void hostSetBackgroundColor( int32_t color ) {
  int mainWindow = [hmslWindowArray indexOfObjectPassingTest:
                    ^ BOOL (id obj, NSUInteger idx, BOOL *stop) {
    if ([obj isKeyWindow]) {
      return TRUE;
    };
    return FALSE;
  }];
  [[hmslWindowArray objectAtIndex:mainWindow]
   setBackgroundColor:[hmslColors objectAtIndex:color]];
  return;
}

void hostSetDrawingMode( int32_t mode ) {
  return;
}

void hostSetFont( int32_t font ) {
  
  return;
}

void hostSetTextSize( int32_t size ) {
  return;
}

void hostGetMouse( uint32_t x, uint32_t y) {
  return;
}

int32_t hostGetEvent( int32_t timeout ) {
  return 0;
}
