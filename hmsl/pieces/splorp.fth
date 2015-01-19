\ Play notes using Jobs that are controlled by global variables.
\ The global variables are set using Faders.
\ The manipulation of the faders can be recorded in
\ a shape and played back.
\
\ The notes for a given job can change by a limited set
\ of intervals relative to the previous note.
\ The set of intervals is controlled by a "complexity" fader.
\ There is no notion of tonic. Only "relative harmony".
\
\ Author: Phil Burk
\ Copyright 1990
\
\ 960623 PLB Reset default-screen

ANEW TASK-SPLORP

CREATE SPLORP-PRESETS
    1 c, 41 c, 57 c, 13 c, 66 c, 31 c,
    
\ Define allowable intervals in order of
\ increasing dissonance -->
CREATE SP-INTERVALS here
	0 c, \ tonic
	7 c, \ fifth
	5 c, \ major fourth, etc.
	4 c, 9 c, 12 c, 3 c,
	2 c, 6 c, 13 c, 11 c, 10 c, 1 c, 8 c,
	here swap - constant NUM_INTERVALS
\ This uses a Forth trick with HERE to define a constant.

\ These global variables are shared by the Jobs
variable LAST-PITCH
variable LAST-TIME

\
variable SPLORP-PITCH \ 0-127
variable SPLORP-DUR
variable SPLORP-VEL		\ 0-127
variable SPLORP-COMPLEXITY

variable START-TIME  \ used to sync jobs.
variable IF-RECORD   \ true if recording

\ Store the jobs in a list so we can access them by index.
OB.OBJLIST ALL-JOBS
OB.JOB SP-JOB0
OB.JOB SP-JOB1
OB.JOB SP-JOB2
OB.JOB SP-JOB3
OB.JOB SP-JOB4
OB.JOB SP-JOB5
6 constant NUM_JOBS

OB.OBJLIST  ALL-INSTRS
\ The default instrument is OB.MIDI.INSTRUMENT
DEFAULT.INSTRUMENT  SP-JINS0
DEFAULT.INSTRUMENT  SP-JINS1
DEFAULT.INSTRUMENT  SP-JINS2
DEFAULT.INSTRUMENT  SP-JINS3
DEFAULT.INSTRUMENT  SP-JINS4
DEFAULT.INSTRUMENT  SP-JINS5

\ Instantiate other neded objects
ob.player SP-PLAYER   \ plays recorded parameters
ob.shape  SP-SH-PLAY  \ stores parameters changes
ob.instrument  SP-PINS
ob.screen SP-SCREEN

OB.OBJLIST ALL-FADERS
OB.FADER SP-FADER0
OB.FADER SP-FADER1
OB.FADER SP-FADER2
OB.FADER SP-FADER3
OB.FADER SP-FADER4
OB.FADER SP-FADER5

OB.RADIO.GRID   SP-RADIO  \ for Record/Stop/Play

: SP.STOP ( -- , stop record or play )
	if-record off
	stop: sp-player
;

\ note standard stack diagram
: SP.RADIO.FUNC  ( value part -- , start of stop morph)
	nip
	CASE
\ Start recording
		0 OF stop: sp-player
			empty: sp-sh-play
			rtc.time@ start-time !
			if-record on
		ENDOF
\ stop whatever
		1 OF sp.stop
		ENDOF
\ start playback
		2 OF start: sp-player
		ENDOF
	ENDCASE
;

: BUILD.SP-RADIO ( -- , setup control )
	1 3 new: sp-radio     ( allocate room for 3 cells )
	700 300 put.wh: sp-radio
\
\ Load radio with functions and text.
	'c sp.radio.func put.down.function: sp-radio
	stuff{ " Record" " Stop" " Play" }stuff.text: sp-radio
	true 1 put.value: sp-radio  ( default is STOP )
	" Record Faders" put.title: sp-radio
;

\ -------------------------------------------------
\ This grid Starts or Stops the jobs.
OB.CHECK.GRID  SP-CHECK
: SP.START/STOP ( flag morph -- , start or stop now )
	swap
	IF rtc.time@ 0 rot execute: []
	ELSE stop: []
	THEN
;

