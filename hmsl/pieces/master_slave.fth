\ Demonstrate the use of MIDI Parsing, software timing
\ and a JOB to synchronize two machines with HMSL.
\ This could be altered to work with one HMSL
\ machine and a normal MIDI sequencer.
\
\ If you are using a regular MIDI sequencer, you may want
\ to use it's MIDI clock.  If so, enter:
\    TRUE IF-SLAVE-CLOCK !
\ before entering SLAVE.
\
\ Author: Phil Burk
\ Copyright 1986 -  Phil Burk, Larry Polansky, David Rosenboom.
\ All Rights Reserved

ANEW TASK-MASTER_SLAVE

VARIABLE NEXT-SONG   ( holds request for next song )
VARIABLE IF-SLAVE-CLOCK
false if-slave-clock !

: SLAVE.MELODIES ( -- , setup two slave melodies )
\ This is so we will have a selection to choose from.
	10 3 new: shape-1
	12  5 100 add: shape-1
	12  9  80 add: shape-1
		6 14  80 add: shape-1
		6 12  80 add: shape-1
	1 new: player-1
	shape-1 add: player-1
	ins-midi-1 put.instrument: player-1
	8 put.repeat: player-1
\
	10 3 new: shape-2
	12  5 100 add: shape-2
		6 21  80 add: shape-2
		6  8  80 add: shape-2
	12 17  80 add: shape-2
	1 new: player-2
	shape-2 add: player-2
	ins-midi-2 put.instrument: player-2
	8 put.repeat: player-2
\
\   Make available to editor.
	clear: shape-holder
	shape-1 add: shape-holder
	shape-2 add: shape-holder
\
\ Set default selection.
	player-1 next-song !
;

\ SLAVE Machine responds to MIDI messages.
: SLAVE.SELECT  ( song# -- , select song )
	CASE  ( easily expandable )
		1 OF player-1 ENDOF
		2 OF player-2 ENDOF
		dup . ." Not available!" cr player-1
	ENDCASE
	dup cr name: [] ." selected!" cr
	next-song !
;

: SLAVE.START ( -- , start song )
	time@ 0 next-song @ execute: []
;

: SLAVE.STOP  ( -- , stop song )
	next-song @ stop: []
;

: SLAVE.CLOCK ( -- , advance software clock )
	1 time+!
;

: SLAVE.INIT  ( -- , set vectors, etc. )
	slave.melodies
	mp.reset
	'c slave.select mp-select-vector !
	'c slave.start mp-start-vector !
	'c slave.stop mp-stop-vector !
	if-slave-clock @
	IF 'c slave.clock mp-clock-vector !
		use.software.timer
	ELSE use.hardware.timer
	THEN
;

: SLAVE.RUN   ( -- , await commands from Master )
	midi.clear
	midi.parser.on
	HMSL
	midi.parser.off
;

: SLAVE.TERM ( -- )
	free: shape-1
	free: player-1
	free: shape-2
	free: player-2
	use.hardware.timer
	mp.reset
;

: SLAVE  ( -- , do all )
	slave.init    slave.run   slave.term
;

\ MASTER Controller sends MIDI system messages to control
\ second machine.

: REMOTE.PLAY  ( 1 | 2 -- , select and play song 1 or 2 )
	midi.song.select
	midi.start
;

cr
." On slave machine, enter:   SLAVE" cr
." Then on master machine, enter:  1 or 2  REMOTE.PLAY" cr
cr