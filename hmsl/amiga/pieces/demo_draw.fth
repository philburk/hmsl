\ Demonstrate playing a shape using an AMIGA instrument.
\ The shape can be edited, while it is played, using the
\ Shape Editor.
\
\ Author: Phil Burk
\ Copyright 1986 - Phil Burk , Larry Polansky , David Rosenboom
\
\ MOD: PLB 11/17/87 Use new IFF samples.

ANEW TASK-DEMO_DRAW

\ Declare Audio Sample object.
OB.SAMPLE SAMPLE-DRAW
\ Declare Ratiometric Tuning Object.
OB.TUNING.RATIOS RATIOS-32-64

\ Set up Instrument to play sample using Amiga Digital Audio
: DD.INIT.INST ( 0/1/2 -- , Load Chosen Sample )
    da.init da.kill   ( reset audio hardware )
\ Construct Amiga Instrument out of component parts.
    sample-draw put.waveform: ins-amiga-1
    0 put.envelope: ins-amiga-1  ( use natural envelope of sample )
    ratios-32-64 put.tuning: ins-amiga-1  ( use overtone tuning )
    110 put.offset: ins-amiga-1    ( Use high offset to be audible. )
\
\ Load chosen Sample
    CASE
        0 OF    " hs:analog2" load: sample-draw
          ENDOF
        1 OF    " hs:mandocello" load: sample-draw 
          ENDOF
        2 OF    " hs:peking" load: sample-draw
          ENDOF
\ Report any illegal choices.
        " DD.INIT.INST" " Illegal sample# , use 0 1 or 2."
        er_fatal er.report
    ENDCASE
;

: DD.INIT.PLAYER ( -- ,  Configure Player to use Amiga)
    ins-amiga-1 put.instrument: player-1
    1 new: player-1
    shape-1 add: player-1
    100000 put.repeat: player-1
;

: DD.FILL.SHAPE
\ Build a simple starting shape.
    32 3 new: shape-1
\    D  P   L  , The Loudness has same range as MIDI velocity
    12  2 100 add: shape-1
    12 34 100 add: shape-1
    12 66 100 add: shape-1
    " Duration" 0 put.dim.name: shape-1
    " Pitch"    1 put.dim.name: shape-1
    " Loudness" 2 put.dim.name: shape-1
\
\ Make melody and sample available for editing.
    clear: shape-holder
    shape-1 add: shape-holder
    sample-draw add: shape-holder
;

: DD.INIT.RATIOS  ( -- , Set up Harmonic Overtone Tuning)
    32 new: ratios-32-64
    32 0 DO
        i 32 +   32 add: ratios-32-64
    LOOP
;

: DD.INIT  ( 0 | 1 | 2 -- , load with selected waveform )
    dd.init.inst
    dd.fill.shape
    dd.init.player
    dd.init.ratios
;

: DD.TERM   ( -- , Clean up )
    free: sample-draw
    free: shape-1
    free: ratios-32-64
    free: player-1
    default: player-1
    default: ins-amiga-1
\ Restore default instrument so that next piece works.
    ins-midi-1 put.instrument: player-1
;

: DD.PLAY   ( -- , Play player. )
    player-1 hmsl.play
;

: #DOIT   ( 0 | 1 | 2 -- , Do whole thing. )
    dd.init   dd.play   dd.term
;

." Enter:   0/1/2 #DOIT" cr
." 0 for Analog,  1 for MandoCello,  2 for Peking." cr

