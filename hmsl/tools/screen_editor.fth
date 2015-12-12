\ Edit Screens by dragging around the controls to where you want them.
\
\ Drag a control by clicking on and dragging.
\ Select a control by a simple click.
\ A selected control will draw a grow box outside corner.
\ Click on it to grow control.
\
\ Autjor: Phil Burk
\ Copyright 1990
\
\ MOD: PLB 2/27/90 Fixed stack problems.
\ MOD: PLB 10/30/90 c/)/}/
\ 00001 PLB 2/12/92 Used +!

ANEW TASK-SCREEN_EDITOR

variable SCR-CG-HIT
variable SCR-MOVED
variable SCR-LAST-X1
variable SCR-LAST-Y1
variable SCR-LAST-X2
variable SCR-LAST-Y2
variable SCR-DOWN-X
variable SCR-DOWN-Y
variable SCR-IF-DRAG
variable SCR-STRETCH-X
variable SCR-STRETCH-Y

: SCR.UNDRAW.BOX ( -- , undraw box at current position )
    gr.mode@
    gr_xor_mode gr.mode!
    scr-last-x1 @ scr-last-y1 @ scr-last-x2 @ scr-last-y2 @
    ug.box
    gr.mode!
;

: SCR.MOUSE.DOWN  { | curx cury control -- }
    scr-cg-hit off
    scr-moved off
    gr.getxy -> cury -> curx
    cg-current-screen @
    many: []  0
    DO   ( Check for hits )
        i 0 cg-current-screen @ ed.at: [] -> control
        curx cury control ?hit: []   ( mouse event trapped? )
        IF   control scr-cg-hit ! ev.track.on
             cury scr-down-y !   curx scr-down-x !
\ Save Box Outline
             -1 control get.rect: []
             scr-last-y2 ! scr-last-x2 ! scr-last-y1 ! scr-last-x1 !
\
\ Figure out whether to drag or stretch.
\ Stretch if past half way point.
             curx scr-last-x2 @ scr-last-x1 @ + 2/ ( average x )
             > scr-stretch-x !
             cury scr-last-y2 @ scr-last-y1 @ + 2/ ( average y )
             > scr-stretch-y !
\
\ Drag if no stretching.
             scr-stretch-x @ scr-stretch-y @ or 0= scr-if-drag !
             leave 
        THEN
    LOOP
;

: SCR.APPLY.STRETCH  { | old_dx old_dy w h -- , calc stretches }
    -1 scr-cg-hit @ get.rect: []  ( -- x1 y1 x2 y2 )
    rot - -> old_dy ( -- x1 x2 old_dy )
    swap - -> old_dx
    scr-cg-hit @ get.wh: [] -> h -> w
    scr-stretch-x @
    IF w   scr-last-x2 @ scr-last-x1 @ - *
        old_dx 2/ + ( round up )
        old_dx  / -> w
    THEN
    scr-stretch-y @
    IF h  dup . scr-last-y2 @ scr-last-y1 @ - dup . * dup .
        old_dy 2/ +  dup . ( round up )
        old_dy  / dup . cr -> h
    THEN
    w h scr-cg-hit @ put.wh: []
;

: SCR.MOUSE.UP   ( -- )
    scr-moved @
    IF  scr.undraw.box
\ Find entry in screen and update x,y
        cg-current-screen @ many: [] 0
        DO   i 0 cg-current-screen @ ed.at: []
             scr-cg-hit @ =
             IF
\ Apply drag
                 scr-if-drag @
                 IF  scr-cg-hit @
                     scr-last-x1 @ scr-last-y1 @  scg.dc->wc
                     i cg-current-screen @ put: []
                 ELSE
\ Apply stretches
                     scr.apply.stretch
                 THEN
                 leave
             THEN
        LOOP
        cg-current-screen @ dup undraw: [] draw: []
    THEN
    ev.track.off
    scr-moved off
;

: SCR.DRAG.BOX { curx cury | dx dy -- , drag to new position }
    curx scr-down-x @ - -> dx
    cury scr-down-y @ - -> dy
    dx scr-last-x1 +! \ 00001
    dy scr-last-y1 +!
    dx scr-last-x2 +!
    dy scr-last-y2 +!
    curx scr-down-x !
    cury scr-down-y !
;
    
: SCR.MOUSE.MOVE  ( -- )
     scr-moved @
     IF  ( not first movement )
         scr.undraw.box
     THEN
     gr.getxy 
     scr-if-drag @
     IF scr.drag.box  
        scr.undraw.box
     ELSE
         scr-stretch-y @
         IF scr-last-y2 !
         ELSE drop
         THEN
         scr-stretch-x @
         IF scr-last-x2 !
         ELSE drop
         THEN
         scr.undraw.box
     THEN
     scr-moved on
;

: SCR.CHECK.EVENT ( -- done? , Process one event from event queue. )
    false         ( default done flag )
    ev.get.event  ( get one event )
    CASE
         EV_NULL OF ENDOF

         EV_MOUSE_DOWN OF scr.mouse.down
             ENDOF

         EV_MOUSE_UP OF scr.mouse.up
             ENDOF

         EV_MOUSE_MOVE OF scr.mouse.move
             ENDOF

         EV_CLOSE_WINDOW OF drop true
             ENDOF

         EV_REFRESH OF
                hmsl.refresh
         ENDOF
    ENDCASE
;

: EDIT.SCREEN  ( screen -- )
    hmsl.open
    dup draw: []
    stack.mark
    BEGIN
        stack.check
        scr.check.event
    UNTIL
    dup undraw: []
    hmsl.close
    dump.source: []
;

