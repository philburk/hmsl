\ lp global utilities
\ hmsl based

\ author: lp  6/87
\ these are general utilities, not quite general enough to be 
\ included in hmsl

anew task-global_util

\ ================== some midi stuff ======================

\  start and end midi system exclusive messages
hex
: SYSEX f0 midi.xmit ;
: ENDSYSEX f7 midi.xmit ;
decimal

\ utility for midi sysex codes that need successive nibbles
hex
: LO/HI.MASK  ( byte-data -- , sends it out to midi device in two nibbles )
		( first lo, then hi )	
	dup 0000000f and midi.xmit
	000000f0 and -4 ashift midi.xmit
;
decimal

\ ================== amiga local sound stuff ================

\ following routine takes in a given frequency on the amiga,
\ and transposes it up or down an octave to within the current
\ frequency range specified by the variables below.

v: local-lo-freq 30 local-lo-freq !
v: local-hi-freq 1750 local-hi-freq !

: DA.SCALE.UP \ freq -- up to  right octave
		dup 0= IF drop 1 THEN
		BEGIN
			dup local-lo-freq @ <
		WHILE
			2* 
		REPEAT
;

: DA.SCALE.DOWN \ freq -- down to right octave
		dup 0= IF drop 1 THEN
		BEGIN
			dup local-hi-freq @ >
		WHILE
			2/ 
		REPEAT
;

: LOCAL.FREQ.SCALE \ freq -- octave-of-freq within range 
	da.scale.down
	da.scale.up
;

\ this is the routine to use -- use it wherever you would use
\ da.freq!, but make sure the variables are set properly

: SCALED.DA.FREQ! \  freq -- , vectored da.freq! to scale in range
	local.freq.scale da.freq!
;	

: LOCAL.OFF ( -- , turns off all four amiga voices )
	4 0 DO
		i da.channel!
		da.stop
	LOOP
;

: LOCAL.ON ( -- , turns on all four amiga voices )
	4 0 DO
		i da.channel!
		da.start
	LOOP
;

\ ================= general forth stuff ===============

: NEG/POS (  -- , randomly returns 1 or -1 )
	2 choose 0= 
		IF -1
		ELSE 1
		THEN
;

: *OR/ ( -- , randomly multiply or divide )
	2 choose 0= 
		IF *
		ELSE /
		THEN
;


	
