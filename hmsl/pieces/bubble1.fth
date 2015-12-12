\ Generate note using hailstone sequence.
\ Play in Gamut using MIDI input.
\
\ Author: Phil Burk
ANEW TASK-BUBBLE

VARIABLE LAST-NOTE
VARIABLE LAST-VELOCITY

: NEW.NUMBER  ( n -- n' )
	dup 1 and
	IF   ( odd )
		3 * 5 -
	ELSE  ( even )
		2/ 1+
	THEN
;

: JOB.FUNC  ( job -- )
	get.instrument: []    ( get job instrument )
	dup last.note.off: []
	last-note @ new.number dup last-note !
\    63 and
	31 and
	last-velocity @ rot note.on: []
;

: NOTE.RESPONSE  ( note velocity -- , for MIDI parser )
	last-velocity !
	get.offset: ins-midi-1 -
	last-note !
;

HEX
: BEND.RESPONSE  ( lo hi -- )
	7lo7hi->14
	2000 - 8 * 2000 /
	A swap - put.duration: job-1
;
DECIMAL

: BUBBLE.TERM  ( -- )
	free.hierarchy: job-1
	free: job-1
	default.hierarchy: job-1
;

: BUBBLE.INIT
	23 last-note !
	100 last-velocity !
	0 'c job.func 0stuff: job-1
	rtc.rate@ 6 / put.duration: job-1
	ins-midi-1 put.instrument: job-1
	20 put.offset: ins-midi-1
	tr-current-key put.gamut: ins-midi-1
	mp.reset
	'c note.response  mp-on-vector !
	'c bend.response  mp-bend-vector !
;

: BUBBLE
	bubble.init
	midi.parser.on
	job-1 hmsl.play
	bubble.term
;

: TEST.ALGO  ( N -- , test note generator , loop until key hit )
	BEGIN new.number dup . cr?
		?terminal
	UNTIL drop
;

cr ." Enter: BUBBLE" cr
