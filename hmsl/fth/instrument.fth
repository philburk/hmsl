\ Generic Instrument which serves as the base Instrument class.
\
\ Default Interpreter also defined.
\
\ Author: Phil Burk
\ Copyright 1986 -  Phil Burk, Larry Polansky, David Rosenboom.
\
\ MOD: PLB 4/14/87 Fix velocity bug in INTERP.EXTRACT.PV
\ MOD: PLB 4/27/87 Put offset before gamut translation.
\ MOD: PLB 6/15/87 Add DEFAULT:
\ MOD: PLB 10/7/87 Add TRANSLATE:
\                  Make subclass of OB.INT
\ MOD: PLB 10/22/87 Make subclass of Circular Buffer.
\                  Add GET. and PUT.CHANNEL:
\ MOD: PLB 12/15/87 Change from OB.CIRCULAR to OB.LIST
\ MOD: PLB 11/8/88 Move FREE: in CLOSE: to OB.MIDI.INSTRUMENT
\ MOD: PLB 11/15/88 Fixed GET.CHANNEL:
\ MOD: PLB 2/20/89 Add FIRST.NOTE.OFF:
\ MOD: PLB 10/4/89 Add DEFAULT.INSTRUMENT
\ MOD: PLB 11/16/89 Add MUTE
\ MOD: PLB 3/26/90 All Interpreters moved to H:INTERPRETERS
\ MOD: PLB 4/9/91 Fix -CFAs for Clone.
\ MOD: PLB 9/25/91 Moved PUT.PRESET: from H:MIDI_INSTRUMENT

ANEW TASK-INSTRUMENT

\ Declare methods.
METHOD PUT.TUNING:
METHOD GET.TUNING:
METHOD PUT.GAMUT:
METHOD GET.GAMUT:
METHOD OPEN:
METHOD ELEMENT.ON:
METHOD ELEMENT.OFF:
METHOD CLOSE:
METHOD PUT.OPEN.FUNCTION:
METHOD PUT.ON.FUNCTION:
METHOD PUT.OFF.FUNCTION:
METHOD PUT.CLOSE.FUNCTION:
METHOD NOTE.ON:
METHOD NOTE.ON.FOR:
METHOD NOTE.OFF:
METHOD RAW.NOTE.ON:
METHOD RAW.NOTE.OFF:
METHOD FIRST.NOTE.OFF:
METHOD LAST.NOTE.OFF:
METHOD PRESET:
METHOD PUT.CHANNEL.RANGE:
METHOD GET.CHANNEL.RANGE:
METHOD PUT.CHANNEL:
METHOD GET.CHANNEL:
METHOD PUT.MUTE:
METHOD GET.MUTE:
METHOD PUT.#VOICES:
METHOD GET.#VOICES:
METHOD ALL.OFF:
METHOD PUT.PRESET:
METHOD GET.PRESET:

defer DEFAULT.ON.INTERP
'c 3drop is default.on.interp
defer DEFAULT.OFF.INTERP
'c 3drop is default.off.interp

:CLASS OB.INSTRUMENT <SUPER OB.LIST
    IV.LONG IV-INS-OFFSET
    IV.LONG IV-INS-TUNING
    IV.LONG IV-INS-GAMUT
    IV.LONG IV-INS-OPEN-CFA
    IV.LONG IV-INS-ON-CFA
    IV.LONG IV-INS-OFF-CFA
    IV.LONG IV-INS-CLOSE-CFA
    IV.LONG IV-INS-CHAN-LO
    IV.LONG IV-INS-CHAN-HI
    IV.LONG IV-INS-CHANNEL
    IV.LONG IV-INS-#OPEN     ( How many times opened.)
    IV.SHORT IV-INS-MUTE      ( if true, no Note On )
    IV.SHORT IV-INS-#VOICES   ( number voices allowed )
    IV.LONG IV-INS-PRESET

