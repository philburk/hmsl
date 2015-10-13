//
//  hmsl_gui.m
//  HMSL-OSX
//
//  Created by Andrew C Smith on 1/27/15.
//  Copyright (c) 2015 Andrew C Smith. All rights reserved.
//

#import "hmsl.h"
#import "pf_all.h"

int32_t hostInit( void ) {
  gHMSLContext.events = malloc(sizeof(enum HMSLEventID) * EVENT_BUFFER_SIZE);
  gHMSLContext.events_read_loc = 0;
  gHMSLContext.events_write_loc = 0;
  return -1;
}

void hostTerm( void ) {
  free(gHMSLContext.events);
  return;
}

uint32_t hostOpenWindow( hmslWindow *window ) {
  char title[80];
  ForthStringToC(title, (const char*)window->title, 80);
  uint32_t windowIndex = hmslOpenWindow(title, window->rect_left, window->rect_bottom, window->rect_right - window->rect_left, window->rect_bottom - window->rect_top);
  return windowIndex;
}

void hostCloseWindow( uint32_t window ) {
  hmslCloseWindow( window );
  return;
}

void hostSetCurrentWindow( uint32_t window ) {
  hmslSetCurrentWindow( window );
  return;
}

void hostDrawLineTo( int32_t x, int32_t y ) {
  HMSLPoint start, end;
  start.x = gHMSLContext.currentPoint.x; start.y = gHMSLContext.currentPoint.y;
  end.x = x; end.y = y;
  hmslDrawLine( start, end );
  gHMSLContext.currentPoint = end;
  return;
}

void hostMoveTo( int32_t x, int32_t y ) {
  gHMSLContext.currentPoint.x = x;
  gHMSLContext.currentPoint.y = y;
  return;
}

/*
 * Draws text in the current context at the current pen point
 *
 * address - address in memory of the string to copy
 * count - number of bytes to read
 */
void hostDrawText( uint32_t address, int32_t count ) {
  hmslDrawText( (char*)address, count, gHMSLContext.currentPoint );
  gHMSLContext.currentPoint.x += hmslGetTextLength( (char*)address, count);
  CGContextSynchronize(drawingContext);
  return;
}

/*
 * Gets the length of the string, using the current font face and size
 *
 * address - address in memory of the string to copy
 * count - number of bytes to read
 * 
 * Returns the length of the text
 */
uint32_t hostGetTextLength( uint32_t address, int32_t count ) {
  return hmslGetTextLength( (char*)address, count );
}

/* 
 * Draws a filled rectangle in the current context
 * 
 * x1, y1 - integer coordinates of one corner of rectangle
 * x2, y2 - integer coordiantes of opposing corner of rectangle
 */
void hostFillRectangle( int32_t x1, int32_t y1, int32_t x2, int32_t y2 ) {
  HMSLRect rect;
  rect.origin.x = x1; rect.origin.y = y1;
  rect.size.w = x2 - x1; rect.size.h = y2 - y1;
  hmslFillRectangle( rect );
  gHMSLContext.currentPoint = rect.origin;
  return;
}

/*
 * Sets the stroke/fill drawing color of the current context
 *
 * color - index of color to use, defined as constants in hmsl.h
 */
void hostSetColor( int32_t color ) {
  if (drawingContext != nil) {
      hmslSetDrawingColor(drawingContext, hmslColors[color & HMSL_COLORS_MASK]);
  }
  return;
}

/* 
 * Sets background color of main window
 *
 * color - index of color to use, defined as constants in hmsl.h
 */
void hostSetBackgroundColor( int32_t color ) {
  hmslSetBackgroundColor(hmslColors[color & HMSL_COLORS_MASK]);
  CGContextSynchronize(drawingContext);
  return;
}

/*
 * Sets drawing mode
 *
 * mode - 0 for normal (overwrite); 1 for XOR.
 */
void hostSetDrawingMode( int32_t mode ) {
  switch (mode) {
    case 0:
      CGContextSetBlendMode(drawingContext, kCGBlendModeNormal);
      break;
    case 1:
      CGContextSetBlendMode(drawingContext, kCGBlendModeExclusion);
      break;
  }
  return;
}

/*
 * Sets the font from a dictionary of possible fonts
 * 
 * font - index of font to set
 */
void hostSetFont( int32_t font ) {
  return;
}

/* 
 * Sets the font size in some units.
 *
 * size - integer size
 */
void hostSetTextSize( int32_t size ) {
  hmslSetTextSize(size);
  return;
}

/*
 * Called whenever HMSL wants to know where the mouse is (usually open receiving an event)
 *
 * x - address in memory where the mouse event's x coordinates should be written
 * y - address in memory where the mouse event's y coordinates should be written
 *
 * should return void
 */
void hostGetMouse( uint32_t x, uint32_t y) {
  *(int32_t*)x = gHMSLContext.mouseEvent.x;
  *(int32_t*)y = gHMSLContext.mouseEvent.y;
  return;
}

/*
 * Polled regularly to receive latest events in the GUI
 *
 * timeout - time til we should stop blocking (disabled here)
 *
 * Returns an int, defined in the enum HMSLEventID
 */
int32_t hostGetEvent( int32_t timeout ) {
  if (gHMSLContext.events_read_loc < gHMSLContext.events_write_loc) {
    // Case statement should set global variables for mouseEvent, keyPress, etc.
    return hmslGetEvent();
  } else {
    return EV_NULL;
  }
}

