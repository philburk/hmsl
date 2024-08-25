\ Random walk.
\ Author: Phil Burk
\ Copyright 1986 -  Phil Burk, Larry Polansky, David Rosenboom.
\
\ MOD: PLB 6/4/87 Changed SET to PUT to conform to naming conv.

MRESET WALK:
ANEW TASK-RAN_WALK

METHOD WALK:
METHOD PUT.MIN:
METHOD PUT.MAX:
METHOD PUT.STEP:
METHOD CLIP:
METHOD STEP:

:CLASS OB.RANDOM.WALK <SUPER OB.INT
    IV.LONG IV-RW-MIN
    IV.LONG IV-RW-MAX
    IV.LONG IV-RW-STEP
    IV.LONG IV-RW-CUR

:M INIT: ( -- )
    0 iv=> iv-rw-min
    255 iv=> iv-rw-max
    5 iv=> iv-rw-step
    0 iv=> iv-rw-cur
    init: super
;M

:M PUT.MIN:  ( min -- )
    iv=> iv-rw-min
;M

:M PUT.MAX:  ( max -- )
    iv=> iv-rw-max
;M

:M PUT.STEP:  ( step -- )
    iv=> iv-rw-step
;M

:M CLIP: ( val -- legalval )
    dup iv-rw-min <
    IF drop iv-rw-min
    ELSE dup iv-rw-max >
        IF drop iv-rw-max
        THEN
    THEN
;M

:M STEP:   ( -- , newval )
    iv-rw-cur iv-rw-step dup 2/
    swap choose swap - + \ calculate balanced step
;M

:M WALK:  (  -- rval , new random walk position. )
    self step: []
    self clip: []
    dup iv=> iv-rw-cur
;M

;CLASS

false .IF
OB.RANDOM.WALK RW1
: RW.TEST  ( -- )
    BEGIN
         walk: rw1 . cr
         ?terminal
    UNTIL
;
.THEN
