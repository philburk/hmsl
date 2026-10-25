\ Tools for recording notes into shapes,
\ playback, shape conversion, player initialization, etc.
\
\ Author: Phil Burk
\ Copyright 1990 Phil Burk, Larry Polansky, David Rosenboom

\ LP hacking
\ fudged for polansky alterations...
\ used for piece DUET
\ 5/21/90
\ changed: RC.NOTE.ON  to check for RC-ECHO-ON? for echoing or not...

ANEW TASK-RECORD_LP

\ Utilities for converting one shape to another.
\ The two most common forms for storing notes in a shape are:
\    1) compressed, 1 element/note with ONTIME
\    1) expanded, 2 elements/note with zero velocity for off
\
\ These utilities will convert between them.
\ The times are considered to be in ABSOLUTE form
\ which means relative to the beginning of the shape,
\ as opposed to RELATIVE to the previous event.

: SH.ATLEAST  { #elements #dim shape -- , for dim, at least }
    shape dimension: []  #dim = not
    shape max.elements: [] #elements < OR
    IF #elements #dim shape new: []
    THEN
;

: SH.COMPRESS.NOTES  ( source target -- , extract expanded notes )
    { source target | time note vel ontime -- , locals }
\ Assume times are absolute, sorted.
\ Setup target shape
    source many: [] 2/ 8 +  4  target sh.atleast
    target empty: []
\
\ check source
    source dimension: [] 3 -
    abort" SH.COMPRESS - Source must have 3 dimensions."
\
\ Loop through all notes in source
    source many: []  0
    DO  i source get: []  -> vel -> note -> time
\ When we find an ON, look for corresponding OFF
        vel 0>
        IF  0 -> ontime
\ Loop through remaining notes
            source many: []  i 1+
            DO  i source get: []  0=  ( OFF event ? )
                IF note =  ( matching note? )
                    IF ( -- time_of_off )
                        time - -> ontime LEAVE
                    ELSE drop
                    THEN
                ELSE 2drop
                THEN
            LOOP
            ontime 0= 
            IF  ." SH.COMPRESS - Missing OFF event." cr
                1 -> ontime
            THEN
\ Add note to target shape
            time note vel ontime target add: []
        THEN
    LOOP
;

: SH.EXPAND.NOTES ( source target -- , expand notes into two )
    { source target | time note vel ontime -- , locals }
\ Make room in target.
    source many: [] 2*  3 target sh.atleast
\
\ Loop throught source notes.
    source many: [] 0
    DO  i source get: [] -> ontime -> vel -> note -> time
\ Insert ON event
        time note vel ( values for target shape ON event )
        time 0 target search.back: []  ( find spot )
        target insert: []
\ Insert OFF event
        time ontime + note 0 ( values for target shape ON event )
        time ontime +  0 target search.back: []  ( find spot )
        target insert: []
    LOOP
;

\ Recording Tools for MIDI Parser -----------------------------

variable RC-START-TIME    ( time recording started )
variable RC-STOP-TIME     ( time recording stopped )
variable RC-TARGET-SHAPE  ( hold shape currently being recorded )
variable RC-TARGET-INSTR  ( instrument to echo on, holds interpreters )
\ this next variable added to see if echo wanted or not... lp 5/21/90
variable RC-ECHO-ON?
\ added to echo on a current midi channel, but not necessarily
\ record on that channel...
variable rc-curr-channel
1 rc-curr-channel ! \ start it at 1

\ MIDI Parser Functions for recording.
: RC.ADD.NOTE.ON ( note velocity -- , add note to shape )
\ Check to see if shape is full, extend if it is.
    rc-target-shape @ ensure.room
\
\ Save note in shape using "absolute time" not durations.
    midi.rtc.time@
    rc-start-time @ - 0 max ( calc relative time )
    -rot rc-target-shape @ add: []  ( add individual on/off event )
;

\ lp hack 5/21/90
: RC.NOTE.ON ( note velocity -- , for MIDI Parser )
    midi.rtc.time@ vtime!
\
\ Echo to synthesizer using interpreter if instrument set
    rc-target-instr @
    IF  rc.add.note.on
        rc-target-shape @ dup many: [] 1- swap  ( elmnt# shape )
        rc-target-instr @ element.on: [] ( just use ON when recording )
\ lp hack this next line...
    ELSE 
	\ echos on whatever channel rc-curr-channel is set for
	rc-echo-on? @
		IF
			midi-channel @ >r
			rc-curr-channel @ midi.channel!
		 	2dup midi.noteon   ( lp hack... )
			r> midi.channel!
		THEN
	        rc.add.note.on
    THEN
;

: RC.NOTE.OFF ( note velocity -- , force velocity to zero )
    drop 0 rc.note.on
;


: RC.NOTE.WAIT  ( note velocity -- , start recording on first note )
    midi.rtc.time@ rc-start-time !
    rc.note.on
    'c rc.note.on mp-on-vector !
    'c rc.note.off mp-off-vector !
;

: RECORD.START ( time shape -- , Set MIDI parser )
    rc-target-shape !
    rc-start-time !
    'c rc.note.on mp-on-vector !
    'c rc.note.off mp-off-vector !
    midi.parser.on
;

: RECORD.WAIT ( shape -- , start recording when first note played )
    rc-target-shape !
    'c rc.note.wait mp-on-vector !
    'c 2drop mp-off-vector !
    midi.parser.on
;

: RECORD.STOP ( time -- , stop recording )
    rc-stop-time !
    'c 2drop mp-on-vector !
    'c 2drop mp-off-vector !
;

: PLAY.EXPANDED  ( player -- , setup for playing back recorded shape )
    dup play.only.on: []
    dup use.absolute.time: []
    get.instrument: [] dup use.standard.interp
    0 swap put.offset: []
;

: EXTRACT.RECORDING  { player | shape -- , copy to other shape for playback }
    player many: [] 1 =
    IF  0 player get: [] -> shape
\ Copy notes from recorded shape
        rc-target-shape @  shape sh.compress.notes
\ Convert times to "relative"
        rc-stop-time @ rc-start-time @ -
            0 shape differentiate: []
\ Setup player
        3 player put.on.dim: []
        player play.only.on: []
        'c interp.el.on.for
          player get.instrument: [] ?dup
          IF put.on.function: []
          ELSE drop >newline
              ." EXTRACT.RECORDING - Player must have instrument!" cr
          THEN
    ELSE >newline ." EXTRACT.RECORDING - Player must have shape!" cr
    THEN
;
    
\ Test Recording tools
if-testing @ .IF
ob.shape rc-shape
ob.shape target-shape
ob.player rc-pl
ob.midi.instrument rc-ins
\ for straight playback
ob.player rc-pl-x
ob.midi.instrument rc-ins-x

: PLAY.STRAIGHT
    rc-shape rc-ins-x build: rc-pl-x
    rc-pl-x play.expanded
    0 put.offset: rc-ins-x
;

: TEST.RECORD  ( -- )
    32 3 new: rc-shape
    rc-shape record.wait
    ." Record until key hit" cr
    forbid()
    midi.clear
    midi.parse.loop
    permit()
    rtc.time@ record.stop
;

: TEST.PLAYBACK ( -- )
    target-shape rc-ins build: rc-pl
    rc-pl extract.recording
    0 put.offset: rc-ins
    rc-pl hmsl.play
;

: RC.TEST.TERM
    free: rc-shape
    free: rc-pl
    free: target-shape
    mp.reset
;
.THEN

