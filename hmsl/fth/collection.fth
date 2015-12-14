\ Notes: to implement
\ - productions also have behavior to select functions
\ - players have behavior to select shapes
\
\ Collections are the primary morph for building hierarchies.
\ Collections can contain other morphs, like players,
\ structures, productions, or other collections.
\ There are two basic kinds of collections, sequential and
\ parallel. Sequential collections execute their component
\ morphs one after the other.  Parallel collections start
\ all their morphs at the same time.  Collections are done
\ when the last sub morph finishes.
\
\ Author: Phil Burk
\ Copyright 1986 -  Phil Burk, Larry Polansky, David Rosenboom.
\ All Rights Reserved
\

\ MOD: PLB 10/13/86 Changed to IV.LONG system
\ MOD: PLB 1/??/87 Changed EXECUTE: strategy.
\ MOD: PLB 1/27/87 Added repeat count. Removed auto add:
\      to coll-holder. 
\ MOD: PLB 2/27/87 Changed OB.COLL.LOOP to use late bound EXEC.ONCE:
\ MOD: PLB 3/2/87 Add REPEAT to PRINT:
\ MOD: PLB 5/23/87 Check REPEAT.COUNT at beginning for zero.
\      Add STOP:
\ MOD: PLB 5/28/87 Set REPCOUNT in PUT.REPEAT:
\      Add 0STUFF:
\ MOD: PLB 6/10/87 Add DEFAULT:
\ MOD: PLB 11/3/87 Add DELETE:
\ MOD: PLB 4/26/88 Add check for overflow in DONE:
\ MOD: PLB 4/26/88 Make DELETE: use late bound REMOVE:
\      so that actions work.
\ MODS to OLD STRUCTURE which was a collection with a behavior.
\ MOD: PLB 7/9/86 Created new class called OB.FRAME 
\      This is essentially a structure without the grid of
\      tendencies. These objects can have variable number
\      of collections without having to resize the grid.
\ MOD: PLB 7/29/86 Added ability to terminate a structure if
\      a bahavior returns an index < 0.
\ MOD: PLB 10/11/86 Use default behavior, set LASTCOLL to -1 for
\      proper sequencing that starts at 0
\ MOD: PLB 10/13/86 Change to IV.LONG system.
\ MOD: PLB 1/14/87 Converted to new DONE: method.
\      Base on EXECUTE and DONE: instead of TASK:
\ MOD: PLB 1/27/87 Changed FRAME to STRUCTURE, STRUCTURE to
\      TSTRUCTURE, Changed GET.LAST.COLLID: to GET.LAST.ID:
\ MOD: PLB 3/1/87 Made behaviors terminate, BEHAVE: updates iv-last-morph.
\ MOD: PLB 3/2/87 Support repeat count in struct.
\ MOD: PLB 3/7/87 Add error for EXTEND:
\ MOD: PLB 5/23/87 Added STOP check, check REPEAT count at beginning.
\ MOD: PLB 6/15/87 Add DEFAULT:
\ MOD: PLB 10/7/87 Use instance object for Tendency Grid.
\ ------------------------------------------------------
\
\ MOD: PLB 10/21/88 Radical Redesign of COLLECTION, move behavior
\ into it from OB.STRUCTURE.  Allowed switching between parallel and
\ sequential mode.
\ MOD: PLB 8/11/89 Fixed order for Parallel execution.
\      Set mode at INIT: instead of default.
\ MOD: PLB 8/31/89 Fixed STOP: self bug.
\ MOD: PLB 2/6/90 Add FINISH: method.
\ MOD: PLB 3/12/90 c/REPITITION/REPETITION/
\ MOD: Reorganize STOP code, use TERMINATE:
\ MOD: PLB 4/13/90 Added GET.NEXT.TIME: for ACTOBJ
\ MOD: PLB 6/11/90 Fixed STOP.DELAY
\ MOD: PLB 4/28/91 Add 0 IV=> IV-REPCOUNT to COL.STOP
\ 00001 PLB 12/4/91 Reorder START FUNCTION, before start delay
\         Add stack checks to start, stop, repeat function calls.
\ 00002 PLB 2/6/92 Remove stack checks and cuz of EXEC.STACK?
\          Add stack check to COL.EXEC.BEHAV
\ 00003 PLB 3/31/92 Ripped out all generic stuff and moved
\           it to OB.MORPH
\ 00004 PLB 5/21/92 Fix stack check in COL.EXEC.BEHAV
\           Put OB.STRUCTURE in a separate file.
\ 00005 PLB 5/21/92 Add EDIT: method.
\ 00006 PLB 8/3/92 Mac objects now absolute addresses.

