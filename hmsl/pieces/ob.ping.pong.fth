\ Play notes up and down using a new class.
\
\ Author: Phil Burk

ANEW TASK-OB.PING.PONG

:CLASS  OB.PING.PONG  <SUPER  OBJECT
	iv.long  iv-pp-min
	iv.long  iv-pp-max
	iv.long  iv-pp-last
	iv.long  iv-pp-dir
	iv.long  iv-pp-channel

:M INIT:  ( -- , set initial values )
	init: super
	40 iv=> iv-pp-min
	20 choose 40 + iv=> iv-pp-last
		1 iv=> iv-pp-dir
	60 iv=> iv-pp-max
		1 iv=> iv-pp-channel
;M

:M PUT.MIN:  ( min -- , set minimum value )
	iv=> iv-pp-min
;M

:M GET.MIN:  ( -- min )
	iv-pp-min
;M

:M PUT.MAX:  ( max -- )
	iv=> iv-pp-max
;M

:M GET.MAX:  ( -- max )
	iv-pp-max
;M


:M PUT.CHANNEL:  ( channel -- )
	iv=> iv-pp-channel
;M
:M GET.CHANNEL:  ( -- channel )
	iv-pp-channel
;M

:M PLAY:  ( -- , play next note )
\ play notes up and down in zig zag fashion
	iv-pp-dir 0>
	IF  \ going up
		iv-pp-last 1+ dup
		iv-pp-max >
		IF 2-  -1 iv=> iv-pp-dir  \ reverse direction
		THEN
	ELSE  \ going down
		iv-pp-last 1- dup
		iv-pp-min <
		IF 2+  1 iv=> iv-pp-dir  \ reverse direction
		THEN
	THEN  ( note )
	dup iv=> iv-pp-last  \ save for next time
\
	get.channel: self midi.channel!
	64    ( vel )
	5    ( on )
	midi.noteon.for
;M

;CLASS

\ Declare as many objects as we want.
OB.PING.PONG PING1
OB.PING.PONG PING2

: PLAY.OPP  ( -- )
	51 put.max: ping2
	time@ vtime!
	BEGIN
		play: ping1
		play: ping2
		10 delay
		?terminal
	UNTIL
;

