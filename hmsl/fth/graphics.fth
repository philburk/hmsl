\ Graphics Host Dependant Module
\ This module provides simple graphics functions.
\
\ Author: Phil Burk
\ Copyright 1986 Phil Burk, Larry Polansky, David Rosenboom
\ All Rights Reserved
\
\ MOD: PLB 12/3/86 ADD GR_SMALL_TEXT
\ MOD: PLB 12/14/86 Graphics and events in separate HMSL window.
\ MOD: PLB 4/15/87 Force font to system font.
\ MOD: PLB 6/25/87 GR.INIT to use single task.
\ MOD: PLB 7/8/87 Add SYS.INIT
\ MOD: PLB 8/3/89 Convert to H4th
\ 920708 PLB Allow variable size HMSL window default.
\ 930107 PLB Added ?CLOSEBOX

ANEW TASK-GRAPHICS

\ Define device resolution 00003
  0 value GR_XMIN
600 value GR_XMAX
  4 value GR_YMIN  ( Leave room at top for window bar. )
400 value GR_YMAX

\ Define default window 00003
10 value GR_WINDOW_LEFT
40 value GR_WINDOW_TOP
gr_xmax value GR_WINDOW_WIDTH
gr_ymax value GR_WINDOW_HEIGHT

\ Define colors in simple pallette
0 constant GR_WHITE
1 constant GR_BLACK
2 constant GR_RED
3 constant GR_GREEN
4 constant GR_BLUE
5 constant GR_CYAN
6 constant GR_MAGENTA
7 constant GR_YELLOW

0 CONSTANT GR_INSERT_MODE
1 CONSTANT GR_XOR_MODE

\ 2019 Modern GUIs redraw instead of XORing.
\ XOR was used in the past because redrawing was too slow.
0 constant GR_XOR_SUPPORTED

V: GR-HEIGHT
12 value GR_SMALL_TEXT
16 value GR_BIG_TEXT

\ Start code necessary for HMSL ---------------------------
\ Define Mouse Event Codes in a host independant fashion.
0 dup  constant EV_NULL
1+ dup constant EV_MOUSE_DOWN
1+ dup constant EV_MOUSE_UP
1+ dup constant EV_MOUSE_MOVE
1+ dup constant EV_MENU_PICK
1+ dup constant EV_CLOSE_WINDOW
1+ dup constant EV_REFRESH
1+ dup constant EV_KEY   \ 00001
drop

:STRUCT  RECT
    short   rect_top
    short   rect_left
    short   rect_bottom
    short   rect_right
;STRUCT

:STRUCT WindowTemplate  \ Structure used to describe a new window
\   long    wt_wStorage
    struct  rect    wt_rect
    long    wt_title
\   short   wt_visible
\   short   wt_procID
\   long    wt_behind
\   short   wt_goAwayFlag
\   long    wt_refcon
;STRUCT

decimal
: GR.OPENWINDOW ( new_window -- window , open a new window )
    hostOpenWindow()
;

: GR.CLOSEWINDOW ( window -- , close the window )
    hostCloseWindow()
;

U: GR-CURWINDOW  ( holds pointer to current window or 0 )
: GR.SETPORT ( -- , Set window port. )
    gr-curwindow @ hostSetCurrentWindow()
;
    
\ GRAPHICS OUTPUT PRIMITIVES -------------------------

: GR.DRAW ( X Y -- , DRAW IN CURRENT COLOR )
     gr.setport
     hostDrawLineTo()
;
: GR.MOVE ( X Y -- , Move to new position. )
     gr.setport
     hostMoveTo()
;

: GR.TYPE ( addr count -- , Draw string at current position. )
     gr.setport
     hostDrawText()
;

: GR.TEXT ( string -- , Draw string at current position. )
     count gr.type
;

: GR.TEXTLEN  ( addr count -- xpixels , x size of string )
     gr.setport
     hostGetTextLength()
;

: GR.XYTEXT  ( X Y S1 -- , Draw string at x,y )
   -rot GR.MOVE   ( Move to start, use graphics characters )
   GR.TEXT
;

: GR.NUMBER  ( value -- , Display number as text at CP )
     n>text text>string gr.text
;

