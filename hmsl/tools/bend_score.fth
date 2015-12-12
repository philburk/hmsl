\ Play using pitch bend tuning
\ Extensions to score entry
\
\ By Phil Burk
\ Copyright 1995

include? par{  ht:score_entry
include? ratio>pbend  bend_tuning.fth

anew task-bend_score.fth


: MIDI.SET.RPN { val rpn -- , set registered parameter number }
	101 0 midi.control
	100 rpn midi.control
	6 val midi.control
	38 0 midi.control
;

: GM.SET.BEND.RANGE ( semitones -- )
	0 midi.set.rpn
;
: GM.SET.BEND.RANGE.ALL { semitones -- }
	16 0
	DO
		i 1+ midi.channel!
		semitones gm.set.bend.range
	LOOP
;

variable BSC-FUNDAMENTAL    \ current fundamental in pbend units
variable BSC-LAST-PBEND     \ pbend of last note played
variable BSC-NUM-CHANNELS
9 bsc-num-channels !
variable BSC-BASE-CHANNEL
1 bsc-base-channel !
variable BSC-CUR-CHANNEL
1 bsc-cur-channel !

: BSC.NEXT.CHANNEL ( -- , perform round robin assignment of channels )
	bsc-cur-channel @ 1+
	dup bsc-base-channel @ - bsc-num-channels @ >=
	IF
		drop bsc-base-channel @
	THEN
	dup bsc-cur-channel !
\	." bsc-cur-channel = " dup . cr
	midi.channel!
;

: BSC.SET.PROGRAM ( program# -- )
	bsc-num-channels @ 0
	DO
			dup midi.program
			7 127 midi.control  \ full volume
			bsc.next.channel
	LOOP
	drop
;

: BSC.SET.FUNDAMENTAL ( note -- )
	note>pbend bsc-fundamental !
;

: PR.RESET
	1 gm.set.bend.range.all
	60 bsc.set.fundamental
;
pr.reset

: BSC.RATIO>PBEND ( numer denom -- fundamental+pbend )
	ratio>pbend \ convert the ratio to a relative pitch bend
	bsc-fundamental @ +
;

: RAT! ( numer denom -- , set new fundamental, relative to previous )
	bsc.ratio>pbend
	bsc-fundamental !
;

: RAT{  { numer denom -- pbend-old , nest to transposed fundamental }
	bsc-fundamental @
	numer denom  rat!
;

: }RAT  ( pbend-old --  , unnest fundamental )
	bsc-fundamental !
;

\ move this to EVENT_BUFFER !!!
: EB.CATCHUP  ( -- , wait for free nodes silently )
	eb-free-nodes eb.next 0=
	IF
		time@ 60 +
		BEGIN
			?terminal abort" EB.CATCHUP aborted!"
			dup time@ time<
		UNTIL
		drop
	THEN
;

: (PR) { numer denom pbend --  }
	bsc.next.channel
	numer denom ratio>pbend \ convert the ratio to a relative pitch bend
	pbend + \ convert the ratio to an absolute pitch bend
	dup bsc-last-pbend !
	eb.catchup
	pbend>note+pb midi.pitch.bend
	eb.catchup
	note
;

: PR  ( numer denom -- , play ratio off of fundamental )
	bsc-fundamental @ (pr)
;

: >>!  ( -- , set fundamental to previous note )
	bsc-last-pbend @ bsc-fundamental !    \ update fundamental
;

: PR!  ( numer denom -- , play ratio off of fundamental, note is new fundamental )
	bsc-fundamental @ (pr)
	bsc-last-pbend @ bsc-fundamental !    \ update fundamental
;

: >>PR ( numer denom -- , play ratio based on previous note)
	bsc-last-pbend @ (pr)
;
: >>PR! ( numer denom -- , play ratio based on previous note, update fundamental
	>>pr
	bsc-last-pbend @ bsc-fundamental !    \ update fundamental
;
