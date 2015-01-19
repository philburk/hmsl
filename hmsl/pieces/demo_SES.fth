\ Use HMSL Score Entry System to specify notes.
\
\ Author: Phil Burk
\ Copyright 1989 Phil Burk

include? score{ ht:Score_Entry
ANEW TASK-DEMO_SES

score{

: ZAP
	1/4 c3 c g g  ( play quarter notes C C G G )
	par{ b f b f  ( begin parallel section )
	}par{ 1/8 c g a d e b  ( other parallel section )
	}par
	1/4 b b b b
	chord{ c4 e g }chord    ( play these 4 chords )
	chord{ c e g }chord
	chord{ c f a }chord
	chord{ c f a }chord
	end.staccato _ppp 1/16 5 //
	c e c f c g c a c b c a c g c e c f c d  ( many 1/16ths )
	0 //
;

\ Use ZAP in different ways inside a Forth word.
\ Use playnow{ to enter notational system.
: ZAPS ( n -- , play zap N times )
	PLAYNOW 0 DO zap LOOP
;

: ZAPS.PR ( n -- , play zap with different presets )
	playnow 0 DO i 20 + midi.preset zap LOOP
;

: ZAPS.CH ( n -- , play zap on different channels )
	playnow 0 DO i 1+ midi.channel! zap LOOP
;

: ZAPS.CH.PAR ( n -- , play zaps in parallel )
	playnow
	par{ swap    ( -- time N )
		0 DO i 1+ midi.channel! zap
			}par{  ( add parallel section for each one of these )
		LOOP  ( final parallel section empty )
	}par
;


\ A complex piece with different parts.
: BASS.LINE
	1/2 1 midi.channel!
	7 midi.preset c3 g c g  5 midi.preset c a b f
;

: RHYTHM.LINE
	5 octave ! 1/4 2 midi.channel!
	8 0 DO chord{ c f g }chord LOOP  ( play chord 8 times )
	1/2 _ff  ( change loudness )
	chord{ c e a }chord
	chord{ d f a }chord _p
	chord{ e g b }chord _pp
	chord{ d f a }chord
;

: 2PIECE
	playnow
	bass.line
	par{ bass.line }par{ rhythm.line }par
	rhythm.line
;

\ Generate notes using simple algorythm.

: GLISSUP  ( lo-note hi-note -- , play notes up )
	-2sort DO i note LOOP
;

: LADDERS ( -- , play several glisses up )
\ Use value{ to get note values to pass to glissup )
	value{ d5 a5 }value glissup
	value{ f4 f5 }value glissup
	value{ g4 d5 }value glissup
;

: ZING ( -- , play ladders at different speeds plus notes )
	1/4 ladders 1/32 g g g g a a f f f f
	1/8 ladders 1/16 ladders
	1/2 g g d d a a
;

: KEEP.ZING
\ The shape will be extended automatically as needed.
	32 3 new: shape-1  ( allocate initial space )
\
\ Specify key to play in.
	tr-current-key put.gamut: ins-midi-1
	0 put.offset: ins-midi-1
\
\ Play zing into a shape for later playback or manipulation.
	shape-1 ins-midi-1 shapei{ zing }shapei
\
\ Print and play it just to prove it's there.
	print: shape-1
	shep
;

: TEST{  ( -- , surround a notated sequence with this )
\ The shape will be extended automatically as needed.
	32 4 new: shape-1  ( allocate initial space )
\
\ Specify key to play in.
	default: ins-midi-1
	0 put.offset: ins-midi-1
	'c interp.el.on.for put.on.function: ins-midi-1
	'c 3drop put.off.function: ins-midi-1
\
\ Play into a shape for later playback or manipulation.
	shape-1 ins-midi-1 shapei{
;

: }TEST
	}shapei
\
\ Print and play it just to prove it's there.
	print: shape-1
	shep
;

: 4AGAINST6  ( -- , experiment with different rhythms )
	par{
	1/4 c2 g e b c4 g e b
	}par{
	1/6 c5 d g f e b c6 c c d d d
	}par
;

\ --------------------------------------
\ Experiment with phasing.
: PHRASE ( loudness time -- , do one phrase )
	playat loudness! 1/8 c3 e g d f a
;

: PHASED  ( -- , play sequence phase, quieter, like echo )
	time@
	5 0
	DO  100 i 20 * -
		over phrase 12 +
	LOOP drop
;


cr ." Enter:  PLAYNOW ZAP  or 2PIECE  or  PLAYNOW ZING   or  KEEP.ZING" cr
	." or TEST{ 4AGAINST6 }TEST  or  PHASED" cr
	." Read file for channel and voice allocations and other info." cr
