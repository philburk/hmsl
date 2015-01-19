\ Demonstrate Markhov chain behavior
\
\ Author: Larry Polansky & Phil Burk
\ 1990

include? task-score_entry ht:score_entry
decimal
anew task-demo_structure

\ Edit the tendencies of the structure ---------------
\ This will eventually turn into a tabular Shape Editor
variable TSE-CUR-SHAPE

: TSE.FUNC   ( value part#  --  )
	tse-cur-shape @ to: []
;

OB.NUMERIC.GRID  TSE-GRID
OB.SCREEN        TSE-SCREEN

: TSE.INIT  ( shape -- )
	tse-cur-shape !
	tse-cur-shape @ dimension: []
	tse-cur-shape @ many: []
	2dup new: tse-grid
\
\ Load values
	* 0  ( for each element )
	DO ( set min/max then values )
		i tse-cur-shape @ dimension: []
		mod tse-cur-shape @ get.dim.limits: [] ( -- lo hi )
		i put.max: tse-grid
		i put.min: tse-grid
		i tse-cur-shape @ at: []
		i put.value: tse-grid
	LOOP
\
	'c tse.func put.move.function: tse-grid
	'c tse.func put.up.function: tse-grid
\
\ Set appearance.
	" Shape Data" put.title: tse-grid
	'c n>text put.text.function: tse-grid
\
\ Build screen for it.
	" Table Editor" put.title: tse-screen
	4 3 new: tse-screen
	tse-grid 400 600 add: tse-screen
;

: TSE.TERM  ( -- )
	freeall: tse-screen
	free: tse-screen
;
\ --------------------------------------------------
ob.shape m-s-1
ob.shape m-s-2
ob.shape m-s-3
ob.shape m-s-4
ob.shape m-s-5

ob.player m-p-1
ob.player m-p-2
ob.player m-p-3
ob.player m-p-4
ob.player m-p-5

ob.structure m-structure
ob.collection m-collection

\ Pick a random repeat count on start up
: PICK.REPEAT ( player -- )
	get.last: m-structure ." , Choice = " .
	dup name: []
	4 choose
	1+ dup ."  RP=" . flushemit cr?
	swap put.repeat: []
;

\ Setup players and instruments

: INIT.PLAYER { shape ins player -- }
	ins player put.instrument: []
	stuff{ shape player }stuff: []
\
\ Every time a player starts, it will pick a random
\ repeat count.
	'c pick.repeat player put.start.function: []
	ins use.poly.interp
;

: DS.INIT.PLAYERS ( -- , initialize 5 players)
	m-s-1 ins-midi-1 m-p-1
	m-s-2 ins-midi-2 m-p-2
	m-s-3 ins-midi-3 m-p-3
	m-s-4 ins-midi-4 m-p-4
	m-s-5 ins-midi-5 m-p-5
	5 0 DO
		init.player
	LOOP
;

\ Use Score Entry System to put notes into shapes
score{
: DS.INIT.SHAPES
	32 4 new: m-s-1
	m-s-1 ins-midi-1
	shapei{ eh c b4 a d }shapei
\
	32 4 new: m-s-2
	m-s-2 ins-midi-2
	shapei{ 5 7 duration!! c1 d2 a3 e b4 f#5  }shapei
\
	32 4 new: m-s-3
	m-s-3 ins-midi-3
	shapei{ eh e3 d c c 1/16 c c d c d eh e e e d }shapei
\
	32 4 new: m-s-4
	m-s-4 ins-midi-4
	shapei{ chord{ g a# c d# f# }chord s e6 f f#
		g g#  }shapei
\
	32 4 new: m-s-5
	m-s-5 ins-midi-5
	shapei{ g g g g }shapei

	clear: shape-holder
	m-s-1 m-s-2 m-s-3 m-s-4 m-s-5
	5 0 DO add: shape-holder LOOP
;
}score

: DS.INIT ( -- )
	ds.init.players
	ds.init.shapes
	0 m-p-1 m-p-2 0stuff: m-collection \ default is parallel
	0 m-p-1 m-p-2 m-p-3 m-p-4 m-p-5 m-collection 0stuff: m-structure
\
	get.tgrid: m-structure tse.init
	print: m-structure
;

: DS.TERM ( -- )
	clear: shape-holder
	free.hierarchy: m-structure
	free: m-structure
	tse.term
;

: DEMO.STRUCTURE  ( -- )
	ds.init
	m-structure hmsl.play
	ds.term
;

if.forgotten ds.term

cr ." Enter:  DEMO.STRUCTURE    to hear demo" cr