\ Demonstrate the use of ACTIONS to create a Real Time
\ Performance environment.
\
\ This piece requires a MIDI input device, and
\ 2 channels of MIDI output.
\ MIDI input is used to transpose a continuous melody.
\ When a C is input, it triggers a quick sequence.
\ The continuous melody is triggered from the
\ Action Table.
\
\ Author: Larry Polansky (Action Table), Phil Burk (Demo)
\ Copyright 1986 -  Phil Burk, Larry Polansky, David Rosenboom.
\ All Rights Reserved
\
\ MOD: PLB 5/24/87 Use reexecute of PLAYER.
\ MOD: PLB 6/10/87 Use MIDI Parser.
\ MOD: PLB 2/2/88 Allocate more space with NEW:

ANEW TASK-DEMO_ACTION

: DACT.INIT.SEQ1  ( -- , Prepare a quick sequence.)
	16 3 new: shape-1
	4 10 120 add: shape-1
	4 12  80 add: shape-1
	4 16  80 add: shape-1
	4 22  80 add: shape-1
	4 30  70 add: shape-1
	4 40  70 add: shape-1
	4 20 100 add: shape-1
	4 24  80 add: shape-1
	4 30  80 add: shape-1
	4 38  80 add: shape-1
\
\ Put in Player.
	1 new: player-1
	shape-1 add: player-1
	1 put.repeat: player-1
	ins-midi-1 put.instrument: player-1
;

: DACT.INIT.SEQ3  ( -- , Prepare a quick sequence.)
	16 3 new: shape-3
	4 19 120 add: shape-3
	4  6  80 add: shape-3
	4  8  80 add: shape-3
	4 32 100 add: shape-3
	4 41  70 add: shape-3
	4 21  70 add: shape-3
	4 33  80 add: shape-3
	4 32  80 add: shape-3
	4 31  80 add: shape-3
	4 28  80 add: shape-3
\
\ Put in Player.
	1 new: player-3
	shape-3 add: player-3
	1 put.repeat: player-3
	ins-midi-3 put.instrument: player-3
	41 put.preset: ins-midi-3
;

: DACT.INIT.COLL
	2 new: coll-p-1
	player-1 add: coll-p-1
	player-3 add: coll-p-1
;

: DACT.INIT.SEQ2  ( -- , Prepare a repeating sequence.)
\ Sequence with increasing intervals.
	16 3 new: shape-2
	4 10 120 add: shape-2
	4 12  80 add: shape-2
	4 16  80 add: shape-2
	4 14  80 add: shape-2
	8 10  80 add: shape-2
	8  8  80 add: shape-2
\
\ Put in Player.
	1 new: player-2
	shape-2 add: player-2
	10000 put.repeat: player-2
	ins-midi-2 put.instrument: player-2
;

\ Forth words to support actions -------------------.
V: DACT-LAST-NOTE  ( stores last note )
v: DACT-GOING-UP?  ( Is this note higher than th last? )

\ This word gets called when a note on is recieved.
\ It supports all of the uses of the note.
: DACT.NOTE.ON ( note velocity -- , transpose melody )
	IF  ( velocity > 0 means real ON )
\ 1) Transpose melody2.
		dup put.offset: ins-midi-2
\ 2) Execute PLAYER-1 if a C note hit.
		dup 12 mod 0=
		IF get.offset: ins-midi-2  put.offset: ins-midi-1
			rtc.time@ 0 execute: coll-p-1
		THEN
\ 3) See if note is higher.
		dup dact-last-note @ > dact-going-up? ! ( save flag )
		dact-last-note !
	ELSE drop
	THEN
;

: DACT.GOING.UP?  ( -- flag , is melody increasing )
	dact-going-up? @
;

: DACT.PRESET.RESP ( flag -- , change preset for melody )
	IF 40 choose put.preset: ins-midi-2
	THEN
;

\ Random melody support ---------------------------------
: DACT.RANDOM.INIT ( -- , open instrument for this action )
	open: ins-midi-4
	50 put.offset: ins-midi-4
	40 100 note.on: ins-midi-4
;
: DACT.RANDOM.TERM ( -- )
	last.note.off: ins-midi-4
	close: ins-midi-4
;
: DACT.RANDOM.RESP ( flag -- , play a random note )
	rnow \ right now
	IF  last.note.off: ins-midi-4
		26 choose 40 choose 60 + note.on: ins-midi-4
	THEN
;

: DACT.ABORT.P2  ( -- , Abort Player-2 )
	stop: player-2
;

: DACT.EXEC.P2  ( -- , Execute Player-2 )
	start: player-2
;

: DACT.INIT.ACTIONS ( -- , Setup actions )
\ Initialize an action that will change presets if the melody
\ is ascending.
	'c dact.going.up? put.stimulus: act-1
	'c dact.preset.resp put.response: act-1
	act-1 put.action: action-table
	" Preset" put.name: act-1
\
\ This action controls whether the melody is being played.
	'c dact.exec.p2 put.init: act-2
	'c dact.abort.p2 put.term: act-2
	act-2 put.action: action-table
	" Melody" put.name: act-2
\
\ This action will generate random melody when on.
	'c dact.random.init put.init: act-3
	'c dact.random.term put.term: act-3
	'c maybe put.stimulus: act-3
	'c dact.random.resp put.response: act-3
	act-3 put.action: action-table
	" Random" put.name: act-3
;

: DACT.INIT  ( -- , Initialize Piece )
	dact.init.seq1
	dact.init.seq2
	dact.init.seq3
	dact.init.coll
	dact.init.actions
\ Set parser vector so that whenever a NOTE ON is recieved
\ the word DACT.NOTE.ON will be called.  This will occur
\ when MIDI.PARSE is polled (called).
	'c dact.note.on  mp-on-vector !
\
\ Make shapes available.
	clear: shape-holder
	shape-1 add: shape-holder
	shape-2 add: shape-holder
;

: DACT.PLAY ( -- )
	midi.clear midi.parser.on
	HMSL  ( no preposted morphs )
	midi.parser.off
;

: DACT.TERM ( -- , Clean up for others. )
	default.hierarchy: coll-p-1
	free.hierarchy: coll-p-1
	default.hierarchy: player-2
	free.hierarchy: player-2
	default.hierarchy: action-table  ( clean all actions )
	clear: action-table
	mp.reset       ( reset midi parser vectors )
;

: DEMO.ACTION  ( -- , Demonstrate use of Actions) cr
	." Once HMSL starts, activate the window then select" cr
	." 'Action Table' from the 'Screens' Menu." cr
	." Then hit the 'Perform' button to activate Perform." cr
	." Then hit MELODY to start melody." cr
	." Then play keyboard." cr
	." .....Any Key continues:" key drop cr
	dact.init  dact.play  dact.term
;

." Enter:   DEMO.ACTION  to play this piece." cr