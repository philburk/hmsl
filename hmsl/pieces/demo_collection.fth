\ Demonstrate the playing of a moderately complex sequence
\ using a parallel COLLECTION.
\
\ Composer: Phil Burk
\ Copyright 1987 -  Phil Burk, Larry Polansky, David Rosenboom.
\ MOD: PLB 5/28/87 Use 0STUFF:

ANEW TASK-DEMO_COLLECTION

\ The following word will need to be modified to select
\ the MIDI channels you want to play on in your studio.
: SITE-RANGE ( -- lo hi , site specific range of available channels)
    1 8
;

\ Fill shapes with "melodies".
: DC.FILL.SHAPES
\ Make them big enough to add to in Shape Editor.
    16 3 new: shape-1
    10 20 60 add: shape-1
    10 30 70 add: shape-1
    10 25 80 add: shape-1
    10 35 90 add: shape-1
\
    16 3 new: shape-2
    5  24 100 add: shape-2
    5  29 100 add: shape-2
    10 12 100 add: shape-2
    5  13 30  add: shape-2
    20 22 100 add: shape-2
    5  22 30  add: shape-2
\
\ Fill a shape with a fixed duration=10, and
\ a random melody.
    16 3 new: shape-3
    10 set.many: shape-3
    10 0 fill.dim: shape-3  ( Duration )
\ This next dimension will be interpreted as pitch.
    20 40 ( range )  0 9 ( from to ) 1 randomize: shape-3
    40 100  0 9 2 randomize: shape-3  ( random velocity )
;

\ Build hierarchy of morphs.
: DC.INIT
    dc.fill.shapes
    site-range put.channel.range: ins-midi-1
    26 put.preset: ins-midi-1   ( select some appropriate program)
    ins-midi-1 put.instrument: player-1
    site-range put.channel.range: ins-midi-2
    18 put.preset: ins-midi-2
    ins-midi-2 put.instrument: player-2
\
\ Put two shapes in player-1
    0 shape-1 shape-2 0stuff: player-1
    2 put.repeat: player-1
\
\ Put two shapes in player-2
    0 shape-2 shape-3 0stuff: player-2
    1 put.repeat: player-2
\
\ Make available for Shape Editor.
    clear: shape-holder
    shape-1 add: shape-holder
    shape-2 add: shape-holder
    shape-3 add: shape-holder
\
\ Put players in parallel collection.
\ These two players will execute in parallel
    0 player-1 player-2 0stuff: coll-p-1
    128 put.repeat: coll-p-1
\
    ." Hierarchy of piece!" cr
    print.hierarchy: coll-p-1 cr
    ." Hit any key to continue." key drop
;

: DC.PLAY  ( -- , Play the collection.)
    coll-p-1 hmsl.play
;

: DC.TERM  ( -- , Reset & Free allocated data. )
    default.hierarchy: coll-p-1
    free.hierarchy: coll-p-1
;

: DEMO.COLLECTION  ( -- , Do whole thing. )
    dc.init  dc.play  dc.term
;
." Enter:    DEMO.COLLECTION     for collection demo." cr
