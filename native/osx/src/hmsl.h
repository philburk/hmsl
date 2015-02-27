//
//  hmsl.h
//  HMSL-OSX
//
//  Created by Andrew C Smith on 1/27/15.
//  Copyright (c) 2015 Andrew C Smith. All rights reserved.
//

#ifndef HMSL_OSX_hmsl_h
#define HMSL_OSX_hmsl_h

#import <CoreMIDI/CoreMIDI.h>

#import "hmsl_gui.h"

/*
 * header stuff
 */

/*
 * hmsl_gui.m
 */

int32_t hostInit( void );
void hostTerm( void );
uint32_t hostOpenWindow( hmslWindow *window );
void hostCloseWindow( uint32_t window );
void hostSetCurrentWindow( uint32_t window );
void hostDrawLineTo( int32_t x, int32_t y );
void hostMoveTo( int32_t x, int32_t y );
void hostDrawText( uint32_t address, int32_t count );
uint32_t hostGetTextLength( uint32_t addr, int32_t count );
void hostFillRectangle( int32_t x1, int32_t y1, int32_t x2, int32_t y2 );
void hostSetColor( int32_t color );
void hostSetBackgroundColor( int32_t color );
void hostSetDrawingMode( int32_t mode );
void hostSetFont( int32_t font );
void hostSetTextSize( int32_t size );
void hostGetMouse( uint32_t x, uint32_t y);
int32_t hostGetEvent( int32_t timeout );

/* 
 * hmsl_midi.m
 */

void midiSourceProc(MIDIPacketList *pktlist, void *readProcRefCon, void *srcConnRefCon);
int hostMIDI_Init();
void hostMIDI_Term( void );
int hostMIDI_Write( unsigned char *addr, int count, int vtime );
int hostMIDI_Recv( void );
int hostClock_QueryTime( void );
int hostClock_QueryRate( void );
void hostSleep( int msec );

#endif
