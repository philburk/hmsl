//
//  hmsl.h
//  HMSL-OSX
//
//  Copyright (c) 2015 Andrew C Smith. All rights reserved.
//

#ifndef HMSL_OSX_hmsl_h
#define HMSL_OSX_hmsl_h

#include <CoreMIDI/CoreMIDI.h>
#include <CoreGraphics/CGContext.h>

#import "pf_all.h"

#ifndef PF_DEFAULT_DICTIONARY
#define PF_DEFAULT_DICTIONARY "pforth.dic"
#endif

#ifndef HMSL_COLORS
#define HMSL_COLORS

#define HMSL_COLORS_SIZE 8
#define HMSL_COLORS_MASK 0b00000111

static const double hmslWhite[4] = {1.0, 1.0, 1.0, 1.0};
static const double hmslBlack[4] = {0.0, 0.0, 0.0, 1.0};
static const double hmslRed[4] = {1.0, 0.0, 0.0, 1.0};
static const double hmslGreen[4] = {0.0, 1.0, 0.0, 1.0};
static const double hmslBlue[4] = {0.0, 0.0, 1.0, 1.0};
static const double hmslCyan[4] = {0.0, 1.0, 1.0, 1.0};
static const double hmslMagenta[4] = {1.0, 0.0, 1.0, 1.0};
static const double hmslYellow[4] = {1.0, 1.0, 0.0, 1.0};

static const double* hmslColors[HMSL_COLORS_SIZE] = {
  hmslWhite, hmslBlack, hmslRed, hmslGreen, hmslBlue, hmslCyan, hmslMagenta, hmslWhite
};

#endif /* HMSL_COLORS */

typedef ucell_t ucell_ptr_t; // cell that contains an address
typedef ucell_t hmsl_window_index_t; // token for a window

#define EVENT_BUFFER_SIZE 256
#define EVENT_BUFFER_MASK (EVENT_BUFFER_SIZE - 1)

/*
 * Global structs
 */

typedef struct HMSLPoint {
  cell_t x;
  cell_t y;
} HMSLPoint;

typedef struct HMSLSize {
  cell_t w;
  cell_t h;
} HMSLSize;

typedef struct HMSLRect {
  HMSLPoint origin;
  HMSLSize size;
} HMSLRect;

enum HMSLColor {
  WHITE,
  BLACK,
  RED,
  GREEN,
  BLUE,
  CYAN,
  MAGENTA,
  YELLOW
};

enum HMSLEventID {
  EV_NULL,
  EV_MOUSE_DOWN,
  EV_MOUSE_UP,
  EV_MOUSE_MOVE,
  EV_MENU_PICK,
  EV_CLOSE_WINDOW,
  EV_REFRESH,
  EV_KEY
};

typedef struct HMSLEvent {
  enum HMSLEventID id;
  HMSLPoint loc;
} HMSLEvent;

typedef struct HMSLContext {
  HMSLPoint currentPoint;
  HMSLPoint mouseEvent;
  enum HMSLColor color;
  HMSLEvent *events;
  uint32_t events_read_loc;
  uint32_t events_write_loc;
} hmslContext;

typedef struct HMSLWindow {
  short rect_top;
  short rect_left;
  short rect_bottom;
  short rect_right;
  ucell_ptr_t title;
} hmslWindow;


/*
 * global variables
 */

extern hmslContext gHMSLContext;

/*
 * hmsl_gui.m
 */

/*
 * These functions are called from Forth so they will take and return
 * cell wide values.
 */
int32_t hostInit(void);
void hostTerm(void);
hmsl_window_index_t hostOpenWindow( hmslWindow *window );
void hostCloseWindow( hmsl_window_index_t window );
void hostSetCurrentWindow( hmsl_window_index_t window );
void hostDrawLineTo( cell_t x, cell_t y );
void hostMoveTo( cell_t x, cell_t y );
void hostDrawText( ucell_ptr_t address, cell_t count );
uint32_t hostGetTextLength( ucell_ptr_t addr, cell_t count );
void hostFillRectangle( cell_t x1, cell_t y1, cell_t x2, cell_t y2 );
void hostSetColor( cell_t color );
void hostSetBackgroundColor( cell_t color );
void hostSetDrawingMode( cell_t mode );
void hostSetFont( cell_t font );
void hostSetTextSize( cell_t size );
void hostGetMouse( ucell_ptr_t xPtr, ucell_ptr_t yPtr);
cell_t hostGetEvent( cell_t timeout );

/*
 * communication with the obj-c layer
 */

void hmslAddEvent( enum HMSLEventID event_type );
void hmslAddMouseEvent( enum HMSLEventID event_type, HMSLPoint loc );
char* nullTermString( const char*, int32_t );
void hmslDrawLine( HMSLPoint start, HMSLPoint end );
void hmslSetCurrentWindow( uint32_t );
void hmslCloseWindow( uint32_t );
uint32_t hmslOpenWindow( const char* title, short x, short y, short w, short h );
void hmslFillRectangle( HMSLRect rect );
void hmslDrawText( const char*, int32_t, HMSLPoint );
uint32_t hmslGetTextLength( const char*, int32_t );
void hmslSetDrawingColor( const double* );
void hmslSetBackgroundColor( const double* );
void hmslSetTextSize( int32_t );
void hmslSetDrawingMode( int32_t );

/* 
 * hmsl_midi.m
 */

void hostClock_Init(void);
void hostClock_Term(void);
int hostClock_QueryTime(void);
void hostClock_SetTime( int time );
void hostClock_AdvanceTime( int delta );
int hostClock_QueryRate(void);
void hostClock_SetRate( int rate );

void midiSourceProc(MIDIPacketList *pktlist,
                    void *readProcRefCon,
                    void *srcConnRefCon);
int hostMIDI_Init(void);
void hostMIDI_Term(void);
int hostMIDI_Write(unsigned char *addr, int count, int vtime);
int hostMIDI_Recv(void);
void hostSleep( int msec );

int getMainScreenRefreshRate( void );

#endif
