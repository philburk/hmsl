\ Host dependant EVENT support.
\
\ Most modern interactive systems are event driven.
\ This means that the top loop of the code gets events
\ from the operating system and acts on them.  This gives the
\ user more control over the application. 
\ 
\ The event types that are supported are:
\    NULL - nothing happened
\    MOUSE UP or DOWN
\    MOUSE MOVE - optional, slows down system if used all the time.
\    MENU events.
\    WINDOW CLOSE BOX hits.
\    REFRESH - system request to redraw user screen.
\    KEY  - key pressed on keyboard
\
\ This file contains the host dependant words for the 
\ AMIGA running JFORTH
\
\ Author: Phil Burk
\ Copyright 1986 -  Phil Burk, Larry Polansky, David Rosenboom.
\ All Rights Reserved
\
\ MOD: PLB 12/17/86 Added EV_REFRESH
\ MOD: PLB 3/1/88 Add polled mouse tracking.
\ MOD: PLB 6/30/89 Use HMSL-WINDOW instead of GR-CURWINDOW
\ 00001 PLB 9/27/91 Add EV_KEY
\ 00002 PLB 9/28/91 Add RAW.KEY.CONVERT calls to support arrows

getmodule includes
include? OpenDevice() ju:Exec_Support

ANEW TASK-AJF_EVENTS
\ Mouse Tracking for tracked controls.

decimal
IORequest RKC-IORQ

: OPEN.CONSOLE ( -- device | 0 , open console device for CALL )
	console_lib @ 0=
	IF
		0" console.device"
		-1 \ for just getting device address
		rkc-iorq
		0
		OpenDevice() ?dup
		IF
			." OPEN.CONSOLE - Error = " . cr
			0
		ELSE
			rkc-iorq ..@ io_device
			dup console_lib !
			if>rel
		THEN
	ELSE
		console_lib @
	THEN
;

: CLOSE.CONSOLE ( -- )
	console_lib @
	IF
		rkc-iorq CloseDevice()
		console_lib off
	THEN
;

InputEvent FakeEvt

: RAW.KEY.CONVERT  ( code qualifier buffer -- nchars )
	>r  \ save buffer
	console_lib @ 0=
	abort" RAW.KEY.CONVERT - OPEN.CONSOLE must be called first!"
\
\ setup fake input event
	0 FakeEvt ..! ie_NextEvent
	IECLASS_RAWKEY FakeEvt ..! ie_Class
\
\ use input parameters
	FakeEvt ..! ie_Qualifier
	FakeEvt ..! ie_Code
\
	FakeEvt >abs
	r> >abs 32 0
	call console_lib RawKeyConvert
;

VARIABLE EV-IF-TRACK-MOUSE ( true if tracking on )

: EV.POLL.XY ( -- x y , get current x y from window )
    hmsl-window @ dup
    ..@ wd_mousex
    swap ..@ wd_mousey
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

: EV.MOUSE.MOVED? ( -- flag , has mouse moved a significant ammount )
    ev.poll.xy  ev-last-mousey @ =
    IF ( -- x )
        ev-last-mousex @ = 0=
    ELSE drop true
    THEN
;

\ Define Mouse Event Codes in a host independant fashion.
0 dup  constant EV_NULL
1+ dup constant EV_MOUSE_DOWN
1+ dup constant EV_MOUSE_UP
1+ dup constant EV_MOUSE_MOVE
1+ dup constant EV_MENU_PICK
1+ dup constant EV_CLOSE_WINDOW
1+ dup constant EV_REFRESH
1+ dup constant EV_KEY \ 00001
drop

\ Define constants for ARROW keys \ 00002
256
1- dup constant LEFT_ARROW
1- dup constant RIGHT_ARROW
1- dup constant SHIFT_LEFT_ARROW
1- dup constant SHIFT_RIGHT_ARROW
drop

variable RAW-LEFT-ARROW
$ 029B4400 raw-left-arrow !   \ set hex codes for match
variable RAW-RIGHT-ARROW
$ 029B4300  raw-right-arrow !
variable RAW-SH-LEFT-ARROW
$ 039B2041  raw-sh-left-arrow !
variable RAW-SH-RIGHT-ARROW
$ 039B2040  raw-sh-right-arrow !

: MATCH.2.CHARS  { | char  -- char }
	0 -> char
	pad raw-left-arrow $=
	IF
		left_arrow -> char
	ELSE
		pad raw-right-arrow $=
		IF
			right_arrow -> char
		THEN
	THEN
	char
;
		

: MATCH.3.CHARS  { | char  -- char }
	0 -> char
	pad raw-sh-left-arrow $=
	IF
		shift_left_arrow -> char
	ELSE
		pad raw-sh-right-arrow $=
		IF
			shift_right_arrow -> char
		THEN
	THEN
	char
;
		
: EV.GET.KEY { | char  -- char } \ 00002
	0 -> char
	ev-last-code @
	ev-last-qualifier @
	pad 1+ raw.key.convert
	dup pad c!
\
	CASE
		1 OF pad 1+ c@ -> char ENDOF
		2 OF match.2.chars -> char ENDOF
		3 OF match.3.chars -> char ENDOF
	ENDCASE
	char
;

hex
68 constant MOUSEDOWN        \ these are returned in event message
E8 constant MOUSEUP
decimal

: EV.GET.EVENT ( -- event_code , usage is host independant )
    hmsl-window @ ev.getclass dup
    IF
        CASE
        MOUSEBUTTONS OF 
                ev-last-code @ MOUSEDOWN =
                IF   ev_mouse_down
                ELSE ev_mouse_up
                THEN
            ENDOF

\        MOUSEMOVE OF ev_mouse_move ENDOF

        CLOSEWINDOW OF ev_close_window  ENDOF

        MENUPICK OF ev_menu_pick  ENDOF

        REFRESHWINDOW OF ev_refresh ENDOF
        
        RAWKEY OF ev_key  ENDOF \ 00001

        dup . cr " EV.GET.EVENT" " unrecognized event!"
        er_return er.report
        ENDCASE
    ELSE
\ Generate fake MOUSE event.
        drop
        ev-if-track-mouse @
        IF  ev.mouse.moved?
            IF ev.update.track ev_mouse_move
            ELSE ev_null
            THEN
        ELSE  ev_null
        THEN
    THEN
;

: EV.INIT
	if-debug @ IF ." EV.INIT" cr THEN
	ev.track.off
	open.console 0= warning" EV.INIT - could not open console device!"
;
: EV.TERM close.console ;
: SYS.INIT sys.init ev.init ;
: SYS.TERM ev.term sys.term ;
: SYS.RESET sys.reset ev.init ;
