
\ STRUCTURES differs from a COLLECTION in that they have a
\ square grid of tendencies.

\
\ Author: Phil Burk
\ Copyright 1986 -  Phil Burk, Larry Polansky, David Rosenboom.
\ All Rights Reserved

\ 00001 PLB 5/21/92 Removed from file H:COLLECTION

ANEW TASK-STRUCTURE.FTH

METHOD GET.TENDENCY:    METHOD PUT.TENDENCY:
METHOD FILL.TENDENCIES: METHOD GET.TGRID:
METHOD SUM.ROW:
METHOD SCAN.ROW:
METHOD CHAIN:  
METHOD CHOOSE:  
METHOD GET.LAST:
METHOD PUT.LAST:

: STR.BHV.MARKOV ( structure -- index 1 | 0 )
    choose: [] dup 0<
    IF drop 0  ( row was all zeroes! )
    ELSE 1
    THEN
;

:CLASS OB.STRUCTURE <SUPER OB.COLLECTION
    ob.shape IV-ST-TENDENCIES  ( Tendency array )
    iv.long  IV-ST-LAST

:M GET.LAST: ( -- lastchoice , return last one chosen )
    iv-st-last
;M
:M PUT.LAST: ( lastchoice -- , set starting point for chain )
    0 max iv=> iv-st-last
;M

:M GET.TENDENCY: ( s t -- T[s->t] )
    ed.at: iv-st-tendencies
;M

:M PUT.TENDENCY: ( T[s->t] s t --  )
    ed.to: iv-st-tendencies
;M

:M FILL.TENDENCIES: ( value -- , set all tendencies to value )
     fill: iv-st-tendencies
;M

:M GET.TGRID: ( -- tendencies-elmnts-array )
    iv-st-tendencies
;M

:M SUM.ROW:  ( elmnt# -- sum , sum of tendencies times weights )
    0 dimension: iv-st-tendencies 0
    ?DO over i ed.at: iv-st-tendencies
        i at: self get.weight: [] * +  ( -- elmnt# sum )
    LOOP nip
;M

:M SCAN.ROW:  { val elmnt# | choice -- t  , look for bucket }
    -1 -> choice
    0 dimension: iv-st-tendencies 0
    ?DO  elmnt# i ed.at: iv-st-tendencies
        i at: self get.weight: [] * +  ( -- elmnt# sum )
        dup val  >
        IF i -> choice leave
        THEN
    LOOP drop
    choice
;M

:M CHAIN:  ( elmnt# -- choice , calculate weighted probablility )
    dup sum.row: self
    choose
    swap scan.row: self
    dup put.last: self
;M

:M CHOOSE: ( -- choice , next based on last one )
    iv-st-last chain: self
;M

:M NEW: ( #morphs -- , allocate room )
    dup new: super
    dup dup dup new: iv-st-tendencies ( square space )
\ These limits will only affect editing operations.
    0 ?DO 0 100 i put.dim.limits: iv-st-tendencies
    LOOP
\
    set.many: iv-st-tendencies
    10 fill.tendencies: self
    0 iv=> iv-st-last
    iv-behave-cfa 0=
    IF  ." Behavior set to Markov, start at 0." cr
        'c str.bhv.markov put.behavior: self
    THEN
;M

:M FREE: ( -- )
    free: super
    free: iv-st-tendencies
;M
    
:M PRINT: ( -- )
    print: super
    ?pause
    ." Tendencies array ----------" cr
    print: iv-st-tendencies
;M

:M EXTEND:  ( #morphs -- , extend number of morphs allowed)
    extend: super
    max.elements: self dup new: iv-st-tendencies
    . " EXTEND: STRUCTURE" " Clears tendency grid!"
    er_warning ob.report.error
;M

:M CLASS.NAME: ( -- $NAME )
    " OB.STRUCTURE"
;M

;CLASS

: OB.TSTRUCTURE ( -- , fake old class )
    ." OB.TSTRUCTURE is now OB.STRUCTURE !" cr
    ." BEHAVIORS are different too!" cr
    ob.structure
;

if-testing @ [IF]
ob.collection col1
ob.collection col2
ob.collection col3
ob.collection col4
ob.structure st1
: COL.TEST1
    0 col1 col2 col3 0stuff: col4
    print: col4
;

: COL.TERM
    free: col4
    free: st1
;
: ST.INIT
    0 col1 col2 col3 col4 0stuff: st1
;

: ST.TEST
    BEGIN choose: st1 . cr
        ?terminal
    UNTIL
;

if.forgotten col.term
[THEN]