\ Allocate space for RECT records.
VARIABLE GR-RECT 4 vallot

: GR.RECT ( X1 Y1 X2 Y2 -- , Fill region with current FACI )
    gr.setport
    hostFillRectangle()
;

\ GRAPHICS ATTRIBUTES -----------------------------------
V: GR-COLOR ( Foreground Color for primitives. )

: GR.COLOR!   ( Color -- , set color )
    dup gr-color !
    gr.setport
    hostSetColor()
;
: GR.COLOR@ ( -- COLOR , Query COLOR )
    gr-color @
;

V: GR-BCOLOR ( Background Color for primitives. )
: GR.BCOLOR!   ( BColor=0|1 -- )
    dup gr-bcolor !
    gr.setport
    hostSetBackgroundColor()
;
: GR.BCOLOR@ ( -- BCOLOR , Query BCOLOR )
    gr-bcolor @
;

variable GR-MODE
: GR.MODE!  ( mode -- , Set drawing mode mode )
    dup gr-mode !
    gr.setport
    hostSetDrawingMode()
;
: GR.MODE@ ( -- MODE , Query MODE )
    gr-mode @
;

variable GR-FONT
: GR.FONT!  ( font -- )
    dup gr-font !
    gr.setport
    hostSetFont()
;

: GR.FONT@  ( -- font )
    gr-font @
;

: GR.HEIGHT! ( height -- , Set character height in pixels. )
    dup gr-height !
    gr.setport
    hostSetTextSize()
;
: GR.HEIGHT@ ( -- height , Query height )
    gr-height @
;

: GR.SET.CURWINDOW ( window -- , Set current window, rastport, and attributes. )
    gr-curwindow !  gr.setport
    1 gr-color ! ( Default color. )
    gr_small_text gr-height !  ( Set default text character height )
    gr_insert_mode gr-mode !
;

: GR.CLOSECURW ( -- , Close current window )
    gr-curwindow @ ?dup
    IF gr.closewindow
    THEN
    0 gr-curwindow !
;

: GR.HIGHLIGHT ( X1 Y1 X2 Y2 -- , HIGHLIGHT region )
    gr.mode@ >r
    gr.color@ >r
    GR_XOR_MODE gr.mode!
    GR_YELLOW gr.color!
    gr.rect
    r> gr.color!
    r> gr.mode!
;
: GR.DEHIGHLIGHT ( X1 Y1 X2 Y2 -- , HIGHLIGHT region )
    gr.highlight
;

\ GRAPHICS CONTROL -------------------------------------
: GR.CLEAR ( -- , Clear screen )
      gr.color@ 0 gr.color!
      0 0 gr_xmax gr_ymax gr.rect
      gr.color!
;

\ Create in dictionary for 0 at startup.
CREATE GR%-IF-INIT 0 ,   

: GR.INIT  ( -- , Initialize graphics system. )
    gr%-if-init @ NOT 
    IF 
        0 gr-curwindow !
        true gr%-if-init !
    THEN
;

: GR.TERM ( -- , Terminate Graphics )
    gr%-if-init @
    IF gr.closecurw
\       FALSE gr%-if-init !  ( never init twice )
    THEN
;

: GR.CHECK ( -- , aborts if graphics system not initialized )
   gr-curwindow @ 0= abort" GR.CHECK - No open window!!"
;
    
\ GRAPHICS INPUT -------------------------------------------
V: GR%-PENSTATE
V: GR%-MOUSE_XPOS
V: GR%-MOUSE_YPOS

VARIABLE EV-IF-TRACK-MOUSE ( true if tracking on )
VARIABLE EV-LAST-MOUSEX
VARIABLE EV-LAST-MOUSEY

: EV.GETXY  ( -- x y , get X,Y from previous mouse event)
    EV-LAST-MOUSEX EV-LAST-MOUSEY hostGetMouse()
    ev-last-mousex @
    ev-last-mousey @
;

: EV.GET.EVENT ( -- event_code , usage is host independant )
    1000 60 / ( timeout = about 1 tick )
    hostGetEvent()
    \ do not return move events if tracking turned off
    dup EV_MOUSE_MOVE =
    IF
        ev-if-track-mouse @ 0=
        IF
            drop EV_NULL
        THEN
    THEN
