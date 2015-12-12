\ BOUNCE
\ Make notes from MIDI keyboard repeat with decreasing
\ duration to give bouncing effect.
\
\ Requires multi voice MIDI synth, eg. YAMAHA FB-01
\ for output, and a polyphonic Keyboard for input.
\
\ Author: Phil Burk
\ Copyright 1986
\ All Rights Reserved
\
\ MOD: PLB 5/13/87 Converted to use OB.JOB
\ MOD: PLB 5/24/87 Use MIDI-PARSER
\ MOD: PLB 6/4/87 Adjust BN.PRESET
\ MOD: PLB 1/10/89 Use RTC.TIME@ for EXECUTE:
\ MOD: PLB 4/29/91 Named shapes for demo

ANEW TASK-BOUNCE

OB.SHAPE SH-BOUNCE

: BN.BUILD.DECAY  ( -- , Prepare a decaying sequence.)
\ Sequence with decreasing durations velocity.
    12 3 new: sh-bounce
    20 1 120 add: sh-bounce
    15 1  80 add: sh-bounce
    12 1  70 add: sh-bounce
        9 1  60 add: sh-bounce
        6 1  50 add: sh-bounce
        3 1  30 add: sh-bounce
        1 1  20 add: sh-bounce
        1 1  20 add: sh-bounce
;

\ These will hold dynamically instantiated objects.
OB.OBJLIST BN-PLAYERS
OB.OBJLIST BN-INSTRUMENTS

variable BN-NEXT-PLAYER   ( rotate through players )
\ Sets number of voices to use.
\ Change this to a lower number if need be.
8 constant BN_MANY_PLAYERS
7 constant BN_MANY_MASK

: BN.SET.PLAYER ( instrument player -- )
    1 over new: []
    sh-bounce over add: []
    1 over put.repeat: []
    put.instrument: []
;

: BN.MAKE.PLAYERS ( -- , )
    bn_many_players new: bn-players
    bn_many_players new: bn-instruments
    bn_many_players 0
    DO instantiate ob.midi.instrument
        dup add: bn-instruments
        i 1+ over put.channel: []  \ set each one on its own channel
        instantiate ob.player
        dup add: bn-players
        bn.set.player
    LOOP
;

\ Forth words to support actions -------------------.
: EXECUTE.PLAYER ( player -- , execute a player )
    midi.rtc.time@ 0 rot execute: []
;

\ This word gets called when a note on is recieved.
: BN.NOTE.ON ( note velocity -- , bounce note )
    IF  ( velocity > 0 means real ON )
        1- ( adjust for notes being 1 , non rests )
        bn-next-player @
        dup 1+ bn_many_mask and    bn-next-player !
        get: bn-players tuck
        get.instrument: []
        put.offset: []  ( transpose bounce notes )
        execute.player
    ELSE drop
    THEN
;

: BN.PRESET ( preset -- , set for all instruments )
    1+ ( adjust from 0-127 to 1-128 )
    bn_many_players 0
    DO dup i get: bn-instruments
        put.preset: []
    LOOP drop
;

: BN.INIT  ( -- , Initialize Piece )
    bn.build.decay
    bn.make.players
    0 bn-next-player !
\ Set parser vector so that whenever a NOTE ON is recieved
\ the word BN.NOTE.ON will be called.  This will occur
\ when MIDI.PARSE is polled (called).
\ This will occur automatically if MIDI.PARSER.ON is called
\ before calling HMSL.
    'c bn.note.on  mp-on-vector !
    'c bn.preset   mp-program-vector !
\
\ Make shapes available.
    clear: shape-holder
    sh-bounce add: shape-holder
    " Response" put.name: sh-bounce
    sh-bounce standard.dim.names
\
    midi.clear  ( clear MIDI input of extraneous data )
    midi.parser.on
    4 time-advance !  ( for faster response )
;

: BN.TERM ( -- , Clean up for others. )
    midi.parser.off
    free: sh-bounce
    many: bn-players 0
    DO  i get: bn-players dup free: []
        deinstantiate
        i get: bn-instruments deinstantiate
    LOOP
    free: bn-players
    free: bn-instruments
    mp.reset       ( reset midi parser vectors )
    rtc.rate@ time-advance !
;

: BOUNCE ( -- )
    bn.init  hmsl  bn.term
;

cr
." Enter:   BOUNCE  to play this piece." cr
." Play MIDI keyboard .. edit SH-BOUNCE to modify response." cr
cr
