\ Play notes up and down using a variable
\
\ Author: Phil Burk

ANEW TASK-VAR.PING.PONG

40 value  pp_min
60 value  pp_max
45 value  pp_last
	1 value  pp_dir
	1 value  pp_channel


: PING.PONG  ( -- , play next note )
\ play notes up and down in zig zag fashion
	pp_dir 0>
	IF  \ going up
		pp_last 1+ dup
		pp_max >
		IF 2-  -1 -> pp_dir  \ reverse direction
		THEN
	ELSE  \ going down
		pp_last 1- dup
		pp_min <
		IF 2+  1 -> pp_dir  \ reverse direction
		THEN
	THEN  ( note )
	dup -> pp_last  \ save for next time
\
	pp_channel midi.channel!
	64    ( vel )
	5    ( on )
	midi.noteon.for
;


: PLAY.VPP  ( -- , play notes up and down )
	time@ vtime!
	BEGIN
		ping.pong
		10 delay
		?terminal
	UNTIL
;

." Enter:   PLAY.VPP" cr
