\ Markov Chain
\
\ Author: Phil Burk
\ Copyright 1989
\ All Rights Rserved

ANEW TASK-MARKOV_CHAIN

METHOD  SUM.ROW:
METHOD  SCAN.ROW:
METHOD  CHAIN:  

\ First order Markov Chain
:CLASS OB.MARKOV <SUPER OB.SHAPE

:M SUM.ROW:  ( elmnt# -- sum )
    0 dimension: self 0
    DO over i ed.at: self +  ( -- elmnt# sum )
    LOOP nip
;M

:M SCAN.ROW:  { value elmnt# | choice -- choice  , look for bucket }
    -1 -> choice
    0 dimension: self 0
    DO  elmnt# i ed.at: self +
        dup value  >
        IF i -> choice leave
        THEN
    LOOP drop
    choice
;M

:M CHAIN:  ( index -- index' , calculate weighted probablility )
    dup sum.row: self ?dup
    IF  choose
        swap scan.row: self
    THEN
;M

;CLASS


