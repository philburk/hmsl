\ Weighted probability.
\ This object uses weighted probabilities to
\ determine the transition from one state to the next.
\ In the example given, the probability of following
\ one note with another specific note is put in a table.
\ A new note is chosen based on the previous note.
\
\ A technique similar to this could be used to
\ implement a Markov Chain.
\
\ Phil Burk   4/89

include? { ju:locals

MRESET SUM.ROW:
ANEW TASK-DEMO_CHAIN

METHOD  SUM.ROW:
METHOD  SCAN.ROW:
METHOD  CHAIN:
METHOD  CHOOSE:

:CLASS OB.CHAIN <SUPER OB.SHAPE
	iv.long iv-mrk-last

:M SUM.ROW:  ( elmnt# -- sum )
	0 dimension: self 0
	DO over i ed.at: self +  ( -- elmnt# sum )
	LOOP nip
;M

:M SCAN.ROW:  { value elmnt# | choice -- choice  , look for bucket }
	-1 -> choice
	0 dimension: self 0
	DO  elmnt# i ed.at: self +
		dup value  >
		IF i -> choice leave
		THEN
	LOOP drop
	choice
;M

:M CHAIN:  ( elmnt# -- choice , calculate weighted probablility )
	dup sum.row: self
	choose
	swap scan.row: self
	dup iv=> iv-mrk-last
;M

:M CHOOSE: ( -- choice , next based on last one )
	iv-mrk-last chain: self
;M
;CLASS

true .IF
OB.CHAIN  W1

: SETUP.CHAIN
	4 4 new: w1
	1 2 5 3   add: w1
	7 20 0 12 add: w1
	5 5 5 15   add: w1
	13 8 5 3  add: w1
	print: w1
;

: TEST  ( -- , test a weighted object )
	setup.chain
	cr 0 sum.row: w1   0
	DO  i .   i 0 scan.row: w1 . cr
	LOOP
;


variable default-interval
2 default-interval !  ( use whole tone scale )

: PLAY.CHAIN  ( -- , play a series of four notes using a CHAIN chain )
	eb.on
	setup.chain anow
	32 0
	DO  choose: w1  default-interval @ * 50 +
		64 10 midi.noteon.for 14 vtime+!
	LOOP
	free: w1
;

cr ." Enter:  PLAY.CHAIN   to hear demo" cr

.THEN