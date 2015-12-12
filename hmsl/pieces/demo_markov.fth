\ Use Markov Chain to calculate next item.
\
\ Author: Phil Burk
\ Copyright 1989
\ All Rights Rserved

include? ob.markov  ht:markov_chain

ANEW TASK-DEMO_MARKOV

OB.MARKOV  m1

: SETUP.MARKOV
    4 4 new: m1
    1 2 5 3   add: m1
    7 20 0 12 add: m1
    5 5 5 15   add: m1
    13 8 5 3  add: m1
    print: m1
;

: TEST  ( -- , test a weighted object )
    setup.markov
    cr 0 sum.row: m1   0
    DO  i .   i 0 scan.row: m1 . cr
    LOOP
;

: BANG  ( note -- )
    60 choose 50 + midi.noteon
    2 choose 1+ 100 * msec midi.lastoff
;

variable default-interval
2 default-interval !

: PLAY.MARKOV  ( -- , play a series of four notes using a markov chain )
    setup.markov
    0 BEGIN dup default-interval @ * 50 + bang
        chain: m1
        ?terminal
    UNTIL drop
    free: m1
;

.THEN

cr ." Enter:  PLAY.MARKOV   to hear demo" cr
