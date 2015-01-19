\ Schedule the playing of morphs using a shape
\ and a special interpreter.
\ This is handy if you want Morphs to play at specific times
\ as opposed to "when another morph finishes".
\
\ This technique could be useful in film scoring.
\
\ Author: Phil Burk
\ Copyright 1990 Phil Burk

ANEW TASK-SCHEDULE_MORPHS

\ Morphs to be scheduled.
OB.PLAYER  PL-X
OB.PLAYER  PL-Y
OB.PLAYER  PL-Z
OB.COLLECTION  COL-X

\ Shape to contain Morph Schedule
OB.SHAPE SM-SHAPE
\ Player to play it
OB.PLAYER SM-PLAYER
\ Instrument to hold special Interpreter
\ Don't need OB.MIDI.INSTRUMENT
OB.INSTRUMENT SM-INSTR

: BEATS  ( N -- time , calculate time for N beats )
	ticks/beat @ *
;

: TELL.START ( morph -- )
	name: [] ."  started" cr
;

: SM.INIT  ( -- )
\ Setup players with random melodies.
\ Give them recognizable presets.
	prefab: pl-x
	5 get.instrument: pl-x put.preset: []
	prefab: pl-y
	10 get.instrument: pl-y put.preset: []
	prefab: pl-z
	15 get.instrument: pl-z put.preset: []
\
\ Put in functions to help us tell what's happening.
	'c tell.start put.start.function: pl-x
	'c tell.start put.start.function: pl-y
	'c tell.start put.start.function: pl-z
	'c tell.start put.start.function: col-x
\
\ Setup a collection to play two of the players at once.
	stuff{ pl-x pl-y }stuff: col-x
\
\ Setup shape with schedule for playing Morphs
\ You can have an optional ON dimension in dim 3.
\ Time will be specified in "beats" since beginning of piece.
\ You can use any timing system you want.
\ Dimsensions:
\       Time  Morph  Repeat OnTime
	32 4 new: sm-shape
	stuff{
		0     pl-x    2       0   ( 0 means run till done )
	10 beats  pl-y    1      60   ( run for 1 second )
	14 beats  pl-z    3       0
	33 beats  col-x   1       0
	36 beats  pl-z    1    1 beats   ( play first part )
	38 beats  pl-z    1    2 beats
	42 beats  pl-z    1       0
}stuff: sm-shape
sm-shape print.morph.shape
\
sm-shape sm-instr build: sm-player
8 put.repeat: sm-player
10 beats put.repeat.delay: sm-player
\
\ We use absolute time since it makes it easier to schedule
\ complex events like one would in a film score.
use.absolute.time: sm-player
\
\ Tell player to get ON TIMES from dimension 3.
3 put.on.dim: SM-PLAYER
\
\ TELL INSTRUMENT TO USE SPECIAL INTERPRETER!!
'c interp.play.morph  put.on.function:  sm-instr
;

: SM.TERM  ( -- )
	cleanup: col-x
	cleanup: pl-z
	cleanup: sm-player
;

if.forgotten sm.term

: SCHEDULE.MORPHS  ( -- )
	sm.init
	hmsl-graphics off
	sm-player hmsl.play
	hmsl-graphics on
	sm.term
;

cr ." Enter:  SCHEDULE.MORPHS    to hear them." cr