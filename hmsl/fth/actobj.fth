\ Active Object List Processor
\ This morph contains a list of executable morphs.
\ It provides a simple multitasking facility by sending
\ task messages to each of it's members in series.
\ Morphs can be made active by posting them to this list.
\
\ Author: Phil Burk
\ Copyright 1986 -  Phil Burk, Larry Polansky, David Rosenboom.
\ All Rights Reserved
\
\ MOD: PLB 7/26/86 Made AO.SCAN always process an object even if reset occurs.
\ MOD: PLB 7/27/86 Fixed AO.SCAN
\ MOD: PLB 7/29/86 Added AO.ACTIVATE and AO.DEACTIVATE
\ MOD: PLB 12/9/86 Initialize AO-COUNT at AO.INIT
\ MOD: PLB 1/14/87 Make ACTOBJ an OB.OBJLIST, Add AO.EXEC
\ MOD: PLB 5/23/87 No error in AO.UNPOST.
\      TASK: no longer returns done? flag.
\ MOD: PLB 10/18/87 Add AO.RESET
\ MOD: PLB 11/3/87 Use DELETE: in AO.UNPOST
\ MOD: PLB 11/16/87 Change default size from 32 to 128
\ MOD: PLB 2/9/90 Move AO.REPEAT to H:TIME
\ MOD: PLB 4/13/90 Moved DO.NEXT.EVENT and SELF.CLOCK to HMSL_TOP
\ MOD: PLB 2/18/92 Add SYS.CLEANUP
     
ANEW TASK-ACTOBJ

OB.OBJLIST ACTOBJ

: AO.POST ( morph -- , post object to active list )
     add: actobj
;

: AO.UNPOST ( morph -- , delete from active list )
    delete: actobj
;

V: AO-COUNT  ( Keep track of how many times AO.SCAN called. )

\ Scan entire active object list.
\ When repeating loop, call AO.REPEAT and DO.NEXT.EVENT
: (AO.SCAN) ( -- )
    many: actobj   ( are there any? )
    IF reset: actobj  ( start at beginning )
       BEGIN manyleft: actobj
       WHILE next: actobj   ( get object from list )
           task: []    ( time slice object )
       REPEAT
    THEN
    1 ao-count +!   ( Track calls for performance analysis. )
;

variable AO-ENABLE
: AO.SCAN ( -- , Time slice next object.)
\ Check variable to avoid recursion with SERVICE.TASKS
    ao-enable @
    IF  ao-enable off
        (ao.scan)
        ao-enable on
    THEN
;

\ Set CFA of low level task server. This ensures that ao.scan
\ will get called when lengthy words get called , provided they call
\ SERVICE.TASKS in their loops.
: AO.ACTIVATE  ( -- , Activate AO.SCAN )
    ao-enable on
    'c ao.scan tasks-cfa !
;
: AO.DEACTIVATE  ( -- , Deactivate AO.SCAN )
    'c noop tasks-cfa !
;

\ These words are used for testing or for simple sequenceing.
: AO.LOOP ( -- , scan until all done or key hit )
      ao.activate
      BEGIN
           many: actobj 0>
           ?terminal/64 0= and
      WHILE
           ao.scan
      REPEAT
      ao.deactivate
;

: AO.EXEC ( morph -- , Execute morph then task )
    start: []
    ao.loop
;

: AO.INIT  ( -- , Allows for 128 active tasks. )
    128 new: actobj
    0 ao-count !
    ao-enable on
;

: AO.RESET ( -- , Stop all active objects. )
    reset: actobj
    BEGIN
        manyleft: actobj
    WHILE
        next: actobj abort: []
    REPEAT
    clear: actobj
    ao.deactivate
;

: AO.TERM
    free: actobj
;

: SYS.INIT sys.init ao.init ;
: SYS.RESET ao.reset sys.reset ;
: SYS.CLEANUP ao.reset sys.cleanup ;
: SYS.START ao.activate sys.stop ;
: SYS.STOP ao.reset ao.deactivate sys.stop ;
: SYS.TASK ao.scan sys.task ;
: SYS.TERM free: actobj sys.term ;
