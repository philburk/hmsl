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
#import "HMSLApplication.h"
#import "hmsl.h"
#import "pf_all.h"

HMSLWindow *mainWindow;

void hmslSetBackgroundColor( const double* color ) {
  if (mainWindow != NULL) {
    [mainWindow hmslBackgroundColor:color];
    NSColor *bgcolor = [NSColor colorWithRed:color[0] green:color[1] blue:color[2] alpha:color[3]];
    [APP.fontAttributes setObject:bgcolor forKey:NSBackgroundColorAttributeName];
  }
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
  rect.size.h++; rect.size.w++;
  [mainWindow drawRectangle:rect];
}

uint32_t hmslOpenWindow(const char* title, short x, short y, short w, short h) {
  NSRect frame = NSMakeRect(x, y, w, h);
  NSString *windowTitle = [NSString stringWithCString:title encoding:NSASCIIStringEncoding];
  HMSLWindow* hmslWindow = [HMSLWindow hmslWindowWithTitle:windowTitle frame:frame];
  [hmslWindow hmslBackgroundColor:hmslColors[0]];
  mainWindow = hmslWindow;
  return (uint32_t)hmslWindow.windowNumber;
}

void hmslSetDrawingColor( const double* rgba ) {
  if (mainWindow != NULL) {
    [mainWindow hmslDrawingColor: rgba];
  }
  return;
}

void hmslSetDrawingMode( int32_t mode ) {
  [mainWindow hmslDrawingMode: mode];
  return;
}

void hmslSetTextSize( int32_t size ) {
  if (mainWindow != NULL) {
    
    @autoreleasepool {
      NSFont *currentFont = [APP.fontAttributes objectForKey:NSFontAttributeName];
      NSFont *resizedFont = [NSFont fontWithName:currentFont.fontName size:((CGFloat)size)];
      [APP.fontAttributes setObject:resizedFont forKey:NSFontAttributeName];
    }
    
  }
}

uint32_t hmslGetTextLength( const char* string, int32_t size ) {
  uint32_t textLength;
  
  @autoreleasepool {
    char* nullTerm = nullTermString(string, size);
    NSString *text = [NSString stringWithCString: nullTerm encoding:NSASCIIStringEncoding];
    NSSize textSize = [text sizeWithAttributes:APP.fontAttributes];
    textLength = (uint32_t)textSize.width;
    free(nullTerm);
  }
  
  return textLength;
}

// string parameter is not a Forth string
void hmslDrawText( const char* string, int32_t size, HMSLPoint loc ) {
  
  @autoreleasepool {
    if (mainWindow != NULL) {
      char* nullTerm = nullTermString(string, size);
      NSString *text = [NSString stringWithCString: nullTerm encoding:NSASCIIStringEncoding];
      
      NSPoint point;
      point.x = loc.x;
      point.y = ((HMSLView*)mainWindow.contentView).frame.size.height - loc.y - 3;
      
      [mainWindow drawText:text atPoint:point];
      
      free(nullTerm);
    }
  }
  
  return;
}

// Borrows the input string
char* nullTermString( const char* string, int32_t size ) {
  char *out = malloc(size+1);
  memcpy(out, string, size);
  out[size] = '\0';
  return out;
}

int32_t hmslAvailableEventFIFO() {
  return EVENT_BUFFER_SIZE - ((gHMSLContext.events_write_loc - gHMSLContext.events_read_loc) & ((2 * EVENT_BUFFER_SIZE) - 1));
}

void hmslAddEvent( enum HMSLEventID event_type ) {
  if (hmslAvailableEventFIFO() > 0) {
    HMSLEvent event;
    event.id = event_type;
    gHMSLContext.events[gHMSLContext.events_write_loc & EVENT_BUFFER_MASK] = event;
    gHMSLContext.events_write_loc += 1;
  }
  return;
}

void hmslAddMouseEvent( enum HMSLEventID event_type, HMSLPoint loc ) {
  if (hmslAvailableEventFIFO() > 0) {
    HMSLEvent event;
    event.id = event_type;
    event.loc = loc;
    gHMSLContext.events[gHMSLContext.events_write_loc & EVENT_BUFFER_MASK] = event;
    gHMSLContext.events_write_loc += 1;
  }
  return;
}
