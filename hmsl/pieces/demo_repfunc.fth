\ Use Repeat Function to modify shape.
\
\ Composer: Phil Burk
\ Copyright 1987 - Phil Burk , Larry Polansky, David Rosenboom.

ANEW TASK-DEMO_REPFUNC

\ Forth functions to use in productions.
: DRF.RAND.NOTE  ( -- , randomize notes in shape-1 )
    4 20
\ select subrange of shape
    many: shape-1 choose
    many: shape-1 choose 2sort
    1 randomize: shape-1  ( randomize note dimension )
;

: DRF.RAND.DUTY  ( -- , select random duty cycle for player )
    4 choose 1+ 5 put.duty.cycle: player-1
;

: DRF.REVERSE ( -- , reverse entire shape-1 )
    0  many: shape-1 1-  ( start and end index )
    1 reverse: shape-1   ( randomize notes )
;

: DRF.REPFUNC ( player -- , do some modification to shape )
    drop  ( just address player explicitly )
    3 choose
    CASE
        0 OF drf.rand.note ENDOF
        1 OF drf.rand.duty ENDOF
        2 OF drf.reverse ENDOF
    ENDCASE
    shape-1 se.update.shape   \ show change in shape editor
;

: DRF.INIT ( -- , set up morphs )
    8 3 new: shape-1
    8 set.many: shape-1     ( "fill" without using ADD: )
    10 0 fill.dim: shape-1  ( set durations )
    80 2 fill.dim: shape-1  ( set velocities )
    4 20 0 7 1 randomize: shape-1
    120 0 2 ed.to: shape-1  ( start with one loud one )
\
\ Set up a player.
    200 put.repeat: player-1
    0 shape-1 ( shape-1 ) 0stuff: player-1  ( play shape twice )
    1 8 put.channel.range: ins-midi-1
    -1 put.preset: ins-midi-1  ( Leave machine presets alone.)
    ins-midi-1 put.instrument: player-1
    'c drf.repfunc put.repeat.function: player-1
;

: DRF.PLAY  ( -- , Play collection. )
    player-1 hmsl.play
;

: DRF.TERM    ( -- , Clean up )
    default.hierarchy: player-1
    free.hierarchy: player-1
;

if.forgotten drf.term

: DEMO.REPFUNC  ( -- , DO whole thing. )
    DRF.init DRF.play DRF.term
;

cr ." Enter:   DEMO.REPFUNC     for demo." cr
