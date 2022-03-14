\ A string quartet
\
\ Targeted for Korg X5DR - General MIDI
\
\ Dedicated to Mary Valente aka "Lilac Nose"
\
\ Composed by Phil Burk
\ Copyright 1996 Phil Burk

include? score{  ht:score_entry
include? $midifile1{ ht:midifile

ANEW TASK-STRQ_A.FTH


: HC ( chan -- , hear channel )
	playnow midi.channel!
	1/8 c d e f g a
;

: MC! ( channel -- )
	midi.channel!
;

: VIOLIN1    1 mc! 41 midi.preset ( -200 midi.pitch.bend ) ;
: VIOLIN1.PIZZ 2 mc! 46 midi.preset  ;
: VIOLIN2    3 mc! 41 midi.preset ( 200 midi.pitch.bend ) ;
: VIOLA      4 mc! 42 midi.preset 0 midi.pitch.bend ;
: VIOLA.PIZZ 5 mc! 46 midi.preset  ;

: CELLO      6 mc! 43 midi.preset 0 midi.pitch.bend ;


: hear.all
	cello c2 a g e
	viola c3 a g e
	viola.pizz c3 a g e
	violin1 c4 a g e
	violin1.pizz c4 a g e
	violin2 c5 a g e
;

: theme1
	1/8 c c# 1/2 legato f
	1/4 d e 1/2 a end.legato 1/8 e f d e
;

: viola.1
	viola 1/8 rest rest 1/8 c3 a3 g g#
	1/2 a 1/2 e  1/8 g a f g
;

: violin2.1
	violin2 1/8 d5 rest 1/8 f rest g g#
	1/2 a 1/2 e  1/8 g5 a f e
;

: violin2.2
	violin2 legato 1/2 a5  1/8 g f e d
	1/4 a e end.legato 1/2 rest

;

: theme2
	1/8 c f 1/2 legato d
	1/4 e g 1/2 b  end.legato 1/8 g f g e
;

: viola.2
	viola 1/8 rest rest 1/8 f3 a3 f f#
	1/2 b 1/2 f#  1/8 c d g a
;

: violin2.3
	violin2 legato 1/1 a6 1/8 e g
	1/2 f#  end.legato 1/8 c d g g#
;

: violin2.4
	violin2 legato 1/2 f6 1/8 e c d b5
	1/2 a  end.legato 1/2 rest
;

: cello.1
	cello 2 octave ! theme1
;

: violin1.1
	violin1 4 octave ! theme1
;

: violin1.2
	violin1 4 octave ! theme2
;

: cello.2
	cello 2 octave ! theme2
;

: part1 \ 9:4 time
	1 0 do par{ cello.1 }par{ viola.1 }par loop
	2 0 do par{ cello.1 }par{ viola.1 }par{ violin1.1 }par loop
	2 0 do par{ cello.1 }par{ viola.1 }par{ violin1.1 }par{ violin2.1 }par loop
	1 0 do par{ cello.1 }par{ viola.1 }par{ violin1.1 }par{ violin2.2 }par loop
;


: part4 \ 9:4 time
	1 0 do par{ cello.2 }par{ viola.2 }par loop
	2 0 do par{ cello.2 }par{ viola.2 }par{ violin1.2 }par loop
	2 0 do par{ cello.2 }par{ viola.2 }par{ violin1.2 }par{ violin2.3 }par loop
	1 0 do par{ cello.2 }par{ viola.2 }par{ violin1.2 }par{ violin2.4 }par loop
;

: part5
	par{ cello 1/8 g2 f g e  c d e f  g f g e  f g a b
	}par{ viola.pizz 1/2 g4 c g a
	}par{ violin1.pizz 1/8 rest 1/2 f5 d c 3/8 g
	}par
;

: (part6)
	par{ cello  legato 1/2 c3
	}par{ viola legato 1/8 d#4 rest a4 rest
	}par{ violin1 legato 1/8 rest f#5 rest f#
	}par{ violin2 legato 1/2 c6
	}par
;

: part6
	transposition @ >r
	4 0
	DO
		(part6)
		2 transposition +!
	LOOP
	r> transposition !
;

: part7
	par{ cello    legato   1/4 f#3 f d# c   c d# f# g
	}par{ viola   legato   1/2 d#4 rest    d# rest
	}par{ violin1 staccato 1/2 rest a5     rest c6
	}par{ violin2 staccato 1/4 f#6 f d# c  f# e d# e
	}par
;

: part8
	staccato 1/8
	par{ cello    chord{ d3 g }chord rest rest rest
	}par{ viola   rest chord{ d4 g }chord rest rest
	}par{ violin1 rest rest chord{ c5 f }chord rest
	}par{ violin2 rest rest rest chord{ c6 f }chord
	}par
;

: part9
	staccato 1/8
	par{ cello    rest chord{ d3 g }chord
	}par{ viola   rest chord{ d4 g }chord
	}par{ violin1 chord{ c5 f }chord rest
	}par{ violin2 chord{ c6 f }chord rest
	}par
;

: p10.violin \ 1/2 duration
	staccato
	violin1  2 0
	DO 1/16 g5 f d e  f e c d
	LOOP
;

: p10.viola \ 1/2 duration
	staccato
	viola  2 0
	DO 1/16 g4 f d e  f e c d
	LOOP
;

: part10
	p10.violin
	par{ cello legato 1/4  b3 a g g# 1/2 a a# end.legato
	}par{ p10.violin 1/16  g5 f d e   f e c d   e c c# d#   e f f# g
	}par{ p10.viola 1/16  g4 f d e   f e c d   1/8 e c#   1/4 c
	}par
	end.staccato
;

: spread.chord  { n1 n2 n3 n4 -- }
	transposition @ >r
	par{  cello   1/4 n1 note  n2 note  n3 note
		1/2 n4 note 1/4 n1 note  n2 note  n3 note
		12 transposition +!
	}par{ viola   1/4 rest n1 note  n2 note  n3 note
		1/2 n4 note 1/4 n1 note  n2 note
		12 transposition +!
	}par{ violin1 1/4 rest rest n1 note  n2 note  n3 note
		1/2 n4 note 1/4 n1 note
	}par{ violin2 1/4 rest rest rest  n1 note  n2 note  n3 note
		1/2 n4 note
	}par
	r> transposition !
;

: part11
	par{
		violin1 staccato 1/16 a g# a g# 1/4 f  \ part 10 overlaps
		legato
	}par{
		value{ c3 d# f g# }value spread.chord
	}par
	value{ a2 c#3 f# a }value spread.chord
	value{ g2 a# c#3 e }value spread.chord
	value{ f2 g# a# d3 }value spread.chord
\
	value{ f#2 a# c#3 e }value spread.chord
	value{ e2 f# g# b }value spread.chord
	value{ d2 g b d3 }value spread.chord
\	value{ e2 f# a# d#3 }value spread.chord
;
: part12
	viola 96 staccato!
	1/2 d#4 d# d# d#
	g# g f d
	1/4 d#4 d# d# d# d# d# d# d#
	g# f g d f g f d
;

: part13
	end.staccato
	par{
		viola 1/8 d#4 rest f rest g# rest a# rest
		1/4 a 1/8 g# rest 1/4 f 1/8 f# rest
	}par{
		cello 1/8 d#2 rest f rest g# rest a# rest
		1/4 a 1/8 g# rest 1/4 f 1/8 f# rest
	}par
;

: p14.cello \ 1/1 duration
	cello 1/8 d2 d# f# a# a g# f f#
;
: part14
	par{
		4 0 DO p14.cello LOOP
	}par{
		viola 1/4  a#4 f  d d#
		1/4 f# 1/8 g# a# a g# f f#
		1/4 g# 1/8 e d# b3 c4 e d#
		1/4 f# 1/8 g# a# d5 c# a4 a#
	}par
;

: part15
	violin2 1/4 f#6 1/8 c# c d# g5 g# a#
	par{
		cello 1/8 d2 d# f f# g g# a a#
	}par{
		viola 1/8 d3 d# f f# g g# a a#
	}par{
		violin1 1/8 d5 d# f f# g g# a a#
	}par
;

: p16.cello \ 1/1 duration
	cello 1/8 a#2 c f# c#   f e g g#
;

: part16
	par{
		2 0 DO p16.cello LOOP
	}par{
		violin1 3/8 f#4 g#  1/4 e
		1/4 f f# b 1/8 g g#
	}par
	par{
		2 0 DO p16.cello LOOP
	}par{
		viola 2 0 DO 1/8 rest 1/4 c4 c#   e 1/8 f# LOOP
	}par{
		violin1 1/8 a#6 c f# c#   f e g g#
		1/4 a#6 f#   f d#
	}par{
		violin2 1/8 a#5 c f# c#   f e g g#
		1/4 a#6 f#   f d#
	}par
;

: part17
	par{
		cello _mf  1/8 a2 f# d# c
			3/8 a#  e  f
			1/8 g# g a f# f  d# e f# f
			c# d e f  legato 1/4 c e
			1/2 f# d  d#  f# 1/1 g
	}par{
		viola _mf 1/4 d#4  rest
			3/8 a#  e  f
			1/8 g# g a f# f  d# e f# f
			c# d e f  d# e c f#
			legato 1/2 d#  f f# a# 1/1  a
	}par{
		violin1.pizz _f 1/8 a5 rest d# rest
			3/8 f g# a#
			1/8 c#5 rest a rest rest rest  c rest c
			c# 3/8 rest   d# 3/8 rest
		violin1.pizz 1/8 f#5 f rest d#  d rest e rest
			f# rest rest g  a# rest a# rest
			1/8 a d6 rest c# rest c c# rest
	}par{
		violin2 _mf 1/8 a5 f# d# c
			_mf f _p e e   _mf g# _p g g   _mf a# _p a a
			_mf c#6 c a a#  c# c c c c
			c# c c c#   d# d c c#
			legato 1/2 d#  f f# a# 1/1  a
	}par
;

: part18
	par{
		cello 1/1 rest
	}par{
		viola 1/1 rest

	}par{
		violin1
	}par{
		violin2 legato 1/2 g#5 c6 b5

	}par
;

: sqa
	part1
	part4
	part5
	part6
	part7
	2 0 do part8 loop
	_pp part9 _mf part9 _f part9 _ff part9 _mf
	part10
	part11
	part12
	part13
	p14.cello
	part14
	part15
	part16
	part17
;

\ playnow sqa
\ playnow ( part16 ) part17 part18
: tt ( -- save it to a MIDI file )
	48 dup ticks/beat !
	4 * -> default_tpw
	" strq.mid" $midifile1{ playnow sqa }midifile1
;

." Enter:  PLAYNOW SQA" cr

