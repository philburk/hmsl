/***************************************************************
** HMSL Graphics functions
**
** Author: Robert Marsanyi
***************************************************************/

#include <windows.h>
#include "pf_all.h"
#include "hmsl_graphics.h"
#include "hmsl_font.h"
#include "hmsl_event.h"


const static COLORREF sColorPallette[] = 
{
	RGB( 255, 255, 255), /* white */
	RGB(   0,   0,   0), /* black */
	RGB( 255,   0,   0), /* red */
	RGB(   0, 255,   0), /* green */
	RGB(   0,   0, 255), /* blue */
	RGB(   0, 255, 255), /* cyan */
	RGB( 255,   0, 255), /* magenta */
	RGB( 255, 255,   0), /* yellow */
};

#define COLOR_PALLETE_SIZE  (sizeof(sColorPallette)/sizeof(COLORREF))

HMSLContext *gHMSLContext;

DWORD WINAPI HMSLThreadFunc( LPVOID parm )
{
	HWND graphWnd;
	pf_Rect *rect;
	char title[80];
	int x, y, width, height;
	pf_WindowTemplate *wt;
	MSG msg;
	HANDLE hEvent;

	wt = (pf_WindowTemplate*)parm;

	/* translate the title from Forth */
	ForthStringToC( title, (const char *)wt->wt_title );

	/* dereference the rectangle structure in the template */
	rect = &(wt->wt_rect);
	x = rect->rect_left; 
	y = rect->rect_top;
	width = rect->rect_right - x;
	height = rect->rect_bottom - y;

	/* call CreateWindow */
	graphWnd = CreateWindow( "HMSLClass",
		title,
		WS_OVERLAPPEDWINDOW,
		x,
		y,
		width,
		height,
		(HWND) NULL,
		(HMENU) NULL,
		gHMSLContext->hg_hInstance,
		NULL );
	
	/* tell the calling thread what the window handle is */
	gHMSLContext->hg_hWndGraphics = graphWnd;
	if( graphWnd )
	{
		/* show the result */
		ShowWindow( graphWnd, SW_SHOW );

		/* get the device context for future drawing operations */
		gHMSLContext->hg_hDC = GetDC( graphWnd );
		gHMSLContext->hg_Color = -1;
		hostSetColor( 0 );
		gHMSLContext->hg_At.x = 0;
		gHMSLContext->hg_At.y = 0;

		hfInit();

		hEvent = OpenEvent( EVENT_MODIFY_STATE, TRUE, "HMSLOpenWindowEvent" );
		SetEvent( hEvent );

		/* close the event */
		CloseHandle( hEvent );
		
		/* Start the message loop, exit on WM_QUIT */
		while (GetMessage(&msg, (HWND) NULL, 0, 0)) 
		{
			/* hand it off to Windows to process normally */
			TranslateMessage(&msg); 
			DispatchMessage(&msg); 
		}

		/* destroy the window */
		DestroyWindow( graphWnd );

		/* Return the exit code to Windows. */
		return msg.wParam;;
	}
	else
	{
		hEvent = OpenEvent( EVENT_MODIFY_STATE, TRUE, "HMSLOpenWindowEvent" );
		SetEvent( hEvent );

		/* close the event */
		CloseHandle( hEvent );
		
		return(0);
	}
}

/***************************************************************
hostInit
Register the appropriate window class in preparation for CreateWindow
*/

Err hostInit( void )
{
	WNDCLASS wc;
		
	/* allocate hGraph structure */
	gHMSLContext = malloc( sizeof( HMSLContext ) );
	if( !gHMSLContext ) return(-1);

	wc.lpszClassName = "HMSLClass";
	wc.lpfnWndProc = HMSLWndProc;
	wc.style = CS_OWNDC | CS_VREDRAW | CS_HREDRAW;
	wc.hInstance = GetModuleHandle( NULL );
	wc.hIcon = LoadIcon( NULL, IDI_APPLICATION );
	wc.hCursor = LoadCursor( NULL, IDC_ARROW );
	wc.hbrBackground = (HBRUSH)( COLOR_WINDOW+1 );
	wc.lpszMenuName = NULL;
	wc.cbClsExtra = 0;
	wc.cbWndExtra = 0;

	if( !RegisterClass( &wc ) )
	{
		free( gHMSLContext );
		return(-1);
	}

	/* our window handle is that of the foreground window at this point, right? */
	gHMSLContext->hg_hWndMain = GetForegroundWindow();
	gHMSLContext->hg_hInstance = GetModuleHandle( NULL );
	gHMSLContext->hg_hWndGraphics = NULL;

	/* initialize event stuff */
	HMSL_InitMessages();

	return(0);
}

