\ Demonstrate reading and playing of a simple MIDIFile
\
\ Author: Phil Burk
\ Copyright 1990 Phil Burk

\ This also appears as an example in the HMSL Manual.
include? $mf.load.shape ht:midifile

ANEW TASK-DEMO_READ_MF

OB.SHAPE SH1
OB.PLAYER PL1
OB.MIDI.INSTRUMENT INS1

: READ.MF  ( -- , read a midifile into a shape )
	0 " hmf:simple.mf" $mf.load.shape  \ loads as absolute expanded
	mf-shape sh1 sh.compress.notes     \ convert to compressed
;

: PLAY.MF  ( -- , play the shape read from MIDIFile )
	sh1 ins1 build: pl1
	0 put.offset: ins1     \ 0 offset because stored as MIDI notes
	use.absolute.time: pl1 \ absolute not relative time
	3 put.on.dim: pl1      \ use ontimes of compressed notes
	pl1 hmsl.play
;

s