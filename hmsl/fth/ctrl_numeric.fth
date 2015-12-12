\ Numeric Grid - numbers on grid, click on one, move up or down
\ to change number.
\ Move to the right for coarse control,
\  to the left for fine control.
\
\ Copyright 1989 Phil Burk
\
\ MOD: PLB 2/10/91 Use GR.START.DIM
\ MOD: PLB 6/3/91 c/gr.height@/iv-cg-text-size/
\ MOD: PLB 6/24/91 set default max to 127
\ 00001 PLB 2/21/92 Inset further if 3D


ANEW TASK-CTRL_NUMERIC

variable CG-PREV-MX
variable CG-PREV-MY
variable CG-PREV-TIME
variable CG-DELTA-MODE
0 constant CG_POS_MODE
1 constant CG_SPEED_MODE

:CLASS OB.NUMERIC.GRID <SUPER OB.CHECK.GRID
    ob.elmnts iv-cg-limits  ( dim 0 = min, dim 1 = max )

:M PUT.MIN: ( value part -- , set min )
    dup 0<
    IF  swap  many: iv-cg-limits 0
        ?DO dup i 0 ed.to: iv-cg-limits  ( set each one )
        LOOP
        swap put.min: super
    ELSE dup>r 0 ed.to: iv-cg-limits r> cg.clip.part
    THEN
;M

:M GET.MIN: ( part -- value , get min )
    dup 0<
    IF get.min: super
    ELSE 0 ed.at: iv-cg-limits
    THEN
;M

:M PUT.MAX: ( value part -- , set max )
    dup 0<
    IF  swap  many: iv-cg-limits 0
        ?DO dup i 1 ed.to: iv-cg-limits  ( set each one )
        LOOP
        swap put.max: super
    ELSE dup>r 1 ed.to: iv-cg-limits r> cg.clip.part
    THEN
;M
:M GET.MAX: ( part -- value , get max )
    dup 0<
    IF get.min: super
    ELSE 1 ed.at: iv-cg-limits
    THEN
;M

:M INIT: ( -- )
    init: super
    0 iv=> iv-cg-min
    127 iv=> iv-cg-max
;M

