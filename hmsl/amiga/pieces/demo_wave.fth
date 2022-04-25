\ Play a pseudo random melody in equal tempered tuning.
\ Edit melody and waveform.
\
\ Author: Phil Burk
\ Copyright 1986 -  Phil Burk, Larry Polansky, David Rosenboom.
\ All Rights Reserved
\ MOD: PLB 6/4/87 Use equal temper.
\ MOD: PLB 6/4/89 Clip random note to zero.

ANEW TASK-DEMO_WAVE

\ Declare Morphs
OB.WAVEFORM WAVE-DRAW

\ This custom interpreter uses the shape data as the center for
\ a range of random notes.
: DRAW.RNOTE.ON ( element# shape instr -- , randomly offset note )
    >r interp.extract.pv  ( -- note vel )
    swap 8 choose 4 - + 0 max swap  ( -- random_note vel )
    r> note.on: []
;

: DRAW.BUILD.INS ( -- , Build instrument)
    wave-draw put.waveform: ins-amiga-1  ( repeating waveform )
\ Use one channel to amplitude modulate the other for envelope.
    env-bang put.envelope: ins-amiga-1
    tuning-equal put.tuning: ins-amiga-1
\
\ Set ON interpreter, use default INTERP.LAST.OFF for off.
    'c draw.rnote.on  put.on.function:  ins-amiga-1
\
\ Set up player and instrument.
    ins-amiga-1 put.instrument: player-1
    0 put.offset: ins-amiga-1
    100000 put.repeat: player-1
    0 shape-1 0stuff: player-1

\ Build random waveform.
    16 new: wave-draw
    16 0
    DO
        256 choose 128 - add: wave-draw
    LOOP
    " Waveform/Timbre" 0 put.dim.name: wave-draw
;

: DRAW.BUILD.SHAPE  ( -- )
\ Build a simple starting shape.
    32 2 new: shape-1
    12 23 add: shape-1
    12 27 add: shape-1
    12 46 add: shape-1
    " Duration" 0 put.dim.name: shape-1
    " Random Pitch Center" 1 put.dim.name: shape-1
;

: DRAW.INIT  ( -- , Initialize demo )
    draw.build.ins
    draw.build.shape
    clear: shape-holder
    shape-1 add: shape-holder
    wave-draw add: shape-holder ( you can edit waveform,)
    env-bang add: shape-holder  ( and the envelope too! )
;

: DRAW.TERM  ( -- )
    free: wave-draw
    free: shape-1
    free: player-1
    clear: shape-holder
    ins-midi-1 put.instrument: player-1
;

: DO.DRAW  ( -- )
    player-1 hmsl.play
;

: DEMO.WAVE   ( -- , Run demo )
    draw.init
    do.draw
    draw.term
;

cr ." Enter:   DEMO.WAVE   then edit the Shape WAVE-DRAW" cr
