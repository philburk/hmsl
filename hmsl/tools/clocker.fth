\ Job that sends MIDI clock pulses every N ticks

ANEW TASK-MIDI_CLOCKER

OB.JOB CLOCKER-JOB

: CLOCKER.FUNC  ( job -- , advance clock of MIDI sequencers )
    drop midi.clock
;

: CLOCKER.START  ( job -- , start external sequencers )
    drop midi.start
;

: CLOCKER.STOP  ( job -- , stop external sequencers)
   drop midi.stop
;

: CLOCKER.SETUP  ( ticks/clock -- )
    put.duration: clocker-job
    0 'c clocker.func 0stuff: clocker-job
    'c clocker.start put.start.function: clocker-job
    'c clocker.stop put.stop.function: clocker-job
;

: CLOCKER.TERM  ( -- )
    free: clocker-job
;

if.forgotten clocker.term

\ Alternative clocker using POST.EVENT

: CLOCK.EVENT  ( data1 ticks/clock --  , standard stack )
    recursive
    midi.clock  ( send MIDI clock  )
    dup vtime@ + -rot   ( add to time for next )
    'c clock.event post.event
;

: START.CLOCKER  ( morph -- , use as a start function )
    drop vtime@ time@ max 2+  ( calc start time %Q )
    0 2  ( happen every 2 ticks )
    'c clock.event post.event
;

\ Move to HMSL_TOP

: 0HMSL.PLAY  ( 0 morph1 morph2 ... morphN -- , play'em )
    0depth 0< abort" Need 0 before list!"
    time@ rtc.rate@ + >r
    BEGIN dup
    WHILE r@ 0 rot execute: []
    REPEAT drop  rdrop
    hmsl
;
