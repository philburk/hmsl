\ An Amiga instrument adds envelopes, and  waveforms to the
\ original class.
\
\ Author: Phil Burk
\ Copyright 1986 - David Rosenboom, Larry Polansky, Phil Burk.
\
\ MOD: PLB 11/21/86 Added LOUDNESS to sampled instruments.
\      Added NOTE.ON: & NOTE.OFF:
\ MOD: PLB 3/2/87 Translate note index.
\ MOD: PLB 3/6/87 Allow "VELOCITY" range of 0-127 like MIDI.
\ MOD: PLB 5/24/87 Add channel allocation. Remove VOICE#
\ MOD: PLB 6/15/87 Add DEFAULT:
\ MOD: PLB 1/23/90 Add ALL.OFF:
\ MOD: PLB 3/14/90 Fix AI.TERM missing ;
\ 00001 PLB 11/12/91 Remove error from double open.

ANEW TASK-AMIGA_INSTRUMENT

\ Amiga Channel Allocator
OB.ALLOCATOR AMIGA-ALLOCATOR

METHOD PUT.ENVELOPE:
METHOD GET.ENVELOPE:
METHOD PUT.WAVEFORM:
METHOD GET.WAVEFORM:
METHOD PUT.LOUDNESS:
METHOD GET.LOUDNESS:
METHOD SET.NOTE:

:CLASS OB.AMIGA.INSTRUMENT <SUPER OB.INSTRUMENT
    IV.LONG IV-INS-ENVELOPE
    IV.LONG IV-INS-WAVEFORM
    IV.LONG IV-INS-LOUDNESS

:M DEFAULT:
    default: super
    env-bang iv=> iv-ins-envelope
    ratios-slendro iv=> iv-ins-tuning
    wave-sawtooth iv=> iv-ins-waveform
    0 3 put.channel.range: self
    -1 iv=> iv-ins-channel
    64 iv=> iv-ins-loudness
;M

:M PUT.ENVELOPE:   ( envelope_obj -- , set envelope object )
    iv=> iv-ins-envelope
;M
:M GET.ENVELOPE:   ( -- envelope_obj  , get envelope object )
    iv-ins-envelope 
;M

:M PUT.WAVEFORM:   ( envelope_obj -- , set envelope object )
    iv=> iv-ins-waveform
;M
:M GET.WAVEFORM:   ( -- envelope_obj  , get envelope object )
    iv-ins-waveform 
;M

: INS.WAVE.CHANNEL  ( -- , set channel to waveform channel )
    iv-ins-channel
    iv-ins-envelope
    IF
        2* 1+
    THEN
    da.channel!
;
: INS.MOD.CHANNEL
    iv-ins-channel 2*  da.channel!
;

:M PUT.PERIOD:  ( period -- , set ticks between values )
    ins.wave.channel
    iv-ins-waveform set.period: []  ( calculate which octave too )
;M
:M GET.PERIOD:  ( -- period , get ticks between values )
    iv-ins-waveform get.period: []
;M

:M PUT.LOUDNESS:  ( loudness -- , volume of note )
    64 min ( for AMIGA )
    dup iv=> iv-ins-loudness
    ins.wave.channel da.loudness!
;M
:M GET.LOUDNESS:  ( -- loudness , volume of note )
    iv-ins-loudness
;M

:M SET.NOTE: ( note_index -- , set period for a given note )
    translate: self
    get.tuning: self translate: []
    put.period: self
;M

: AI.ALLOC.CHAN ( -- allocate one or more channels )
    iv-ins-channel -1 >
    IF \ " OPEN: OB.AMIGA.INSTRUMENT" " Already OPEN: !" \ 00001
       \ er_return ob.report.error
    ELSE
        get.envelope: self
        IF  2 get.channel.range: self
            allocate.block.range: amiga-allocator
        ELSE
            get.channel.range: self
            allocate.range: amiga-allocator
        THEN
        IF iv=> iv-ins-channel
        ELSE " OPEN: OB.AMIGA.INSTRUMENT" " No available channel(s)!"
             er_return ob.report.error
             iv-ins-chan-lo iv=> iv-ins-channel
        THEN
    THEN
;

:M OPEN:  ( -- , Configure audio channels. )
    open: super
    ai.alloc.chan
    200 put.period: self
    da.stop
    0 da.freqmod!
\ Act differently when no envelopes.
    get.waveform: self   use: []
    get.envelope: self
    IF  0 da.loudness!
        ins.mod.channel  ( set first channel to modulate second )
        1 da.ampmod!
        0 da.freqmod!
    ELSE
        iv-ins-loudness da.loudness!
        0 da.ampmod!
    THEN
;M


:M CLOSE: ( -- )
    close: super
    iv-ins-channel dup 0<
    IF  drop  ( already closed, big deal )
    ELSE 
        get.envelope: self
        IF 2 deallocate.block: amiga-allocator
        ELSE  deallocate: amiga-allocator
        THEN
        -1 iv=> iv-ins-channel
    THEN
;M

     
:M START: ( -- , START playing a particular note )
    ins.wave.channel
    iv-ins-waveform start: []
    iv-ins-envelope ?dup
    IF  ins.mod.channel   ( set first channel to modulate second )
        start: []
    ELSE
        iv-ins-loudness da.loudness!
    THEN
;M

:M FINISH: ( -- , FINISH playing a particular note )
    get.envelope: self ?dup
    IF  \ Let envelope "finish" waveform.
        ins.mod.channel
        finish: []
    ELSE
        ins.wave.channel
        get.waveform: self finish: []
    THEN
;M

:M RAW.NOTE.OFF: ( note velocity -- , turn note off )
    2drop
    finish: self
;M

:M RAW.NOTE.ON: ( note velocity -- , turn note on , like MIDI )
    2/ 64 min iv=> iv-ins-loudness
    get.tuning: self translate: []
    put.period: self
    start: self
;M

:M LAST.NOTE.OFF: ( -- , turn last note off )
    self finish: []
;M

:M FIRST.NOTE.OFF: ( -- , turn first note off )
    self finish: []  ( currently monophonic so same as last )
;M

:M ALL.OFF: ( -- )
    self finish: []
;M

:M PRINT: ( -- )
    print: super
    ." Loudness = " iv-ins-loudness . CR
    ." Waveform = " iv-ins-waveform ob.name CR
    ." Envelope = " iv-ins-envelope ob.name CR
;M

;CLASS


: AI.INIT ( -- , initialize AMIGA instrument module )
    " AI.INIT" debug.type
    4 new: amiga-allocator
    clear: amiga-allocator
;
: AI.TERM ( -- )
  " AI.TERM"  debug.type
  free: amiga-allocator
;

: SYS.INIT sys.init ai.init ;
: SYS.RESET sys.reset clear: amiga-allocator ;
: SYS.TERM ai.term sys.term ;
