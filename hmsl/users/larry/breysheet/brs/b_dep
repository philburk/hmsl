\ dep-5 stuff for b'rey'sheet
anew task-b_dep

ob.array b_dep-algorithm

\ 6 different algorithms on the dep-5 are used, once again, in
\ a kind of rank ordering of sonic complexity
\ 10= chorous and delay; 6= rev. and ch. in series and parallel
\ 8=non-linear with mod.; 1= ch.; 7= non-lin.; 2=rev.

10 k: chor/delay 6 k: rev/chor 8 k: non/mod 1 k: chor 7 k: non
2 k: rev

: BUILD.B_DEP-ALGORITHM ( -- )
	6 new: b_dep-algorithm
	chor/delay rev/chor non/mod chor non rev
	6 stuff: b_dep-algorithm
;


: CHANGE.D-ALGORITHM ( -- )
	16 midi.channel!
	var-# @ 5 < 
	IF
		2 \ reverb only for last five variations
		22 4 wchoose  d-rev-type! \ only rooms and halls allowed
	ELSE 
		var-# @ 5 - \ 0-12
		2/ choose  
		\ just checking to not go out of bounds
		at: b_dep-algorithm \ algorithm-#
		dup curr-algorithm !
		22 choose d-rev-type! \ all reverb types ok
	THEN
	\ a random room type is picked for each variation
	0 d-hi-boost! \ filter out some of the local sound highs...
	d-algorithm! dep-5.send
;

\ the following routines change parametric values of the dep-5
\ according to what algorithm has been selected, and what variation
\ the piece is in

: DO.DEP.UTIL ( -- )
	var-# @ 4 ashift choose
;

: DO.CHOR ( -- )
	3 choose 
	CASE
	   0 of do.dep.util d-feedback!  endof
	   1 of do.dep.util d-depth! 	 endof
	   2 of do.dep.util d-rate!      endof
	noop
	ENDCASE
	99 d-output! dep-5.send
	16 midi.channel! dep-5.send
;


: DO.REV/CHOR ( -- ) 
	6 choose
	CASE
	0 of do.dep.util d-feedback! endof
	1 of do.dep.util d-depth!    endof
	2 of do.dep.util d-rate!     endof
	3 of do.dep.util d-rev-time! endof
	4 of do.dep.util d-predelay! endof
	5 of do.dep.util d-hf-damp!  endof
	noop
	ENDCASE
	99 d-output! dep-5.send
	16 midi.channel! dep-5.send
;

: DO.CHOR/DELAY ( -- )
	6 choose
	CASE
	0 of do.dep.util d-rate!       endof
	1 of do.dep.util d-depth!      endof
	2 of do.dep.util d-feedback!   endof
	3 of do.dep.util d-#-delays!   endof
	4 of do.dep.util d-delay-time! endof
	5 of do.dep.util d-hf-damp!    endof
	noop
	ENDCASE
	99 d-output! dep-5.send
	16 midi.channel! dep-5.send
 ;

: DO.NON/MOD ( -- )
	\ don't change non-linears, they're a bit too poppy!
	3 choose
	CASE
	0 of do.dep.util d-rate!       endof
	1 of do.dep.util d-depth!      endof
	2 of do.dep.util d-feedback!   endof
	noop
	ENDCASE
	99 d-output! dep-5.send
	16 midi.channel! dep-5.send
 ;

\ when to change dep parameter -- slower than pitch or wst
: DEP.WHEN? ( -- flag )
	prev-dep @ 
	17 var-# @ - choose 5 *
	+ 
	doitnow?
		IF
		   time@ prev-dep ! true
		ELSE false
		THEN
;

\ these guys are too poppy, do nothing here...
: DO.REV ;
: DO.NON ;

: CHANGE.DEP ( stimulus -- )
	drop
	dep.when?
	IF
	   var-# @ 5 > 
	   IF
		16 midi.channel! 99 d-output! dep-5.send
		curr-algorithm @
		CASE
		   chor/delay of do.chor/delay endof
		   rev/chor   of do.rev/chor   endof
                   non/mod    of do.non/mod    endof
                   chor       of do.chor       endof
		   rev        of do.rev        endof
		   non        of do.non        endof
		noop
		ENDCASE
	   THEN
	THEN
;

	
