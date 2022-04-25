\ Play Amiga samples from the MIDI keyboard.
\
\ This is an example of using the MIDI parser to
\ play Amiga samples based on MIDI input from
\ a keyboard.  Several samples can be loaded and
\ selected based on MIDI presets.
\ The constant PS_NUM_SAMPLES is the number of
\ allowable samples.
\ You can load different samples by
\ changing the word PS.SAMPLE.INIT
\
\ You can specify new tunings by putting different
\ tuning objects in the variable PLAY-TUNING.
\
\ To play the samples, enter:  PLAY.SAMPLE
\ More instructions at the end of file.
\
\ Author: Phil Burk
\ Copyright 1987 Phil Burk, Larry Polansky, David Rosenboom
\ All Rights Reserved
\
\ MOD: PLB 4/18/88 Added preset changes to switch samples.

ANEW TASK-PLAY_SAMPLE

OB.OBJLIST PS-INSTRUMENTS   ( hold the instruments )
OB.OBJLIST PS-SAMPLES

variable PS-CHANNEL
variable PS-PRESET    ( current sample index )
variable PLAY-TUNING

\ Change these values for your site!!!!!!!!!
32 constant PS_MAX_SAMPLES  ( max number of samples available )
12 constant PS_OFFSET    ( offset for instruments )
1 ps-channel !
tuning-equal play-tuning !  ( can be switched to other tunings )

ps-channel @ ." Receiving on MIDI channel " . cr

\ Load a dynamically instantiated sample with data.
: PS.LOAD.SAMPLE   ( $filename -- , load one more sample )
    instantiate ob.sample dup add: ps-samples
    dup add: shape-holder
    2dup load: []
    put.name: []
;

: PS.SAMPLE.INIT   ( -- , instantiate list of samples )
    ps_max_samples new: ps-samples
\ Change these to load your own samples. !!!!!!!!!
    " hs:analog1" ps.load.sample
    " hs:analog2" ps.load.sample
    " hs:hiconga" ps.load.sample
    " hs:grand" ps.load.sample
    " hs:bowl" ps.load.sample
    " hs:peking" ps.load.sample
    " hs:peking_stopped" ps.load.sample
    " hs:mandocello" ps.load.sample
;


: PS.PRESET.INS  ( instrument -- , set sample in instrument )
    ps-preset @ get: ps-samples
    swap put.waveform: []
;

: PS.PRESET ( preset -- , set all instruments )
    many: ps-samples mod ps-preset !
    'c ps.preset.ins do: ps-instruments
\ Display name on screen.
    gr-curwindow @
    IF  ps-preset @ get: ps-samples get.name: []
        400 110 2 pick gr.xytext
        c@ 14 swap - 0 max 0 DO "  " gr.text LOOP
    THEN
;

: PS.PRESET.CHAN ( preset -- , check for proper MIDI channel)
    if-debug @
    IF ."  c,p = " mp.channel@ . dup . flushemit cr?
    THEN
    mp.channel@ ps-channel @ =
    IF ps.preset
    ELSE drop
    THEN
;

\ This word can be customized for special purposes.
: PS.SETUP.INS   ( instrument -- , setup for sample playing )
    play-tuning @ over put.tuning: []
    ps_offset over put.offset: []
    0 over put.envelope: []
    open: []
;

: PS.MAKEM ( -- , make 4 instruments )
    4 new: ps-instruments
    4 0
    DO instantiate ob.amiga.instrument
       add: ps-instruments
    LOOP
;

: PS.DESTROYEM ( instrument -- )
    dup close: []
    dup get.waveform: [] delete: shape-holder
    deinstantiate
;

V: PS-NEXT  ( hold index of next available instrument )

\ This uses a very simple and dumb Round Robin
\ voice allocation scheme.
: PS.PLAYNEXT  ( note velocity -- , play note with Amiga )
    ?dup
    IF  >r 36 - 0 max r>   ( move down two octaves )
        ps-next @ 1+ 3 and dup ps-next !  ( cycle through instruments )
        get: ps-instruments note.on: []
    ELSE drop
    THEN
;
: PS.PLAYNEXT.CHAN ( note velocity -- , play if on right channel)
    mp.channel@ ps-channel @ =
    IF ps.playnext
    ELSE 2drop
    THEN
;

: PS.INIT  ( -- , initialize piece )
    clear: amiga-allocator
    clear: shape-holder
    ps.sample.init
    ps.makem
    0 ps.preset
    'c ps.setup.ins do: ps-instruments
    mp.reset
    'c ps.playnext.chan mp-on-vector !
    'c ps.preset.chan mp-program-vector !
;

: PS.TERM ( -- )
    'c ps.destroyem do: ps-instruments
    free: ps-instruments
    freeall: ps-samples
    free: ps-samples
    clear: shape-holder
;

: PLAY.SAMPLE ( -- )
    ps.init
    midi.clear
\    midi.parser.on MIDI.PARSE.LOOP midi.parser.off
    midi.parser.on HMSL midi.parser.off
    ps.term
;

\ Instructions
cr
." Enter: PLAY.SAMPLE  and play MIDI keyboard to hear samples." cr cr
." Change MIDI presets to select different samples." cr
cr
." Set PLAY-TUNING for new tunings, eg. " cr
."    EG.   RATIOS-SLENDRO PLAY-TUNING !  " cr
cr

: PS.SLENDRO
    ratios-slendro play-tuning !
    play.sample
;