ANEW TASK-COLLECTION

\ Control whether a collection is simply sequential, simply parallel
\ or uses a complex behavior.
METHOD ACT.SEQUENTIAL:         METHOD ACT.PARALLEL:
METHOD PUT.BEHAVIOR:     METHOD GET.BEHAVIOR:

\ -----------------------------------------------------------
:CLASS OB.COLLECTION <SUPER OB.MORPH
    IV.LONG IV-COL-MODE
    IV.LONG IV-PENDING      ( used for counting unfinished )
    IV.LONG IV-BEHAVE-CFA   ( CFA of behavior word )

0 constant PARALLEL_MODE
1 constant SEQUENTIAL_MODE
2 constant BEHAVIOR_MODE

:M ?HIERARCHICAL:  ( -- flag , true if can contain other morphs)
    true
;M

:M INIT: ( -- )
    init: super
    parallel_mode iv=> iv-col-mode
;M

:M ?NEW:  ( Max_elements -- addr | 0 )
    1 ?NEW: SUPER   ( declare as one dimensional )
;M

:M NEW: ( max_elements -- , abort if error )
    ?new: self <new:error>
;M

\ Since this is a one-dimensional list, let's inherit a bunch
\ of list methods.
inherit.method delete: ob.list
inherit.method 0stuff: ob.list
inherit.method }stuff: ob.list
inherit.method freeall: ob.objlist
inherit.method deinstantiate: ob.objlist
inherit.method ?instantiate: ob.objlist

:M DEINSTANTIATE.HIERARCHY:
    self ?hierarchical: []
    IF
        many: self 0
        ?DO
            i get: self deinstantiate.hierarchy: []
        LOOP
        deinstantiate: self
    ELSE
        free: self
    THEN
;M

:M ACT.SEQUENTIAL: ( -- , behave sequentially )
    sequential_mode iv=> iv-col-mode
;M

:M ACT.PARALLEL: ( -- , behave in parallel )
    parallel_mode iv=> iv-col-mode
;M

:M PUT.BEHAVIOR:  ( cfa-behavior  -- , set behavior to be used)
    dup iv=> iv-behave-cfa
    IF behavior_mode
    ELSE parallel_mode
    THEN iv=> iv-col-mode
;M

