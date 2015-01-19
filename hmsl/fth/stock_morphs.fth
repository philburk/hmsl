\ Define a set of stock MORPHS to be used.
\
\ Author: Phil Burk
\ Copyright 1986 -  Phil Burk, Larry Polansky, David Rosenboom.
\
\ MOD: PLB 6/1/87 Add JOBs
\ MOD: PLB 1/26/88 Add INIT: of INS-MIDI-5 thru 8

ANEW TASK-STOCK_MORPHS.FTH

\ Declare some shapes to use.
OB.SHAPE SHAPE-1
OB.SHAPE SHAPE-2
OB.SHAPE SHAPE-3
OB.SHAPE SHAPE-4
OB.SHAPE SHAPE-5
OB.SHAPE SHAPE-6
OB.SHAPE SHAPE-7
OB.SHAPE SHAPE-8

\ Declare shape players.
OB.PLAYER PLAYER-1
OB.PLAYER PLAYER-2
OB.PLAYER PLAYER-3
OB.PLAYER PLAYER-4
OB.PLAYER PLAYER-5
OB.PLAYER PLAYER-6
OB.PLAYER PLAYER-7
OB.PLAYER PLAYER-8

exists? ob.midi.instrument [IF]
  OB.MIDI.INSTRUMENT INS-MIDI-1
  OB.MIDI.INSTRUMENT INS-MIDI-2
  OB.MIDI.INSTRUMENT INS-MIDI-3
  OB.MIDI.INSTRUMENT INS-MIDI-4
  OB.MIDI.INSTRUMENT INS-MIDI-5
  OB.MIDI.INSTRUMENT INS-MIDI-6
  OB.MIDI.INSTRUMENT INS-MIDI-7
  OB.MIDI.INSTRUMENT INS-MIDI-8
[THEN]

: STOCK.INIT.SPI  ( -- , Initialize Shapes, Players, Instr)
       init: shape-1
       init: shape-2
       init: shape-3
       init: shape-4
       init: shape-5
       init: shape-6
       init: shape-7
       init: shape-8

       init: player-1
       init: player-2
       init: player-3
       init: player-4
       init: player-5
       init: player-6
       init: player-7
       init: player-8
\
\ Set default instruments in some players.
[ exists? ob.midi.instrument [IF] ]
       init: ins-midi-1
       init: ins-midi-2
       init: ins-midi-3
       init: ins-midi-4
       init: ins-midi-5
       init: ins-midi-6
       init: ins-midi-7
       init: ins-midi-8
       ins-midi-1 put.instrument: player-1
       ins-midi-2 put.instrument: player-2
       ins-midi-3 put.instrument: player-3
       ins-midi-4 put.instrument: player-4
[ [THEN] ]
;

\ Declare sequential and parallel collections.
OB.COLLECTION COLL-S-1
OB.COLLECTION COLL-S-2
OB.COLLECTION COLL-S-3
OB.COLLECTION COLL-S-4

OB.COLLECTION COLL-P-1
OB.COLLECTION COLL-P-2
OB.COLLECTION COLL-P-3
OB.COLLECTION COLL-P-4

OB.STRUCTURE STRUCT-1

\ Declare some productions.
OB.PRODUCTION PRODUCTION-1
OB.PRODUCTION PRODUCTION-2
OB.PRODUCTION PRODUCTION-3
OB.PRODUCTION PRODUCTION-4

OB.JOB JOB-1
OB.JOB JOB-2
OB.JOB JOB-3
OB.JOB JOB-4

CREATE IF-STOCK-INIT 0 ,

: STOCK.INIT    ( -- , Initialize stock objects. )
\ Players and streams need INIT: on MAC for proper CFAs
    if-stock-init @ 0=
    IF    " STOCK.INIT" debug.type
       stock.init.spi
\
       init: coll-s-1
       act.sequential: coll-s-1
       init: coll-s-2
       act.sequential: coll-s-2
       init: coll-s-3
       act.sequential: coll-s-3
       init: coll-s-4
       act.sequential: coll-s-4
       init: coll-p-1
       init: coll-p-2
       init: coll-p-3
       init: coll-p-4
       init: struct-1
\
       init: production-1
       init: production-2
       init: production-3
       init: production-4
\
       init: job-1
       init: job-2
       init: job-3
       init: job-4
\
       true if-stock-init !
    THEN
;

: SYS.INIT sys.init stock.init ;

\ END
