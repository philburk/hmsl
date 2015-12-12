\ MIDI Stubs
\ These are used when MIDI is not loaded and we want to
\ load the rest of the system without too much trouble.

ANEW TASK-MIDI_STUBS

: NO.MIDI  ( -- , report no MIDI )
    >newline ." MIDI Support is not loaded!" cr
;

: MIDI.NOTEON 2drop no.midi ;
: MIDI.NOTEOFF 2drop no.midi ;
: MIDI.PRESET drop no.midi ;

: MIDI.PARSER.ON no.midi ;
: MIDI.PARSER.OFF no.midi ;
: MP.RESET no.midi ;

variable MIDI-PARSER
: MIDI.PARSE.MANY ;

: EB.ON ;
