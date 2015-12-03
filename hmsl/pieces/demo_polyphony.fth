\ Demonstrate the generation of chords and polyphony
\ using one shape.
\
\ By setting the OFF interpreter to 3DROP we can
\ specify our own OFF time for a note by using a 0 velocity.
\ Each note would now have two elements, an ON element
\ and an OFF element.
\ This gives us complete control over the notes
\ so we could play anything including overlapping notes.
\ This will be hard to edit, however, using the shape editor.
\ As an alternative, we could write an interpreter that
\ generated chords based on shape data.  See HP:DEMO_CHORDS .
\
\ Author: Phil Burk
\ Copyright 1989 Phil Burk

include? { ju:locals

ANEW TASK-DEMO_POLYPHONY

\ Declare objects.
OB.SHAPE  poly-SHAPE
OB.PLAYER poly-PLAYER
OB.MIDI.INSTRUMENT  poly-INSTR

: ADD.NOTE { dur note velocity ontime shape -- }
	shape dimension: [] 3 - abort" ADD.NOTE assumes 3 dimensions!"
\ Turn on 1 note then wait for ontime
	ontime note velocity shape add: []
\
\ Turn note off with 0 velocity.
	dur ontime -  ( calc offtime )
		note 0 shape add: []
;

\ These words build chords by adding the proper elements
\ to a shape.
: ADD.TRIAD  { dur fund velocity ontime shape int1 int2 -- }
	shape dimension: [] 3 - abort" This word assumes 3 dimensions!"
\ Turn on 3 notes then wait for ontime
	0 fund velocity shape add: []
	0 fund int1 + velocity shape add: []
	ontime fund int2 + velocity shape add: []
\
\ Not turn those 3 notes off with 0 velocity.
	0 fund 0 shape add: []
	0 fund int1 + 0 shape add: []
	dur ontime -  ( calc offtime )
		fund int2 + 0 shape add: []
;

: ADD.MAJOR.TRIAD ( dur fund velocity ontime shape -- )
	4 7 add.triad
;

: ADD.MINOR.TRIAD ( dur fund velocity ontime shape -- )
	3 7 add.triad
;

: ADD.DIM.TRIAD ( dur fund velocity ontime shape -- )
	3 6 add.triad
;

: ADD.AUG.TRIAD ( dur fund velocity ontime shape -- )
	4 8 add.triad
;

\ Simplified words for easier notation.
variable THIS-SHAPE
: +MAJOR  ( dur fund velocity -- )
	2 pick 2* 3 /   this-shape @ add.major.triad
;

: +MINOR  ( dur fund velocity -- )
	2 pick 2* 3 /   this-shape @ add.minor.triad
;

: +NOTE ( dur note velocity -- )
	2 pick 2* 3 /   this-shape @ add.note
;

: +PEDAL+TRIPLET { dur note -- , build special overlapping notes }
	0 note 110 this-shape @ add: [] ( play low note )
	dur 3 /  ( get dur for triplet )
	dup note 14 + 90 +note
	dup note 17 + 90 +note
		note 20 + 90 +note
	0 note 0 this-shape @ add: [] ( low note off )
;

: POLY.INIT ( -- , build shape using these words )
	128 3 new: poly-shape
	poly-shape this-shape !
	12 4 80 +note
	12 7 90 +note
	24 9 110 +minor  \ A min
	24 5 100 +major  \ F maj
	48 2 100 +minor  \ D min
	12 9 110 +note
	12 7 100 +note
	48 14 110 +minor \ D min
	24 12 110 +minor \ C maj
	24 12 110 +minor \ C maj
\
\ Play overlapping notes.
	24 4 +pedal+triplet
	24 9 +pedal+triplet
	48 7 +pedal+triplet
	48 12 +pedal+triplet
\
	print: poly-shape
	." Hit key to continue!" key drop cr
\
\ Now build hierachy to play this
	0 poly-shape 0stuff: poly-player
	poly-instr put.instrument: poly-player
	2000 put.repeat: poly-player
\
\ Specify null OFF interpreter to allow polyphony!!
	'c 3drop PUT.OFF.FUNCTION: poly-instr
;

: POLY.TERM ( -- )
	stop: poly-player
	free: poly-player
	free: poly-shape
;

: DEMO.POLYPHONY ( -- , play piece )
	poly.init
	poly-player hmsl.play
	poly.term
;

." Enter:  DEMO.POLYPHONY    to hear demo!" cr