\ A pop song
\
\ converted to Korg X5DR - General MIDI

include? score{  ht:score_entry

ANEW TASK-POP1

\ move this to EVENT_BUFFER !!!
0 [IF]
: EB.CATCHUP  ( -- , wait for free nodes silently )
	BEGIN
		eb-free-nodes eb.next 0=
	WHILE
		60 20 * time@ +
    	BEGIN
			?terminal abort" EB.CATCHUP aborted!"
			dup time@ time<
		UNTIL
		drop
	REPEAT
;
[THEN]

: HC ( chan -- , hear channel )
	playnow midi.channel!
	1/8 c d e f g a
;

: MC!  midi.channel! ;

: bass 1 mc! 35 midi.preset ;
: guitar 2 mc! 29 midi.preset ;
: trumpet   3 mc! 57 midi.preset ;

\ drums on channel 10
: drum.tom.hi  10 mc! 47 note ;
: drum.kick    10 mc! 31 note ;
: drum.wood.block 10 mc! 76 note ;
: drum.snare 10 mc! 38 note ;
: drum.ride 10 mc! 51 note ;
: drum.timbal.hi 10 mc! 65 note ;
: drum.timbal.lo 10 mc! 66 note ;
: drum.bell 10 mc! 56 note ;
: drum.cuica 10 mc! 78 note ;
: drum.shake 10 mc! 69 note ;


: theme1
	c e d f g g g rest
;

: beat1
	par{
		1/8 drum.kick drum.kick
	}par{
		4 0 DO 1/8 20 /\ drum.tom.hi rest drum.tom.hi drum.tom.hi loop
	}par{
		4 0 DO 1/8 rest rest drum.ride drum.ride loop
	}par{
		6 0 DO 1/8 rest 1/16  drum.snare drum.snare loop
	}par
;

: beat2
	par{
		1/8 drum.kick rest drum.kick rest
	}par{
		1/8 rest rest drum.snare  drum.wood.block
	}par{
		1/8 rest rest rest   1/16 drum.ride drum.ride
	}par
;

: shuka 1/16 drum.shake drum.shake drum.shake rest ;

: beat3
	par{
		1/8 drum.kick rest drum.kick rest
	}par{
		1/8 rest rest drum.snare  rest
	}par{
		shuka shuka
	}par{
		1/8 drum.bell rest drum.bell drum.ride
	}par
;

: riff2 { n0 n1 n2 n3 -- }
	par{
		bass 1/8 20 /\ n0 note  n0 note  rest  rest
	}par{
		guitar 1/8 rest rest _ff
		2 0 do chord{ n1 note n2 note n3 note }chord loop
	}par
;

: bed2
	2 0 DO par{ beat2 }par{ value{ c2 c4 e g }value riff2 }par LOOP
	2 0 DO par{ beat2 }par{ value{ d2 d4 f a }value riff2 }par LOOP
;
: bed3
	2 0 DO par{ beat3 }par{ value{ c2 c4 e g }value riff2 }par LOOP
	2 0 DO par{ beat3 }par{ value{ d2 d4 f a }value riff2 }par LOOP
;

: theme2
	1/8 c3 c c c d d d d
	1/1 rest
	1/4 c4 1/8 g3 e d f a f
	1/1 rest
;

: theme3
	1/4 c4 c 1/8 g3 a 1/4 d
	1/1 rest
	1/4 c3 e 1/2 g
	1/1 rest
;

: trans1
	1 24 duration!! drum.timbal.hi drum.timbal.hi drum.timbal.hi
	1/8 drum.timbal.hi drum.timbal.hi drum.timbal.hi rest
	1/8 drum.timbal.lo drum.timbal.lo rest
;

: intro
	bed2 bed2
;
: verse2
	par{
		4 0 do bed2 loop
	}par{
		trumpet _fff theme2 theme2
	}par
;
: verse3
	par{
		4 0 do bed3 loop
	}par{
		trumpet _fff theme3 theme3
	}par
;

: pop1
	intro
	verse2 verse2
	trans1
	verse3 verse3
;

cr ." Enter: playnow 90 tpw! pop1" cr


