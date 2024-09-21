\ action setup for b'rey'sheet

anew task-b_acts

OB.ACTION XWST
: BUILD.XWST
	'c cwss put.response: xwst
	'c always put.stimulus: xwst	
	highest put.priority: xwst
;

\ whenever a new variation is picked, the dep-5 algorithm is changed
: VAR.UP.RESPONSE inc.var-# change.d-algorithm ;
: VAR.DOWN.RESPONSE dec.var-# change.d-algorithm ;

OB.ACTION VAR.UP
OB.ACTION VAR.DOWN
: BUILD.UP.DOWN
	lowest put.priority: var.down
	lowest put.priority: var.up
	'c var.up.response   put.init: var.up
	'c var.down.response put.init: var.down
	'c var.up.response   put.term: var.up
	'c var.down.response put.term: var.down
;

OB.ACTION SINE
: BUILD.SINE
	lowest put.priority: sine
	'c force.sine put.init: sine
	'c force.sine put.term: sine
;

OB.ACTION PITCHES
: BUILD.PITCHES
	'c pitch.change put.response: pitches
	'c always       put.stimulus: pitches
	highest         put.priority: pitches
;

OB.ACTION FOLLOW
: BUILD.FOLLOW
	'c fb.follow put.response: follow
	'c always    put.stimulus: follow
	high         put.priority: follow
;

OB.ACTION DEP
: BUILD.DEP
	'c change.dep put.response: dep
	'c always     put.stimulus: dep
	low           put.priority: dep
;

: BUILD.B.ACTS
	build.follow
	build.pitches
	build.xwst
	build.dep
	build.up.down
	build.sine
	var.down put.action: action-table
	sine put.action: action-table
	follow put.action: action-table
	pitches put.action: action-table
	xwst put.action: action-table
	dep put.action: action-table
	var.up put.action: action-table
	1 1 2 10 put.priority.probs
;	
