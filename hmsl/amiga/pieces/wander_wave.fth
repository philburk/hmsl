\ Perform timbre modulation by performing a random walk
\ for each byte of a waveform.
\
\ Demonstrates the use of dynamically instantiated objects.
\
\ Author: Phil Burk
\ Copyright 1986 -  Phil Burk, Larry Polansky, David Rosenboom.

include? ob.random.walk hf:random_walk.fth

ANEW TASK-WANDER_WAVE

16 constant WW_#BYTES
OB.OBJLIST WW-HOLDER  ( will hold dynamically instantiated walkers )
OB.RANDOM.WALK WW-PITCH  ( declare single walker for pitch )

: WW.INIT ( -- )
\ Make room in waveform.
    ww_#bytes new: wave-1
    ww_#bytes set.many: wave-1
\
\ Dynamically instantiate a RANDOM.WALK object for each waveform.
    ww_#bytes new: ww-holder
    ww_#bytes 0
    DO  instantiate ob.random.walk
        dup add: ww-holder
	127 over put.max: []   ( set range )
        -128 over put.min: []
        10 swap put.step: []
    LOOP
\
\ Start sound.
    0 da.channel!
    start: wave-1
\
\ Set up pitch walker.
    100 put.step: ww-pitch
    300 put.min: ww-pitch
    5000 put.max: ww-pitch
;

: WW.TERM ( -- )
    da.kill 20 msec
    many: ww-holder 0
    DO i get: ww-holder deinstantiate
    LOOP
    clear: ww-holder
;

: WW.PLAY ( -- )
    BEGIN
\ Modify timbre
        ww_#bytes 0
        DO i at: ww-holder walk: []
           i to: wave-1
        LOOP
\ Modify pitch
        walk: ww-pitch da.period!
        5 msec
        ?terminal
    UNTIL
;

: WANDER ( -- )
    ww.init   ww.play    ww.term
;

cr
." Enter:  WANDER to hear AMIGA audio timbre modulation." cr
cr
