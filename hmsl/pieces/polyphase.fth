\ Experiment with phasing of polyphonic shapes.
\ This piece uses the stock morphs.
\
\ Play piece by entering:
\    POLYPHASE
\    Select SHAPE EDITOR from main menu.
\    Change the length of shapes 1,2,3 and 4 to start phasing.
\
\ If you want to save the shape data for later playback,
\
\    POLY.INIT   ( to setup objects )
\    POLY.PLAY   ( to run four players )
\
\ After editing the shapes, you can save them by entering:
\    POLY.SAVETO <filename>
\    ( eg.  POLY.SAVETO RAM:POLY_DATA    on Amiga )
\
\ You can then enter: POLY.TERM
\
\ The next time you run you can follow the POLY.INIT command
\ above with INCLUDE <filename> . This will reload your shapes.
\ Look at the file you have created. It can be edited.
\
\ Composer: Phil Burk
\ Copyright 1987
\
\ MOD: PLB 1/14/87 Removed OPER.POST.EXECs.

INCLUDE? LOGTO JU:LOGTO

decimal
ANEW TASK-POLYPHASE

V: POLY-#REP
16 POLY-#REP !

: POLY.OBJ.INIT  ( shape instrument player -- , prepare these objects )
	tuck put.instrument: []
	1 over new: []  ( allocate space in player )
	poly-#rep @ over put.repeat: []     ( repeat 16 times )
	tuck add: []    ( add shape )
	add: coll-p-1   ( add to parallel collection )
;

: POLY.SH.INIT ( shape -- , fill with song data )
	32 3 2 pick83 new: []
\ Duration - pitch - velocity
	12 18 100 3 pick83 add: []
	12 28  80 3 pick83 add: []
		6 22 100 3 pick83 add: []
	12 32 100 3 pick83 add: []
	12 30 100 3 pick83 add: []
		6 26 100 3 pick83 add: []
	drop
;

: POLY.FILL  ( -- , fill all shapes with same data )
	shape-1 poly.sh.init
	shape-2 poly.sh.init
	shape-3 poly.sh.init
	shape-4 poly.sh.init
;

: POLY.INIT ( -- , Initialize piece. )
	poly.fill
\
	8 new: coll-p-1    ( make room for up to 8 players )
	shape-1 ins-midi-1 player-1 poly.obj.init
	shape-2 ins-midi-2 player-2 poly.obj.init
	shape-3 ins-midi-3 player-3 poly.obj.init
	shape-4 ins-midi-4 player-4 poly.obj.init
\
\ Play for a long time.
	200 put.repeat: coll-p-1
\
\ Make shapes available to shape editor.
	clear: shape-holder
	shape-1 add: shape-holder
	shape-2 add: shape-holder
	shape-3 add: shape-holder
	shape-4 add: shape-holder
;

\ This word will save the shapes to a file.
\ Use like:    POLY.SAVETO POLY-DUMP
: POLY.SAVETO  ( <filename> -- , save to a file )
	logto   ( reads filename from input line )
	dump.source: shape-1
	dump.source: shape-2
	dump.source: shape-3
	dump.source: shape-4
	logend
;

: POLY.STAGGER ( dtime -- , stagger players by dtime )
	0 dup put.start.delay: player-1
	over + dup put.start.delay: player-2
	over + dup put.start.delay: player-3
	over + dup put.start.delay: player-4
	2drop
;

: POLY.PLAY   ( -- , execute piece )
	coll-p-1 hmsl.play
;

: POLY.TERM ( -- , free memory )
	default.hierarchy: coll-p-1
	free.hierarchy: coll-p-1
	clear: shape-holder
;

: POLYPHASE ( -- , Play complete piece. )
	poly.init
	poly.play
	poly.term
;

: MIDI.PC! ( preset channel -- , for easy setup of voices)
	midi.channel!
	midi.preset
;

\ Set Instrument Presets for an FB-01 in bank 3.
: POLY.FB-01 ( -- )
	7 1 midi.pc!
15 2 midi.pc!
18 3 midi.pc!
28 4 midi.pc!
;

cr
." Enter POLYPHASE to start piece." cr
." Edit shapes to hear phasing." cr
." (Requires 4 MIDI channels.)" cr
." 6 POLY.STAGGER will stagger start times." cr
cr