: NCG.CLIP.VALUE ( value part -- value' part )
    dup>r get.min: self
    r@ get.max: self clipto r>
;

:M PUT.VALUE: ( value part -- )
    dup>r
    ncg.clip.value  to: iv-cg-values
\ update drawing of self if needed
    ?drawn: self
    IF  r@ clear.part: self
        r@ self draw.part: []
    THEN
    rdrop
;M

:M GET.VALUE:  ( part -- value )
     at: iv-cg-values
;M

:M FREE:  ( -- )
    free: iv-cg-limits
    free: super
;M

:M NEW: ( nx ny -- )
    2dup new: super
    * dup 2 new: iv-cg-limits
    set.many: iv-cg-limits
    -1 get.min: self -1 put.min: self  ( update parts )
    -1 get.max: self -1 put.max: self
;M

:M DRAW.PART: ( part -- , draw a single part of a control )
    >r
\
\ Use smaller characters or color 2 if the cell is disabled.
    r@ get.enable: self 0=
    IF gr.start.dim
    THEN
    service.tasks
\ Position in cell
    r@ cg.part.topleft
    iv-cg-text-size + 1+ swap ( -- y x )
    r@ get.value: self n>text gr.textlen - ( right justify )
\
\ move in farther if using 3D bevel, 00001
    cg-3d @
    IF
        cg-bevel-thickness @ -
    ELSE
        1-
    THEN
    iv-cg-width + swap gr.move
\
\ Draw number
    r@ get.value: self gr.number
    r@ get.enable: self 0=
    IF gr.end.dim
    THEN
    rdrop
;M

: NG.DRAW.LABELS  ( -- , draw side labels )
    iv-cg-numy 0
    ?DO iv-cg-text-cfa
       IF i iv-cg-text-cfa 1 exec.stack?  ( -- addr c )
       ELSE i get.text: self count
       THEN
       ?dup
       IF
\ right justify text
            2dup gr.textlen  ( -- a c xpixels )
            iv-cg-leftx 2- swap -  ( -- addr count x' )
            iv-cg-topy i 1+ iv-cg-height * + 4- gr.move
            gr.type
       ELSE drop
       THEN
    LOOP
;

:M DRAW:  ( -- )
    draw: super
    ng.draw.labels
;M

: CG.BELOW.MIDDLE? ( -- flag )
     iv-cg-lasthit iv-cg-numx  / iv-cg-height  * iv-cg-topy  +
     iv-cg-height 2/ +  ( y midline of part hit )
     cg-first-my @ <
;

: CG.CHANGE.VALUE  ( delta -- , used to change value )
    iv-cg-lasthit get.value: self +
    iv-cg-lasthit put.value: self
;

:M EXEC.DOWN: ( -- )
\ Increment or decrement if above or below line
    get.increment: self    cg.below.middle?
    IF negate
    THEN   cg.change.value
\
\ Set up for tracking.
    ev.track.on
    cg-first-mx @ cg-prev-mx !
    cg-first-my @ cg-prev-my !
    iv-cg-lasthit highlight: self
;M

: CG.CALC.DELTA.POS  ( -- dv , delta based on x position)
    cg-prev-my @ cg-last-my @ -  ( dy , with up=positive)
    cg-last-mx @ cg-first-mx @ - ( -- dy xdist )
    iv-cg-width 2* + 0 max
    iv-cg-width 5 * min    ( active 2widths to either side )
\ biggest = range/height/4
\ dv = ( biggest + 5*width/height) * dy / 5*width
    iv-cg-lasthit get.max: self
    iv-cg-lasthit get.min: self - ( range )
    iv-cg-height 4* / 1 max   *
    iv-cg-width 5 * dup>r iv-cg-height / +
    * r> /
    dup
    IF  cg-last-mx @ cg-prev-mx !
        cg-last-my @ cg-prev-my !
    THEN
;

: CG.CALC.DV  { dy dt height range -- dv }
    dy dup abs *
    5 ashift height /  ( scale by pixels per active area )
    dt / ( scaled by time )
    range 8 max *
    -12 ashift
;
1 cg-delta-mode !

: CG.CALC.DELTA.SPEED  ( -- dv , delta based on speed)
    cg-prev-my @ cg-last-my @ -  ( dy , with up=positive)
    time@ cg-prev-time @ over cg-prev-time ! - ( dt )
    6 ashift rtc.rate@ /  ( normalize to 64 ticks/second )
    1 64 clipto
    iv-cg-height  ( height of active area )
    iv-cg-lasthit get.max: self
    iv-cg-lasthit get.min: self - ( range )
    ( -- dy dt height range ) cg.calc.dv
    dup
    IF  cg-last-mx @ cg-prev-mx !
        cg-last-my @ cg-prev-my !
    THEN
;

: CG.CALC.DELTA  ( -- dv , use chosen mode )
    cg-delta-mode @
    CASE
        cg_pos_mode OF cg.calc.delta.pos ENDOF
        cg_speed_mode OF cg.calc.delta.speed ENDOF
        ." Illegal CG-DELTA-MODE" cr 0
    ENDCASE
;

:M MOUSE.MOVE:   ( x y -- , process mouse MOVE event )
    cg-last-my !   cg-last-mx !
    cg.calc.delta ?dup
    IF  iv-cg-lasthit get.value: self >r
        cg.change.value
        iv-cg-lasthit get.value: self r> -
        IF iv-cg-move-cfa self execute: []  ( only call if value changes )
        THEN
    THEN
;M

:M MOUSE.UP:  ( x y -- , process mouse UP event )
    ev.track.off
    iv-cg-lasthit clear.part: self
    iv-cg-lasthit draw.part: self
    mouse.up: super
;M

;CLASS

