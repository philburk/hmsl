\ Select object and counter control definitions
\
\ Author: Phil Burk
\ Copyright 1986 -  Phil Burk, Larry Polansky, David Rosenboom.
\ All Rights Reserved
\
\ MOD: PLB 10/11/86 Add CUSTOM.EXEC: SUPER to CUSTOM.EXEC: to fix
\      wierd highlighting.
\ MOD: PLB 8/8/88 Convert to new system.
\ MOD: PLB 1/23/90 Fixed and disabled CG.HIT.MIDDLE, don't zero.
\ MOD: PLB 2/6/90 Moved out TEXT.FUNCTION:
\ 00001 PLB 2/21/92 Added 3D insets.

ANEW TASK-CTRL_COUNT

:CLASS OB.COUNTER <SUPER OB.CONTROL

:M INIT: ( -- )
    init: super
    0 iv=> iv-cg-min
;M

: CG.DRAW.UPARROW ( -- )
    iv-cg-leftx 1+ iv-cg-topy iv-cg-height 4/ + 2dup gr.move
    iv-cg-leftx iv-cg-width 2/ + iv-cg-topy 1+ gr.draw
    iv-cg-leftx 1- iv-cg-width +
        iv-cg-topy iv-cg-height 4/ + gr.draw gr.draw
;

: CG.DRAW.DOWNARROW ( -- )
    iv-cg-leftx 1+ iv-cg-topy iv-cg-height 2/ dup 2/ + +
    2dup gr.move
    iv-cg-leftx iv-cg-width 2/ + iv-cg-topy iv-cg-height + 1- gr.draw
    iv-cg-leftx 1- iv-cg-width +
        iv-cg-topy iv-cg-height 2/ dup 2/ + + gr.draw gr.draw
;

: CG.DRAW.BOX  ( -- , clear and draw box around control )
    0 gr.color!
    -1 get.rect: self gr.rect
    1 gr.color!
    cg-3d @
    IF
    	-1 0 cg.draw.part.bevel
    ELSE
    	-1 get.rect: self ug.box
    THEN
;

: CG.DRAW.ARROWS
    cg.draw.box
    cg.draw.uparrow
    cg.draw.downarrow
\
\ position for text
    iv-cg-leftx 2+
        iv-cg-topy iv-cg-height 2/ dup 2/ + 4- + ( x y ) gr.move
;

: CG.DRAW.VALUE  ( -- )
    cg.draw.arrows
    0 get.value: self
    iv-cg-text-cfa ?dup
    IF execute
    ELSE n>text
    THEN
    dup 256 u>
    IF
    	" CG.DRAW.VALUE" " Text too long"
    	er_return ob.report.error
    	2drop
    ELSE gr.type
    THEN
;

:M DRAW: ( -- , Draw value )
    draw: super
    cg.draw.value
;M

:M ?HIT: ( x y -- true_if_hit )
    swap iv-cg-leftx dup iv-cg-width + 1- within?
    IF iv-cg-topy  iv-cg-height 4/  4  ug.?hit
       IF iv=> iv-cg-lasthit true
       ELSE false
       THEN
    ELSE drop false
    THEN
;M

: CG.HIT.MIDDLE  ( -- , zero if numeric )
    iv-cg-text-cfa 0=
    IF 0 0 self put.value: []
    THEN
;

:M EXEC.DOWN: ( -- , change number as needed )
    iv-cg-lasthit
    CASE
       0 OF iv-cg-value iv-cg-incr + dup iv-cg-max >
              IF drop iv-cg-min
              THEN   0 put.value: self ENDOF
       1 OF ( cg.hit.middle ) ENDOF
       2 OF ( cg.hit.middle ) ENDOF
       3 OF iv-cg-value iv-cg-incr - dup iv-cg-min <
              IF drop iv-cg-max
              THEN   0 put.value: self ENDOF
    ENDCASE
    cg.draw.value
;M

;CLASS
