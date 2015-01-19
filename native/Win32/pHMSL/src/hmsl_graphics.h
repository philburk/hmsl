#ifndef _HMSL_GRAPHICS
#define _HMSL_GRAPHICS
/***************************************************************
** Interface for HMSL Graphics functions
**
** Author: Robert Marsanyi
***************************************************************/

#include <windows.h>
#include "dbl_list.h"

typedef struct pf_Rect
{
	short rect_top;
	short rect_left;
	short rect_bottom;
	short rect_right;
} pf_Rect;

typedef struct pf_WindowTemplate
{
	pf_Rect wt_rect;
	long    wt_title;
} pf_WindowTemplate;

typedef struct HMSLContext
{
	HWND    hg_hWndMain;
	HANDLE  hg_hInstance;
	HWND    hg_hWndGraphics;
	HDC     hg_hDC;
	POINT   hg_At;
	POINTS  hg_ev_mouseXY;
	DWORD   hg_ev_time;
	int     hg_Color;
	DoubleList hg_MsgQueue;
	DoubleList hg_FreeMsgList;
	HANDLE  hg_MsgMutex;
	HANDLE  hg_MsgSemaphore;
} HMSLContext;

/* Graphics drawing modes that HMSL defines */
#define GR_INSERT_MODE 0
#define GR_XOR_MODE 1

Err hostInit( void );
void hostTerm( void );
uint32 hostOpenWindow( pf_WindowTemplate *windowTemplate );
void hostCloseWindow( uint32 window );
void hostSetCurrentWindow( uint32 window );
void hostDrawLineTo( int32 x, int32 y );
void hostMoveTo( int32 x, int32 y );
void hostDrawText( uint32 address, int32 count );
uint32 hostGetTextLength( uint32 addr, int32 count );
void hostFillRectangle( int32 x1, int32 y1, int32 x2, int32 y2);
void hostSetColor( int32 color );
void hostSetBackgroundColor( int32 color );
void hostSetDrawingMode( int32 mode );
void hostSetFont( int32 font );
void hostSetTextSize( int32 size );
void hostGetMouse( uint32 x, uint32 y );

#endif /* _HMSL_GRAPHICS */