\ Example piece that uses tempo map for parts of a measure
\ A shape plays a tempo profile while 4 other players
\ play out their melodies.

ANEW TASK-STAGGER

OB.SHAPE STAGGER-SHAPE
OB.PLAYER STAGGER-PLAYER
OB.INSTRUMENT STAGGER-INS

: STAGGER.INTERP  ( elmnt shape ins -- )
	drop 1 swap ed.at: []
	rtc.rate!  ( set tempo to value in shape )
;

: STAGGER.SETUP  ( -- , set stagger rates )
	16 2 new: stagger-shape
	stuff{
		20 68
		20 64
		20 56
		20 64
		20 68
		20 53
		20 56
		20 52
	}stuff: stagger-shape
\
	stagger-shape stagger-ins build: stagger-player
	'c stagger.interp  put.on.function: stagger-ins
	'c 3drop put.off.function: stagger-ins
	10000 put.repeat: stagger-player
;

OB.COLLECTION STAGGER-COL
4 constant NUM_PLAYERS

: SIMPLE.SETUP ( -- )
	num_players 0
	DO instantiate ob.player dup add: stagger-col
		dup prefab: []
		10000 swap put.repeat: []
	LOOP
;

: STAGGER.INIT  ( -- )
	act.parallel: stagger-col
	num_players 1+ new: stagger-col
	stagger.setup
	simple.setup
	stagger-player add: stagger-col
	clear: shape-holder
	stagger-shape add: shape-holder
	num_players 0
	DO i get: stagger-col	first: [] add: shape-holder
	LOOP
;

: STAGGER.TERM  ( -- )
	many: stagger-col 0>
	IF	num_players 0
		DO i get: stagger-col dup free: [] deinstantiate
		LOOP
		free: stagger-player
		free: stagger-col
	THEN
	clear: shape-holder
;

: STAGGER ( -- )
	stagger.init
	stagger-col hmsl.play
	stagger.term
;

if.forgotten stagger.term

cr ." To hear tempo being controlled by a shape, enter:   STAGGER" cr
