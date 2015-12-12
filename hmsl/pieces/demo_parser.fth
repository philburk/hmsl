\ Demonstrate MIDI Parser
\
\ Respond differently to each note in the octave.
\ Author: Phil Burk
\ Copyright 1990

ANEW TASK-DEMO_PARSER

\ Define functions to respond to NOTE ON command.
: DP.RAND.PRESET  ( note velocity -- )
    40 choose midi.preset
    midi.noteon
;

: DP.FADE { note velocity incr -- , echo note softer and higher }
    rnow  ( set virtual time to now )
    8 0
    DO  note velocity 10 midi.noteon.for
        20 vtime+!  ( advance virtual time )
        velocity 5 * -3 shift -> velocity ( fade velocity by 5/8 )
        note incr + -> note
    LOOP
;

: DP.FADE.OUT  ( note velocity -- , echo note softer and softer )
    0 dp.fade
;

: DP.FADE.UP ( note velocity -- , echo note softer and higher )
    1 dp.fade
;
: DP.FADE.DOWN ( note velocity -- , echo note softer and lower )
    -1 dp.fade
;
: DP.FADE.RAND ( note velocity -- , echo note softer and lower )
    3 choose+/- dp.fade
;

: DP.FADE.WALK  ( note velocity -- , play notes in walk )
    rnow  ( set virtual time to now )
    8 0
    DO  2dup 10 midi.noteon.for
        20 vtime+!  ( advance virtual time )
        swap 3 choose+/- + swap
    LOOP 2drop
;

: DP.FASTER  { note velocity | dur -- , repeat notes faster }
    rnow  ( set virtual time to now )
    20 -> dur
    16 0
    DO  note velocity dur 2/ midi.noteon.for
        dur vtime+!  ( advance virtual time )
        dur 1- -> dur
    LOOP
;

: DP.SWOOP  ( note velocity -- , play note and bend )
    rnow  ( set virtual time to now )
    swap 12 choose+/- + swap 2dup  ( offset note )
    midi.noteon
    50 0
    DO  i 100 * $ 2000 + midi.bend
        1 vtime+!  ( advance virtual time )
    LOOP
    $ 2000 midi.bend
    midi.noteoff
;

: DP.MAJOR.CHORD  ( note velocity -- )
;

\ Temporarily change the Preset to 7.
variable DP-SAVED-PROGRAM
: DP.CHANGE.PROGRAM  ( note velocity -- )
    midi.recall.program dp-saved-program !  ( save previous )
    7 midi.program
    midi.noteon
;
: DP.RESTORE.PROGRAM  ( note velocity -- )
    midi.noteoff
    dp-saved-program @ midi.program
;

: DP.RANDOM.CHORD  ( note velocity -- )
    rnow
    2dup 20 midi.noteon.for
    swap 4 choose 1+ + swap 2dup 20 midi.noteon.for
    swap 4 choose 1+ + swap 20 midi.noteon.for
;

: DP.MAJOR.CHORD  ( note velocity -- )
    2dup midi.noteon
    swap 4 + swap 2dup midi.noteon
    swap 3 + swap midi.noteon
;

: DP.NOTE.OFF  ( note velocity -- , Note OFF response )
    over 12 mod
    CASE
        0 OF midi.noteoff ENDOF
        1 OF 2drop ENDOF
        2 OF drop 0 dp.major.chord ENDOF
        7 OF dp.restore.program ENDOF
        11 OF midi.noteoff ENDOF
        >r 2drop r>
    ENDCASE
;

: DP.NOTE.ON  ( note velocity -- , select function based on note)
    over 12 mod  ( which note in octave )
    CASE
        0 OF dp.rand.preset ENDOF
        1 OF dp.fade.up ENDOF
        2 OF dp.major.chord ENDOF
        3 OF dp.fade.rand ENDOF
        4 OF dp.fade.out ENDOF
        5 OF dp.random.chord ENDOF
        6 OF dp.swoop ENDOF
        7 OF dp.change.program ENDOF
        8 OF dp.fade.down ENDOF
        9 OF dp.faster ENDOF
    10 OF dp.fade.walk ENDOF
    11 OF midi.noteon ENDOF
ENDCASE
;

: DP.HELP ( -- , display help information )
    ." Demonstrate HMSL MIDI Parser!" cr
    ." Note - Function" cr
    ."  C   - Select Random Program"cr
    ."  C#  - Echo softer and Higher" cr
    ."  D   - D Major chord" cr
    ."  D#  - Echo softer, random increment" cr
    ."  E   - Echo softer" cr
    ."  F   - Random Chord" cr
    ."  F#  - Swoop Up" cr
    ."  G   - Temporarily set Program = 7" cr
    ."  G#  - Echo softer and Higher" cr
    ."  A   - Echo faster and faster" cr
    ."  A#  - Echo softer in random walk" cr
    ."  B   - Just Play a B" cr
;

: DP.INIT  ( -- , set up parser )
    eb.on ( turn on event buffering )
    midi.clear
    mp.reset
    'c dp.note.on mp-on-vector !
    'c dp.note.off mp-off-vector !
    dp.help
;

: DP.TERM  ( -- )
    mp.reset
;

: DEMO.PARSER  ( -- )
    dp.init
    >newline ." Hit RETURN to quit." cr
    midi.parse.loop
    dp.term
;

." Connect MIDI Keyboard, use polyphonic setting." cr
." Enter: DEMO.PARSER" cr
