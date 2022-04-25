\ Dynamic Collection
\ Basis for a Collection Tutorial
\
\ Author: Phil Burk
\ Copyright 1990

ANEW TASK-DEMO_STARTSTOP


: SS.START  ( collection -- )
    >r  ( save on return stack )
    stuff{
        instantiate ob.player dup prefab: []
        instantiate ob.player dup prefab: []
        instantiate ob.player dup prefab: []
        instantiate ob.player dup prefab: []
    r@ }stuff: []
    r> print.hierarchy: []
;

: SS.REPEAT  ( collection -- )
    2 CHOOSE
    IF act.sequential: []
    ELSE act.parallel: []
    THEN
;

: SS.STOP  ( collection -- , get rid of players )
    dup many: []  0
    DO i over get: []  ( get player )
        deinstantiate
    LOOP drop
;

OB.COLLECTION SS-COL

: SS.INIT  ( -- , setup collection
    'c ss.start   put.start.function: ss-col
    'c ss.repeat  put.repeat.function: ss-col
    'c ss.stop    put.stop.function: ss-col
    20 put.repeat: ss-col
;

: SS.TERM  ( -- )
    free: ss-col
;

: StartStop
    ss.init
    ss-col  HMSL.PLAY
    ss.term
;

