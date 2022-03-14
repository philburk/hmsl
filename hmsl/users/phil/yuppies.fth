\ Yuppies in the Jungle
\
\ converted to Korg X5DR - General MIDI

include? score{  ht:score_entry

ANEW TASK-YUPPIES

: HC ( chan -- , hear channel )
	playnow midi.channel!
	1/8 c d e f g a
;

\ Yuppies in the Jungle score
score{

: MC! ( channel -- )
	midi.channel!
;

: BASS 1 mc! 35 midi.preset ;
: ORGAN 2 mc! 19 midi.preset ;

: PERC1 3 mc! 118 midi.preset ; \ hand drum

: PERC2 4 mc! 114 midi.preset ; \ tap

: COCO.INTRO
	1/8 rest g3 g3 g3
;

: COCO.L1
	1/4 c2 g1 1/8 c2 1/16 d 1/4 e 1/16 rest
;

: COCO.L2
	1/4 d2 a1 1/8 d2 1/16 e 1/4 f 1/16 rest
;

: COCO.L3
	1/4 e2 c 1/8 e2 1/16 f 1/4 g 1/16 rest
;

: COCO.RHYTHM
	1/8 C5 rest C5 rest
	C5 rest rest 1/16 C5 C5
;

: COCONUTS
	perc1 coco.intro
	par{
		perc1 coco.rhythm coco.rhythm coco.rhythm coco.rhythm
	}par{
		bass  coco.l1 coco.l2 coco.l3 coco.l1
	}par
;

: YUPPIES.A1
	1/8 c4 rest e4 rest
	1/8 c4 1/16 c6 g5 1/8 chord{ e5 e4 }chord g5
;

: YUPPIES.A2
	1/8 f4 rest d4 rest
	1/8 f4 1/16 b6 a5 1/8 chord{ d4 f5 }chord A5
;

: YUPPIES.A3
	1/8 g3 rest g4 rest
	2 0
	DO
		1/16 chord{ G4 G5 }chord G G rest
	LOOP
;

: YUPPIES.BASS
	1/4 c2 e2 c2 rest
	1/4 f2 d2 f2 rest
	1/4 c2 e2 c2 rest
	1/4 g1 rest g1 rest
;

: YUPPIES.B1
	1/8 rest 1/16 g4 g rest rest g rest
;

: YUPPIES.B2
	1/8 rest c4 rest c4
;

: YUPPIES
	par{
		organ yuppies.a1 yuppies.a2 yuppies.a1 yuppies.a3
	}par{
		perc1 6 0 DO yuppies.b1 LOOP
		yuppies.b2 yuppies.b2
	}par{
		bass yuppies.bass
	}par
;

: GETBACK.BASS
	1/4 c2 10 /\ c2 a1 a1
;
: GETBACK.ORGAN
	1/16 rest 10 /\ e4 a4 d5  a4 d5 g5 rest
	1/2 rest
;
: GETBACK.C
	1/8 rest 10 /\ c4 rest c4
	1/8 e5 rest e5 rest
;

: GETBACK.D
	1/16 rest g5 rest g rest 10 /\ g g rest
	1/16 rest g5 rest g rest 10 /\ g g rest
;

: GETBACK
	par{
		bass getback.bass
	}par{
		organ getback.organ
	}par{
		perc1 getback.c
	}par{
		loudness@ _pp PERC2 getback.d loudness!
	}par
;

: PLAYLOOP ( <word> -- )
	playnow time-advance @ vtime+!
	[compile] '
	BEGIN
		vtime@
		over execute
		vtime@ swap -
		?delay
	UNTIL
;

: YUPPIES.IN.JUNGLE
	130 tpw!
	coconuts
	2 0 DO yuppies LOOP
	8 0 DO getback LOOP
	bass 2/1 c1
;
\ MIDI CHannel assignments
\	1 = bass , bank 6 L
\	2 = cheesy organ , 2 notes , bank 7 R
\	3 = drums , bank 6 LR
\	4 = drums , bank 6 L
\   5 = bank 3
\   6 = bank 5

0 .IF
: FB.SETUP.JUNGLE
	rnow
	15 fb.configuration
	8 0
	DO
		i 1+ mc! 0 fb.#notes!
	LOOP
	6 mc! 1 fb.#notes! 3 fb.bank 127 fb.pan!
	5 mc! 1 fb.#notes! 3 fb.bank 0 fb.pan!
	4 mc! 1 fb.#notes! 6 fb.bank 64 fb.pan!
	3 mc! 1 fb.#notes! 6 fb.bank 64 fb.pan!
	2 mc! 2 fb.#notes! 7 fb.bank 127 fb.pan!
	1 mc! 1 fb.#notes! 6 fb.bank 0 fb.pan!
;
.THEN

\ These are callable from MIDI Parser
: PLAY.JUNGLE
\	fb.setup.jungle
	playnow yuppies.in.jungle
;

\ playnow 130 tpw! getback getback getback getback

." Enter: playnow yuppies.in.jungle" cr


