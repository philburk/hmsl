\ Set vectors for HMSL

\
\ Author: Phil Burk
\ Copyright 1986 -  Phil Burk, Larry Polansky, David Rosenboom.
\ All Rights Reserved

ANEW TASK-SET_VECTORS.FTH

DEFER OLD.ABORT

: SET.ABORT  ( cfa -- , set abort function )
    what's old.abort ' quit -
    IF cr >name id. cr
       ." SET.ABORT - Abort already set!" cr
    ELSE
       what's abort is old.abort
       is abort
    THEN
;

: RESET.ABORT ( -- , reset abort to original function )
    what's old.abort ' quit -
    IF  what's old.abort is abort
        ' quit is old.abort
    THEN
;

DEFER OLD.KEY

: SET.KEY  ( cfa -- , set KEY function )
    what's OLD.KEY ' quit -
    IF cr >name id. cr
       ." SET.KEY - KEY already set!" cr
    ELSE
       what's KEY is old.KEY
       is KEY
    THEN
;

: RESET.KEY ( -- , reset KEY to original function )
    what's OLD.KEY ' quit -
    IF  what's old.KEY is KEY
        ' quit is old.key
\    ELSE cr ." RESET.KEY - KEY not set!" cr
    THEN
;

DEFER OLD.EMIT

: SET.EMIT  ( cfa -- , set EMIT function )
    what's OLD.EMIT ' quit -
    IF cr >name id. cr
       ." SET.EMIT - EMIT already set!" cr
    ELSE
       what's EMIT is old.EMIT
       is EMIT
    THEN
;

: RESET.EMIT ( -- , reset EMIT to original function )
    what's OLD.EMIT ' quit -
    IF  what's old.EMIT is EMIT
        ' quit is old.EMIT
\    ELSE cr ." RESET.EMIT - EMIT not set!" cr
    THEN
;

