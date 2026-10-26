\ Play with Yamaha FB-01
\ 
\ Author: Phil Burk
\ Copyright 1986 -  Phil Burk, Larry Polansky, David Rosenboom.
\
ANEW TASK-FB-01

U: MIDI-DUR
300 MIDI-DUR !

: MIDI.HIT  ( -- , Sound note )
    56 100 midi.noteon    midi-dur @ msec
    midi.lastoff    midi-dur @ msec
;

: FB.HIT16 ( -- , Sound 16 channels )
    16 0
    DO  i 1+ dup . cr midi.channel!
        midi.hit
        ?terminal IF leave THEN
    LOOP
;

\ FB-01 Event List messages: F0 43 75 70 <events> F7
\
\ Each event is sent in its own complete SysEx message so that it is sent
\ immediately. HMSL holds SysEx data until the F7 arrives, because current
\ MIDI systems cannot send part of a SysEx message, so events sent inside
\ one long SysEx would not play until the end.
\ This is the same approach as Larry's lp_util/fb_util.fth.

: FB.START.EVENTS ( -- , Start event list message for FB-01 )
    $ F0 midi.xmit
    $ 43 midi.xmit
    $ 75 midi.xmit
    $ 70 midi.xmit
;

: FB.STOP.EVENTS ( -- , End event list message, send it now )
    $ F7 midi.xmit
    midi.flush
;

: FB.FRACT.ON  ( note fraction velocity -- , note on with fraction )
    fb.start.events
    $ 10 midi.cvm+3D
    fb.stop.events
;

: FB.FRACT.OFF  ( note fraction -- , note off with fraction )
    fb.start.events
    $ 00 midi.cvm+2D
    fb.stop.events
;

true .IF
\ Test fractions.
: FB.TEST1  ( -- , random melody in semitone range)
    10 0
    DO  100 choose 60 over 120  .s fb.fract.on
        100 msec
        60 swap fb.fract.off
        100 msec
    LOOP
;
.THEN