/***************************************************************
hostTerm
Clean up
*/

void hostTerm( void )
{
	if( gHMSLContext->hg_hWndGraphics ) hostCloseWindow( (uint32)(gHMSLContext->hg_hWndGraphics) );
	HMSL_TermMessages();
	hfTerm();
	if( gHMSLContext ) free( gHMSLContext );
}

/***************************************************************
hostOpenWindow
Map the window template to parameters for CreateWindow, and show it
*/

uint32 hostOpenWindow( pf_WindowTemplate *wt )
{
	HANDLE hEvent;
	HANDLE hThread;
	DWORD dwThreadID;
	DWORD waitResult;
	
	gHMSLContext->hg_hWndGraphics = NULL;

	/* create an event */
	if( (hEvent = CreateEvent( NULL, TRUE, FALSE, "HMSLOpenWindowEvent" )) == NULL )
	{
		goto clean;
	}
	
	/* spawn the window thread */
	if( (hThread = CreateThread( NULL,
		0,
		HMSLThreadFunc,
		wt,
		0,
		&dwThreadID )) == NULL )
	{
		goto clean;
	}

	/* wait for the event to go set, indicating the window handle is valid */
	if( (waitResult = WaitForSingleObject( hEvent, 5000 )) != WAIT_OBJECT_0 )
	{
		goto clean;
	}

clean:
	if( hEvent ) CloseHandle( hEvent );

	/* return the window handle */
	return( (uint32)(gHMSLContext->hg_hWndGraphics));
}

/***************************************************************
hostCloseWindow
Send a WM_QUIT to the window thread
*/

void hostCloseWindow( uint32 window )
{
	PostMessage( (HWND)window, WM_QUIT, 0, 0 );
}

/***************************************************************
hostSetCurrentWindow
Nothing required.
*/

void hostSetCurrentWindow( uint32 window )
{
	return;
}

/***************************************************************
hostDrawLineTo
Use LineTo()
*/

void hostDrawLineTo( int32 x, int32 y )
{
	LineTo( gHMSLContext->hg_hDC, x, y );
	gHMSLContext->hg_At.x = x;
	gHMSLContext->hg_At.y = y;
	return;
}

/***************************************************************
hostMoveTo
Use MoveToEx()
*/

void hostMoveTo( int32 x, int32 y )
{
	MoveToEx( gHMSLContext->hg_hDC, x, y, NULL );
	gHMSLContext->hg_At.x = x;
	gHMSLContext->hg_At.y = y;
	return;
}

/***************************************************************
hostDrawText
Set the text color to the current foreground color and use TextOut
*/

void hostDrawText( uint32 addr, int32 count )
{
	TEXTMETRIC textMetrics;
	SIZE textSize;
	
	/* Allow for overhang */
	GetTextMetrics( gHMSLContext->hg_hDC, &textMetrics );

	/* Get the text's width and height */
	GetTextExtentPoint32( gHMSLContext->hg_hDC,
		(char*)addr,
		count,
		&textSize );

	/* Draw the text at (x, y-height) */
	TextOut( gHMSLContext->hg_hDC,
		gHMSLContext->hg_At.x,
		gHMSLContext->hg_At.y - textMetrics.tmAscent,
//		gHMSLContext->hg_At.y,
		(char*)addr,
		count );

	/* Increment x by the width */
	gHMSLContext->hg_At.x += textSize.cx;

	gHMSLContext->hg_At.x -= textMetrics.tmOverhang;

	/* Move the window pointer to the new position */
	MoveToEx( gHMSLContext->hg_hDC,
		gHMSLContext->hg_At.x,
		gHMSLContext->hg_At.y,
		NULL );
	return;
}

