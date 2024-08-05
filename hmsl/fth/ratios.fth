\ Ratio based tuning systems.
\ Just intoned scales can be created using this class.
\
\ Author: Phil Burk
\ Copyright 1986 - David Rosenboom, Larry Polansky, Phil Burk.
\ All Rights Reserved
\
\ MOD: PLB 5/24/87 Add SYS.INIT
\ MOD: PLB 11/16/87 Print 1/1

MRESET PUT.1/1:

ANEW TASK-RATIOS

METHOD PUT.1/1:
METHOD GET.1/1:

:CLASS OB.TUNING.RATIOS <SUPER OB.SHAPE
    IV.LONG IV-RAT-1/1

:M INIT: ( -- )
    init: super
    9240 iv=> iv-rat-1/1
;M

:M NEW:  ( #pairs -- )
    2 new: super
;M

\ Try to use a base period that divides evenly by the ratios used.
:M PUT.1/1:  ( 1/1_period -- , Set base period for 1/1 ratio )
    iv=> iv-rat-1/1
;M

:M GET.1/1:  ( -- 1/1_period , base period for 1/1 ratio )
    iv-rat-1/1
;M

:M TRANSLATE: ( index -- period , Convert index to a period )
    many: self /mod     ( -- r q )
    iv-rat-1/1 rot      ( -- q 1/1 r )
    get: self swap */   ( -- q p ,  calculate base period )
    swap negate ashift  ( shift to proper octave )
;M

:M PLAY: ( -- , play ratios )
    da.start
    many: self 0 DO
        i translate: self
        da.period! 500 msec
        ?terminal IF leave THEN
    LOOP
    da.stop
;M

:M PRINT: ( -- )
    print: super
    ." 1/1 period = " iv-rat-1/1 . cr
;M
;CLASS

: RATIO*  ( n1 d1 n2 d2 -- n1*n2 d1*d2 , multiply two ratios )
    rot *  ( denominators )
    >r * r> ( numerator )
;

\ Some stock tunings.
OB.TUNING.RATIOS RATIOS-SLENDRO
OB.TUNING.RATIOS RATIOS-OVERTONE

: RAT.INIT  ( -- , Initialize tuning systems. )
    " RAT.INIT" debug.type
    5 new: ratios-slendro
    1 1 add: ratios-slendro
    8 7 2dup add: ratios-slendro
    8 7 ratio* add: ratios-slendro
    3 2 add: ratios-slendro
    12 7  add: ratios-slendro

    12 new: ratios-overtone
    12 0 DO
        i 12 + 12 add: ratios-overtone
    LOOP
;
: RAT.TERM
    " RAT.TERM" debug.type
    free: ratios-slendro
    free: ratios-overtone
;

: SYS.INIT sys.init rat.init ;
: SYS.TERM rat.term sys.term ;
