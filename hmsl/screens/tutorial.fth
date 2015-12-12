\ This file is from the tutorial in the Control Grid Chapter

ANEW TASK-TUTORIAL

OB.CHECK.GRID MY-CHECK

: CHECK.FUNC ( value part -- )
    ." Part = " .
    ." , Value = " . cr
;

: BUILD.MY-CHECK  ( -- )
    1 4 new: my-check
    500 300 put.wh: my-check
    'c check.func put.down.function: my-check
    stuff{ " Mayo" " Mustard"  " Catsup"  " Sprouts"
    }stuff.text: my-check
;

\ Numeric Grid
OB.NUMERIC.GRID  MY-NUMERIC

: MN.DOWN ( value part -- )
    cr ." DOWN: Part# " . ."  = " . cr?
;

: MN.MOVE ( value part -- )
    cr ." MOVE: Part# " . ."  = " . cr?
;
: MN.UP ( value part -- )
    cr ." UP: Part# " . ."  = " . cr?
;

: BUILD.MY-NUMERIC  ( -- , setup grid )
    2 3 new: my-numeric
    300 300 put.wh: my-numeric
\ Set global Min and Max
    1 -1 put.min: my-numeric
    10 -1 put.max: my-numeric
\ Set specific min and max
    0 5 put.min: my-numeric
    100 5 put.max: my-numeric
    3 1 put.value: my-numeric
    'c mn.down put.down.function: my-numeric
    'c mn.move put.move.function: my-numeric
    'c mn.up put.up.function: my-numeric
;


OB.SCREEN MY-SCREEN

: MYSC.INIT  ( -- )
    0 scg.selnt
    4 3 new: my-screen
    build.my-check
    my-check 500 1000 add: my-screen
    build.my-numeric
    my-numeric 2000 500 add: my-screen
    " Tutorial" put.title: my-screen
    ascii X put.key: my-screen
    my-screen default-screen !
;

: MYSC.TERM
    freeall: my-screen
    free: my-screen
;

if.forgotten mysc.term

: TEST
    mysc.init
    hmsl
    mysc.term
;

