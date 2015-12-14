\ Schedule Events at a Specified Time
\ An event consists of a data1, data2, cfa pair.
\ The data will be put on the stack and the CFA executed.
\
\ Events are added to the list using this word.
\ The events are kept in sorted order for speed.
\    POST.EVENT  ( time data1 data2 cfa -- , add to event list )
\
\ Copyright 1989 - Phil Burk, Larry Polansky, David Rosenboom
\ All Rights Reserved
\
\ MOD: PLB 8/17/90 Put proper time in NEXT-EVENT-TIME, S. Brandorff
\ 00001 PLB 11/20/91 Use EXIT instead of RETURN
\ 00002 PLB 2/18/92 Add SYS.TASK and SYS.CLEANUP
\ 00003 PLB 3/12/92 Removed NEXT-EVENT-TIME, used DO LOOP
\       in DO.NEXT.EVENT to prevent race condition, c/index/indx/

ANEW TASK-EVENT_LIST

OB.SHAPE EVENT-SHAPE

: DO.NEXT.EVENT  ( -- , execute next event )
    many: event-shape 0
    ?DO \ 00003
        0 at: event-shape ( equivalent to 0 0 ed.at: but faster )
        doitnow?
        IF
            first: event-shape
\ remove before EXECUTE in case EXECUTE causes insert
            0 remove: event-shape
            -2 exec.stack?
            drop \ time
            many: event-shape 0=
            IF LEAVE
            THEN
        ELSE
            LEAVE
        THEN
    LOOP
;

\ This is similar to the search.back method but uses TIME>
: EVL.SEARCH.BACK  { time | indx -- index , next highest if false }
    many: event-shape  dup -> indx   0 \ 00003
    ?DO  -1 +-> indx
        time   indx 0 ed.at: event-shape time>
        IF 1 +-> indx leave
        THEN
    LOOP
    indx
;

: POST.EVENT  ( time data1 data2 cfa -- , add to event list )
\ insert before next later time
    many: event-shape 0=
    IF
        add: event-shape
    ELSE
        3 pick  ( get time )
        evl.search.back
        insert: event-shape
    THEN
;

: EVL.INIT  ( -- , setup job )
    64 4 new: event-shape
;

: EVL.TERM ( -- )
    free: event-shape
;

: SYS.INIT ( -- ) sys.init evl.init ;
: SYS.TERM ( -- ) evl.term sys.term ;
: SYS.RESET ( -- ) sys.reset clear: event-shape ;
: SYS.CLEANUP ( -- ) sys.cleanup clear: event-shape ;
: SYS.TASK ( -- )  do.next.event sys.task ;

if.forgotten evl.term

