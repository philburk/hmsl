\ Set startup vector for HMSL
\
\ Author: Phil Burk
\ Copyright 1986 -  Phil Burk, Larry Polansky, David Rosenboom.
\ All Rights Reserved

ANEW TASK-STARTUP

: HMSL.INIT.ASK  ( -- , Ask if user wants to HMSL.INIT )
    hmsl.copyright
    ." Do you want to initialize HMSL? (probably Yes)" Y/N cr
    IF hmsl.init
    ELSE ob.init
    THEN
;

: AUTO.INIT  ( -- , called automatically at startup )
    auto.init
    hmsl.init.ask
;
