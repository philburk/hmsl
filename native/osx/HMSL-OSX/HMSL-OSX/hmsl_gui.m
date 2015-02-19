//
//  hmsl_gui.m
//  HMSL-OSX
//
//  Created by Andrew C Smith on 1/27/15.
//  Copyright (c) 2015 Andrew C Smith. All rights reserved.
//

#import "hmsl.h"
#import "pf_all.h"

#import <Foundation/Foundation.h>

void hostInit( void ) {
  return;
}

void hostTerm( void ) {
  return;
}

uint32_t hostOpenWindow( void ) {
  return 0;
}

void hostCloseWindow( uint32_t window ) {
  return;
}

void hostSetCurrentWindow( uint32_t window ) {
  return;
}

void hostDrawLineTo( int32_t x, int32_t y ) {
  return;
}

void hostMoveTo( int32_t x, int32_t y ) {
  return;
}

void hostDrawText( uint32_t address, int32_t count ) {
  return;
}

uint32_t hostGetTextLength( uint32_t addr, int32_t count ) {
  return 0;
}

void hostFillRectangle( int32_t x1, int32_t y1, int32_t x2, int32_t y2 ) {
  return;
}

void hostSetColor( int32_t color ) {
  return;
}

void hostSetBackgroundColor( int32_t color ) {
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