:M DEFAULT: ( -- )
    0 iv=> iv-ins-offset
    0 iv=> iv-ins-tuning
    0 iv=> iv-ins-gamut
    0 iv=> iv-ins-open-cfa
    0 iv=> iv-ins-on-cfa
    0 iv=> iv-ins-off-cfa
    0 iv=> iv-ins-close-cfa
    1 iv=> iv-ins-chan-lo
    1 iv=> iv-ins-chan-hi
    -1 iv=> iv-ins-channel
    0 iv=> iv-many
    0 iv=> iv-ins-#open
    false iv=> iv-ins-mute
    8 iv=> iv-ins-#voices
    -1 iv=> iv-ins-preset  ( default says don't change preset )
;M

:M INIT: ( -- )
    init: super
    self default: []
;M

:M PUT.TUNING: ( tuning -- )
    iv=> iv-ins-tuning
;M

:M GET.TUNING: ( -- tuning )
    iv-ins-tuning
;M

:M PUT.PRESET: ( preset -- , set preset for use when opened. )
    dup iv=> iv-ins-preset
    self preset: []
;M

:M GET.PRESET: ( -- preset , fetch preset for use when opened. )
    iv-ins-preset
;M

:M PUT.MUTE: ( flag -- , set mute flag )
    iv=> iv-ins-mute
;M

:M GET.MUTE: ( -- flag , set mute flag )
    iv-ins-mute
;M

:M PUT.GAMUT: ( gamut -- , for note index translation)
    iv=> iv-ins-gamut
;M

:M GET.GAMUT: ( -- gamut )
    iv-ins-gamut
;M

:M PUT.OFFSET: ( offset -- )
    iv=> iv-ins-offset
;M

:M GET.OFFSET: ( -- offset)
    iv-ins-offset
;M

:M PUT.CHANNEL.RANGE: ( lo hi -- )
    2sort iv=> iv-ins-chan-hi
    iv=> iv-ins-chan-lo
;M

:M GET.CHANNEL.RANGE: ( -- lo hi )
    iv-ins-chan-lo
    iv-ins-chan-hi
;M

:M PUT.CHANNEL: ( channel -- )
    iv=> iv-ins-channel
;M

:M GET.CHANNEL: ( -- channel )
    iv-ins-channel
;M

:M ELEMENT.ON: ( elmnt# shape -- )
    self iv-ins-on-cfa ?dup
    IF  -3 exec.stack?
    ELSE default.on.interp
    THEN
;M

:M ELEMENT.OFF: ( elmnt# shape -- )
    self iv-ins-off-cfa ?dup
    IF  -3 exec.stack?
    ELSE default.off.interp
    THEN
;M

:M PUT.OPEN.FUNCTION: ( cfa -- )
    iv=> iv-ins-open-cfa
;M

:M PUT.ON.FUNCTION: ( cfa -- )
    iv=> iv-ins-on-cfa
;M

:M PUT.OFF.FUNCTION: ( cfa -- )
    iv=> iv-ins-off-cfa
;M

:M PUT.CLOSE.FUNCTION: ( cfa -- )
    iv=> iv-ins-close-cfa
;M

:M TRANSLATE: ( note_index -- note )
    iv-ins-offset +
    iv-ins-gamut ?dup
    IF translate: []
    THEN
;M

:M DETRANSLATE: ( note -- note_index true | false )
    iv-ins-gamut ?dup
    IF  detranslate: []
        IF  iv-ins-offset - true
        ELSE false
        THEN
    ELSE iv-ins-offset - true
    THEN
;M

:M PUT.#VOICES: ( #voices -- , maximum voices for this instrument )
    1 max iv=> iv-ins-#voices
;M
:M GET.#VOICES: ( -- #voices )
    iv-ins-#voices
;M

:M LAST.NOTE.OFF: ( -- , turn off last note played)
    many: self
    IF  last: self 64
        self raw.note.off: []
        many: self 1- remove: self
    THEN
;M

:M FIRST.NOTE.OFF: ( -- , turn off first note played)
\ This used to be called LAST.NOTE.OFF:  by mistake.
    many: self
    IF  0 at.self 64
        self raw.note.off: []
        0 remove: self
    THEN
;M

:M ALL.OFF: ( -- , turn off all notes )
    limit: self
    IF  many: self 0
        ?DO i at.self 64
           self raw.note.off: []
        LOOP
        empty: self
    THEN
;M

:M RAW.NOTE.ON: ( note velocity -- )
    swap . . ."  ON" cr
;M

:M RAW.NOTE.OFF: ( note velocity -- )
    swap . . ."  OFF" cr
;M

:M NOTE.ON: ( note_index velocity -- )
    iv-ins-mute
    IF 2drop
    ELSE >r translate: self  dup r>  ( convert to note )
        dup
        IF many: self iv-ins-#voices =  ( Turn one off if full. )
           IF  first.note.off: self
           THEN
           self raw.note.on: []
           add: self
        ELSE self raw.note.off: []
             delete: self
        THEN
    THEN
;M

:M NOTE.OFF: ( note_index velocity -- )
    >r translate: self dup r>
    self raw.note.off: []
    delete: self
;M

:M NOTE.ON.FOR: ( note vel ontime -- )
    >r
    2dup self note.on: []
    r> vtime@ >r vtime+!  ( advance virtual timer )
    self note.off: []
    r> vtime!  ( restore virtual timer )
;M

:M OPEN: ( -- )
    1 iv+> iv-ins-#open
    limit: self iv-ins-#voices 1+ <
    IF iv-ins-#voices 1+ new: self ( allocate space for note tracking )
    THEN
    self iv-ins-open-cfa if.exec|drop
    iv-ins-mute
    IF  if-debug @
        IF  name: self ."  muted!" cr
        THEN
    THEN
;M

:M CLOSE: ( -- )
    iv-ins-#open 1- dup 0=  ( final close? )
    IF  all.off: self
        free: self
    THEN
    0 max iv=> iv-ins-#open
    self iv-ins-close-cfa if.exec|drop
;M

:M PRINT: ( -- )
    cr name: self cr
    print: super
    ." Open Function  = " iv-ins-open-cfa cfa. cr
    ." On Function    = " iv-ins-on-cfa cfa. cr
    ." Off Function   = " iv-ins-off-cfa cfa. cr
    ." Close Function = " iv-ins-close-cfa cfa. cr
    ." Channel Range  = " iv-ins-chan-lo . iv-ins-chan-hi . cr
    ." Channel        = " iv-ins-channel . cr
    ." Tuning         = " iv-ins-tuning ob.name cr
    ." Gamut          = " iv-ins-gamut ob.name cr
    ." Offset         = " iv-ins-offset . cr
    ." # Times Opened = " iv-ins-#open . cr
    ." Mute           = "
    iv-ins-mute IF ." ON!!!" ELSE ." off" THEN cr
    ." Preset        = " iv-ins-preset . cr
;M

;CLASS

defer DEFAULT.INSTRUMENT   ( use for device independant pieces )

