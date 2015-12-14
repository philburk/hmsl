\ Screen Class, Holds Several Control Grids
\
\ Methods required to be in a screen.
\
\ NAME:  FREE:  PUT.XY: GET.XY.DC: DRAW: PUT.ACTIVE: UNDRAW:
\ MOUSE.DOWN: MOUSE.MOVE: MOUSE.UP: KEY: GET.WH:
\
\ Author: Phil Burk
\ Copyright 1986 -  Phil Burk, Larry Polansky, David Rosenboom.
\ All Rights Reserved
\
\ MOD: PLB 7/14/86 Now stores relative address of control objects.
\ MOD: PLB 8/8/88 Call UNDRAW: for each control.
\ MOD: PLB 9/22/89 Big Change, Screens set x,y of grids.
\ MOD: PLB 10/5/89 Add DUMP.SOURCE:
\ MOD: PLB 10/29/89 Add DEFAULT-SCREEN
\ MOD: PLB 2/7/90 Add PUT.KEY:
\ MOD: PLB 2/23/90 Add CUSTOM-SCREENS auto add:
\ MOD: PLB 3/22/90 Undraw: previous when new one drawn:
\ MOD: PLB 7/18/90 Check for '3' in NEW:
\ MOD: PLB 2/10/91 No GR_BIG_TEXT , use GR-CURWINDOW not HMSL-WINDOW
\ 00001 PLB 9/27/91 Add: KEY:
\ 00002 PLB 9/28/91 Added calls to PUT.ACTIVE:
\ 00003 PLB 10/9/91 Added def of PUT.ACTIVE: for nested screens.
\ 00004 PLB 10/9/91 Use FLAG local variable in MOUSE.DOWN: for nesting.
\ 00005 PLB 2/6/92 Use EXEC.STACK?
\ 00006 PLB 2/12/92 Use put.xy.dc:
\ 00007 PLB 2/17/92 Fixed hit in screen causing highlight change.
\ 00007 PLB 2/17/92 Added DOWN/MOVE/UP function.
\ 00008 PLB 5/25/92 Add DELETE method.
\ 00009 PLB 8/3/92 Use OB.IN.DICT? to avoid relative/absolute issue.
\ 00010 PLB 10/1/92 Clean up titles on Mac

ANEW TASK-SCREEN

10 constant MAX_CUSTOM_SCREENS
OB.OBJLIST CUSTOM-SCREENS

variable CG-CURRENT-SCREEN ( holds currently active screen )
variable CG-DRAWING-SCREEN ( true when drawing, allow sub-screens )
variable DEFAULT-SCREEN    ( holds screen to display on startup )
variable SCR-LAST-KEY  ( for sequential allocation )
ascii A 1- scr-last-key !

\ Make sure custom screens don't have garbage in them.
: [FORGET]  ( -- )
    [forget]
    reset: custom-screens
    BEGIN manyleft: custom-screens
    WHILE next: custom-screens
        dup ob.in.dict? not  ( in dictionary )
        IF dup delete: custom-screens
           dup free: [] >newline
           name: [] ."  removed from CUSTOM-SCREENS" cr
        ELSE drop
        THEN
    REPEAT
\ Make sure DEFAULT screen is still in dictionary.
    default-screen @ ?dup
    IF  ob.in.dict? 0=
        IF  default-screen off
            >newline ." DEFAULT-SCREEN set to 0" cr
        THEN
    THEN
\ Make sure CURRENT screen is still in dictionary.
    cg-current-screen @ ?dup
    IF  ob.in.dict? 0=
        IF  cg-current-screen off
            >newline ." CG-CURRENT-SCREEN set to 0" cr
        THEN
    THEN
;


METHOD PUT.KEY:  METHOD GET.KEY:

:CLASS OB.SCREEN <SUPER OB.ELMNTS
    IV.LONG IV-SC-TITLE  ( pointer to title string )
    IV.LONG IV-SC-CTRL-HIT
    IV.LONG IV-SC-DRAW-CFA
    IV.LONG IV-SC-UNDRAW-CFA
\
\ provide functions for screen hits
    IV.LONG IV-SC-DOWN-CFA
    IV.LONG IV-SC-MOVE-CFA
    IV.LONG IV-SC-UP-CFA
    
    IV.BYTE IV-SC-KEY        ( character to use for Menu )
    IV.BYTE IV-SC-DRAWN
    IV.SHORT IV-SCR-LEFTX
    IV.SHORT IV-SCR-TOPY

:M INIT:
    init: super
\    " <HMSL>" iv=> iv-sc-title  \ VERY BAD IDEA in HForth 00010
    0 iv=> iv-sc-ctrl-hit
    0 iv=> iv-sc-draw-cfa
    0 iv=> iv-sc-undraw-cfa
\
\ Assign sequential characters.
    scr-last-key @ 1+ dup ascii Z >
    IF drop ascii A
    THEN dup scr-last-key !
    iv=> iv-sc-key
;M

\ Methods for setting up a control, specify appearance, etc.
:M PUT.XY.DC: ( leftx topy -- )
    iv=> iv-scr-topy    iv=> iv-scr-leftx
