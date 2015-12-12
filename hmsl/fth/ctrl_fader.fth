\ Fader control class.
\ Useful for on screen mixers or other continuous controllers.
\
\ Author: Phil Burk
\ Copyright Phil Burk 1989
\
\ MOD: PLB 6/14/90  Moved Fader numeric display down 2 pixels
\ MOD: PLB 1/28/91  Shrank Fader range for better updating,
\			PUT.VALUE: now updates display if drawn.
\ MOD: PLB 6/5/91 Fixed knob updating, with Darren Gibbs

ANEW TASK-CTRL_FADER

METHOD PUT.KNOB.SIZE:
METHOD GET.KNOB.SIZE:
METHOD IF.SHOW.VALUE:

:CLASS OB.FADER <SUPER OB.CONTROL
    iv.short IV-CG-YOFF
    iv.short IV-CG-KNOB-SIZE
	iv.short IV-CG-KNOB-Y
    iv.short IV-CG-SHOWV?

:M INIT:
    init: super
    10 iv=> iv-cg-knob-size
    true iv=> iv-cg-showv?
;M

:M PUT.KNOB.SIZE: ( size -- , set in world coordinates )
    0 swap scg.delta.wc->dc 1 max
    iv=> iv-cg-knob-size drop
;M

:M GET.KNOB.SIZE: ( -- size )
    iv-cg-knob-size
    0 swap scg.delta.dc->wc
;M

:M IF.SHOW.VALUE:  ( flag -- )
    iv=> iv-cg-showv?
;M

: CG.FADER.VAL>Y   ( value -- y , y for top of knob )
    iv-cg-min -
    iv-cg-height iv-cg-knob-size - 2-
    iv-cg-max iv-cg-min - 1 max */
    iv-cg-topy iv-cg-height + iv-cg-knob-size - 1- swap -
;

: CG.FADER.Y>VAL   ( y -- val )
    iv-cg-topy iv-cg-height + iv-cg-knob-size - 1- swap -
    iv-cg-max iv-cg-min -
    iv-cg-height iv-cg-knob-size - 2- 1 max */
    iv-cg-min + cg.clip.value
;

: CG.KNOB.AT.Y  ( y -- , draws the knob at Y )
	dup iv=> iv-cg-knob-y
    iv-cg-leftx 2+ swap
    iv-cg-leftx iv-cg-width + 2- over iv-cg-knob-size +
    gr.rect
;

: CG.FADER.KNOB  ( -- , draw knob of fader )
    iv-cg-value cg.fader.val>y ( y position of knob )
	cg.knob.at.y
;

: CG.FADER.VALUE ( -- , display value of fader )
    iv-cg-showv?
    IF  iv-cg-topy iv-cg-height + 14 +
        iv-cg-leftx iv-cg-width 2/ +  ( middle )
        iv-cg-value n>text gr.textlen 2/ -
        swap gr.move iv-cg-value gr.number
    THEN
;

:M DRAW: ( -- )
    draw: super
    cg.draw.box
    cg.fader.knob
    cg.fader.value
;M

:M PUT.VALUE: ( value part -- , set value , update display )
	?drawn: self
	IF	0 gr.color!
		iv-cg-knob-y cg.knob.at.y
    	cg.fader.value
	THEN
\
	put.value: super
\
	?drawn: self
	IF	1 gr.color!
		cg.fader.knob
    	cg.fader.value
	THEN
;M

:M ?HIT:  ( mx my -- true_if_hit )
    swap iv-cg-leftx dup iv-cg-width + 1- within?
    IF dup iv-cg-topy dup iv-cg-height + 1- within?
       IF  ( -- y )
           0 get.value: self cg.fader.val>y 2dup <
           IF 2drop 0 \ above knob
           ELSE dup iv-cg-knob-size + within?
               IF 1 \ on knob
               ELSE 2 \ below knob
               THEN
           THEN  iv=> iv-cg-lasthit true
       ELSE drop false
       THEN
    ELSE drop false
    THEN
;M

:M EXEC.DOWN: ( -- )
    iv-cg-lasthit
    CASE
    1 OF  ev.track.on
          cg-first-my @ iv-cg-value cg.fader.val>y -
          iv=> iv-cg-yoff
      ENDOF
    0 OF iv-cg-value get.increment: self +
         0 self put.value: []
      ENDOF
    2 OF iv-cg-value get.increment: self -
         0 self put.value: []
      ENDOF
    ENDCASE
;M

:M MOUSE.MOVE: ( x y -- )
    nip    3 gr.color!
    iv-cg-yoff - cg.fader.y>val
    0 get.value: self over =
    IF drop
    ELSE 0 self put.value: []
        iv-cg-move-cfa self execute: []
    THEN
;M

:M MOUSE.UP:  ( x y )
    mouse.up: super
    iv-cg-lasthit 1 =
    IF  ev.track.off
    THEN
    self draw: []
;M

;CLASS

    
