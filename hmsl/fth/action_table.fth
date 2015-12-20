\ ACTION-TABLE definition and behaviors (PERFORM environment)
\ HMSL
\ author Larry Polansky
\
\ define ACTION-TABLE as a STRUCTURE
\
\ ACTION-TABLE uses global  variables for length of each priority
\ column, and when an action is created these lengths are
\ checked to see if there is enough room in that column. There
\ are also similar variables for the EXEC count in each column,
\ used by the STOCHASTIC PRIORITY  BEHAVIOR.
\
\ Copyright 1986 Phil Burk, Larry Polansky, David Rosenboom
\ All Rights Reserved
\
\ MOD: PLB 1/27/87 Change <SUPER OB.FRAME to OB.STRUCTURE
\      Changed GET.COLL: to GET:
\ MOD: PLB 5/20/87 Changed INIT: to clear col-length array
\ MOD: PLB 5/23/87 No done? for TASK:
\      Optimized UNWEIGHTED.BEHAVIOR
\ MOD: PLB 9/3/87 Added 0STUFF.ACTIONS
\ MOD: PLB 9/23/87 Changed it to 0STUFF: for class.
\ MOD: PLB 10/29/87 Remove ACTION-# references.
\          Remove CHOSE.NEXT.ACTION: declaration.
\ MOD: PLB 11/3/87 Change DELETE-ACTION-#: to REMOVE:
\      Took out DELETE.ACTION: and DELETE.ACTION.IF:
\ MOD: PLB 10/18/88 Moved 65 NEW: to BUILD.ACTION_TABLE
\ MOD: PLB 6/2/89 Change TASK: and behaviors to work
\      with new kind of collection and behaviors.
\ MOD: PLB 2/4/91 Changed TASK: from EXECUTE: to TASK:

\ ================================================================
MRESET PUT.ACTION:

ANEW TASK-ACTION_TABLE

\ Note that for early versions of HMSL, there is probably only
\ going to be one instance of the class ACTION-TABLE ...

\ temporary variables used inside calculations to save
\ stack brain damage
v: CURRENT-PRIORITY
v: TEMP-ACTION \ used in search for delete from table

method PUT.ACTION:
method CLEAR.PRIORITY:

:CLASS OB.ACTION-TABLE    <SUPER OB.COLLECTION

\ Redefine task for ACTION-TABLE so that it never ends from a
\ behavior, only when perform is clicked off. It doesn't need a
\ message-done, because actions are not scheduled!! TASK: for the
\ ACTION-TABLE is a key word to understand in seeing how the
\ ACTION-TABLE interacts with the HMSL polymorphous executive

:m TASK: ( ---  )
    col.exec.behav 1 =
    IF get: self  \  act
       task: []
    ELSE ." Action Table behavior should only pick 1" cr abort
    THEN
;m

\ ================================================================

\ there still seems to be one last little bug in the action-table
\ moving around of actions. it only surfaces when one tries to move
\ an action into the last place in a give priority column, it seems
\ to dissapear. polansky promises to fix this....

\ internal DO...LOOP that re-packs a column from which
\ an ACTION has been deleted. Used in REMOVE:

