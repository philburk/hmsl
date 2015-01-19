\ OBSOLETE - You can now adjust tempo by calling RTC.RATE!
\   RTC.RATE!  ( ticks/second -- )
\     The default is 60 ticks per second.
\
\ This is simply included now as an example of how to
\ vector TIME@.
\ ------------------------------------------------------
\ Provide adjustable tempo by replacing original TIME
\ words with custom functions.
\
\ ( Warning! I suspect this might behave strangely when )
\ ( the clock wraps at 32 bits!? )
\
\ Author: Phil Burk
\ Copyright 1986 -  Phil Burk, Larry Polansky, David Rosenboom.
\ All Rights Reserved

ANEW TASK-TEMPO

\ Variables to use for scaling time.
V: TEMPO*
V: TEMPO/

\ The hardware clock rate on the Amiga and Mac cannot be
\ altered [Oh yes they can!] so we will scale the values from the
\ fixed clock to get alternate tempos.
\ This will eat more CPU time because of the * and /
: TEMPO.TIME@  ( -- time )
	hard.time@   ( get real hardware time )
	tempo* @ *   ( Use * and / to get continuous range. )
	tempo/ @ /
;

: TEMPO.TIME! ( time -- , force value )
	tempo/ @ *   tempo* @ /
	hard.time!
;

: USE.TEMPO.TIMER   ( -- , Set vectors )
	'c tempo.time@ time@-vector !  ( change TIME@ )
	'c tempo.time! time!-vector !  ( change TIME! )
	0 time!
;

\ Just for fun we will parse MIDI notes so that the tempo
\ will increase as one plays up the keyboard.
: MP.TEMPO  ( note vel -- , called by MIDI.PARSE )
	IF ( note ON! )
		time@ swap tempo* !
		time!  ( We need to restore because tempo changes it.)
	ELSE ( Velocity=0 is a cheap note OFF! ) drop
	THEN
;

: TEMPO.INIT  ( -- , Set up for using tempo )
	40 tempo* !     ( Start at 'normal' tempo.)
	40 tempo/ !
	use.tempo.timer
	'c mp.tempo mp-on-vector !
	midi.clear    ( Clear extraneous MIDI input.)
	midi.parser.on
;

: TEMPO.TERM  ( -- , clean up )
	use.hardware.timer    ( Go back to default timer.)
	midi.parser.off
	mp.reset          ( Reset vectors. )
;

cr
." To experiment with tempo, enter:" cr
."    TEMPO.INIT" cr
."    SHAPE-1 HMSL.EDIT.PLAY   ( or other melody)" cr
cr
." Use Shape Editor to create an interesting melody." cr
." Then play an attached MIDI keyboard and listen to" cr
." the tempo change." cr
." When through enter:     TEMPO.TERM    to restore vectors." cr
cr