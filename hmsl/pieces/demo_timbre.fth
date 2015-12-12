\ Play a pseudo random melodyin equal tempered tuning.
\ Edit melody and waveform.
\
\ Author: Phil Burk
\ Copyright 1986 -  Phil Burk, Larry Polansky, David Rosenboom.
\ All Rights Reserved
\ MOD: PLB 6/4/87 Use equal temper.

ANEW TASK-DEMO_TIMBRE

\ Declare Morphs
OB.WAVEFORM WAVE-TIMBRE

\ This custom interpreter uses the shape data as the center for
\ an range of random notes.
: TIMBRE.RNOTE.ON ( element# shape instr -- , randomly offset note )
    >r
    interp.extract.pv  ( -- note timbre )
    128 swap - 6 to: wave-timbre
    8 choose 4 - + 64  ( -- random_note vel )
    r> note.on: []
;

: TIMBRE.BUILD.INS ( -- , Build instrument)
    wave-timbre put.waveform: ins-amiga-1  ( repeating waveform )
\ Use one channel to amplitude modulate the other for envelope.
    env-bang put.envelope: ins-amiga-1
\    tuning-equal put.tuning: ins-amiga-1
\
\ Set ON interpreter, use default INTERP.LAST.OFF for off.
    'c timbre.rnote.on  put.on.function:  ins-amiga-1
\
\ Set up player and instrument.
    ins-amiga-1 put.instrument: player-1
    0 put.offset: ins-amiga-1
    100000 put.repeat: player-1
    0 shape-1 0stuff: player-1

\ Build random waveform.
    16 new: wave-timbre
    16 0
    DO
        256 choose 128 - add: wave-timbre
    LOOP
    " Waveform" 0 put.dim.name: wave-timbre
;

: TIMBRE.BUILD.SHAPE  ( -- )
\ Build a simple starting shape.
    32 3 new: shape-1
    12 23 10 add: shape-1
    12 27 100 add: shape-1
    12 46 200 add: shape-1
    " Duration" 0 put.dim.name: shape-1
    " Random Pitch Center" 1 put.dim.name: shape-1
    " Timbre" 2 put.dim.name: shape-1
;

: TIMBRE.INIT  ( -- , Initialize demo )
    timbre.build.ins
    timbre.build.shape
    clear: shape-holder
    shape-1 add: shape-holder
    wave-timbre add: shape-holder ( you can edit waveform,)
    env-bang add: shape-holder  ( and the envelope too! )
;

: TIMBRE.TERM  ( -- )
    free: wave-timbre
    free: shape-1
    free: player-1
    clear: shape-holder
    ins-midi-1 put.instrument: player-1
;

: DO.DRAW  ( -- )
    player-1 hmsl.play
;

: DEMO.TIMBRE   ( -- , Run demo )
    timbre.init
    do.draw
    timbre.term
;

." Enter:   DEMO.TIMBRE" cr
