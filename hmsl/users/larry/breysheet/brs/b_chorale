\ chorale routine for b'rey'sheet

: 0.chorale  \ , last variation 
	4 0 DO 
		i da.channel!
		curr-pitch @ b.da.freq!
	LOOP
;

: 1.chorale \ , second to last, random pitches from array
	4 0 DO
		i da.channel! 
		9 choose at: local.pitch.array
		b.da.freq!
	LOOP
;

: 2.chorale \ , third to last: random pitches from array in octaves
	4 0 DO
		i da.channel!
		9 choose at: local.pitch.array
		4 1 wchoose 2* *or/ 
		b.da.freq!
	LOOP
;

: 3.chorale \ , fourth to last, 3 and 2 harmonies of pitch array
	4 0 DO
		i da.channel!
		curr-pitch @
		4 2 wchoose 4 1 wchoose 2* * *or/
		b.da.freq!
	LOOP
;

: 4.chorale \ , fifth from last, 3,2,5,7 harmonies
	4 0 DO
		i da.channel!
		curr-pitch @
		8 1 wchoose 3 1 choose * *or/
		b.da.freq!
	LOOP
;
		
;

: debounce.chorale \ -- 0 | 1 , valid pitch or not
	get.pitch curr-pitch @ last-pitch @ = not
;
	
: chorale
	debounce.chorale 
	IF
		current-pitch @ last-pitch !
		var-# @ \ must be 0 - 4 
		CASE 0 of 0.chorale else
		     1 of 1.chorale else
		     2 of 2.chorale else
		     3 of 3.chorale else
	             4 of 4.chorale else
		    ." error!!!! -- shouldn't be in chorale ! " cr
	        ENDCASE
;

