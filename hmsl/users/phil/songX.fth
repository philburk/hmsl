\ A song
\
\ converted to Korg X5DR - General MIDI

include? score{  ht:score_entry

ANEW TASK-SONGX

: HC ( chan -- , hear channel )
	playnow midi.channel!
	1/8 c d e f g a
;

\ switch between multiple scales
OB.TRANSLATOR  tr-mode-0
OB.TRANSLATOR  tr-mode-1
OB.TRANSLATOR  tr-mode-2
OB.TRANSLATOR  tr-mode-3
OB.TRANSLATOR  tr-mode-4
5 constant tr_num_modes
variable tr-mode-var
tr_num_modes array tr-modes

: TR.SET.MODE ( indx -- )
	tr-modes @ tr-mode-var !
;

: TR.SETUP.SCALES  ( -- , set up modes for play )
    36 put.offset: tr-mode-0
    stuff{ 0 2 7 9 }stuff: tr-mode-0
	tr-mode-0 0 tr-modes !
\
    36 put.offset: tr-mode-1
    stuff{ 0 4 7 9 }stuff: tr-mode-1
	tr-mode-1 1 tr-modes !
\
    36 put.offset: tr-mode-2
    stuff{ 0 2 4 9 }stuff: tr-mode-2
	tr-mode-2 2 tr-modes !
\
    36 put.offset: tr-mode-3
    stuff{ 2 5 7 8 }stuff: tr-mode-3
	tr-mode-3 3 tr-modes !
\
    36 put.offset: tr-mode-4
    stuff{ 2 4 7 9 }stuff: tr-mode-4
	tr-mode-4 4 tr-modes !
\
	0 tr.set.mode
;
tr.setup.scales

: tr.free.scales
	tr_num_modes 0
	DO
		i tr-modes @ free: []
	LOOP
;
if.forgotten tr.free.scales

score{

: LOOKUP.SCALE  ( index -- note )
    tr-mode-var @ translate: [] \ translate into current mode
;

: NOTE.IN.SCALE ( index -- , plays note in scale )
    lookup.scale note
;

: NIS note.in.scale ;

: MC! ( channel -- )
	midi.channel!
;

: BASS 1 mc! 35 midi.preset ;
: ORGAN 2 mc! 19 midi.preset ;
: PERC1 3 mc! 118 midi.preset ; \ hand drum

: PERC2 4 mc! 114 midi.preset ; \ tap
: V.HIGH 5 mc! 69 midi.preset ;
: V.MID 6 mc! 57 midi.preset ;
: V.LOW 7 mc! 43 midi.preset ;
: V.FAST 8 mc! 13 midi.preset ;


: THEME1
	1/4 c d f 3/4 e 1/2 a g g# a
;

: CH.OCT { low_note mid_note high_note num -- , play chord in octaves }
	par{
		v.low  1/2 num 0 DO low_note note  low_note 12 + note loop
	}par{
		v.mid  1/4 num 2* 0 do mid_note note  12 + mid_note note loop
	}par{
		v.high  1/8 num 4 * 0 do high_note note  high_note 12 + note loop
	}par
;

: RIFF1 { bnote -- }
	0 bnote + nis
	2 bnote + nis
	3 bnote + nis
	1 bnote + nis
;

: RIFF2 { bnote -- }
	0 bnote + nis
	-1 bnote + nis
	-2 bnote + nis
	-3 bnote + nis
;
: PLAY.SCALE
	size: tr-current-key 3 * 0 DO i . i nis LOOP
;

: RIFF1.LOOP  { bnote num mult -- }
	num 0 DO bnote i mult * + riff1 LOOP
;

: RIFF2.LOOP  { bnote num mult -- }
	num 0 DO bnote i mult * + riff2 LOOP
;

: RIFF.TEST
	v.high 1/16 10 8 1 riff1.loop
	v.mid 1/16 10 8 -1 riff1.loop
	v.low 1/8 1 4 1 riff2.loop
;

: CHORDS.SET1
	tr_num_modes 0
	DO
		i tr.set.mode
		0 lookup.scale 5 lookup.scale 10 lookup.scale 2 ch.oct
	LOOP
;

: CHORDS.SET2
	tr_num_modes 0
	DO
		i tr.set.mode
		par{
			0 lookup.scale 5 lookup.scale 10 lookup.scale 2 ch.oct
		}par{
			v.fast
			1/16 12 4 1 riff2.loop
			1/16 12 4 -1 riff1.loop
		}par
	LOOP
;

: CHORDS.SET3
	tr_num_modes 0
	DO
		i tr.set.mode
		par{
			0 lookup.scale 6 lookup.scale 12 lookup.scale 2 ch.oct
		}par{
			v.fast
			1/16 8 4 1 riff1.loop
			1/16 16 4 -1 riff2.loop
		}par
	LOOP
;


: RAND.NIS  { range bnote num -- }
	num 0
	DO
		3 choose 0>
		IF
			range choose bnote + nis
		ELSE
			rest
		THEN
	LOOP
;
: RAND.RIFF
	par{
		v.low 1/6 10 0 6 rand.nis
	}par{
		v.mid 1/8 10 6 8 rand.nis
	}par{
		v.high 1/16 10 12 16 rand.nis
	}par
;

: SECTION.2
	tr_num_modes 0
	DO
		i tr.set.mode
		par{
			PERC1 c4
		}par{
			rand-seed @
			2 0
			DO
				par{ perc2 c4 c4
				}par{
					dup rand-seed !
					rand.riff
				}par
			LOOP
			drop
		}par
	LOOP
;

\ notes diverging from a center
: DIVERGE  { center  num -- }
	center nis
	num 1 >
	IF
		num 1
		DO
			par{
				center i + nis
			}par{
				center i - nis
			}par
		LOOP
	THEN
;

: SECTION.DIVERGE
	par{
		16 0
		DO
			1/16 64 choose 0 do rest loop
			20 choose 5 +  5 diverge
			}par{
		LOOP
	}par
;

: SONG1
	v.low 2 octave ! theme1
	chords.set1
	v.high section.diverge
	chords.set2
	section.2
	chords.set3
	v.mid section.diverge
	v.fast section.diverge
	v.low 2 octave ! theme1
;

cr ." Enter: playnow song1" cr