: PACK.COLUMN ( abs.end.of.col  action-#  --- , re-packs column )
    over  swap  ( -- end end act# )
    DO \ start at 1 past action-# to move down
        i 1+ get: self    ( -- end action )
        i  put: self
    LOOP ( -- end )
\ null last position
    act-null swap put: self
;


:M REMOVE:  ( action-# --- ,delete and resize )
    dup temp-action !
    -4 ashift current-priority !
    act-null temp-action @ put: self \ replace with act-null
\ Next  test to see if NOT last action in a column
    current-priority @ get.column.length @
    temp-action @ 15 and  1+  =  NOT  \ ---  flag
    IF  \ it's not the last in a column...
       current-priority @ get.column.length @ 1- \ --- col.length
       current-priority @ 4 ashift +   \ --- absolute.end.of.column
       temp-action @  \ --- abs.end.col action-#
       pack.column    \ move others down
    THEN
\ Always decrement the column length when finished
    current-priority @ get.column.length decr
;m

\ ACTIONS are not allowed into the ACTION-TABLE if that priority
\ column is filled. You must first drop an action. If an action is already
\ in the table, it will be deleted before being put in. This is how
\ an action's priority gets changed in the graphic action-table routines.

\ ======================================================

\ Basic method for putting an ACTION into the ACTION-TABLE
\ syntax: ACT-FOO PUT.ACTION: ACTION-TABLE

:M PUT.ACTION:  ( action -- ,puts action into table)
   dup delete: self  \ replace any old occurrences
   dup    ( -- action action )
   get.priority:  []  dup  ( -- action pri pri )
   get.column.length  @    ( -- action pri length )
   dup 15  =
   IF  ( -- action pri length )
       cr bell ." no room in action-table for this priority "
       3drop
   ELSE
       swap dup    ( -- action length pri pri )
       get.column.length incr  ( -- action length pri )
       4 ashift    \ multiply priority to index into table
       +   ( -- action cell# , add row number to get absolute cell#)
       put:  self  \ put the action in table )
    THEN
;m


\ clears a column of the action table
:M CLEAR.PRIORITY: ( priority-# --- clear that column )
    dup 0 >=    \ valid priority?
    IF  dup get.column.length disable   \ reset column length
\ offset into ACTION-TABLE, and end of col., for DO...LOOP
        4 ashift  dup 16  + swap
 \ first remove all ACTIONs in that priority column
        DO    act-null  i put: self
        LOOP
    ELSE drop
    THEN
;m

\ clears action-table
:M CLEAR:
   4 0
   DO  i clear.priority: self
   LOOP
;m

:m PRINT: ( -- )
   ." ACTION-TABLE contains: " cr cr
   64 0
   DO  i get: self  \ get the address of the action
       dup act-null =
       IF  drop ." -- "  ( nothing there )
       ELSE  name: [] space space       \ get the name
       THEN
	\ for each priority  do a coupla CR's
       i 1+ 16 mod 0=
       IF cr cr THEN
    LOOP
;m

\ Make it easy to load the action table.
:M 0STUFF: ( 0 act-a act-b act-c ... -- , add to table )
    0depth dup 0>
    IF  0
        DO put.action: self
        LOOP
    ELSE
        " 0STUFF:" " Need 0 on stack!"
        er_fatal ob.report.error
    THEN drop
;M

;CLASS

\ For PERFORM screen.
OB.ACTION-TABLE ACTION-TABLE

\ Fills action-table with act-null and sets length to 64
\ 64th cell is act-null, which is executed when action-table is
\ empty but behavior is running...

: BUILD.ACTION-TABLE
   65 new: action-table
   65 0 DO
      act-null add: action-table
   LOOP
;

\ ====================== ACTION-TABLE BEHAVIORS ==================
\ Weighted Behavior ----------

: CHOOSE.NEXT.PRIORITY (  --- priority)
     3 priority-prob-sum @ choose
     3 0
     DO  dup i action-prob-sums @ <
         IF ( -- 3 r ) nip i swap  leave
         THEN
     LOOP drop
;

: ACTION.PRI->ACT#   ( default_collid priority -- collid )
    dup action-col-lengths @ ( -- 64 pr. length)
    0=  ( -- 64  priority  flag)
    IF  drop  ( -- 64)
    ELSE      ( -- 64 pr.)
       dup dup action-counters @  ( -- 64 pr. pr. count)
       swap 4 ashift +  ( -- 64  pr. collid)
       swap inc.priority.counter ( -- 64 collid)
       nip \ get rid of 64
    THEN
;

: PRIORITY.BEHAVIOR   ( action-table -- next_act_id 1 )
    64  swap action-table = ( --  64 flag)
    IF
        choose.next.priority    ( -- 64 pr.)
        action.pri->act#
    THEN 1
;

\ UNWeighted Behavior ------
: UNWEIGHTED.BEHAVIOR ( action-table -- next_act_id 1 )
     64  swap action-table = ( --  64 flag)
     IF
        action.next.priority  ( round robin)
        action.pri->act#
    THEN 1
;
