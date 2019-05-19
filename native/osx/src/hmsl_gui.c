//
//  hmsl_gui.m
//  HMSL-OSX
//
//  Created by Andrew C Smith on 1/27/15.
//  Copyright (c) 2015 Andrew C Smith. All rights reserved.
//

#import "hmsl.h"
#import "pf_all.h"

hmslContext gHMSLContext;

int32_t hostInit() {
  gHMSLContext.events = malloc(sizeof(HMSLEvent) * EVENT_BUFFER_SIZE);
  gHMSLContext.events_read_loc = 0;
  gHMSLContext.events_write_loc = 0;
  return -1;
}

void hostTerm() {
  free(gHMSLContext.events);
}

hmsl_window_index_t hostOpenWindow( hmslWindow *window ) {
  char title[80];
  ForthStringToC(title, (const char*)window->title, 80);
  uint32_t windowIndex = hmslOpenWindow(title, window->rect_left, window->rect_bottom, window->rect_right - window->rect_left, window->rect_bottom - window->rect_top);
  return windowIndex;
}

void hostCloseWindow(hmsl_window_index_t window) {
  hmslCloseWindow((uint32_t)window);
}

void hostSetCurrentWindow( hmsl_window_index_t window ) {
  hmslSetCurrentWindow((uint32_t)window);
}

void hostDrawLineTo( cell_t x, cell_t y ) {
  HMSLPoint start, end;
  start.x = gHMSLContext.currentPoint.x; start.y = gHMSLContext.currentPoint.y;
  end.x = x;
  end.y = y;
  hmslDrawLine( start, end );
  gHMSLContext.currentPoint = end;
}

void hostMoveTo( cell_t x, cell_t y ) {
  gHMSLContext.currentPoint.x = x;
  gHMSLContext.currentPoint.y = y;
}

/*
 * Draws text in the current context at the current pen point
 *
 * address - address in memory of the string to copy
 * count - number of bytes to read
 */
void hostDrawText( ucell_t address, cell_t count ) {
  hmslDrawText( (char*)address, (int32_t)count, gHMSLContext.currentPoint );
  gHMSLContext.currentPoint.x += hmslGetTextLength( (char*)address, (int32_t)count);
}

/*
 * Gets the length of the string, using the current font face and size
 *
 * address - address in memory of the string to copy
 * count - number of bytes to read
 * 
 * Returns the length of the text
 */
uint32_t hostGetTextLength( ucell_ptr_t address, cell_t count ) {
  return hmslGetTextLength( (char*)address, (int32_t)count );
}

/* 
 * Draws a filled rectangle in the current context
 * 
 * x1, y1 - integer coordinates of one corner of rectangle
 * x2, y2 - integer coordinates of opposing corner of rectangle
 */
void hostFillRectangle( cell_t x1, cell_t y1, cell_t x2, cell_t y2 ) {
  HMSLRect rect;
  rect.origin.x = x1; rect.origin.y = y1;
  rect.size.w = x2 - x1; rect.size.h = y2 - y1;
  hmslFillRectangle( rect );
  gHMSLContext.currentPoint = rect.origin;
}

/*
 * Sets the stroke/fill drawing color of the current context
 *
 * color - index of color to use, defined as constants in hmsl.h
 */
void hostSetColor( cell_t color ) {
  hmslSetDrawingColor(hmslColors[color & HMSL_COLORS_MASK]);
}

/* 
 * Sets background color of main window
 *
 * color - index of color to use, defined as constants in hmsl.h
 */
void hostSetBackgroundColor( cell_t color ) {
  hmslSetBackgroundColor(hmslColors[color & HMSL_COLORS_MASK]);
}

/*
 * Sets drawing mode
 *
 * mode - 0 for normal (overwrite); 1 for XOR.
 */
void hostSetDrawingMode( cell_t mode ) {
  hmslSetDrawingMode((int32_t)mode);
}

/*
 * Sets the font from a dictionary of possible fonts
 * 
 * font - index of font to set
 */
void hostSetFont( cell_t font ) {
    // TODO
}

/* 
 * Sets the font size in some units.
 *
 * size - integer size
 */
void hostSetTextSize( cell_t size ) {
  hmslSetTextSize((int32_t)size);
}

/**
 * Called whenever HMSL wants to know where the mouse is (usually open receiving an event)
 *
 * @param xPtr address in memory where the mouse event's x coordinates should be written
 * @param yPtr address in memory where the mouse event's y coordinates should be written
 */
void hostGetMouse( ucell_ptr_t xPtr, ucell_ptr_t yPtr) {
  *(cell_t*)xPtr = gHMSLContext.mouseEvent.x;
  *(cell_t*)yPtr = gHMSLContext.mouseEvent.y;
}

/*
 * Polled regularly to receive latest events in the GUI
 *
 * timeout - time til we should stop blocking (disabled here)
 *
 * Returns an int, defined in the enum HMSLEventID
 */
cell_t hostGetEvent( cell_t timeout ) {
  if (gHMSLContext.events_read_loc < gHMSLContext.events_write_loc) {
    HMSLEvent event = gHMSLContext.events[gHMSLContext.events_read_loc & EVENT_BUFFER_MASK];
    gHMSLContext.events_read_loc += 1;
    switch (event.id) {
      case EV_MOUSE_DOWN:
      case EV_MOUSE_MOVE:
      case EV_MOUSE_UP:
        gHMSLContext.mouseEvent.x = event.loc.x;
        gHMSLContext.mouseEvent.y = event.loc.y;
        break;
      default:
        break;
    }
    
    return event.id;
  } else {
    return EV_NULL;
  }
}

