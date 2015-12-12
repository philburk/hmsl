\ This example demonstrates the use of a custom interpreter.
\
\ A custom interpreter uses the data from one shape to
\ transpose the playing of another shape.
\
\ Composer: Phil Burk
\ Copyright 1986 -  Phil Burk, Larry Polansky, David Rosenboom.
\ All Rights Reserved
\ MOD: PLB 6/4/87 Use 0STUFF:

ANEW TASK-DEMO_INTERPRETER

: DI.INIT.MELODY  ( -- Initialize the melody. )
    16 3 new: shape-1
    10 10 120 add: shape-1
    10 13  80 add: shape-1
    10 15  80 add: shape-1
    10 12  80 add: shape-1
    10 19  80 add: shape-1
    10 21  80 add: shape-1
    20 22  80 add: shape-1
\
    1 new: player-1
    shape-1 add: player-1
    128 put.repeat: player-1
    ins-midi-1 put.instrument: player-1
\
\ Name dimensions.
    " Duration" 0 put.dim.name: shape-1
    " Pitch" 1 put.dim.name: shape-1
    " Loudness" 2 put.dim.name: shape-1
;

\ This is the custom INTERPRETER !!!!!!
: DI.INTERP.TRANSPOSE ( elmnt# shape instrument -- , standard stack)
    drop  ( don't need this instrument )
    1 swap ed.at: []   ( get transpose value )
    put.offset: ins-midi-1
;

: DI.INIT.TRANSPOSE  ( -- , Set up transpose shape )
    8 2 new: shape-2
    23 40 add: shape-2  ( transpose at odd times )
    47 48 add: shape-2
    91 38 add: shape-2
    38 50 add: shape-2
\
\ Name dimensions for Shape Editor.
    " Duration"  0 put.dim.name: shape-2
    " Transpose" 1 put.dim.name: shape-2
\
\ Set up Player-2 , use 0STUFF: as alternative to NEW: and ADD:
    0 shape-2 0stuff: player-2
    200 put.repeat: player-2
    ins-midi-2 put.instrument: player-2
\
\ TELL INSTRUMENT HOW TO INTERPRET THE SHAPE !!!!!
    'c di.interp.transpose put.on.function: ins-midi-2
    'c 3drop put.off.function: ins-midi-2
;

: DI.INIT ( -- )
    di.init.melody
    di.init.transpose
\
    0 player-1 player-2 0stuff: coll-p-1
    1 put.repeat: coll-p-1
\
    clear: shape-holder
    shape-1 add: shape-holder
    shape-2 add: shape-holder
;

: DI.PLAY ( -- )
    coll-p-1 hmsl.play
;

: DI.TERM ( -- , Clean up )
    default.hierarchy: coll-p-1
    free.hierarchy: coll-p-1
;

: DEMO.INTERPRETER ( -- , Run Demo )
    di.init   di.play  di.term
;


." Enter:   DEMO.INTERPRETER   to hear piece. " cr

