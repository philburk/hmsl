\ Use PRODUCTIONs to create a random shape and transform it.
\
\ Productions contain Forth words that can be executed at
\ any point in the hierarchy.
\
\ Composer: Phil Burk
\ Copyright 1987 - Phil Burk , Larry Polansky, David Rosenboom.
\ MOD: PLB 6/4/87 Use 0STUFF:

ANEW TASK-DEMO_PRODUCTIONS

\ Create 3 productions to modify shape.
OB.PRODUCTION PROD-RANDOMIZE
OB.PRODUCTION PROD-TRANSPOSE
OB.PRODUCTION PROD-REVERSE

\ Forth functions to use in productions.
: DPR.RAND.NOTE  ( -- , randomize notes in shape-1 )
    20 40                 ( allowable range )
    0   many: shape-1 1-  ( starting and ending index )
    1 randomize: shape-1  ( randomize note dimension )
;

: DPR.RAND.DUTY  ( select random duty cycle for player )
    4 choose 1+ 5 put.duty.cycle: player-1
;

: DPR.TRANS ( -- , transpose shape-1 )
    12 choose             ( ammount to transpose )
    0   many: shape-1 1-  ( start and end index )
    1 transpose: shape-1  ( randomize notes )
;

: DPR.REVERSE ( -- , reverse entire shape-1 )
    0  many: shape-1 1-  ( start and end index )
    1 reverse: shape-1   ( randomize notes )
;

: DPR.INIT ( -- , set up morphs )
    8 3 new: shape-1
    8 set.many: shape-1     ( "fill" without using ADD: )
    10 0 fill.dim: shape-1  ( set durations )
    80 2 fill.dim: shape-1  ( set velocities )
    120 0 2 ed.to: shape-1  ( start with one loud one )
\
\ Place functions in productions.
\ Any number of Forth words can be added to a production.
\ The only limitation is that they must be quick.
    0 'c dpr.rand.note 'c dpr.rand.duty 0stuff: prod-randomize
\
    0 'c dpr.trans 0stuff: prod-transpose
\
    0 'c dpr.reverse 0stuff: prod-reverse
\
\ Set up a player.
    2 put.repeat: player-1
    0 shape-1 0stuff: player-1
    1 8 put.channel.range: ins-midi-1
    -1 put.preset: ins-midi-1  ( Leave machine presets alone.)
    ins-midi-1 put.instrument: player-1
\
\ Build a collection that alternates productions and player.
    0
    prod-randomize
    player-1
    prod-transpose
    player-1
    prod-reverse
    player-1     0stuff: coll-s-1
    16 put.repeat: coll-s-1
\
    cr ." Hierarchy of piece...."
    print.hierarchy: coll-s-1 cr
    ." Hit any key." key drop
;

: DPR.PLAY  ( -- , Play collection. )
    coll-s-1 hmsl.play
;

: DPR.TERM    ( -- , Clean up )
    default.hierarchy: coll-s-1
    free.hierarchy: coll-s-1
;

: DEMO.PRODUCTION  ( -- , DO whole thing. )
    dpr.init dpr.play dpr.term
;

." Enter:   DEMO.PRODUCTION     for demo." cr
