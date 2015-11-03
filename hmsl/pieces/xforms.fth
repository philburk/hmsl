\ This piece uses three tracks.
\ Track one repeats a simple 5 note theme.
\ This sounds good on a bass or tuned drum preset.
\ The second track grabs the theme and slowly transforms it
\ by adding or removing notes, transposing notes, etc.
\ This sounds nice on a flute like preset.
\ The third track periodically grabs a copy of the second
\ track and plays it. Sometimes the playing is delayed.
\ This third track is sometimes slowed down by 2.
\ Try a violin or clarinet sound for this.
\
\ MOD: PLB 9/89 Converted to 3.3 system.
\ MOD: PLB 10/4/89 Added call to SE.UPDATE.SHAPE
\ MOD: PLB 3/26/90 Use new collection, }STUFF:
\ MOD: PLB 4/9/91 Explicit names for clone.
\ MOD: PLB 4/28/96 Use General MIDI presets
\
\ Composer Phil Burk
\ Copyright 1987 Phil Burk

include? { ju:locals

ANEW TASK-XFORMS

OB.SHAPE  SH-THEME
OB.SHAPE  SH-DEVEL
OB.SHAPE  SH-DELAY

OB.COLLECTION  XF-PAR-COL
OB.PRODUCTION PRODUCTION-5

13 constant PRESET_TRACK_1  \ bass or tuned drum
74 constant PRESET_TRACK_2  \ flute

\ 41 constant PRESET_TRACK_3  \ violin
\ 43 constant PRESET_TRACK_3  \ cello
25 constant PRESET_TRACK_3  \ guitar

\ Play theme on drum or bass. ---------------------------------
VARIABLE XF-MEASURE   ( length of a measure )

rtc.rate@ 3 * 5 / ticks/beat !
ticks/beat @ 2/ constant DUR_BASIC

: XF.BUILD.THEME   ( -- theme in sh-theme )
	20 3  new: sh-theme
    DUR_BASIC      14     100 add: sh-theme
    DUR_BASIC 2*   12      80 add: sh-theme
    DUR_BASIC       6      90 add: sh-theme
    DUR_BASIC      15      80 add: sh-theme
    DUR_BASIC       9      70 add: sh-theme
( ---- )
	DUR_BASIC 6 * xf-measure !
;


: XF.INIT.THEME ( -- )
	xf.build.theme
	sh-theme ins-midi-1 build: player-1
	1 put.channel: ins-midi-1
	PRESET_TRACK_1 put.preset: ins-midi-1
\ Use the current key, the default is D minor.
	tr-current-key put.gamut: ins-midi-1
	20 put.offset: ins-midi-1
	800000 put.repeat: player-1
	sh-theme standard.dim.names
	" SH-THEME" put.name: sh-theme
;

\ ------------------------------------------------------------
\ Develop theme by adding, removing and changing notes. ------
\ Played on Pan Flute.
\ These Forth words support this motivic development.
: COPY.SHAPE { shape1 shape2 -- , copy contents of shape }
\ shapes must have same number of dimensions and be newed
	shape2 empty: []
	shape1 many: [] 0
	DO i shape1 get: []
		shape2 add: []
	LOOP
;

2 constant XF_SMALLEST_DUR

: INSERT.NOTE   { shape | elmnt  dur -- , place new note in shape }
\ Find notes to subdivide with sufficient duration.
\ Give up after 20 tries to avoid hanging. piece.
	20 0
	DO  shape many: [] 1- choose    -> elmnt
		elmnt 0 shape ed.at: []   ( get duration )
		dup -> dur xf_smallest_dur >
		IF leave THEN
	LOOP
\
\ Fit two notes in duration of existing note
\ by splitting time alloted
	elmnt 1 shape stretch: []        ( copy element )
	dur 2/ dup elmnt 0 shape ed.to: []    ( 1/2 duration )
	dur swap - elmnt 1+ 0 shape ed.to: [] ( remainder )
\
\ The new note is placed between two existing notes
\ with a random displacement from their average.
\ This "Midpoint Subdivision" method is common in computer
\ graphics where it is used to generate fractal landscapes.
	elmnt 1 shape ed.at: []     ( get note )
	elmnt 2+ 1 shape ed.at: []  ( get next note )
	+ 2/    ( average and displace )
	2 choose+/- +
	elmnt 1+ 1 shape ed.to: []
;

\ These are START and REPEAT functions for a Player
: XF.COPY.SHAPE ( player -- , make copy )
	drop sh-theme sh-devel copy.shape
	27 put.offset: ins-midi-2
\ Update SE display in case it is being shown.
	sh-devel se.update.shape
;

: XF.MODIFY ( player -- , randomly execute a function )
	drop
	many: production-3 choose
	exec: production-3
	sh-devel se.update.shape
;


\ This is a set of modifying functions that can work in a production.
: XF.INSERT.NOTE  ( - )
	sh-devel insert.note  \ ." I"
;

: XF.TRANSPOSE ( -- , random walk offset of MIDI instrument.)
	get.offset: ins-midi-2
	9 choose 4 - +   20 40 clipto
	put.offset: ins-midi-2  \ ." T"
;

: XF.REMOVE ( -- , remove note and lengthen previous note )
\ This maintains original total length.
	many: sh-devel dup 2 >
	IF 1- choose ( -- elmnt )
		dup 1+ 0 ed.at: sh-devel ( -- elmnt dur2 )
		over 0 ed.at: sh-devel + ( -- elmnt new_dur )
		over 0 ed.to: sh-devel
		1+ remove: sh-devel
	ELSE drop
	THEN \ ." R"
;

: XF.CHANGE.NOTE ( -- , change one of the notes )
	many: sh-devel choose dup
	1 ed.at: sh-devel       ( get note )
	11 choose 5 - + 1 25 clipto   ( move up or down )
	swap 1 ed.to: sh-devel
	\ ." C"
;

: STOP.ECHO  ( morph -- , stop echoing player )
	drop finish: player-1
	finish: player-3
;

: XF.INIT.DEVEL ( -- , setup objects to develop theme )
	40 3 new: sh-devel
	sh-devel ins-midi-2 build: player-2
	tr-current-key put.gamut: ins-midi-2
	2 put.channel: ins-midi-2
	PRESET_TRACK_2 put.preset: ins-midi-2
	sh-theme sh-devel copy.shape
	sh-devel standard.dim.names
	" SH-DEVEL" put.name: sh-devel
\
\ Add measure rest before playing shape.
	xf-measure @ put.start.delay: player-2
\
\ Production-3 holds functions that are randomly executed
\ by the word XF.MODIFY.
	stuff{
		'c xf.insert.note
		'c xf.insert.note
		'c xf.insert.note
		'c xf.transpose
		'c xf.remove
		'c xf.change.note
		'c xf.change.note
	}stuff: production-3
\
\ Execute XF.MODIFY every time PLAYER-2 repeats.
	'c xf.copy.shape put.start.function: player-2
	'c xf.modify put.repeat.function: player-2

\ Put Player-2 in a Collection so we can restart it.
	stuff{ player-2 }stuff: coll-p-2
	8 put.repeat: player-2       ( 1 development cycle )
	100000 put.repeat: coll-p-2       ( develop 8 times )
	'c stop.echo put.stop.function: coll-p-2
;

\ ---------------------------------------------------------
\ Third track which embellishes piece. --------------------
\ This will play a delayed and sometimes slower copy of s2
: XF.COPY.S2-S3 ( -- )
	sh-devel sh-delay copy.shape
\ Set random delay to 0-3 measures to space out responses
	xf-measure @ 4 choose * put.repeat.delay: player-3
	sh-delay se.update.shape
;

: XF.PROLONG.S3  ( -- , multiply all durations by 2 )
	many: sh-delay 0
	DO i 0 ed.at: sh-delay 2*
		i 0 ed.to: sh-delay
	LOOP
	sh-devel se.update.shape
;

: XF.EXEC.FLUFF  ( player -- , randomly copy or prolong )
	drop
	2 choose
	IF 2 choose
		IF xf.copy.s2-s3
		ELSE xf.prolong.s3
		THEN
	THEN
;

: XF.INIT.FLUFF ( -- )
\ Setup player for sh-delay
	sh-delay ins-midi-3 build: player-3
	3 put.channel: ins-midi-3
	PRESET_TRACK_3 put.preset: ins-midi-3
	tr-current-key put.gamut: ins-midi-3
	'c xf.exec.fluff put.repeat.function: player-3
	800000 put.repeat: player-3
\
\ Setup shape
	40 3 new: sh-delay
	sh-theme sh-delay copy.shape
	sh-delay standard.dim.names
	" SH-DELAY" put.name: sh-delay
;

\ ------------------------------------------------------
: XF.INIT  ( -- , tie everything together )
	xf.init.theme
	xf.init.devel
	xf.init.fluff
\
\ Top level collection.
	0 player-1   \ Play Theme
		coll-p-2   \ Development
		player-3   \ echo
	0stuff: xf-par-col
	1 put.repeat: xf-par-col
\
\ Put shapes in holder for editing
	clear: shape-holder
	sh-theme add: shape-holder
	sh-devel add: shape-holder
	sh-delay add: shape-holder
\
\ use explicit names for clone
	" sh-theme" put.name: sh-theme
	sh-theme standard.dim.names
	" sh-devel" put.name: sh-devel
	sh-devel standard.dim.names
	" sh-delay" put.name: sh-delay
	sh-delay standard.dim.names
\
\    print.hierarchy: xf-par-col
;

: XF.TERM  ( -- )
	free: production-3
	default.hierarchy: xf-par-col
	free.hierarchy: xf-par-col
	sh-theme delete: shape-holder
	sh-devel delete: shape-holder
	sh-delay delete: shape-holder
;

: XFORMS  ( -- , play piece )
	cls
	xf.init
	cr ." Seed = " rand-seed ? cr
	xf-par-col hmsl.play
	xf.term
;

: XF.RAND  ( seed -- , provide seed for repeatable performance )
	depth 1 <
	abort" Supply seed for random function."
	rand-seed !
	xforms
;
cr ." Enter:  XFORMS     or    seed XF.RAND" cr
