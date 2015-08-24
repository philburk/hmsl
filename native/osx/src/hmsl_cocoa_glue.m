//
//  hmsl_cocoa_glue.m
//  HMSL-OSX
//
//  Created by Andrew C Smith on 8/20/15.
//  Copyright (c) 2015 3DO. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "HMSLWindow.h"
#import "HMSLView.h"
#import "hmsl.h"
#import "pf_all.h"

HMSLWindow *mainWindow;

void hmslSetBackgroundColor( const double* color ) {
  [mainWindow hmslBackgroundColor:color];
}

void hmslSetCurrentWindow( uint32_t window ) {
  HMSLWindow* newMain = [[HMSLWindow windowDictionary] objectForKey:[NSNumber numberWithInteger:(NSInteger)window]];
  if (newMain != NULL) {
    [newMain performSelectorOnMainThread:@selector(makeMainWindow) withObject:NULL waitUntilDone:YES];
    mainWindow = newMain;
  }
}

void hmslCloseWindow( uint32_t window ) {
  HMSLWindow* closeMe = [[HMSLWindow windowDictionary] objectForKey:[NSNumber numberWithInteger:(NSInteger)window]];
  if (closeMe != NULL) {
    [closeMe performSelectorOnMainThread:@selector(close) withObject:NULL waitUntilDone:YES];
  }
}

void hmslDrawLine( HMSLPoint start, HMSLPoint end ) {
  // Flip the y-values (Quartz drawing is from bottom-left)
  HMSLView *view = (HMSLView*)mainWindow.contentView;
  start.y = view.frame.size.height - start.y;
  end.y = view.frame.size.height - end.y;
  [mainWindow drawLineFrom:start to:end];
}

void hmslFillRectangle( HMSLRect rect ) {
  // Flip the y-value of the origin
  HMSLView *view = (HMSLView*)mainWindow.contentView;
  rect.origin.y = view.frame.size.height - rect.origin.y - rect.size.h;
  [mainWindow drawRectangle:rect];
}

uint32_t hmslOpenWindow(const char* title, short x, short y, short w, short h) {
  NSRect frame = NSMakeRect(x, y, w, h);
  NSString *windowTitle = [NSString stringWithCString:title encoding:NSASCIIStringEncoding];
  HMSLWindow* hmslWindow = [HMSLWindow hmslWindowWithTitle:windowTitle frame:frame];
  [hmslWindow hmslBackgroundColor:hmslColors[0]];
  mainWindow = hmslWindow;
  
  NSGraphicsContext *currentContext = [NSGraphicsContext graphicsContextWithWindow:hmslWindow];
  
  if (currentContext != nil) {
    NSGraphicsContext.currentContext = currentContext;
    hmslWindow.graphicsContext = currentContext;
    drawingContext = [NSGraphicsContext.currentContext CGContext];
  } else {
    NSLog(@"Unable to initialize context");
  }
  
  return (uint32_t)hmslWindow.windowNumber;
}

void hmslSetDrawingColor( CGContextRef context, int32_t color ) {
  const double *rgba = hmslColors[color];

  [[NSColor colorWithRed:rgba[0] green:rgba[1] blue:rgba[2] alpha:rgba[3]] set];
  CGContextSetRGBFillColor(context, rgba[0], rgba[1], rgba[2], rgba[3]);
  CGContextSetRGBStrokeColor(context, rgba[0], rgba[1], rgba[2], rgba[3]);
  
  return;
}

void hmslSetTextSize( int32_t size ) {
  
  @autoreleasepool {
    NSFont *currentFont = [mainWindow.fontAttributes objectForKey:NSFontAttributeName];
    NSFont *resizedFont = [NSFont fontWithName:currentFont.fontName size:(CGFloat)size];
    mainWindow.fontAttributes = [NSDictionary dictionaryWithObject:resizedFont forKey:NSFontAttributeName];
  }
  
}

uint32_t hmslGetTextLength( const char* string, int32_t size ) {
  uint32_t textLength;
  
  @autoreleasepool {
    char* nullTerm = nullTermString(string, size);
    NSString *text = [NSString stringWithCString: nullTerm encoding:NSASCIIStringEncoding];
    textLength = (uint32_t)[text sizeWithAttributes:mainWindow.fontAttributes].width;
    free(nullTerm);
  }
  
  return textLength;
}

void hmslDrawText( const char* string, int32_t size ) {
  
  @autoreleasepool {
    char* nullTerm = nullTermString(string, size);
    NSString *text = [NSString stringWithCString: nullTerm encoding:NSASCIIStringEncoding];
    NSPoint point;
    point.x = gHMSLContext.currentPoint.x;
    HMSLView *view = (HMSLView*)mainWindow.contentView;
    point.y = view.frame.size.height - gHMSLContext.currentPoint.y;
    [text drawAtPoint:point withAttributes:mainWindow.fontAttributes];
    free(nullTerm);
  }
  
  return;
}

// Borrows the input string
char* nullTermString( const char* string, int32_t size ) {
  char *out = malloc(size+1);
  ForthStringToC(out, string-1, size+1);
  return out;
}


void hmslAddEvent( enum HMSLEventID event_type ) {
  gHMSLContext.events[gHMSLContext.events_write_loc] = event_type;
  gHMSLContext.events_write_loc += 1;
  return;
}

enum HMSLEventID hmslGetEvent( void ) {
  enum HMSLEventID val = gHMSLContext.events[gHMSLContext.events_read_loc];
  gHMSLContext.events_read_loc += 1;
  return val;
}
