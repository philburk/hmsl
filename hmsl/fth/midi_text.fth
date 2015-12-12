\ Utility for converting MIDI note numbers <> text
\
\ Author: Phil Burk
\ Copyright 1991 Phil Burk
\ 00001 PLB 2/16/92 Add more room to M>T-PAD for $APPEND, remove $ROM

include? { ju:locals

ANEW TASK-MIDI_TEXT

$ROM $NOTES-TEXT
	," C"  ," C#" ," D"  ," D#"
	," E"  ," F"  ," F#" ," G"
	," G#" ," A"  ," A#" ," B"

variable M>T-PAD 4 allot \ room for 8 characters \ 00001

: MIDI>$ ( note -- $text )
	12 /mod ( note octave )
	1- 0 max ( start at note 12 for octave = 0 )
	swap $notes-text ( -- octave $note )
	m>t-pad $move
	n>text m>t-pad $append  \ append octave number
	m>t-pad
;

create NOTE-OFFSETS
  9 c, ( A )
 11 c, ( B )
  0 c, ( C )
  2 c, ( D )
  4 c, ( E )
  5 c, ( F )
  7 c, ( G )
align

: $>MIDI { $text | addr indx num note ok? -- note true | false }
	0 -> ok?
\ false if bad
	$text count -> num -> addr
	-1 -> note
	0 -> indx
\
\ check for note A-G
	addr indx + c@ tolower ascii a -
	dup 0 7 within?
	IF
		note-offsets + c@ -> note
		indx 1+ -> indx
	ELSE
		drop  \ bad note
	THEN
\
\ check for sharps and flats
	indx 0>
	IF
		addr indx + c@ ascii # =
		IF
			note 1+ -> note
			indx 1+ -> indx
		THEN
		addr indx + c@ ascii b =
		IF
			note 1- -> note
			indx 1+ -> indx
		THEN
	THEN
\
	indx 0>
	IF
		addr indx + c@ dup isdigit
		IF
			ascii 0 - 1+ 12 *  \ calculate octave offset
			note + -> note
			indx 1+ -> indx
		ELSE drop
		THEN
		indx num = -> ok?
	THEN
\
\ return parameters
	note 127 <
	ok? AND
	IF
		note true
	ELSE
		false
	THEN
;

