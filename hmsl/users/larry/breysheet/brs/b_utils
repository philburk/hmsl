\ b'rey'sheet utilities
anew task-b_utils

\ this file is for the duet version of BRS
\ it contains code for both the master and the slave machine
\ To run it as a slave, type SLAVE-MODE ON, to run it as
\ a master, type SLAVE-MODE OFF

\ 1/11/90

v: slave-mode

: INIT.LOCAL.PITCH.ARRAY
	 l_F#' l_E' l_D# l_C# l_B l_A l_G# l_F# l_E 
	 9 stuff: local.pitch.array
;

: INIT.F.PITCH.ARRAY
	f_F#' f_E' f_D# f_C# f_B f_A F_G# f_F# f_E
	9 stuff: f.pitch.array
;

: INIT.FF.PITCH.ARRAY
	ff_F#' ff_E' ff_D# ff_C# ff_B ff_A ff_G# ff_F# ff_E
	9 stuff: ff.pitch.array
;

\ tune up adc to pitch arrays -- this should be done once
\ before the piece is played to tune to singer
: FILL.ADC.ARRAY
	1 midi.channel!
	9 0 DO
		f.lastoff
		I at: f.pitch.array
		i at: ff.pitch.array 120 f.noteon
		BEGIN 
			par@ . cr midi.parse.loop key 13 = 
		UNTIL
		par@ dup . cr
\ now back to old routine....
		i to: adc.array 
	LOOP
	print: adc.array
;

\ the slave's adc array has to be stuffed manually....
	
\ stuff it initially with "reasonable" values
\ these values are for larry's voice...
: INIT.ADC.ARRAY
\	120 113 109 102 96 89 84 77 71
	620 593 577 542 512 480 462 434 398
	9 stuff: adc.array
;

: INIT.PITCH
	build.pitch.arrays
	init.local.pitch.array
	init.f.pitch.array
	init.ff.pitch.array
	init.adc.array
;

\ takes input value and returns the array values
\ corresponding to it.
\ Valid found when input adc value is less than
\ halfway away from a given array index.
: SEARCH.ADC.ARRAY ( adc-value -- pitch-index )
	8 temp-adc-index !
	8 0 DO 
		i 1+ at: adc.array 
		i at: adc.array \ par@ i+1 i
		+ 2/ over  \ par@ average par@
		> 
	 	IF
			I temp-adc-index ! LEAVE
		THEN
	LOOP
	drop temp-adc-index @ 
;


\ STABLE.INDEX is only used for the master machine....

\ to make this next routine more or less stable, adjust
\ the index of the do...loop.
\ the outer routine IF...THEN checks to see if the
\ adc input value is at least big enough to be in the
\ range, and if not, it doesn't return a stable index
: STABLE.INDEX ( -- index, stable )
      par@ 0 at: adc.array > \ make sure input value at least in range
      IF
	par@ search.adc.array par@ search.adc.array
	over = \ index flag
        adc-debounce @ 0 DO  \ how many comparisons to make for stability
		par@ search.adc.array 
		2 pick 	= 
 		and \ index flag
	LOOP
	IF
		dup last-adc-value !
	ELSE	drop last-adc-value @ 
	THEN
      ELSE last-adc-value @
      THEN
\ MASTER CODE
\ the following is for the master machine, sends out the stable index
\ over MIDI-CHANNEL 5
	dup
	midi-channel @ (   -- index index last-channel )
	5 midi-channel !
	swap 60 + 100 midi.noteon
	midi-channel !
;

\ There was a bug in the old version of MP.CHANNEL@
exists? MP.STATE not
.IF
: MP.CHANNEL@  ( -- channel )
    mp-last-cvm @ 15 and 1+
;
.THEN

: PARSE.ADC ( p v -- , )
	mp.channel@
	5 = IF
		drop 60 - 0 8 clipto last-adc-value !  
	ELSE
		2drop 
	THEN
;
\ the following word is used for the SLAVE MACHINE, in place of
\ STABLE.INDEX
: SLAVE.INDEX
	last-adc-value @ 
;

\ 'c parse.adc mp-on-vector !

\ this is basic routine for putting adc values into a variables
: GET.PITCH ( -- , stuffs variables for current pitches )
\ the following code is for the slave machine. it replaces the word
\ stable index by simply grabbing the index from the master machine
	slave-mode @ IF
		slave.index    ( slave machine code )
	ELSE
		stable.index    ( master machine code )
	THEN
	dup
	at: local.pitch.array curr-lpitch !
	dup at: f.pitch.array curr-fpitch !
	at: ff.pitch.array curr-ffpitch !
;

\ increments how far in piece
: INC.VAR-# ( -- )
	var-# @ 1+ 16 min var-# !
	." var-# : " var-# ? cr
;

: DEC.VAR-#  ( -- )
	var-# @ 1- 0 max var-# !
	." var-# : " var-# ? cr
;

