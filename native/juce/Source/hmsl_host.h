//
//  hmsl.h
//  HMSL-OSX
//

#ifndef HMSL_OSX_hmsl_h
#define HMSL_OSX_hmsl_h

#import "pf_all.h"

typedef ucell_t ucell_ptr_t; // cell that contains an address
typedef ucell_t hmsl_window_index_t; // token for a window

#define EVENT_BUFFER_SIZE 256
#define EVENT_BUFFER_MASK (EVENT_BUFFER_SIZE - 1)

/*
 * Global structs
 */

/*
typedef struct HMSLSize {
  cell_t w;
  cell_t h;
} HMSLSize;

typedef struct HMSLRect {
  HMSLPoint origin;
  HMSLSize size;
} HMSLRect;
*/

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

/*
 * This must match the structure defined in HMSL. Where?
 */
typedef struct HMSLWindow {
  short rect_top;
  short rect_left;
  short rect_bottom;
  short rect_right;
  ucell_ptr_t title;
} hmslWindow;

/*
 * These functions are called from Forth so they will take and return
 * cell wide values.
 */
#ifdef __cplusplus
extern "C" {
#endif

int32_t hostInit(void);
void hostTerm(void);

// GUI
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

// int getMainScreenRefreshRate( void );

// Events
void hostGetMouse( ucell_ptr_t xPtr, ucell_ptr_t yPtr);
cell_t hostGetEvent( cell_t timeout );

// MIDI
void hostClock_Init(void);
void hostClock_Term(void);
cell_t hostClock_QueryTime(void);
void hostClock_SetTime( cell_t time );
void hostClock_AdvanceTime( cell_t delta );
cell_t hostClock_QueryRate(void);
void hostClock_SetRate( cell_t rate );

cell_t hostMIDI_Init(void);
void hostMIDI_Term(void);
cell_t hostMIDI_Write(ucell_ptr_t buffer, cell_t count, cell_t vtime);
// @return positive MIDI byte or negative number
cell_t hostMIDI_Recv(void);
cell_t hostMIDI_Port(void);
void hostSleep( cell_t msec );

#ifdef __cplusplus
}
#endif

#endif