;

: GR.GETXY ( -- x y )
      ev.getxy
;

: ?CLOSEBOX ( -- flag , was the closebox hit )
    ev.get.event EV_CLOSE_WINDOW =
;

\ These next two routines are obsolete, but may be used for testing.
: GR.XYLOC? ( -- x y flag , return mouse button state )
      ?terminal IF ABORT THEN  ( %? )
      ev.get.event
      CASE
        EV_NULL OF ENDOF
        EV_MOUSE_DOWN OF true gr%-penstate !
                  gr.getxy gr%-mouse_ypos ! gr%-mouse_xpos !
            ENDOF
        EV_MOUSE_UP OF false  gr%-penstate !
                  gr.getxy gr%-mouse_ypos ! gr%-mouse_xpos !
            ENDOF
\        MOUSEMOVE OF gr.getxy gr%-mouse_ypos ! gr%-mouse_xpos ! 
\            ENDOF
      endcase
      gr%-mouse_xpos @
      gr%-mouse_ypos @
      gr%-penstate  @
;

: GWAIT.SWUP  ( -- , Wait until SW1 is up. )
     BEGIN
        gr.xyloc? nip nip not
     UNTIL
;

\ HMSL specific support ------------------------------

windowTemplate HMSL-NewWindow
\ Set this to a string.
defer  HMSL.TITLE  ( -- $string )
'c null is hmsl.title

: Window.Defaults  ( WIndowTemplate -- , set reasonable defaults )
    >r
    80 r@ .. wt_rect ..! rect_top
    10 r@ .. wt_rect ..! rect_left
    320 r@ .. wt_rect ..! rect_bottom
    400 r@ .. wt_rect ..! rect_right
    " HMSL" r@ ..! wt_title
    rdrop
;

\ Just open message window.
: GR.OPENHMSL ( -- , Open HMSL window for tests. )
    HMSL-NewWindow window.defaults
    hmsl.title ?dup
    IF HMSL-NewWindow ..! wt_title
    THEN
\
\ use adjustable values 00001
    gr_window_top hmsl-newwindow .. wt_rect ..! rect_top
    gr_window_left hmsl-newwindow .. wt_rect ..! rect_left
    gr_window_top gr_window_height + hmsl-newwindow .. wt_rect ..! rect_bottom
    gr_window_left gr_window_width + hmsl-newwindow .. wt_rect ..! rect_right
\
    HMSL-NewWindow gr.openwindow dup hmsl-window ! ?dup
    IF  gr.set.curwindow
    ELSE ." Could not open HMSL window!" cr abort
    THEN
;

: GR.CLOSEHMSL  ( -- , close HMSL window )
    gr.closecurw
    hmsl-window off
;

: HMSL.SET.WINDOW  ( -- )
    hmsl-window @ ?dup
    IF gr.set.curwindow
    ELSE ." HMSL.SET.WINDOW - not open!" abort
    THEN
;


: EV.GET.KEY  ( -- char , get key data saved by EV.GET.CLASS )
    [char] X
;

: EV.POLL.XY ( -- x y , get current x y from window )
    hmsl-window @ gr-curwindow ! gr.setport
    ev.getxy
;

: EV.UPDATE.TRACK ( -- , update mouse tracking position )
    ev.poll.xy ev-last-mousey !
    ev-last-mousex !
;

: EV.TRACK.ON ( -- , turn on mouse tracking )
    true ev-if-track-mouse !
    ev.update.track
;
: EV.TRACK.OFF
    false ev-if-track-mouse !
;

: EV.FLUSH  ( -- , flush events from queue )
    BEGIN
        ev.get.event
    EV_NULL = UNTIL
;


VARIABLE EV-LAST-TICKS    \ Saved for detecting double clicks.
VARIABLE EV-PREV-TICKS    \ Time before for detecting double clicks.

: EV.2CLICK? ( -- flag , true if last was double click )
    ev-last-ticks @
    ev-prev-ticks @ -
    5 <
;

\ -----------------------------------------------------

: SYS.INIT sys.init " gr.init" debug.type gr.init ;
: SYS.TERM gr.term sys.term ;
