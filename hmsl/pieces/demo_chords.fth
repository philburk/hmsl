\ Demonstrate the generation of chords
\ using one shape.
\
\ We will use a smart interpreter that uses one
\ dimension of a shape to tell it whether to play a note
\ or a chord or whatever.
\ As an alternative, see HP:DEMO_POLYPHONY
\
\ Author: Phil Burk
\ Copyright 1989 Phil Burk

include? { ju:locals

ANEW TASK-DEMO_CHORDS

\ Declare objects.
OB.SHAPE  chord-SHAPE
OB.PLAYER chord-PLAYER
OB.MIDI.INSTRUMENT  chord-INSTR
ob.array CH-ON-FUNCTIONS
ob.array CH-OFF-FUNCTIONS

\ Variables used for temporary storage.
variable THIS-INSTR
variable THIS-MODE
variable THIS-VELOCITY
variable THIS-PITCH

\ Define possible modes (values for dim 3 )
0 constant MODE_NOTE
1 constant MODE_MAJOR
2 constant MODE_MINOR
3 constant MODE_RANDOM
4 constant MODE_HANG
5 constant MODE_ALLOFF

: CH.NOTE+  ( offset -- , play note at offset )
	this-pitch @ +  this-velocity @
	this-instr @ note.on: []
;

: CH.NOTE.ON ( -- , play note )
	0 ch.note+
;

: CH.MAJOR.ON ( -- , play major chord )
	0 ch.note+   4 ch.note+   7 ch.note+
;

: CH.MINOR.ON ( -- , play major chord )
	0 ch.note+   3 ch.note+   7 ch.note+
;

: CH.RANDOM.ON  ( -- , play randomly offset note )
	9 choose 4 - ch.note+
;

: CH.ALL.OFF ( -- , turn all notes off )
	this-instr @ all.off: []
;

: CHORDS.ON.INTERP ( element# shape instr -- , standard stack )
	this-instr !  ( save for later )
	get: []  ( get data and save it in variables )
	this-mode ! this-velocity ! this-pitch !
	drop
	this-mode @ exec: ch-on-functions
;

: CH.NOTE.OFF ( -- , turn last note off )
	this-instr @ last.note.off: []
;

: CH.TRIAD.OFF ( -- , turn off three notes )
	3 0
	DO ch.note.off
	LOOP
;

: CHORDS.OFF.INTERP ( element# shape instr -- , standard stack )
	this-instr !  ( save for later )
	get: []  ( get data and save it in variables )
	this-mode ! this-velocity ! this-pitch !
	drop
	this-mode @ exec: ch-off-functions
;

\ Simplified words for easier notation.
variable THIS-SHAPE
: +MAJOR  ( dur fund velocity -- )
	mode_major this-shape @ add: []
;

: +MINOR  ( dur fund velocity -- )
	mode_minor this-shape @ add: []
;

: +NOTE ( dur note velocity -- )
	mode_note this-shape @ add: []
;

: CH.SET.FUNCTIONS
	6 new: ch-on-functions
	'c ch.note.on   mode_note   to: ch-on-functions
	'c ch.major.on  mode_major  to: ch-on-functions
	'c ch.minor.on  mode_minor  to: ch-on-functions
	'c ch.note.on   mode_hang   to: ch-on-functions
	'c ch.random.on mode_random to: ch-on-functions
	'c ch.all.off   mode_alloff to: ch-on-functions
\
	6 new: ch-off-functions
	'c ch.note.off  mode_note   to: ch-off-functions
	'c ch.triad.off mode_major  to: ch-off-functions
	'c ch.triad.off mode_minor  to: ch-off-functions
	'c noop         mode_hang   to: ch-off-functions
	'c ch.note.off  mode_random to: ch-off-functions
	'c noop         mode_alloff to: ch-off-functions
;

: CHORD.INIT ( -- , build shape using these words )
\ Note similarity to hp:demo_polyphony.
\ Need 4 dimensional shape.
	40 4 new: chord-shape
	chord-shape this-shape !
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
\ Now experiment with hanging notes and random notes.
	0 5 100 mode_hang add: chord-shape
	6 12 110 mode_random add: chord-shape
	6 16 110 mode_random add: chord-shape
	12 12 110 mode_hang add: chord-shape
	12 2 110 mode_random add: chord-shape
	12 4 110 mode_random add: chord-shape
	0 0 0 mode_alloff add: chord-shape
\
\ Add low note to triads
	0 2 100 mode_hang add: chord-shape
	24 14 110 +minor
	0 0 0 mode_alloff add: chord-shape
	0 0 120 mode_hang add: chord-shape
	48 12 120 +minor
	0 0 0 mode_alloff add: chord-shape

	print: chord-shape
	." Hit key to continue!" key drop cr
\
\ Now build hierachy to play this
	0 chord-shape 0stuff: chord-player
	chord-instr put.instrument: chord-player
	2000 put.repeat: chord-player
\
\ Specify use of special interpreters
	'c chords.on.interp put.on.function: chord-instr
	'c chords.off.interp put.off.function: chord-instr
\
\ Make available for editing.
	" Duration" 0 put.dim.name: chord-shape
	" Pitch" 1 put.dim.name: chord-shape
	" Velocity" 2 put.dim.name: chord-shape
	" Mode" 3 put.dim.name: chord-shape
	chord-shape add: shape-holder
\
\ Set limits for editing
	0 127 2 put.dim.limits: chord-shape ( velocity )
	0 5 3 put.dim.limits: chord-shape   ( mode )
	ch.set.functions
;

: chord.TERM ( -- )
	stop: chord-player
	free: chord-player
	free: chord-shape
	free: ch-on-functions
	free: ch-off-functions
	chord-shape delete: shape-holder
;

: DEMO.CHORDS ( -- , play piece )
	chord.init
	chord-player hmsl.play
	chord.term
;


." Enter:  DEMO.CHORDS    to hear piece!" cr