: SP.CHECK.FUNC  ( value part -- , start or stop job)
\ get job from object list
\ value is TRUE or FALSE
	get: all-jobs sp.start/stop
;

: BUILD.SP-CHECK ( -- )
	2 3 new: sp-check   ( 2 wide by 3 high )
	400 300 put.wh: sp-check  ( width and height )
\
\ Load check with functions and text.
	'c sp.check.func put.down.function: sp-check
	" On/Off" put.title: sp-check
	stuff{ " Job0" " Job1" " Job2" " Job3"
		" Job4" " Job5"
	}stuff.text: sp-check
;
\ --------------------------------------------------
\ send MIDI controller values to several channels
: SP.SEND.MOD  ( value -- , send modulation value )
	num_jobs 0 DO
		i 1+ midi.channel!
		1 over midi.control
	LOOP drop
;
: SP.SEND.PORTAMENTO  ( value -- )
	num_jobs 0 DO
		i 1+ midi.channel!
		5 over midi.control
		$ 41 over IF 127 ELSE 0 THEN midi.control
	LOOP drop
;

\ Perform based on index
: SP.DO.VALUE  ( value index -- , do indexed action )
	CASE
		0 OF splorp-pitch ! ENDOF
		1 OF splorp-dur !  ENDOF
		2 OF splorp-vel !  ENDOF
		3 OF splorp-complexity ! ENDOF
		4 OF sp.send.mod ENDOF
		5 OF sp.send.portamento ENDOF
		." SP.DO.VALUE - Invalid index!" drop
	ENDCASE
;
\ Record parameter and index for later calls to SP.DO.VALUE
\ The shape will contain:
\     time    value  index
: SP.RECORD.VALUE  ( value index -- )
\ add to shape with current time if recording
	if-record @
	IF	\ any room left in shape
		max.elements: sp-sh-play  many: sp-sh-play 1+ >
		IF
			rtc.time@ start-time @ - -rot add: sp-sh-play
		ELSE \ stop recording and turn off control
			sp.stop true 1 put.value: sp-radio
			2drop
		THEN
	ELSE 2drop
	THEN
;

: SP.SET.FADER  ( value index -- )
	2dup sp.do.value
	at: all-faders
	0 swap put.value: []
;

: SP.SHOW.VALUE  ( value index -- , make faders move)
	at: all-faders
	0 swap put.value: []
;


: SP.FADER.FUNC ( value part -- , standard stack diagram )
	drop dup current.object get.data: [] dup>r
	sp.do.value
	r> sp.record.value
;

: BUILD.SP-FADER { $text maxv indx fader -- , build slider }
	180 2000 fader put.wh: []
	$text fader put.title: []
	indx fader put.data: []
\
	0 0 fader put.min: []
	maxv 0 fader put.max: []
	maxv 8 / 1 max 0 fader put.value: []
	1 fader put.increment: []
\
\ slider specific methods
		140 fader put.knob.size: []
\
	'c sp.fader.func fader put.move.function: []
	'c sp.fader.func fader put.up.function: []
;

: BUILD.SP-FADERS  ( -- )
	stuff{ sp-fader0 sp-fader1 sp-fader2
		sp-fader3 sp-fader4 sp-fader5
	}stuff: all-faders
	" Pitch" 50 0  sp-fader0  build.sp-fader
	" Duration"    5 1  sp-fader1  build.sp-fader
	" Velocity"  127 2  sp-fader2  build.sp-fader
	" Complexity" num_intervals 1- 3  sp-fader3  build.sp-fader
	" Modulation"  127 4  sp-fader4  build.sp-fader
\ don't use MOVE function, just UP
	0 put.move.function: sp-fader4  \ too much to transmit
	" Portamento" 127 5  sp-fader5  build.sp-fader
	0 put.move.function: sp-fader5  \ too much to transmit
;

\ --------------------------------------------------
\ build screen out of controls
400 constant FADER_DX
220 constant FADER_DY
[NEED] XY+
: XY+ ( x y a b -- x+a y+b )
	rot + >r
	+ r>
;
[THEN]

: SP-SCREEN.INIT  ( -- )
\ Do all x,y placement here for easier layout.
	build.sp-check
	build.sp-radio
	build.sp-faders
