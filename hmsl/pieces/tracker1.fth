\ TRACKER
\
\ Play the last 16 notes received from a MIDI keyboard
\ in a repeating pattern.  Use a circular buffer
\ to hold the notes.
\
\ Author: Phil Burk
\ Copyright 1986
\ All Rights Reserved
\
\ MOD: PLB 6/4/87 Use MIDI.PARSER.ON

ANEW TASK-TRACKER

VARIABLE MT-SHAPE-MAX
VARIABLE MT-NOTE-DUR
VARIABLE MT-NEXT-INDEX

16 mt-shape-max !
8 mt-note-dur !

\ This word gets called when a note on is recieved.
: MT.NOTE.ON ( note velocity -- , bounce note )
    ?dup  ( velocity > 0 means real ON )
    IF  many: shape-1 max.elements: shape-1  >=
        IF  ( Put in next position in shape. )
            mt-note-dur @ -rot
            mt-next-index @ 1+ dup mt-next-index !
            max.elements: shape-1 mod
            put: shape-1
        ELSE
            mt-note-dur @ -rot add: shape-1
        THEN
    ELSE drop
    THEN
;

: MT.BUILD.PLAYER ( -- , Setup player with shape. )
    mt-shape-max @ 3 new: shape-1
    mt-note-dur @ 0 0 add: shape-1 ( start with a rest )
\
    0 shape-1 0stuff: player-1
    4000 put.repeat: player-1
\
    0 put.gamut: ins-midi-1
    0 put.offset: ins-midi-1
    ins-midi-1 put.instrument: player-1
;

: MT.INIT  ( -- , Initialize Piece )
    mt.build.player
\
\ Set parser vector so that whenever a NOTE ON is recieved
\ the word MT.NOTE.ON will be called.  This will occur
\ when MIDI.PARSE is polled (called).
    mp.reset
    'c mt.note.on  mp-on-vector !
    'c midi.preset   mp-program-vector !
\
\ Make shapes available.
    clear: shape-holder
    shape-1 add: shape-holder
;

: MT.PLAY ( -- )
    midi.clear
    midi.parser.on
    player-1 hmsl.play  ( no preposted morphs )
    midi.parser.off
;

: MT.TERM ( -- , Clean up for others. )
    default.hierarchy: player-1
    free.hierarchy: player-1
    mp.reset       ( reset midi parser vectors )
;

: TRACKER ( -- )
    mt.init  mt.play  mt.term
;

cr ." Enter:   TRACKER  to play this piece." cr
." Play notes on MIDI keyboard." cr
