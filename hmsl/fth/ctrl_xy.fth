\ XY Continuous Controller
\
\ This can be used like a continuous joystick for
\ theremins, etc.  It can also be used for horizontal
\ or vertical faders.
\ The control is considered to have 2 parts, horizontal
\ and vertical.  Each "part" has its own value, min, and max.
\
\ The UP, DOWN and MOVE functions are passed:
\    ( x-value y-value -- )
\ instead of
\   ( value part# -- )
\
\ Use PUT.ENABLE: to disable horizontal or vertical motion
\ to make this into a 1D fader.
\
\ Author: Phil Burk
\ Copyright Phil Burk 1989

ANEW TASK-CTRL_XY

METHOD PUT.KNOB.SIZE:
METHOD GET.KNOB.SIZE:

METHOD X>VALUE:   METHOD VALUE>X:
METHOD Y>VALUE:   METHOD VALUE>Y:

3 value HIGHLIGHT_COLOR

0 constant XY_HORIZONTAL_PART
1 constant XY_VERTICAL_PART

:CLASS OB.XY.CONTROLLER <SUPER OB.NUMERIC.GRID
    iv.short IV-CG-XY-XOFF          \ offset within knob of click
    iv.short IV-CG-XY-YOFF
    iv.short IV-CG-XY-KNOB-XSIZE    \ in device coordinates
    iv.short IV-CG-XY-KNOB-YSIZE
    iv.short IV-CG-XY-KNOB-X        \ current X position
    iv.short IV-CG-XY-KNOB-Y        \ current Y position
    iv.byte  IV-CG-XY-IN-KNOB?      \ did mouse click in knob?

:M INIT:
    init: super
    10 iv=> iv-cg-xy-knob-xsize
    10 iv=> iv-cg-xy-knob-ysize
;M

:M NEW: ( -- , allocate two parts )
    1 2 new: super ( allocate two parts )
    1 iv=> iv-cg-numx  ( just one vertical part, and one horizontal )
    1 iv=> iv-cg-numy
;M

:M PUT.KNOB.SIZE: ( size part# -- , set in world coordinates )
\ size = 0 means don't display any knob
\ size < 0 means size in device coordinates
    over 0=
    IF drop iv=> iv-cg-xy-knob-xsize
       0 iv=> iv-cg-xy-knob-ysize
    ELSE  ( non-zero )
        over 0>  ( world coordinates ? )
        IF
            IF  0 swap scg.delta.wc->dc
               iv=> iv-cg-xy-knob-ysize drop
            ELSE 0 scg.delta.wc->dc
               drop iv=> iv-cg-xy-knob-xsize
            THEN
        ELSE
            IF  abs iv=> iv-cg-xy-knob-ysize
            ELSE abs iv=> iv-cg-xy-knob-xsize
            THEN
        THEN
    THEN
;M

:M GET.KNOB.SIZE: ( part -- size )
    IF  iv-cg-xy-knob-ysize
        0 swap scg.delta.dc->wc nip
    ELSE iv-cg-xy-knob-xsize
        0 scg.delta.dc->wc drop
    THEN
;M

: CG.XY.V>X  ( value -- x , of left edge of knob )
    xy_horizontal_part get.min: self -
    iv-cg-width iv-cg-xy-knob-xsize - 2-
\
    xy_horizontal_part get.max: self
    xy_horizontal_part get.min: self - 1 max */
    iv-cg-leftx + 1+
;

:M VALUE>X:  ( value -- x , x for center of knob )
    cg.xy.v>x  iv-cg-xy-knob-xsize 2/ +
;M

: CG.XY.X>V ( x -- value , x = left of knob )
    1- iv-cg-leftx -
    xy_horizontal_part get.max: self
    xy_horizontal_part get.min: self -
    iv-cg-width iv-cg-xy-knob-xsize - 2- 1 max */
    xy_horizontal_part get.min: self +
    xy_horizontal_part get.min: self
    xy_horizontal_part get.max: self clipto
;

:M X>VALUE:  ( x -- val , x at center of knob )
    iv-cg-xy-knob-xsize 2/ - cg.xy.x>v
;M

: CG.XY.V>Y  ( value -- y , y for top of knob )
    xy_vertical_part get.min: self -
    iv-cg-height iv-cg-xy-knob-ysize - 2-
\
    xy_vertical_part get.max: self
    xy_vertical_part get.min: self - 1 max */
    iv-cg-topy iv-cg-height + iv-cg-xy-knob-ysize - 1- swap - 
;
:M VALUE>Y:  ( value -- y , y for center of knob )
    cg.xy.v>y iv-cg-xy-knob-ysize 2/ +
;M

: CG.XY.Y>V  ( y -- value )
\ Calculate pixels from edge
    iv-cg-topy iv-cg-height + iv-cg-xy-knob-ysize - 1- swap -
\ Calculate range
    xy_vertical_part get.max: self xy_vertical_part get.min: self -
    iv-cg-height iv-cg-xy-knob-ysize - 2- 1 max */
    xy_vertical_part get.min: self +
    xy_vertical_part get.min: self xy_vertical_part get.max: self clipto
;
:M Y>VALUE:   ( y -- val , y at center )
    iv-cg-xy-knob-ysize 2/ - cg.xy.y>v 
;M

: CG.UNDRAW.KNOB ( -- , undraw from current position )
    iv-cg-xy-knob-xsize
    IF
        gr.color@
        0 gr.color!
        iv-cg-xy-knob-x
        iv-cg-xy-knob-y
        over iv-cg-xy-knob-xsize +
        over iv-cg-xy-knob-ysize +
        gr.rect
        gr.color!
    THEN
;

: CG.DRAW.KNOB  ( -- , draw knob of xy controller )
    iv-cg-xy-knob-xsize
    IF
        xy_horizontal_part get.value: self cg.xy.v>x ( x position of knob )
        dup iv=> iv-cg-xy-knob-x
        xy_vertical_part get.value: self cg.xy.v>y ( y position of knob )
        dup iv=> iv-cg-xy-knob-y
        over iv-cg-xy-knob-xsize +
        over iv-cg-xy-knob-ysize +
        gr.rect
    THEN
;

:M DRAW: ( -- )
    iv-cg-leftx iv-cg-topy
    over iv-cg-width + over iv-cg-height + ug.box
    iv-cg-draw-cfa ?execute
    cg.draw.knob
    1 gr.color!
    cg.draw.title
    ng.draw.labels
;M

:M ?HIT:  { mx my -- true_if_hit }
    false iv=> iv-cg-xy-in-knob?
    my iv-cg-topy dup iv-cg-height + 1- within?
    IF mx iv-cg-leftx dup iv-cg-width + 1- within?
        ( -- true_if_hit )
        dup
        IF  \ is it IN knob?
            mx
            iv-cg-xy-knob-x
            dup iv-cg-xy-knob-xsize + within?
            IF
                my
                iv-cg-xy-knob-y
                dup iv-cg-xy-knob-ysize + within?
                iv=> iv-cg-xy-in-knob?
            THEN
        THEN
    ELSE false
    THEN
;M

: CG.UPDATE.KNOB ( -- )
    cg.undraw.knob
    cg.draw.knob
;

: CG.XY.SETVALS  ( x y --  changed?)
    xy_vertical_part get.enable: self \ is Y enabled
    IF
        iv-cg-xy-yoff - cg.xy.y>v
        xy_vertical_part get.value: self over =
        IF drop false
        ELSE xy_vertical_part put.value: self true
        THEN  ( -- ychanged? )
    ELSE
        drop false  ( -- x y-not-changed )
    THEN
\
    swap
    xy_horizontal_part get.enable: self
    IF
        iv-cg-xy-xoff - cg.xy.x>v
        xy_horizontal_part get.value: self over =
        IF drop false
        ELSE xy_horizontal_part put.value: self true
        THEN  ( -- ychanged? xchanged? )
    ELSE
        drop false  ( -- x y-not-changed )
    THEN
\
    OR  ( if either one changed )
;

:M EXEC.DOWN: ( -- )
    cg-first-mx @ cg-first-my @
\
\ set offsets for knob
    iv-cg-xy-in-knob?
    IF ( -- x y , track knob )
        dup xy_vertical_part get.value: self cg.xy.v>y -
        iv=> iv-cg-xy-yoff
        over xy_horizontal_part get.value: self cg.xy.v>x -
        iv=> iv-cg-xy-xoff 
    ELSE
        iv-cg-xy-knob-xsize 2/ iv=> iv-cg-xy-xoff
        iv-cg-xy-knob-ysize 2/ iv=> iv-cg-xy-yoff
    THEN
\
\ update values
    cg.xy.setvals
    IF    
       highlight_color gr.color!
       cg.update.knob
    THEN
    ev.track.on
;M

:M MOUSE.DOWN: (  x y -- trapped? , process mouse DOWN event )
\ execute even if disabled
    2dup self ?hit: []
    IF  cg-first-my !   cg-first-mx !
        self exec.down: [] true
        iv-cg-down-cfa self execute: []
    ELSE 2drop false
    THEN
;M

:M EXECUTE: ( cfa | 0 -- , pass x & y values )
    ?dup
    IF
        >r xy_horizontal_part get.value: self
        xy_vertical_part get.value: self
        r> execute
    THEN
;M

:M MOUSE.MOVE: ( x y -- )
    2dup cg-last-my !   cg-last-mx !
    cg.xy.setvals
    IF iv-cg-move-cfa self execute: []
       highlight_color gr.color!
       cg.update.knob
    THEN
;M

:M MOUSE.UP:  ( x y -- )
    1 gr.color!
    mouse.up: super-dooper
    ev.track.off
    cg.update.knob  
;M

;CLASS

\ Utility functions to make an XY controller only vertical or horizontal
: XY.ONLY.HORIZONTAL ( cg-xy -- )
    >r  0 xy_vertical_part r@ put.enable: [] \ disable vertical part
    r@ get.wh.dc: []  \ ( -- width height )
    NIP 2- negate \ subtract borders from HEIGHT
    xy_vertical_part r> put.knob.size: []
;

: XY.ONLY.VERTICAL ( cg-xy -- )
    >r  0 xy_horizontal_part r@ put.enable: [] \ disable horizontal part
    r@ get.wh.dc: []  \ ( -- width height )
    DROP 2- negate \ subtract borders from WIDTH
    xy_horizontal_part r> put.knob.size: []
;

