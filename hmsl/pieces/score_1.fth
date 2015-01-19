\ Simple piece using Score Entry System
\
\ Composer: Phil Burk 1990

include? score{ ht:score_entry

ANEW TASK-SCORE_1

score{

: MOTIF1 ( -- , play a motif, emphasize 1st note )
	_FF A  _MF D E F F G
;
: MOTIF2 ( -- , another motif )
	_FF E  _MF G C D B E
;
: COMBO1 ( -- , play motifs in parallel )
	PAR{ MOTIF1 }PAR{ MOTIF2 }PAR
;
: COMBO2 ( -- , play in polyrhythm )
	PAR{ 1/4 MOTIF1 }PAR{ 1/6 C5 C C E E E B B B }PAR
	1/8 G4 E F D E C
;
: COMBO3  ( -- , combine various elements randomly )
	1/4 MOTIF1 MOTIF2
	2 CHOOSE
	IF  1/16 MOTIF1 MOTIF1 MOTIF2 MOTIF2
		1/4 COMBO1
	ELSE COMBO2
	THEN
;
: SCORE_1 ( -- , play the whole thing )
	TPW@ COMBO3  ( save tempo, play COMBO3 )
\
\ Get louder by 6 each 16th note
	1/16 _PPP 6 //
\
\ Play 12 random notes in an expandng range
	12 0 DO i 1+ CHOOSE 60 + NOTE LOOP
\
\ Set loudness back to medium. Play two chords
	_MF 3/8 CHORD{ C3 D F }CHORD   CHORD{ E G A }CHORD
\
	COMBO3 1/16 COMBO1 COMBO2
\
\ Accelerate, play faster and faster
	4 ACCEL{ COMBO3 }ACCEL
\
\ Reset tempo
	TPW! MOTIF2 COMBO2 MOTIF2
\
\ Final chord
	3/2 CHORD{ C3 D F A B }Chord
;

." Enter:     PLAYNOW SCORE_1     to hear piece." cr