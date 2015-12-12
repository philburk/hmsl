\ Provide MIDI based instrument.
\
\ Author: Phil Burk
\ Copyright 1986 -  Phil Burk, Larry Polansky, David Rosenboom.
\
\ MOD: PLB 3/10/87 Provide two note buffer LAST.NOTE.OFF:
\      will work with LEGATO.
\ MOD: PLB 5/24/87 Add SYS.INIT and SYS.RESET
\ MOD: PLB 6/15/87 Add DEFAULT:
\ MOD: PLB 10/7/87 Move OPEN: SUPER to after channel allocation.
\                  Use TRANSLATE: instead of INSTR.TRANSLATE
\ MOD: PLB 10/22/87 Use Circular Buffer for tracking notes.
\                  Override channel allocation if channel already set.
\ MOD: PLB 11/17/87 Added PUT.#VOICES and GET.#VOICES.
\ MOD: PLB 12/15/87 Use LIST methods to allow proper NOTE.OFF:
\                   handling. Add ALL.OFF:
\ MOD: PLB 11/8/88 Check IV-INS-#OPEN in CLOSE:
\ MOD: PLB 2/20/89 Add FIRST.NOTE.OFF: and change LAST.NOTE.OFF:
\      to work like a LIFO anstead of a FIFO.
\ MOD: PLB 3/30/89 Add channel setting to ALL.OFF: to fix note hang.
\ MOD: PLB 5/12/89 Add NOTE.ON.FOR:  for event buffering polyphony.
\ MOD: PLB 1/23/90 Moved NOTE.ON.FOR: to OB.INSTRUMENT
\ MOD: PLB 4/11/90 Moved ALL.OFF: to OB.INSTRUMENT, added
\        RAW.NOTE.ON:
\ MOD: PLB 1/3/91 Set DEFAULT.INSTRUMENT at compile time
\ MOD: PLB 9/25/91 Moved PUT.PRESET: to H:Instrument

ANEW TASK-MIDI_INSTRUMENT

\ MIDI Channel Allocator
OB.ALLOCATOR MIDI-ALLOCATOR

:CLASS OB.MIDI.INSTRUMENT <SUPER OB.INSTRUMENT
    IV.LONG IV-INS-CHANSET   ( true if channel forced, not alloc)

:M DEFAULT: ( -- )
    default: super
    36 put.offset: self    ( low C on many synths )
    1 16 put.channel.range: self  ( MIDI range )
;M

:M INIT: ( -- )
    init: super
    1 set.width: self
;M

:M PRESET: ( preset -- , change MIDI preset )
    dup 0<
    IF drop
    ELSE
        iv-ins-channel dup 0<
        IF 2drop
        ELSE midi.channel!
             midi.preset
        THEN
    THEN
;M

:M OPEN: ( -- , open instrument )
    iv-ins-channel 0<
    IF   ( allocate channel since none set )
        get.channel.range: self allocate.range: midi-allocator
        IF iv=> iv-ins-channel
        ELSE
            iv-ins-chan-lo dup iv=> iv-ins-channel
            mark: midi-allocator
        THEN
        false iv=> iv-ins-chanset
    ELSE iv-ins-#open 0=  ( only the first time opened )
        IF  iv-ins-channel mark: midi-allocator
            true iv=> iv-ins-chanset
        THEN
    THEN
    iv-ins-preset preset: self
    open: super
;M

:M RAW.NOTE.OFF: ( note velocity -- , turn off raw note )
    iv-ins-channel midi.channel!
    midi.noteoff
;M

:M RAW.NOTE.ON: ( note velocity -- , play raw note )
    iv-ins-channel midi.channel!
    midi.noteon
;M

:M CLOSE: ( -- , close channel if final close )
    iv-ins-#open 1 =  ( final close? )
    IF  all.off: self
        iv-ins-channel deallocate: midi-allocator
        iv-ins-chanset 0=
        IF  -1 iv=> iv-ins-channel
        THEN
        false iv=> iv-ins-chanset
    THEN
    close: super
;M

:M PRINT: ( -- )
    print: super
    ." #Voices       = " iv-ins-#voices . cr
;M


;CLASS

: MI.INIT ( -- , initialize MIDI instrument module )
    16 new: midi-allocator
    clear: midi-allocator
    1 put.offset: midi-allocator
    'c ob.midi.instrument is default.instrument
;

\ set default
'c ob.midi.instrument is default.instrument
    
: SYS.INIT sys.init mi.init ;
: SYS.RESET sys.reset clear: midi-allocator ;
: SYS.TERM free: midi-allocator sys.term ;
