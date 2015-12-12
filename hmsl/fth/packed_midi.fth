\ Tools for handling packed MIDI messages.
\ A packed MIDI Message one cell packed as:
\     b0-b1-b2-cn
\
\ 1-3 bytes ORd with a count byte.
\
\ Author: Phil Burk
\ Copyright 1990 Phil Burk
\ MOD: PLB 6/19/91 use only vtime
decimal

ANEW TASK-PACKED_MIDI.FTH

variable PM-OUT-PAD  ( only used by this next word in background )

: MIDI.UNPACK  ( packed-midi -- addr count )
    pm-out-pad 2dup be!
    swap 3 and
;

: MIDI.PACK  ( addr count -- packed-midi )
    dup 4 <
    IF swap be@ $ FFFFFF00 and OR
    ELSE ." MIDI.PACK doesn't handle SYSEX!" cr 2drop 0
    THEN
;

: INTERP.PACKED.MIDI  ( elmnt# shape instr -- )
    drop
    1 swap ed.at: []  ( get packed data )
    midi.unpack  midi.write
;

defer OLD.MIDI.WRITE
ob.shape CAPTURED-MIDI   \ shape to hold captured events

variable CAPTURE-TIME
variable IF-CAPTURING
variable ECHO-CAPTURE
echo-capture on

: CAPTURE.MIDI  ( addr count -- , write MIDI to shape )
    echo-capture @
    IF 2dup old.midi.write
    THEN
    captured-midi ensure.room ( -- a c )
    midi.pack
	capture-time @ 0=
	IF
		vtime@ capture-time !  \ first time?
	THEN
	vtime@ rtc.time@ max capture-time @ -
    tuck 0 search.back: captured-midi ( - a c i )
    insert: captured-midi
;

: }CAPTURE  ( -- )
    if-capturing @
    IF  what's old.midi.write is midi.write
        if-capturing off
    THEN
;

: CAPTURE{ ( -- )
    }capture
    0 capture-time !
    what's midi.write is old.midi.write
    'c capture.midi is midi.write
    if-capturing on
    64 2 new: captured-midi
;
: CAPTURE.TERM
    free: captured-midi
;

if.forgotten capture.term

ob.player pl-capture
ob.midi.instrument ins-capture

: PLAY.CAPTURED  ( -- )
    captured-midi ins-capture build: pl-capture
    use.absolute.time: pl-capture
    'c interp.packed.midi put.on.function: ins-capture
;