;M
    
:M GET.XY.DC: ( -- leftx topy )
    iv-scr-leftx iv-scr-topy
;M

:M PUT.XY: ( leftx topy -- )
    scg.wc->dc
    iv=> iv-scr-topy    iv=> iv-scr-leftx
;M
    
:M GET.XY: ( -- leftx topy )
    iv-scr-leftx iv-scr-topy
    scg.dc->wc
;M

:M NEW: ( #elmnts 3 -- , new: then add to custom-screens )
    dup 3 -
    IF " NEW: screen" " must have 3 dimensions, eg. 10 3 NEW:"
       er_warning ob.report.error
       drop 3
    THEN
    new: super
    self add: custom-screens
;M

:M FREE: ( -- , delete from custom-screens )
    free: super
    self delete: custom-screens
;M

:M DELETE: { control -- , to make it easy to delete controls }
    many: self 0
    ?DO
        i 0 ed.at: self control =
        IF
            i remove: self LEAVE
        THEN
    LOOP
;M

:M PUT.KEY:  ( character -- , set char for menu )
    iv=> iv-sc-key
;M

:M GET.KEY:  ( -- character )
    iv-sc-key
;M

:M PUT.TITLE:  ( string-address -- , SET screen title )
    iv=> iv-sc-title
;M
:M GET.TITLE:  ( -- string-address, GET screen title )
    iv-sc-title dup 0=
    IF
        drop " Untitled_Screen"   \ 00010
    THEN
;M

:M PUT.DRAW.FUNCTION: ( cfa -- , called before draw )
    iv=> iv-sc-draw-cfa
;M
:M GET.DRAW.FUNCTION: ( -- cfa , called before draw )
    iv-sc-draw-cfa
;M

:M PUT.UNDRAW.FUNCTION: ( cfa -- , called after undraw )
    iv=> iv-sc-undraw-cfa
;M
:M GET.UNDRAW.FUNCTION: ( -- cfa , called after undraw )
    iv-sc-undraw-cfa
;M

:M PUT.DOWN.FUNCTION: ( cfa --  , cfa to execute when mouse down )
     iv=> iv-sc-down-cfa
;M
:M GET.DOWN.FUNCTION:  ( -- cfa )
    iv-sc-down-cfa
;M
:M PUT.MOVE.FUNCTION: ( cfa --  , cfa to execute when mouse moves )
     iv=> iv-sc-move-cfa
;M
:M GET.MOVE.FUNCTION:  ( -- cfa )
    iv-sc-move-cfa
;M
:M PUT.UP.FUNCTION: ( cfa --  , cfa to execute when mouse up )
     iv=> iv-sc-up-cfa
;M
:M GET.UP.FUNCTION:  ( -- cfa )
    iv-sc-up-cfa
;M

:M PRINT.ELEMENT: ( e# -- , print name,x,y )
    get: self
    4 spaces rot name: []
    swap 8 .r 8 .r
;M

:M FREEALL:  ( -- , free held control grids )
    many: self 0
    ?DO i 0 ed.at: self free: []
    LOOP
;M

: (SCREEN.DRAW) ( -- )
    cg-drawing-screen @ 0= dup  ( leave flag for OFF at end )
    IF  cg-drawing-screen on     ( top level screen )
        gr.clear 1 gr.color!     ( don't clear if sub-screen )
    THEN
    service.tasks
\
    0 scg.selnt   ( set normalization transform for CGs )
    iv-sc-draw-cfa ?dup
    IF
        0 exec.stack?
    THEN
    service.tasks
\
    gr.height@
    gr_big_text gr.height!
    0 200 scg.move
    get.title: self gr.text
    gr.height!
\
    many: self ?dup
    IF 0 DO
           i get: self  2dup + 0>  ( specify x,y ? )
           IF 2 pick put.xy: []  ( set x,y of control )
           ELSE 2drop
           THEN ( -- control|subscreen )
\ add screen offsets for subscreen
           iv-scr-leftx  iv-scr-topy + 0>
           IF
              dup>r get.xy.dc: []
              >r iv-scr-leftx +  \ add offsets
              r> iv-scr-topy +
              r@ put.xy.dc: [] \ 00006
              r>
           THEN
           draw: []
           service.tasks
       LOOP
    ELSE " DRAW: in OB.SCREEN" " No controls!"
         er_return  er.report
    THEN
    IF  cg-drawing-screen off
        self cg-current-screen !
    THEN
;

:M UNDRAW: ( -- , undraw controls and then do undraw.function )
\ deactivate any active control 00002
    iv-sc-ctrl-hit ?dup
    IF
        0 swap put.active: []
        0 iv=> iv-sc-ctrl-hit
    THEN
\
    gr-curwindow @
    IF  many: self 0
        ?DO
            i 0 ed.at: self undraw: []
        LOOP
        iv-sc-undraw-cfa ?dup
        IF
            0 exec.stack?
        THEN
        false iv=> iv-sc-drawn
    THEN
    0 cg-current-screen !
    0 cg-drawing-screen !
;M

:M DRAW:   ( -- , Draw all the control objects )
    hmsl-window @
    IF hmsl.set.window
       cg-current-screen @ ?dup
       IF undraw: []
       THEN
       (screen.draw)
       true iv=> iv-sc-drawn
    ELSE " DRAW: SCREEN" " No window to DRAW: in!"
        er_fatal er.report
        cg-current-screen off
    THEN
;M

:M ?DRAWN: ( -- flag , true if drawn )
    iv-sc-drawn
;M

:M PUT.ACTIVE: ( active? -- , stub for embedded screens 00003 )
    drop
;M
:M GET.ACTIVE: (  -- active? , stub for embedded screens )
    FALSE
;M

:M MOUSE.DOWN:   { x y | flag -- flag, process mouse down event, scan controls }
    false -> flag  \ default to no hit 00004
    hmsl.set.window
    rnow
    many: self  0
    ?DO   ( Check for hits )
        x y i 0 ed.at: self mouse.down: []   ( mouse event trapped? )
        IF
            true -> flag  \ yes we hit one
            i 0 ed.at: self
\ change activation if ctrl changes
            dup iv-sc-ctrl-hit = not
            IF  iv-sc-ctrl-hit ?dup
                IF
                    FALSE swap put.active: []
                THEN
\ activate new control
                TRUE over put.active: []
            THEN
            iv=> iv-sc-ctrl-hit         ( save for up )
            leave 
        THEN
    LOOP
    flag dup not
    IF
        0 iv=> iv-sc-ctrl-hit
        iv-sc-down-cfa ?dup
        IF
            >r x y r> -2 exec.stack?
        THEN
    THEN
;M

:M MOUSE.UP:     ( x y -- , process mouse up event )
    hmsl.set.window
    iv-sc-ctrl-hit  ?dup 
    IF rnow mouse.up: []
    ELSE
        iv-sc-up-cfa ?dup
        IF
            -2 exec.stack?
        ELSE
            2drop
        THEN
    THEN
;M

:M MOUSE.MOVE:     ( x y -- , process mouse movement )
    hmsl.set.window
    iv-sc-ctrl-hit  ?dup 
    IF rnow mouse.move: []
    ELSE
        iv-sc-move-cfa ?dup
        IF
            -2 exec.stack?
        ELSE
            2drop
        THEN
    THEN
;M


:M KEY:     ( char -- , process keyboard input )
    hmsl.set.window
    iv-sc-ctrl-hit  ?dup 
    IF rnow key: []
    ELSE drop
    THEN
;M

:M DUMP.SOURCE:  ( -- , print code for screen layout )
    >newline 
\ Print width and height code for Controls
    many: self 0
    ?DO 4 spaces
       i 0 ed.at: self dup get.wh: [] swap . .
       ."  put.wh: " name: [] cr
    LOOP
\ Print code to build screen.
    4 spaces max.elements: self . ."  3 new: " name: self cr
    many: self 0
    ?DO 4 spaces
       i get: self rot name: []    bl 22 emit-to-column
       swap 8 .r 8 .r
       ."   add: " name: self cr
    LOOP
;M

:M PRINT:  ( -- )
    print: super
    ." Command Key = " iv-sc-key emit cr
;M

;CLASS

: SC.CHECK.EVENT ( -- done? , Process one event from event queue. )
    false         ( default done flag )
    ev.get.event  ( get one event )
    CASE
        EV_NULL OF ENDOF

        EV_MOUSE_DOWN OF cg-current-screen @ ?dup
                 IF ev.getxy rot mouse.down: [] drop THEN
             ENDOF

        EV_MOUSE_UP OF cg-current-screen @ ?dup 
                 IF ev.getxy rot mouse.up: [] THEN
             ENDOF

        EV_MOUSE_MOVE OF cg-current-screen @ ?dup 
                 IF ev.getxy rot mouse.move: [] THEN
             ENDOF

         EV_KEY OF ev.get.key ?dup \ 00001
                 IF cg-current-screen @ ?dup
                    IF key: []
                    ELSE drop
                    THEN
                 THEN
             ENDOF
             
        EV_CLOSE_WINDOW OF drop true .s
             ENDOF
    ENDCASE
;

: SC.RESET ( -- )
    " SC.RESET" debug.type
    gr-curwindow @
    IF gr.clear
    THEN
    cg-drawing-screen off
    cg-current-screen off
    default-screen off
;

: SC.INIT ( -- )
    " SC.INIT -- OB.SCREEN initialization!" debug.type
    sc.reset
    max_custom_screens new: custom-screens
;
: SC.TERM  ( -- )
    " SC.TERM" debug.type
    free: custom-screens
;

: SYS.INIT sys.init sc.init ;
: SYS.RESET sys.reset sc.reset ;
: SYS.TERM sc.term sys.term ;

true [IF]
: SC.TEST  ( screen -- )
    dup draw: []
    stack.mark
    BEGIN
        stack.check
        sc.check.event
    UNTIL
    undraw: []
;

[THEN]

