\ Host specific code for vectoring ABORT.
\ The words used outside this file are:
\ SET.ABORT and RESET.ABORT and OLD.ABORT
\
\ JForth uses DEFER for it's vectored words.
\
\ Author: Phil Burk
\ Copyright 1986 -  Phil Burk, Larry Polansky, David Rosenboom.
\ All Rights Reserved

ANEW TASK-AJF_ABORT

DEFER OLD.ABORT
VARIABLE IF-ABORT-SET

: SET.ABORT  ( cfa -- , set abort function )
    if-abort-set @
    IF cr >name id. cr
       ." SET.ABORT - Abort already set!" cr
    ELSE
       what's abort is old.abort
       is abort
       true if-abort-set !
    THEN
;

: RESET.ABORT ( -- , reset abort to original function )
    if-abort-set @
    IF  what's old.abort is abort
        false if-abort-set !
    ELSE cr ." RESET.ABORT - ABORT not set!" cr
    THEN
;
