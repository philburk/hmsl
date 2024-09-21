\ roland dep-5 midi implementation
\ hmsl based -- system exclusive

\ author: lp  5/87
\ this file must also use global_util file, for definition of
\ words like sysex and endsysex

\ these utilities should be "tuned" to the dep-5: that is
\ the correspondence between byte values and actual dep
\ parameter values is not apparent. some of these
\ correspondences have been made hueristically (like for algorithm)
\ and the author is currently waiting for more information from
\ roland to tune the file further.

anew task-dep-5_util

\ =================================================

\ utilities
hex
: D.ID 41 midi.xmit ;
: D.APR 35 midi.xmit ; ( all parameters )
: D.CHANNEL midi-channel @ 1- midi.xmit ;
: D.FORMAT 52 midi.xmit ;
: D.LEVEL 20 midi.xmit ;
: D.GROUP 01 midi.xmit ;
decimal

\ ==================================================
\ variables for dep-5 parameters

v: d-rev-type 
v: d-output  
v: d-q  
v: d-mid-freq 
v: d-lo-boost
v: d-mid-boost
v: d-hi-boost
v: d-feedback ( feedback of chorous )
v: d-rate ( of chorous )
v: d-depth ( of chorous )
v: d-algorithm
v: d-predelay ( or delay time )
v: d-rev-time ( or delay feedback -- number of delays? )
v: d-hf-damp ( or gate time )

\ delay time, feedback of delay, and gate time are
\ "aliased" as they are in the parameter knobs of the dep-5
\ (see below). 


\ reverb types
\ specials and plates
0 k: s1  1 k: s2   2 k: p1  3 k: p2
\ halls
4 k: h14 5 k: h20  6 k: h27  7 k: h36
8 k: h48 9 k: h61  10 k: h76 
\ rooms
11 k: r0.3 12 k: r1.4 13 k: r3.1 14 k: r8.2 15 k: r14
16 k: r20 17 k: r27 18 k: r36 19 k: r48
20 k: r61 21 k: r76

\ ==========================================================

\ words for storing variables

: D.CLIPTO ( parameter-value -- 0-127 )
	0 255  clipto 
;

\ the dep-5 uses some kind of division of 8 bits for
\ deciding on the algorithm. these numbers were determined
\ hueristically, there is probably some bit pattern involved...

ob.array algorithm-array

: BUILD.ALGORITHM-ARRAY
\ not sure of exact numbers between 4-6... but these seem to work
	11 new: algorithm-array
	254 227 200 172 143 115 81 59 31 3 0 
	11 0 DO
		i to: algorithm-array
	LOOP
;

\ the following words "condition" values stored in variables. it is
\ better to use these routines than to directly store values in
\ these variables

\ all the routines below have the stack diagram: ( value -- )
\ To have something happen, you must store a value via one of these
\ routines, and then call DEP-5.SEND

: D-REV-TYPE! 0 22  clipto d-rev-type ! ;
: D-OUTPUT! 0 99 clipto  d-output ! ;
: D-Q! d.clipto d-q ! ;
: D-MID-FREQ! d.clipto d-mid-freq ! ;
: D-LO-BOOST! d.clipto d-lo-boost ! ;
: D-MID-BOOST! d.clipto d-mid-boost ! ;
: D-HI-BOOST! d.clipto d-hi-boost ! ;
: D-FEEDBACK! d.clipto  d-feedback ! ( values ? ) ;
: D-RATE! d.clipto d-rate !  ( values ? ) ;
: D-DEPTH!  d.clipto d-depth !  ( values ? ) ;
\ wants numbers between 0 and 11
: D-ALGORITHM! 1 11 clipto 1-
	at: algorithm-array 
	 d-algorithm ! ;
: D-PREDELAY! d.clipto d-predelay ! ;
: D-DELAY-TIME! d-predelay! ;
: D-REV-TIME! d.clipto d-rev-time ! ;
: D-#-DELAYS! d-rev-time! ;
: D-FEEDBACK-DELAY! d-rev-time! ;
: D-HF-DAMP! d.clipto d-hf-damp ! ;
: D-GATE! d-hf-damp! ;

: DEP-5.SEND ( --- )
	sysex d.id d.apr d.channel
	d.format d.level d.group
	d-rev-type @ midi.xmit ( reverb type )
	d-output @ midi.xmit ( output level )
	d-q @ midi.xmit ( parametric q )
	d-mid-freq @ midi.xmit ( parametric frequency )
	d-lo-boost @ lo/hi.mask
	d-mid-boost @ lo/hi.mask
	d-hi-boost @ lo/hi.mask
	d-feedback @ lo/hi.mask
	d-rate @ lo/hi.mask
	d-depth @ lo/hi.mask
	d-algorithm @ lo/hi.mask
	d-predelay @ lo/hi.mask
	d-rev-time @ lo/hi.mask
	d-hf-damp @ lo/hi.mask
endsysex midi.flush
;


: dep-5.init
build.algorithm-array
;		


