\ Test dynamic intonation using PitchBend on multiple channels.

include? ratio>pbend  tools/bend_tuning.fth
include? par{  tools/score_entry
include? task-bend_score  tools/bend_score.fth

anew TASK-TRAT

\ simple piece using ratio scoring
: TRAT1
	1 1 PR   3 2 PR  4 3 PR
;

: TRAT2
	trat1
	5 4 rat{ trat1 }RAT
	trat1
;

: TRAT.CH1
	chord{ 1 1 PR  3 2 PR 4 3 PR }chord
;
: TRAT.CH2
	chord{ 1 1 PR  4 3 >>PR  4 3 >>PR }chord
;
: TRAT.CH3
	chord{ 4 5 >>PR  4 3 >>PR  4 3 >>PR }chord
;

: TRAT3
	par{ 1/8 4 0 DO 1 1 PR 7 5 PR 3 4 PR 5 4 PR LOOP
	}par{
		1/4 4 0 DO 4 1 RAT{ 1 1 PR 3 2 PR }RAT LOOP
	}par
;
: TRAT4
	par{ trat3
	}par{ 1/16 5 4 RAT{
		8 0 DO  1 1 PR  9 8 PR  8 5 PR  7 4 PR LOOP
		}RAT
	}par
;

: TRAT5
	1/8
	4 0
	DO
		2 1 PR  5 4 PR   1 1 PR   1 1 PR
		1 1 PR  3 2 >>PR  3 4 >>PR  4 5 >>PR!
	LOOP
;

: TRAT.SCALE  { numer denom num -- , play a series of just intervals }
	num  0
	DO
		numer denom >>PR
	LOOP
;

: TRAT.SCALES  ( -- , perform up and down scales )
	8 0
	DO
		4 i +  3 i + 2dup 8 trat.scale swap 8 trat.scale
	LOOP
;
: TRAT.DIVERGE  ( -- , perform up and down scales, diverging and rejoining )
	8 0
	DO
		par{
			4 i +  3 i + 2dup 8 trat.scale swap 8 trat.scale
		}par{
			4 i +  3 i + SWAP 2dup 8 trat.scale swap 8 trat.scale
		}par
	LOOP
;

: TRAT6   { n1 n2 -- , play chords with sliding fundamental }
	1 1 PR  2 3 >>PR  n1 n2 >>PR  n1 n2 >>PR  n2 n1 >>PR  n2 n1 >>PR
	8 0
	DO
		CHORD{  n2 n1 >>PR! n1 n2 PR   3 2 PR }CHORD
	LOOP
;

: TRAT7
	par{
		1/12   4 0 DO   1 1 PR  3 4 PR  4 5 PR  LOOP
	}par{
		1/4   1 2 PR   3 8 PR   9 16 PR  4 6 PR
	}par
	1/12   4 0
		DO   chord{   5 6 PR!  2 3 PR  }chord
			3 4 PR!  3 2 PR!
		LOOP
	1/12   4 0 DO   2 1 PR  6 5 PR  4 3 >>PR  LOOP
;

: TRAT8
	1/4 1 1 pr  6 5 >>pr  4 5 >>pr  3 2 >>pr
	1/2 4 5 >>pr  1 1 >>pr!
;

: TRAT9
	1/4 1 1 pr  5 3 >>pr  5 6 >>pr  5 4 >>pr
	1/2 3 2 >>pr  1 2 >>pr!
;

: TRAT10 \ play chords with a single internal fundamental
	chord{  1 1 pr  3 4 >>pr 2 3 >>pr  }chord
	chord{  4 3 pr!  3 4 >>pr 2 3 >>pr  }chord
	chord{  2 3 pr!  3 5 >>pr 5 6 >>pr  }chord
	chord{  3 2 pr!  2 3 >>pr 3 4 >>pr  }chord
	chord{  5 3 pr!  3 5 >>pr 2 3 >>pr  }chord
	chord{  4 5 pr!  3 4 >>pr 5 6 >>pr  }chord
;

: TRAT11 \ play bass chords plus high ornamentation
	par{ chord{  1/2 1 1 pr  3 4 >>pr 2 3 >>pr  }chord
	}par{   1/8 4 1 rat{  1 1 pr  3 4 pr   4 3 pr  2 3 pr }rat
	}par
	par{ chord{  1/2 4 3 pr!  3 4 >>pr 2 3 >>pr  }chord
	}par{   1/8 4 1 pr  3 4 >>pr   5 4 >>pr  6 5 >>pr
	}par
	par{ chord{  1/2 2 3 pr!  3 5 >>pr 5 6 >>pr  }chord
	}par{   1/8 4 1 pr  3 5 >>pr   5 3 >>pr  6 5 >>pr
	}par
	par{ chord{  1/2  3 2 pr!  2 3 >>pr 3 4 >>pr  }chord
	}par{   1/8 4 1 pr  3 4 >>pr   5 4 >>pr  6 5 >>pr
	}par
	par{ chord{  1/2  5 3 pr!  3 5 >>pr 2 3 >>pr  }chord
	}par{   1/8 4 1 rat{  1 1 pr  3 4 pr   4 3 pr  2 3 pr }rat
	}par
	par{ chord{  1/2  4 5 pr!  3 4 >>pr 5 6 >>pr  }chord
	}par{   1/8 4 1 pr  3 4 >>pr   5 4 >>pr  6 5 >>pr
	}par
;

: TRAT12  ( -- , pound steady chord )
	1/8  4 0 DO chord{  1 1 pr  3 4 >>pr 4 5 >>pr  }chord LOOP
	4 3 rat!
	1/8  4 0 DO chord{  1 1  pr!  4 5 >>pr 5 6 >>pr  }chord LOOP
;

: TRAT
	1 bsc.set.program
	pr.reset
	1/4
\	trat3 trat4
\	4 3 RAT{ trat4 trat3 }RAT
	1 2 rat!
	1/16  4 3 trat6  5 4 trat6  6 5 trat6
	1/2   1 2 >>PR  2 3 >>PR  2 3 >>PR!
	trat7
	1/16  trat.scales trat.diverge
	trat8 trat8
	trat9 trat9
	1/4 _ff 1 2 rat! trat10 1 2 rat! trat10
	_mf 1 2 rat! trat11 trat12
	1/4 1 2 rat! trat10
	1/16  1 2 rat! trat.scales trat.diverge
	1/4 1 2 rat! trat10
;

." To listen, enter:    playnow  trat" cr

\ playnow  1 bsc.set.program pr.reset 1/16  4 3 trat6  5 4 trat6  6 5 trat6