\
\ Put controls in screen.
	10 3 new: sp-screen
	sp-check            200 1000  add: sp-screen
	sp-radio            200 2500  add: sp-screen
	1200 300
	2dup sp-fader0  -rot  add: sp-screen fader_dx fader_dy xy+
	2dup sp-fader1  -rot  add: sp-screen fader_dx fader_dy xy+
	2dup sp-fader2  -rot  add: sp-screen fader_dx fader_dy xy+
	2dup sp-fader3  -rot  add: sp-screen fader_dx fader_dy xy+
	2dup sp-fader4  -rot  add: sp-screen fader_dx fader_dy xy+
	2dup sp-fader5  -rot  add: sp-screen 2drop
\
\ Specify name for pull down radio.
	" Splorp" put.title: sp-screen
\
\ Make Splorp come up first.
	sp-screen default-screen !
;

: SP-SCREEN.TERM   ( -- , free allocated memory )
	freeall: sp-screen
	free: sp-screen
	se-screen default-screen !
;

\ Called when job is tasked.
: SP.JOB.FUNC  { job -- , play note based on parameters }
\    job get.instrument: [] last.note.off: []
\ Determine duration, multiple of common ticks/beat
	ticks/beat @ splorp-dur @
	2 choose -
	3 - shift 1 max
\
\ ( -- dur ,  sync with other jobs )
	vtime@ last-time - over mod -
	vtime@ last-time !
	job put.duration: []
\
\ Determine Pitch
	splorp-complexity @ 1+ choose sp-intervals + c@  ( get interval )
	last-pitch @ splorp-pitch @  >
	IF negate
	THEN
	last-pitch @ + dup last-pitch !  ( +/- interval )
\
\ get other parameters for NOTE.ON.FOR:
	splorp-vel @
	job get.duration: [] 2/  ( on for 1/2 of duration )
	job get.instrument: []   ( note vel instr )
	note.on.for: []
;

\ Used by player to playback data in shape.
: SP.INTERP  ( elmnt shape instr -- )
	drop get: []  ( -- time value index )
	2dup sp.do.value
	sp.show.value drop
;

: BUILD.JOB  { instr job -- }
	'c sp.job.func instr job build: []
;

: SPLORP.INIT  ( -- , initialize everything in Splorp )
	sp-screen.init
	1024 3 new: sp-sh-play
\
\ Starting values.
	stuff{
		0 10 0
		0 12 1
		60 50 0
		200 30 0
	}stuff: sp-sh-play
	sp-sh-play sp-pins build: sp-player
\ set interpreters
	'c sp.interp put.on.function: sp-pins
	'c 3drop put.off.function: sp-pins
\ use absolute time as recorded
	use.absolute.time: sp-player
	if-record off
	1000 put.repeat: sp-player
\
\ set defaults
	20 0 sp.set.fader
	2 1 sp.set.fader
	64 2 sp.set.fader
	1 3 sp.set.fader
	0 4 sp.set.fader
	0 5 sp.set.fader
	vtime@ last-time !
	rtc.rate@ 2/ ticks/beat !
\
\ Build object lists.
	stuff{ sp-job0 sp-job1 sp-job2 sp-job3 sp-job4 sp-job5
	}stuff: all-jobs

	stuff{ sp-jins0 sp-jins1 sp-jins2 sp-jins3
		sp-jins4 sp-jins5
	}stuff: all-instrs

\ Build Jobs from lists
	num_jobs 0
	DO
	    \ set MIDI program in instrument
	    splorp-presets i + c@ i get: all-instrs put.preset: []
	    i get: all-instrs i get: all-jobs build.job
		i 1+ i get: all-instrs put.channel: []
	LOOP
;

: SPLORP.TERM  ( -- )
	sp.stop
	many: all-jobs 0
	DO i get: all-jobs stop: []
	LOOP
	sp-screen.term
	free: sp-player
	freeall: all-jobs
	free: all-jobs
	free: all-instrs
;

: SPLORP  ( -- )
	splorp.init
	hmsl
	splorp.term
;

if.forgotten splorp.term
." Enter:  SPLORP" CR
