\ Graphics Host Dependant Module
\ For JForth versions, most of the code can be found
\ in the file JU:AMIGA_GRAPH
\
\ Author: Phil Burk
\ Copyright 1986 -  Phil Burk, Larry Polansky, David Rosenboom.
\ All Rights Reserved
\
\ MOD: PLB 12/17/86 Add REFRESHWINDOW flag.
\ MOD: PLB 8/31/87 Remove "Beta" from window title.
\ MOD: PLB 11/16/87  Version 3.14
\ MOD: PLB  1/29/88  Version 3.15
\ MOD: PLB  4/26/88  Version 3.16
\ MOD: PLB  11/15/88 Version 3.18
\ MOD: PLB  1/13/89  Version 3.19
\ MOD: PLB 5/27/89   Version 3.20 Beta
\ MOD: PLB 6/17/89   Version 3.21 Beta
\ MOD: PLB 10/3/89   Version 3.32 Beta , no longer GIMMEZEROZERO
\      Special GR.CLEAR
\ MOD: PLB 2/28/91 c/0/false/ for HMSL.TITLE since 0 isn't always CONSTANT
\ MOD: PLB 5/20/91 Added SYS.INIT to call GR.INIT
\ 00001 PLB 9/27/91 Add VANILLAKEY events

ANEW TASK-AJF_GRAPH

\ HMSL specific support ------------------------------

\ Constants for graphic text size
\ Use color instead of text size for showing difference.
9 constant GR_SMALL_TEXT
9 constant GR_BIG_TEXT
    
\ GRAPHICS INPUT -------------------------------------------

: GR.GETXY ( -- x y , Get x y for last mouse event )
    ev.getxy ( Amiga HMSL NO LONGER uses GIMMEZEROZERO window )
;

NewWindow HMSL-NewWindow

\ Set by top level.
defer HMSL.Title
' false is HMSL.TITLE

: GR.OPENHMSL ( -- , Open HMSL window for tests. )
    hmsl-newwindow NewWindow.Setup
\
\ Don't use GIMMEZEROZERO window.
  WINDOWDRAG WINDOWDEPTH | WINDOWCLOSE | REPORTMOUSE |
  WINDOWSIZING |  hmsl-newWindow ..! nw_Flags
\
\ give window a default title
    HMSL.Title dup 0=
    IF drop 0" -=< HMSL >=-"
    THEN >abs hmsl-newwindow ..! nw_Title
\
    5 hmsl-newwindow ..! nw_topedge    ( expand window )
    186 hmsl-newwindow ..! nw_height
    MOUSEBUTTONS CLOSEWINDOW |   MENUPICK |   REFRESHWINDOW |
		RAWKEY | \ 00001
		hmsl-newwindow ..! NW_IDCMPFlags
    hmsl-newwindow gr.openwindow gr.set.curwindow
    gr-curwindow @ hmsl-window !
;

\ Redefine for non GIMMEZEROZERO
  4 value GR_XMIN
620 value GR_XMAX
 12 value GR_YMIN  ( Leave room at top for window bar. )
189 value GR_YMAX

: HMSL.SET.WINDOW  ( -- , draw in HMSL window )
    hmsl-window @ ?dup
    IF gr.set.curwindow
    ELSE " HMSL.SET.WINDOW" " Window not open!"
        er_fatal  er.report
    THEN
;


: SYS.INIT sys.init gr.init ;
: SYS.TERM gr.term sys.term ;
