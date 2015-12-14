\ Demonstrate advanced use of HMSL sequencer.
\
\ Generate some tracks via SES,
\ use algorithmic interpreters on some tracks.
\
\ Author: Phil Burk
\ Copyright 1990 Phil Burk
\ All Rights Reserved

include? seq.init hsc:sequencer

ANEW TASK-DEMO_SEQ

." Read and edit this file to customize it for your setup." cr
score{
\ Define several tracks using SES
: DSEQ.HARMONY  ( -- , play chords )
    1/2
    chord{ c3 e g }chord
    chord{ c3 e g }chord
    chord{ d3 f a }chord
    chord{ d3 f a }chord
;

: DSEQ.RHYTHM  ( -- , polyrhythm )
    par{
        1/4 c3 g e g
    }par{
        1/3 e5 c e
    }par
    par{
        1/4 d3 a f a
    }par{
        1/3 f5 d f
    }par
;

\ Assign to various tracks
: DSEQ>TRACKS
    1 track{ dseq.harmony }track
    2 track{ dseq.rhythm }track
;

\ This interpreter will set variables that will be used by a
\ JOB that runs along with the sequencer.
\ We will define this job as a class so that we can use more than one.

METHOD RECALC:    METHOD SETUP:
:CLASS  OB.ZIGZAG  <SUPER  OB.JOB
    iv.long  IV-ZZ-LOWEST
    iv.long  IV-ZZ-HIGHEST
    iv.long  IV-ZZ-LAST-IN
    iv.long  IV-ZZ-LAST-NOTE
    iv.long  IV-ZZ-DIR
    iv.long  IV-ZZ-CHANNEL

:M RECALC: ( value -- , reset limits )
    dup iv-zz-last-in 2sort
    iv=> iv-zz-highest
    iv=> iv-zz-lowest
    iv=> iv-zz-last-in
;M

:M PUT.CHANNEL:  ( channel -- )
    iv=> iv-zz-channel
;M
:M GET.CHANNEL:  ( -- channel )
    iv-zz-channel
;M

:M INIT:  ( -- , called at compile time )
    init: super
    40 recalc: self
    60 recalc: self
    50 iv=> iv-zz-last-note
    1 iv=> iv-zz-dir
    8 put.duration: self
    1 put.channel: self
;M

: ZZ.JOB.FUNC  ( job -- , this will be called by TASK: )
\ play notes up and down in zig zag fashion
    drop  ( don't need )
    iv-zz-dir 0>
    IF  \ going up
        iv-zz-last-note 1+ dup
        iv-zz-highest >
        IF 2-  -1 iv=> iv-zz-dir  \ reverse direction
        THEN
    ELSE  \ going down
        iv-zz-last-note 1- dup
        iv-zz-lowest <
        IF 2+  1 iv=> iv-zz-dir  \ reverse direction
        THEN
    THEN  ( note )
    dup iv=> iv-zz-last-note
    64    ( vel )
    get.duration: self 2/
    get.channel: self midi.channel!
    midi.noteon.for
;

:M SETUP:   ( -- , get it ready to use )
    stuff{ 'c zz.job.func }stuff: self
;M

;CLASS

OB.ZIGZAG  ZIGZAG1
OB.ZIGZAG  ZIGZAG2
OB.COLLECTION  DSEQ-COLL

: ZZ.RECALC.JOB  { el# shape instr job -- , send note info to job }
    el# shape get: []   ( time note vel )   ?DUP
    IF  400 swap / job put.duration: [] \ use velocity
        dup 38 >
        IF  job recalc: []
        ELSE 36 =
            IF  instr get.channel: []
                job put.channel: []
                job start: []
            ELSE job stop: []
            THEN
        THEN
    ELSE drop \ note
    THEN drop \ time
;

: ZZ.INTERP1  ( el# shape instr -- , send note info to job )
    zigzag1 zz.recalc.job
;
: ZZ.INTERP2  ( el# shape instr -- , send note info to job )
    zigzag2 zz.recalc.job
;

\ just in case
: ZZ.STOP1 ( instr -- )
    drop stop: zigzag1
;
: ZZ.STOP2 ( instr -- )
    drop stop: zigzag2
;

: DSEQ.INIT   ( -- )
    dseq>tracks
\
    setup: zigzag1
    setup: zigzag2
\
\ This is another way to start accompanying morphs
\ play the two jobs in parallel
\   stuff{ zigzag1 zigzag2 }stuff: dseq-coll
\   act.parallel: dseq-coll
\   dseq-coll seq-accompany !
\
\ set the interpreters and other functions for tracks 3 & 4
    'c zz.interp1 put.on.function: sqins-3
    'c zz.stop1 put.close.function: sqins-3
\
    'c zz.interp2 put.on.function: sqins-4
    'c zz.stop2 put.close.function: sqins-4
;

: DSEQ.TERM  ( -- )
    cleanup: dseq-coll
;

if.forgotten dseq.term

