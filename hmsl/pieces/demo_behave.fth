\ Demonstrate the use of an "intelligent" collection
\
\ A BEHAVIOR will determine which component to
\ execute next.  The collection will be filled with
\ various morphs.
\
\ Composer: Phil Burk
\ Copyright 198 -  Phil Burk, Larry Polansky, David Rosenboom.

ANEW TASK-DEMO_BEHAVE

: DS.INIT.SP  ( -- )
	prefab: player-1
	1 get.instrument: player-1 put.preset: []
\
	prefab: player-2
	5 get.instrument: player-2 put.preset: []
\
	prefab: player-3
	10 get.instrument: player-3 put.preset: []
\
	prefab: player-4
	15 get.instrument: player-4 put.preset: []
\
	prefab: player-5
	20 get.instrument: player-5 put.preset: []
\
\ Place two of the players in a parallel collection.
	stuff{ player-4 player-5 }stuff: coll-p-1
	2 put.repeat: coll-p-1
\
\ Make shapes available to Shape Editor
	clear: shape-holder
	shape-1 add: shape-holder
	shape-2 add: shape-holder
	shape-3 add: shape-holder
	shape-4 add: shape-holder
	shape-5 add: shape-holder
;

: BH.PICK2  ( structure -- v0 v1 2 , pick two of them )
	many: [] ?dup
	IF ( -- n )
		BEGIN
			dup choose over choose 2dup = ( make sure different )
		WHILE 2drop
		REPEAT rot drop 2 .s
	ELSE 0
	THEN
;

: DS.INIT.COLL ( -- , setup top collection )
	stuff{ player-1 player-2 player-3 coll-p-1 }stuff: coll-p-2
\
\ Tell collection to use custom behavior.
	'c bh.pick2   put.behavior: coll-p-2
	32 put.repeat: coll-p-2
;

: DS.INIT  ( -- , Initialize all morphs )
	ds.init.sp
	ds.init.coll
	." Hierarchy of piece."
	print.hierarchy: coll-p-2 cr
	." Hit key." key drop
;

: DS.PLAY ( -- )
	coll-p-2 hmsl.play
;

: DS.TERM ( -- )
	default.hierarchy: coll-p-2
	free.hierarchy: coll-p-2
;

: DEMO.BEHAVE ( -- , Demonstrate a random BEHAVIOR )
	ds.init  ds.play  ds.term
;

." Enter:  DEMO.BEHAVE    to hear demo." cr