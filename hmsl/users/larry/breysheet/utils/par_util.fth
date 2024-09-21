\ Test 8520 access.
\ The parallel port is on 8520-A DRB

ANEW TASK-PAR_util

hex
BFE101 constant PAR-DATA-ADDR
BFE301 constant PAR-DIR-ADDR

: PAR.SET.I/O  ( byte -- , set data direction registers )
\ bit = 0-input , 1-output
    par-dir-addr absc!
;

: PAR@ ( -- byte )
    par-data-addr absc@
;

: PAR! ( byte -- )
    par-data-addr absc!
;

: PAR.OUTPUT.MODE
    FF par.set.i/o
;

: PAR.INPUT.MODE
    00 par.set.i/o
;

: PAR.TEST  ( byte1 byte2 -- , alternate byte values )
    par.output.mode
    BEGIN
        over par! 100 msec
        dup  par! 100 msec
        ?terminal
    UNTIL 2drop
;

VARIABLE PAR-DELAY
10 par-delay !

: PAR.WATCH  ( -- , monitor changes on parallel port )
    par.input.mode
    0
    BEGIN
        par@ dup 2 pick - abs 1 > ( change beyond jitter? )
        IF dup . swap drop cr
        ELSE drop
        THEN
        par-delay @ 0 DO LOOP
        ?terminal
    UNTIL drop
;

    
decimal