:M GET.BEHAVIOR:  ( -- cfa-behavior  , fetch behavior's cfa )
     iv-behave-cfa
;M

:M PRINT.ELEMENT:  ( e# -- , print the element )
    get: self  ( get morph)
    dup get.weight: [] 4 .r 4 spaces   ( show weights )
    name: []
;M

:M PRINT: ( -- , print it )
     print: super
     iv-col-mode
     CASE
        sequential_mode OF ." Sequential Mode" cr ENDOF
        parallel_mode OF ." Parallel Mode" cr ENDOF
        behavior_mode OF ." Behavior = "
            iv-behave-cfa >name id. cr ENDOF
     ENDCASE
;M

( sequential collections execute the next element after )
( receiving a done message from the previous. )
: COL.BHV.SEQ ( -- index 1 | 0 )
    iv-current dup many: self <
    IF dup 1+ iv=> iv-current 1
    ELSE drop 0
    THEN
;

( Parallel collections wait for all DONE: messages )
( to arrive before signalling completion. )
: COL.BHV.PAR ( -- 0 1 2 ... N , exec all morphs NOW)
    iv-col-done?
    IF 0
    ELSE  many: self dup 1- swap
        0 ?DO dup i - swap LOOP 1+  set.done: self
    THEN
;

: COL.EXEC.BEHAV ( -- v0 v1 .. vn N | 0 ) \ 00002
    depth >r
    self iv-behave-cfa execute
    depth 1- over - r> -    \ 00004 was OVER +
    IF
        .s " COL.EXEC.BEHAV" " Stack error in behavior!"
        er_fatal ob.report.error
    THEN
;

: COL.BEHAVE ( -- v0 v1 .. vn N | 0 , execute morphs just once )
    iv-col-mode
    CASE
        parallel_mode OF col.bhv.par ENDOF
        sequential_mode OF col.bhv.seq ENDOF
        behavior_mode OF col.exec.behav ENDOF
        " COL.EXEC.ONCE" " Illegal mode!"
        er_fatal ob.report.error
    ENDCASE
;

: COL.UPDATE.TIME ( time -- , update maximum time )
    dup iv-time-next time> \ !!!!
    IF iv=> iv-time-next
    ELSE drop
    THEN
;

: COL.EXEC.LOOP  ( -- )
\ Execute morphs until one tasks itself or done.
    BEGIN
        0 iv=> iv-pending
        col.behave dup 0>
        IF  0
            DO >r iv-time-next self r> at: self    ?execute: []
               IF col.update.time
               ELSE 1 iv+> iv-pending
               THEN
            LOOP
        ELSE drop col.do.repeat reset: self
        THEN
        iv-repcount 0= iv-pending 0> or
    UNTIL
;

: COL.STOP.CHILDREN  ( time -- )
    self ?hierarchical: []
    IF  reset: self
        BEGIN manyleft: self
        WHILE dup next: self
            0 over put.invoker: [] ( orphan them first )
            terminate: []
        REPEAT
    THEN
    drop
;

:M TERMINATE:  ( time -- , stop all children )
    iv-if-active
    IF  
        dup col.stop.children
        morph.stop
    ELSE drop
    THEN

;M

:M DONE: ( time sender -- , process completion message from child )
    mo.track.done drop
    col.update.time
\
\ Is this the last one to report back?
    iv-pending  1-  dup iv=> iv-pending 0=
    IF
\ are there any repetitions left?
        iv-repcount
        IF  col.exec.loop  ( give it a chance to finish )
        THEN
\
\ is it finally done?
        iv-repcount 0=
        IF  iv-time-next morph.stop
        THEN
    THEN
;M

:M CUSTOM.EXEC: ( -- time true | false )
    many: self 0>
    IF
        col.exec.loop
    THEN
    iv-pending
    IF false
    ELSE iv-time-next true
    THEN
;M

:M PRINT.HIERARCHY: ( -- , print name and indent for children )
    print.hierarchy: super
    3 morph-indent +!
    many: self 0
    ?DO i get: self print.hierarchy: []
    LOOP
    -3 morph-indent +!
;M

:M 0STUFF: ( 0 m0 m1 ... mN -- , easy build of collection)
    <0stuff:>
;M

:M }STUFF:  ( stuff...  --- , load it into object )
    stuff.depth >r
        <}stuff:>
    r> set.many: self
;M

:M CLASS.NAME: ( -- $NAME )
    " OB.COLLECTION"
;M

defer EDIT.COLLECTION
' drop is edit.collection

:M EDIT: ( -- , edit using current editor ) \ 00005
    self edit.collection
;M

:M DUMP.SOURCE.BODY:
    dump.morph.body
\
     >newline tab
     iv-col-mode
     CASE
        sequential_mode OF ." act.sequential: " ENDOF
        parallel_mode OF ." act.sequential: " ENDOF
        behavior_mode OF ." 'c "
            iv-behave-cfa cfa. ." put.behavior: "
            ENDOF
     ENDCASE
     name: self cr
\
    iv-pntr 
    IF
        tab max.elements: self . ."  new: " name: self cr
\
        many: self 0>
        IF
            tab ." stuff{" cr
            tab tab 
            many: self 0
            ?DO
                i get: self name: []
                out @ 60 >
                IF
                    cr tab tab
                ELSE
                    space
                THEN
            LOOP
            cr
            tab ." }stuff: " name: self cr
        THEN
    THEN
;M

;CLASS

\ Included for compatibility.
: OB.COLL.PAR ( -- fake old style collection )
    ." OB.COLL.PAR is obsolete, use OB.COLLECTION !" cr
    ob.collection
;
: OB.COLL.SEQ ( -- fake old style collection )
    ." OB.COLL.SEQ is obsolete, use OB.COLLECTION !" cr
    ob.collection
    latest name> >body
\ use->rel \ 00006
    act.sequential: []
;

: BH.RANDOM ( struct --  next-id 1 | 0, choose randomly)
    many: [] 1+ choose  dup
    IF 1- 1
    THEN
;

