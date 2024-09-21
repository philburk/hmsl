\ pitch changing for b'rey'sheet
\ author: polansky

anew task-b_pitch

\ utility used by various routines to see if voice has changed pitch
: VOICE.CHANGED? ( -- flag, true if pitch has changed )
	get.pitch
	curr-fpitch @ prev-fpitch @ = not
;

\ routine that returns a flag based on a relation of where
\ we are in piece, to if the voice has changed. that is,
\ the higher the variation, the less likely it is to use
\ the fact that the voice has changed to return a true value...
: PROB.VOICE.CHANGED? ( -- flag )
	17 choose var-# @ > 
		IF voice.changed?
		ELSE true
		THEN
;

\ basic decision making mechanism for when to change pitch according
\ to a " faster-if-higher-variation" scheme
:  PITCH.WHEN? ( -- flag )
	prev-lpitch @ 
	17 var-# @ - \ --  prev-time 1->12
	8 5 wchoose 5 3 wchoose
	*/ \ -- prev-time scaled-prob
	+ \ - newtime
	doitnow? 
	IF
		time@ prev-lpitch ! true
	ELSE
		false
	THEN
;

\ used in one of the chorales
: FROM.l.ARRAY 9 choose at: local.pitch.array ;

\ pick a new pitch in a harmonic space defined by the number
\ of the current variation
: PICK.NEW.PITCH ( -- )
	4 choose 0 DO
	   curr-lpitch @ var-# @ 2 + 1 wchoose * \ multiply to get numerator
	   var-# @ 2 + 1 wchoose / \ divide by denominator	
	   4 choose da.channel! scaled.da.freq!
	LOOP
;

\ =======================================

\ chorale routines for b'rey'sheet


\ all four voices follow exactly
: 0.CHORALE  ( --  , last variation  )
	4 0 DO 
		i da.channel!
		curr-lpitch @ scaled.da.freq!
	LOOP
;

: 1.CHORALE ( -- , second to last, random pitches from array )
	4 0 DO
		i da.channel! 
		from.l.array
		scaled.da.freq!
	LOOP
;

: 2.CHORALE ( -- , third to last: random pitches from array in octaves )
		( and perfect fifths at octaves )
	4 0 DO
		i da.channel!
		from.l.array
		4 1 wchoose 2* *or/ 
		scaled.da.freq!
	LOOP
;

: 3.CHORALE ( --  , fourth to last, 3 and 2 harmonies of current pitch )
	4 0 DO
		i da.channel!
		curr-lpitch @ \ -- pitch 3|2 
		4 2 wchoose 
		4 1 wchoose 2* \  -- pitch 3|2 6|4|2
		* \ -- pitch 18|12|6|12|8|4
		*or/ \ --  new-pitch
		scaled.da.freq!
	LOOP
;

: 4.CHORALE ( --  , fifth from last, 3,2,5,7 harmonies )
	4 0 DO
		i da.channel!
		curr-lpitch @
		8 1 wchoose 
		3 1 wchoose * \ -- curr-pitch rand
		*or/
		scaled.da.freq!
	LOOP
;

: DEBOUNCE.CHORALE
	get.pitch curr-lpitch @ last-lpitch @ = not 
;

\ main chorale routine for variations 0-4	
: CHORALE ( -- )
	debounce.chorale
	IF
		curr-lpitch @ last-lpitch !
		var-# @ \ must be 0 - 4 
		CASE 0 of 0.chorale endof
		     1 of 1.chorale endof
		     2 of 2.chorale endof
		     3 of 3.chorale endof
	             4 of 4.chorale endof
		    ." error!!!! -- shouldn't be in chorale ! " cr
	        ENDCASE
	THEN
;

\ ============== main pitch changing routine =====================

\ respsonse for pitch changing action
: PITCH.CHANGE ( stimulus -- )
	drop
	var-# @ 5 < ( do chorales for variations 0-4 )
	   IF chorale 
	   ELSE prob.voice.changed?
		IF  pitch.when? 
	            IF pick.new.pitch
		    THEN
		THEN
           THEN
;

\ fbo1 follows voice exactly throughout, and updates pitches
: FB.FOLLOW  ( stimulus -- , tracks fb to voice )
	( fb uses channel 1 !)
	1 midi.channel!
	drop \ this is response
	voice.changed?
	IF
		curr-fpitch @ prev-fpitch !
		1 midi.channel!
		f.lastoff
		curr-fpitch @ curr-ffpitch @ 
		127 f.noteon
	THEN
;
