\ Demonstration piece for HMSL running MIDI
\ Jam in 7/4 with 4 channels
\
\ Channel 1 is a bass line that moves in minor or major semitones,
\ It has notes at the first and second beat in the measure.
\
\ Channel 2 is a basic drum beat on beat 1 3 and 5.
\
\ Channel 3 and 4 are jobs that jam in a random walk
\ that avoids getting too close to the bass.  The tempo of these
\ instruments is recalculated on every measure.
\
\ Author/Composer: Phil Burk
\ Copyright 10/9/86

ANEW TASK-JOB_JAM

rtc.rate@ 8 / value dur_basic

\ Number of measures
50 constant JAM_REP#
V: JJ-LAST-PEDAL  ( Used for harmonization between channels )

\ Use Stock Morphs
\ SHAPE-1 PLAYER-1 INS-MIDI-1  ( Introduction )
\ SHAPE-2 PLAYER-2 INS-MIDI-2  ( Pulse )
\ SHAPE-3 PLAYER-3 INS-MIDI-3  ( Pedal )
\ JOB-1 INS-MIDI-4    ( Two Jammers )
\ JOB-2 INS-MIDI-5

\ Change these to match your setup !!!!!!!!!!!!
: SITE.RANGE 1 8 ;
\ Constants for appropriate preset.
\ These work well for an FB-01 in Bank 3
0 [IF]
32 constant PRESET_DRUM
10 constant PRESET_BASS
20 constant PRESET_LEAD1
18 constant PRESET_LEAD2
[ELSE]
\ General MIDI
117 constant PRESET_DRUM
35 constant PRESET_BASS
42 constant PRESET_LEAD1
57 constant PRESET_LEAD2
[THEN]

V: JAM-OFFSET
25 jam-offset !

: SETUP.INSTRUMENT ( preset instrument -- , set instrument for JAM )
	dup >r put.preset: []
	site.range r@ put.channel.range: []
	tr-current-key r@ put.gamut: []
	jam-offset @ r> put.offset: []
;

\ ---------------------------------------------------------
: INTRO.INIT  ( -- , Set up Introduction )
\ Allocate and stuff
	15  3 new: shape-1
	320  4 100 add: shape-1
	320  7  80 add: shape-1
	480 11  80 add: shape-1

	160  7 100 add: shape-1
	160  7  80 add: shape-1
	320 11  80 add: shape-1
	480  9  80 add: shape-1

	320  7 100 add: shape-1
	160  2  80 add: shape-1
	160  7  80 add: shape-1
	320  9  80 add: shape-1
	160 11  80 add: shape-1

	320  2 100 add: shape-1
	320  2  80 add: shape-1
	480  7  80 add: shape-1

\ Build Introduction Player
	0 shape-1 0stuff: player-1
	2 put.repeat: player-1
	ins-midi-1 put.instrument: player-1
	preset_drum ins-midi-1 setup.instrument
;

\ ---------------------------------------------------------
\ Use stock JOBs for jamming

V: JAM-LEAD-JOB   ( Holds JOB currently doing a lead. )
V: JAM-FOLLOW-JOB ( This job follows. )
V: JAM-LEAD-SHIFT

: CHOOSE.TEMPOS ( -- , calculate new durations )
	2   2 choose 1+    dup >r
	ashift  ( 4 or 8 )
	dur_basic *
	jam-lead-job @ put.duration: []
	2   5 r> -  ashift ( 16 or 32 )
	dur_basic *
	jam-follow-job @ put.duration: []
;

: JAM.NOTE ( job -- , select a new note and play it)
	4 choose 0>   ( random rests )
	IF
\ If a note has been played, turn it off.
		dup get.data: [] dup 0<  ( -- job note flag )
		IF drop
		ELSE over get.instrument: [] ( -- job note instr )
			0 swap note.off: []
		THEN
		( -- job )
		BEGIN
\ Select new note based on previously stored value.
			dup get.data: [] 5 choose 2 -  +
			dup 0 20 inrange?
			IF ( -- job note , Avoid bass dissonance )
				( by rejecting any notes within 2 of bass. )
					dup 7 and jj-last-pedal @ - abs 2 <
				ELSE  ( Force note back to center if drifts )
					drop 10 false
				THEN  ( -- job note flag )
			WHILE
				drop
			REPEAT  ( -- job note )
\ Save and play that note.
			swap 2dup put.data: [] ( save it )
			40 choose 60 +  ( random velocity/loudness )
			swap get.instrument: [] note.on: []
		ELSE drop
		THEN
;

: SELECT.LEAD  ( -- , pick lead instrument )
	2 choose
	IF   job-1 job-2
	ELSE job-2 job-1
	THEN
	jam-lead-job !   jam-follow-job !
;

: JOBS.INIT   ( -- , Setup jobs for jamming. )
	0 'c jam.note 0stuff: job-1
	ins-midi-4 put.instrument: job-1
	preset_lead1 ins-midi-4 setup.instrument
	-1 put.data: job-1
\
	0 'c jam.note 0stuff: job-2
	ins-midi-5 put.instrument: job-2
	preset_lead2 ins-midi-5 setup.instrument
	-1 put.data: job-2
\
	select.lead choose.tempos
;

\ -------------------------------------------------
\ Custom note INTERPRETER for BASS pedal.
: PEDAL.ON ( elmnt# shape instr -- , called by instrument )
	>r
	interp.extract.pv swap
	IF  ( start of measure )
		select.lead choose.tempos
		8 choose 7 +
	ELSE ( second note )
		jj-last-pedal @
		2 choose 2* 1- +  ( up or down one note in key )
		7 14 clipto
	THEN
	dup jj-last-pedal !
	swap r> note.on: []
;

: PEDAL.OFF ( elmnt# shape instr -- , called by instrument )
	nip nip last.note.off: []
;

: PEDAL.INIT  ( -- )
\ Set up shapes for JAM
	2 3 new: shape-3

\ Stuff with rhythms.
\ The data in this shape is unusual.
\ A 1 in dimension 1 indicates the start of a measure.
    80 1 100 add: shape-3
	480 0  80 add: shape-3

\ Link to player
	0 shape-3 0stuff: player-3
	jam_rep# put.repeat: player-3
	ins-midi-3 put.instrument: player-3
	preset_bass ins-midi-3 setup.instrument
\
\ Install custom note generator.
	'c pedal.on  put.on.function: ins-midi-3
	'c pedal.off put.off.function: ins-midi-3
;

\ -------------------------------------------------

: PULSE.INIT ( -- )
\ Allocate and stuff
	3 3 new: shape-2
		8  7 120 add: shape-2
		8  7  80 add: shape-2
	40 10 100 add: shape-2
\
\ Link to player
	0 shape-2 0stuff: player-2
	jam_rep# put.repeat: player-2
	ins-midi-2 put.instrument: player-2
	preset_drum ins-midi-2 setup.instrument
;

: JAM.INIT ( -- )
	intro.init
	pedal.init
	pulse.init
	jobs.init
\
\ Setup extended jam.
	0 player-3
		player-2
		job-1
		job-2
	0stuff: coll-p-1
\
\ Put introduction in master collection.
	0 player-1
		coll-p-1
	0stuff: coll-s-1
	1 jam-lead-shift !
	print.hierarchy: coll-s-1 cr
;

: JAM.TERM ( -- )
	default.hierarchy: coll-s-1
	free.hierarchy: coll-s-1
	midi.alloff  ( Oops! will fix.)
;

: JAM  ( -- )
\ Initialize
	jam.init
	coll-s-1 hmsl.play
	jam.term
;

cr
." Enter:   JAM   to hear piece!" cr
cr