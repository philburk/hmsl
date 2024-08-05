\ Batcher's Sort by K.E. Batcher
\
\ While slower than Quicksort, on the average, it is 
\ simpler and is faster for almost sorted data.
\
\ References to this sort can be found in Knuth Vol. 3
\ Thanks to John Konopka for publishing similar
\     code in Forth Dimensions, Vol 8 , Number 4 , 1986
\
\ Implementor: Phil Burk
\ Copyright 1987 Delta Research

include? value ju:value

ANEW TASK-BSORT

\ Values required by sort.
0 VALUE BSORT-TT
0 VALUE BSORT-RR
0 VALUE BSORT-DD
0 VALUE BSORT-PP
0 VALUE BSORT-NN
0 VALUE BSORT-QQ

\ This must be vectored to a word that compares two keys.
\ If they are out of order then it exchanges them.
DEFER BSORT-EXCH?

: 2**N ( n -- 2**n , raise 2 to the Nth )
    1 swap ashift
;

: BSORT.SELT ( -- )
    bsort-nn 31 0
    DO  dup i 2**N <=
        IF  drop i leave
        THEN
    LOOP
    1- 30 min -> bsort-tt
;

: BSORT.INNER ( -- )
    bsort-nn bsort-dd - 0
    DO  i bsort-pp and bsort-rr =
        IF  i dup bsort-dd + BSORT-EXCH?
        THEN
    LOOP
;

: BSORT.QTEST ( -- )
    bsort-qq bsort-pp = NOT
    IF  bsort-qq bsort-pp
        2dup -  -> bsort-dd
        -> bsort-rr ( rr=pp )
        2/ -> bsort-qq ( qq=qq/2 )
        0
    THEN
;

: BSORT.SETQRD ( -- )
    bsort-tt 2**N   -> bsort-qq
    0 -> bsort-rr
    bsort-pp -> bsort-dd
;

: BSORT  ( N -- , sort N items using BSORT-EXCH? )
    -> bsort-nn
    bsort.selt
    bsort-tt 2**N  -> bsort-pp
    BEGIN bsort.setqrd  bsort-qq
        BEGIN bsort.inner bsort.qtest
        UNTIL
        bsort-pp 2/ dup -> bsort-pp 0=
    UNTIL
;

false .IF
include? choose ju:random
\ BSort Test
5 constant BST_MAX
BST_MAX ARRAY BST-ARRAY
: BST.RAND ( -- , randomize array )
    bst_max 0
    DO  10000 choose i bst-array !
    LOOP
;

\ This word might be useful in other applications.
: ADDR.EXCH?  ( a1 a2 -- , exchange if greater )
    2dup @ swap @ 2dup <
    IF rot !
       swap !
    ELSE 2drop 2drop
    THEN
;

: BST.EXCH? ( I1 I2 -- , exchange if [I1] > [I2] )
    2dup swap . . 4 spaces
    bst-array swap bst-array swap ( get addresses )
    addr.exch?
;

: BST.SHOW ( -- , print array )
    BST_MAX 0
    DO i bst-array @ . cr ?pause
    LOOP
;

: TEST.BSORT ( -- )
    ' bst.exch? is bsort-exch?
    bst.rand
    ." Before sorting!" cr
    bst.show
    bst_max bsort
    cr ." After sorting!" cr
    bst.show
;

.THEN
