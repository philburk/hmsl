\ amiga waveshape changing for brs

anew task-b_wst

\ four waveforms: each "sourced" from a sine

ob.waveform source-sine
ob.waveform wst-0 
ob.waveform wst-1
ob.waveform wst-2
ob.waveform wst-3

: build.wst
	16 new: source-sine
	16 new: wst-0
	16 new: wst-1
	16 new: wst-2
	16 new: wst-3
;

: FILL.SOURCE-SINE
 	0 50 90 119  127 119  90 50  
 	0 -50 -90 -119 -127 -119 -90 -50
	16 0 DO add: source-sine LOOP
;


: INIT.WST
	build.wst
	fill.source-sine
	16 0 DO
		i at: source-sine
		dup dup dup
		add: wst-0 
		add: wst-1 
		add: wst-2 
		add: wst-3 
	LOOP
	0 wst-0 wst-1 wst-2 wst-3 0stuff: shape-holder
;


: FREE.WST
	free: source-sine
	free: wst-0
	free: wst-1
	free: wst-2
	free: wst-3
	clear: shape-holder
;

\ response

: WST.WHEN? (  -- flag )
	prev-wst @ \ -- last-time
	17 var-# @ choose -  \ -- last-time increment
	+ \  -- new-time
	doitnow?
		IF time@ prev-wst ! true
		ELSE false
		THEN 
;

v: temp-point 
: WST.DEFORM  ( -- ,point by point deformation )
	\ can do more points, the higher the variation
	var-# @ 1+ 1 wchoose 0 \ can go from 0-1 -> 0-17
	DO
		16 choose dup temp-point ! \ pick a point to deform
		at: source-sine  \  -- sine-value
		\ deformation by var-#
		var-# @ 1+ choose neg/pos * \ -- sine-value deform
		+  \ sine-value+deformation
		temp-point @ temp-wst @ to: []
	LOOP
;

: WST.RAND.PORTION  ( -- ,randomize a portion of the waveform )
	-127 128 \ min max
	5 0 wchoose \ start
	var-# @ choose \ end
	0 \ dimension
	temp-wst @ randomize: []
;

: WST.POINT ( -- ,  push up a point )
	16 choose dup at: source-sine \ -- point value
	var-# @ 1+ 4 *  choose 0 \ how many times point pushed	
		DO i + 2dup swap temp-wst @ to: [] 
		LOOP
	drop drop
;

: WST.RAND.ALL ( -- ,  randomize the whole thing ! )
	-128 128 0 15 0 temp-wst @ randomize: []     ( c/16/15/ PLB )
;
 
: WST.REVERSE ( -- ,  reverse a region )
	0 var-# @ choose 0 temp-wst @ reverse: []
;

: WST.INVERT ( -- , invert a region )
	256 var-# @ / 128 - \ point to invert around
	0 var-# @ choose 0 \ value start end dim --
	temp-wst @ invert: []
;

: WST.INVERT.ALL ( -- , invert the whole waveform )
	256 var-# @ / 128 - \ point to invert around
	0 15 0 temp-wst @ invert: []   ( c/16/15/ PLB )
;

: WST.TRANSPOSE ( -- ,  transpose a region )
	var-# @ choose 2*
	neg/pos *
	0 var-# @ choose 0 \ value start end dim --
	temp-wst @ transpose: []
;	

: WST.TRANSPOSE.ALL  ( -- ,  transpose all )
	var-# @ choose 2*
	neg/pos *
	0 15 0 temp-wst @ transpose: []   ( c/16/15/ PLB )
;

\ wstx picks a waveshape transformation based on how far in the piece
\ the transforms are "ordered" according to a rough idea of their
\ sonic complexity
:  WSTX ( wst-starting-address -- )
	temp-wst ! 
	\ must be timeout, and not in lowest variation
	wst.when?  \ time to vary a waveform
	IF var-# @ 2/ choose \ for last few variations
			\ point by point is used
		CASE 
		0 of wst.point			endof
	    	1 of wst.deform  		endof
	    	2 of wst.reverse 		endof
	    	3 of wst.invert  		endof
	    	4 of wst.invert.all		endof
	    	5 of wst.transpose 		endof
	    	6 of wst.transpose.all		endof
	    	7 of wst.rand.portion  		endof
	    	8 of wst.rand.all 		endof
		noop
		ENDCASE
		temp-wst @ se.update.shape
	THEN
;	

\ responses
: CWS0 wst-0 wstx ;
: CWS1 wst-1 wstx ;
: CWS2 wst-2 wstx ;
: CWS3 wst-3 wstx ;

: CWSS drop cws0 cws1 cws2 cws3 ;

\ at end of piece, if sine waves not all their, these routines can
\ "force" sine-waves into the waveshapes
: pick.wst
	4 choose
	CASE
		0 of wst-0 endof
		1 of wst-1 endof
		2 of wst-2 endof
		3 of wst-3 endof
		noop
	ENDCASE
;

\ this is an init and term field for the action used to make
\ the end of the piece assured sine waves...
: FORCE.SINE
	pick.wst temp-wst ! \ pick one of the waveforms...
	\ " sine it out" random number of points...
	16 choose 0 DO
		16 choose dup at: source-sine \ -- index value
  	      swap \ -- value index
		temp-wst @ to: []
	LOOP
;