/***************************************************************
hostGetTextLength
Use GetTextExtentPoint32, GetTextMetrics to figure delta x
*/
uint32 hostGetTextLength( uint32 addr, int32 count )
{
	TEXTMETRIC textMetrics;
	SIZE textSize;
	uint32 x;
	
	/* Get the text's width and height */
	GetTextExtentPoint32( gHMSLContext->hg_hDC,
		(char*)addr,
		count,
		&textSize );
	x = textSize.cx;

	/* Allow for overhang */
	GetTextMetrics( gHMSLContext->hg_hDC, &textMetrics );
	x -= textMetrics.tmOverhang;

	return( x );
}

/***************************************************************
hostFillRectangle
Use Rectangle, assuming current brush and pen are set to correct color
*/
void hostFillRectangle( int32 x1, int32 y1, int32 x2, int32 y2)
{
	/* Add one to xy and y1 so that rectangle includes the far dimension.
	 * This is for compatibility with HMSL.
	 */
	Rectangle( gHMSLContext->hg_hDC, x1, y1, x2+1, y2+1 );

	/* Move the window pointer to the new position */
	gHMSLContext->hg_At.x = x1;
	gHMSLContext->hg_At.y = y1;
	MoveToEx( gHMSLContext->hg_hDC, x1, y1, NULL );
	
	return;
}

/***************************************************************
hostSetColor
If we're not using this color right now, create a new pen and brush
using sColorPallette[] for this color and select them to the DC.  SetTextColor
to this color as well.  Delete the old pen and brush.
*/
void hostSetColor( int32 color )
{
	HPEN hPen, oldPen;
	HBRUSH hBrush, oldBrush;
	COLORREF  rgb;

	/* if we're selecting the current color, just return */
	if( gHMSLContext->hg_Color == color ) return;

	rgb = sColorPallette[ color % COLOR_PALLETE_SIZE ];

	/* otherwise, create a 1-pixel Pen and replace the old one */
	hPen = CreatePen( PS_SOLID, 1, rgb );
	oldPen = SelectObject( gHMSLContext->hg_hDC, hPen );
	DeleteObject( oldPen );

	/* create a Brush and replace the old one */
	hBrush = CreateSolidBrush( rgb );
	oldBrush = SelectObject( gHMSLContext->hg_hDC, hBrush );
	DeleteObject( oldBrush );

	/* select the text color */
	SetTextColor( gHMSLContext->hg_hDC, rgb );

	gHMSLContext->hg_Color = color;

	return;
}

/***************************************************************
hostSetBackgroundColor
Use SetBkColor()
*/
void hostSetBackgroundColor( int32 color )
{
	COLORREF  rgb = sColorPallette[ color % COLOR_PALLETE_SIZE ];
	SetBkColor( gHMSLContext->hg_hDC, rgb );
	return;
}

/***************************************************************
hostSetDrawingMode
Use SetROP2 to set to either R2_COPYPEN ("INSERT") or R2_XORPEN
("XOR") mode
*/
void hostSetDrawingMode( int32 mode )
{
	int winMode;

	winMode = ( mode == GR_XOR_MODE ) ? R2_XORPEN : R2_COPYPEN;
	SetROP2( gHMSLContext->hg_hDC, winMode );

	return;
}

/***************************************************************
hostSetFont
Set font from a font index
*/
void hostSetFont( int32 font )
{
	int size;
	
	size = hfGetFontSize();
	hfSetFont( font, size );

	return;
}

/***************************************************************
hostSetTextSize
Set font height in pixels
*/
void hostSetTextSize( int32 size )
{
	int font;
	
	font = hfGetFontIndex();
	hfSetFont( font, size );

	return;
}

/***************************************************************
hostGetMouse
Get coordinates of last event from gHMSL and put them into variables
*/
void hostGetMouse( uint32 x, uint32 y )
{
	*(int32*)x = gHMSLContext->hg_ev_mouseXY.x;
	*(int32*)y = gHMSLContext->hg_ev_mouseXY.y;
}
