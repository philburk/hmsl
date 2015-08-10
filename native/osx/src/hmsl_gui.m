//
//  hmsl_gui.m
//  HMSL-OSX
//
//  Created by Andrew C Smith on 1/27/15.
//  Copyright (c) 2015 Andrew C Smith. All rights reserved.
//

#import "hmsl.h"
#import "pf_all.h"
#import "HMSLDelegate.h"
#import "HMSLWindow.h"
#import "HMSLWindowDelegate.h"
#import "HMSLView.h"

NSArray *hmslColors;

extern hmslContext *gHMSLContext;
hmslContext *gHMSLContext;

extern NSMutableArray *hmslEventBuffer;
NSMutableArray *hmslEventBuffer;

HMSLWindow* getMainWindow( NSMutableArray *windowArray ) {
  int mainWindow = [windowArray indexOfObjectPassingTest:
                    ^ BOOL (id obj, NSUInteger idx, BOOL *stop) {
                      if ([obj isKeyWindow]) {
                        return TRUE;
                      };
                      return FALSE;
                    }];
  if (mainWindow >= windowArray.count) {
    mainWindow = windowArray.count - 1;
  }
  return [windowArray objectAtIndex:mainWindow];
}

int32_t hostInit( void ) {
  hmslWindowArray = [NSMutableArray arrayWithCapacity:32];
  hmslEventBuffer = [NSMutableArray arrayWithCapacity:100];
  
  gHMSLContext = malloc(sizeof(hmslContext));
  gHMSLContext->currentPoint = NSMakePoint(0, 0);
  gHMSLContext->mouseEvent = NSMakePoint(0, 0);
  NSFont *font = [NSFont fontWithName:@"Helvetica" size:(CGFloat)14.0];
  gHMSLContext->fontAttributes = [NSDictionary dictionaryWithObject:font forKey:NSFontAttributeName];
  
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
  [hmslWindowArray release];
  free(gHMSLContext);
  [hmslColors release];
  return;
}

uint32_t hostOpenWindow( hmslWindow *window ) {
  char title[80];
  ForthStringToC(title, (const char*)window->title, 80);
  NSString *windowTitle = [NSString stringWithCString:title encoding:NSASCIIStringEncoding];
  
  NSRect frame = NSMakeRect(window->rect_left, window->rect_bottom, window->rect_right - window->rect_left, window->rect_bottom - window->rect_top);
  
  HMSLWindowDelegate *windowDelegate = [[HMSLWindowDelegate alloc] init];
  HMSLView *hmslView = [[HMSLView alloc] init];
  
  id hmslWindow = [[HMSLWindow alloc]
                    initWithContentRect: frame
                    styleMask: NSMiniaturizableWindowMask | NSTitledWindowMask | NSClosableWindowMask
                    backing: NSBackingStoreRetained
                    defer: YES];
  [hmslWindow cascadeTopLeftFromPoint:NSMakePoint(20,20)];
  [hmslWindow setContentView:hmslView];
  
  [hmslWindow setTitle:windowTitle];
  [hmslWindow performSelectorOnMainThread:@selector(makeKeyAndOrderFront:) withObject:nil waitUntilDone:YES];
  [hmslWindow setDelegate:windowDelegate];
  [hmslWindow setHasShadow:YES];
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
  return;
}

void hostMoveTo( int32_t x, int32_t y ) {
  HMSLWindow *mainWindow = getMainWindow(hmslWindowArray);
  gHMSLContext->currentPoint.x = x;
  // Need to invert the y value
  gHMSLContext->currentPoint.y = mainWindow.frame.size.height - y;
  return;
}

void hostDrawText( uint32_t address, int32_t count ) {
  NSData *stringData = [NSData dataWithBytes:(void *)address length:count];
  NSString *text = [[NSString alloc] initWithData:stringData encoding:NSASCIIStringEncoding];
  [text drawAtPoint:gHMSLContext->currentPoint withAttributes:gHMSLContext->fontAttributes];
  return;
}

uint32_t hostGetTextLength( uint32_t address, int32_t count ) {
  NSData *stringData = [NSData dataWithBytes:(void *)address length:count];
  NSString *text = [[NSString alloc] initWithData:stringData encoding:NSASCIIStringEncoding];
  uint32_t size = [text sizeWithAttributes:gHMSLContext->fontAttributes].width;
  [text release];
  return size;
}

void hostFillRectangle( int32_t x1, int32_t y1, int32_t x2, int32_t y2 ) {
  HMSLWindow *mainWindow = getMainWindow(hmslWindowArray);
  CGContextFillRect(drawingContext, CGRectMake(x1, mainWindow.frame.size.height - y2, x2 - x1, y2 - y1));
  return;
}

void hostSetColor( int32_t color ) {
  if (currentContext != nil) {
    [[hmslColors objectAtIndex:color] set];
  }
  return;
}

void hostSetBackgroundColor( int32_t color ) {
  [getMainWindow(hmslWindowArray) setBackgroundColor:[hmslColors objectAtIndex:color]];
  return;
}

// There is not a native XOR drawing mode in Quartz
void hostSetDrawingMode( int32_t mode ) {
  switch (mode) {
    case 0:
      CGContextSetBlendMode(drawingContext, kCGBlendModeNormal);
      break;
    case 1:
      CGContextSetBlendMode(drawingContext, kCGBlendModeDifference);
      break;
  }
  return;
}

void hostSetFont( int32_t font ) {
  return;
}

void hostSetTextSize( int32_t size ) {
  // pull down the current font from the context
  NSFont *currentFont = [gHMSLContext->fontAttributes objectForKey:NSFontAttributeName];
  // create a new font and assign it in place of the current font
  gHMSLContext->fontAttributes = [NSDictionary dictionaryWithObject:
                                  [NSFont fontWithName:currentFont.fontName size:(CGFloat)size] forKey:NSFontAttributeName];
  return;
}

void hostGetMouse( uint32_t x, uint32_t y) {
  HMSLWindow *mainWindow = getMainWindow(hmslWindowArray);
  *(int32_t*)x = gHMSLContext->mouseEvent.x;
  *(int32_t*)y = mainWindow.frame.size.height - gHMSLContext->mouseEvent.y;
  return;
}

int32_t hostGetEvent( int32_t timeout ) {
  if (hmslEventBuffer.count > 0) {
    NSNumber *event = [hmslEventBuffer firstObject];
    int val = [event intValue];
    bool debug = true;
    if (debug) {
      switch (val) {
        case EV_MOUSE_DOWN:
          NSLog(@"EV_MOUSE_DOWN at %f, %f", gHMSLContext->mouseEvent.x, gHMSLContext->mouseEvent.y);
          break;
        case EV_MOUSE_UP:
          NSLog(@"EV_MOUSE_UP at %f, %f", gHMSLContext->mouseEvent.x, gHMSLContext->mouseEvent.y);
          break;
        case EV_MOUSE_MOVE:
          NSLog(@"EV_MOUSE_MOVE at %f, %f", gHMSLContext->mouseEvent.x, gHMSLContext->mouseEvent.y);
          break;
        case EV_KEY:
          NSLog(@"EV_KEY happened");
          break;
        case EV_REFRESH:
          NSLog(@"EV_REFRESH happened");
          break;
      }
    }
    [hmslEventBuffer removeObjectAtIndex:0];
    return val;
  } else {
    return EV_NULL;
  }
}
