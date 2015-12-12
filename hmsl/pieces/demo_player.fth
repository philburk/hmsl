\ Demonstrate the playing of a SHAPE as a sequence
\ using a PLAYER.
\
\ The shape is filled with a few notes, and played by a
\ shape player.  The shape player uses a MIDI instrument.
\ The shape is interpreted in the "standard" manner, ie.
\ duration, pitch, loudness.   This file could be modified
\ in countless ways to create new pieces.
\
\ Example of HMSL - the Hierarchical Music Specification Language
\
\ Composer: Phil Burk
\ Copyright 1987 Phil Burk, Larry Polansky, David Rosenboom

\ Mark beginning of file in dictionary.
ANEW TASK-DEMO_PLAYER

\ Initialization word.  Responsible for allocating memory,
\ putting data in shapes, building hierarchy, etc.
\ Note the two character prefix to prevent conflict with other
\ words.
: DPL.INIT    ( -- , Initialize Piece )
\
\ Allocate memory for 16 elements with 3 dimensions.
    10 3 new: shape-1
\
\ Add 3D points to shape.
\ The default interpreter treats dimension 0 as duration,
\ 1 as pitch, and 2 as velocity.
\    D  P  V
    10 10 100 add: shape-1
    10 11  70 add: shape-1
    10 19  90 add: shape-1
    10 15  70 add: shape-1
    10  0  60 add: shape-1  ( rest , when pitch = 0 )
    20  8 100 add: shape-1
\
\ Give names to the dimensions.
\ These show up in the Shape Editor.  They have no meaining
\ to HMSL.  They are treated purely as arbitrary text.
\ This must be done after the NEW: method has been used.
    " Duration" 0 put.dim.name: shape-1
    " Pitch   " 1 put.dim.name: shape-1
    " Velocity" 2 put.dim.name: shape-1
\
\ Select the instrument to use for this player.
    ins-midi-1 put.instrument: player-1
\
\ Set the allowable range of MIDI channels for this instrument.
\ This may vary depending on what you have hooked up.
    1 8 put.channel.range: ins-midi-1
\
\ Allocate room for 5 shapes in player-1, put shape-1 in.
    5 new: player-1
    shape-1 add: player-1
\
\ Make player-1 repeat 2000 times so that you have plenty of
\ time to edit it.
    2000 put.repeat: player-1
\
\ Make shape-1 available in the Shape Editor
    clear: shape-holder
    shape-1 add: shape-holder
;

: DPL.PLAY    ( -- , Perform Piece )
    player-1 HMSL.PLAY
;

: DPL.TERM    ( -- , Clean up. )
    default.hierarchy: player-1
    free.hierarchy: player-1
;

: DEMO.PLAYER   (  -- , Do Entire Process )
    dpl.init
    dpl.play
    dpl.term
;

\ Give user/performer a prompt on how to hear this sequence.
cr ." Enter:  DEMO.PLAYER   to hear a simple sequence." cr
