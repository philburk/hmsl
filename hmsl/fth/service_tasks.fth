\ Support pseudo multi-tasking by calling a CFA
\ from within words that take a long time.
\ HMSL maintains the real time polling by calling this
\ word from inside the interactive graphics words.
\
\ Author: Phil Burk
\ Copyright 1986 -  Phil Burk, Larry Polansky, David Rosenboom.

ANEW TASK-SERVICE_TASKS

U: TASKS-CFA  ( Set by later definitions )
U: SERVICING-TASKS

: SERVICE.TASKS  ( -- , Execute real time tasks )
\ Avoid recursion by setting flag when going in.
    servicing-tasks @ 0=
    IF servicing-tasks on
       tasks-cfa @ execute
       servicing-tasks off
    THEN
;

U: TASKS-COUNT
: SERVICE.TASKS/16  ( -- , Service tasks at 16th rate )
    tasks-count @ dup
    1+ 15 AND tasks-count !  0=
    IF service.tasks
    THEN
;

: ST.INIT
    'c noop  tasks-cfa !  ( Default is do nothing )
;
st.init

: SYS.INIT sys.init st.init ;
: SYS.STATUS sys.status ." SERVICE.TASK = " tasks-cfa @ cfa. cr ;

