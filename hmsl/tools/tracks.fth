\ Record several MIDI channels as different tracks.
\ Similar to a multitrack recorder.
\
\ Author: Phil Burk
\ Copyright 1987 Phil Burk, Larry Polansky, David Rosenboom
\ All Rights Reserved.
\
\ 00001 PLB 9/20/91 Default to sequential tracks if no SEQ# metaevent.

include? task-midifile ht:midifile
include? shapei{ ht:score_entry
decimal

ANEW TASK-TRACKS

\ MultiTrack Recording Support
OB.COLLECTION ALL-TRACKS   \ Hold all tracks

: TRACK.PLAYER ( track# -- player , get player from )
    dup 1 < abort" TRACK.PLAYER - numberring starts at 1 !!"
    1- get: all-tracks
;
: TRACK.SHAPE ( track# -- shape , get shape from )
    track.player 0 swap get: []
;
: TRACK.INSTR ( track# -- instrument , get instrument from )
    track.player get.instrument: []
;

: RECORD.TRACK.START { time track | shape -- , start recording }
    track track.shape dup -> shape
    max.elements: [] 100 <
    IF 64 3 shape new: []  ( allocate initial space for shape )
    ELSE shape clear: []
    THEN
    shape dimension: [] 3 < abort" RECORD.SHAPE - Dimensions < 3 !!"
    track track.instr dup rc-instr ! open: []
    midi.clear
    time shape record.start
;

: RECORD.TRACK.STOP ( -- )
    rtc.time@ record.stop
    rc-instr @ ?dup
    IF  close: []
        rc-instr off
    THEN
;


\ Metronome player.
OB.SHAPE SHAPE-METRO
OB.PLAYER PLAYER-METRO
OB.MIDI.INSTRUMENT INS-METRO

variable METRO-NOTE

: METRO.SETUP ( -- , setup shape for given signature )
    timesig-numer @ 1 32 clipto 3 new: shape-metro
    ticks/beat @ metro-note @ 36 89 clipto   64
        add: shape-metro
    timesig-numer @ 1- 0 32 clipto   0
    DO  ticks/beat @  metro-note @ 36 98 clipto
        32 add: shape-metro
    LOOP
;

: METRO.INIT  ( -- )
    60 metro-note !
    4 timesig-numer !
    4 timesig-denom !
    metro.setup
    0 shape-metro 0stuff: player-metro
    ins-metro put.instrument: player-metro
    8 put.channel: ins-metro
    0 put.offset: ins-metro
    10000 put.repeat: player-metro
;

: METRO.TERM
    free.hierarchy: player-metro
;

if.forgotten metro.term

\ ----------------------------------------------------

16 constant RC_MAX_TRACKS

\ Declare 16 Shapes for Sequencer
OB.SHAPE SQSH-1
OB.SHAPE SQSH-2
OB.SHAPE SQSH-3
OB.SHAPE SQSH-4
OB.SHAPE SQSH-5
OB.SHAPE SQSH-6
OB.SHAPE SQSH-7
OB.SHAPE SQSH-8
OB.SHAPE SQSH-9
OB.SHAPE SQSH-10
OB.SHAPE SQSH-11
OB.SHAPE SQSH-12
OB.SHAPE SQSH-13
OB.SHAPE SQSH-14
OB.SHAPE SQSH-15
OB.SHAPE SQSH-16

\ Declare 16 Players for Sequencer
OB.PLAYER SQPL-1
OB.PLAYER SQPL-2
OB.PLAYER SQPL-3
OB.PLAYER SQPL-4
OB.PLAYER SQPL-5
OB.PLAYER SQPL-6
OB.PLAYER SQPL-7
OB.PLAYER SQPL-8
OB.PLAYER SQPL-9
OB.PLAYER SQPL-10
OB.PLAYER SQPL-11
OB.PLAYER SQPL-12
OB.PLAYER SQPL-13
OB.PLAYER SQPL-14
OB.PLAYER SQPL-15
OB.PLAYER SQPL-16

\ Declare 16 Instruments for Sequencer
OB.MIDI.INSTRUMENT SQINS-1
OB.MIDI.INSTRUMENT SQINS-2
OB.MIDI.INSTRUMENT SQINS-3
OB.MIDI.INSTRUMENT SQINS-4
OB.MIDI.INSTRUMENT SQINS-5
OB.MIDI.INSTRUMENT SQINS-6
OB.MIDI.INSTRUMENT SQINS-7
OB.MIDI.INSTRUMENT SQINS-8
OB.MIDI.INSTRUMENT SQINS-9
OB.MIDI.INSTRUMENT SQINS-10
OB.MIDI.INSTRUMENT SQINS-11
OB.MIDI.INSTRUMENT SQINS-12
OB.MIDI.INSTRUMENT SQINS-13
OB.MIDI.INSTRUMENT SQINS-14
OB.MIDI.INSTRUMENT SQINS-15
OB.MIDI.INSTRUMENT SQINS-16

: TRACKS.INIT { | player instr shape -- }
\ Connect Players, Shapes and Instruments
    0 SQPL-1 SQPL-2 SQPL-3 SQPL-4
      SQPL-5 SQPL-6 SQPL-7 SQPL-8
      SQPL-9 SQPL-10 SQPL-11 SQPL-12
      SQPL-13 SQPL-14 SQPL-15 SQPL-16
    0stuff: all-tracks
\
    sqsh-1 sqins-1 build: sqpl-1
    sqsh-2 sqins-2 build: sqpl-2
    sqsh-3 sqins-3 build: sqpl-3
    sqsh-4 sqins-4 build: sqpl-4
    sqsh-5 sqins-5 build: sqpl-5
    sqsh-6 sqins-6 build: sqpl-6
    sqsh-7 sqins-7 build: sqpl-7
    sqsh-8 sqins-8 build: sqpl-8
    sqsh-9 sqins-9 build: sqpl-9
    sqsh-10 sqins-10 build: sqpl-10
    sqsh-11 sqins-11 build: sqpl-11
    sqsh-12 sqins-12 build: sqpl-12
    sqsh-13 sqins-13 build: sqpl-13
    sqsh-14 sqins-14 build: sqpl-14
    sqsh-15 sqins-15 build: sqpl-15
    sqsh-16 sqins-16 build: sqpl-16
\
    rc_max_tracks 0
    DO i get: all-tracks -> player
       player get.instrument: [] -> instr ( -- p i )
       i 1+ instr put.channel: []  ( set MIDI range )
       player setup.exp.playback
\
       0 player get: [] -> shape
       shape free: []
       2 shape set.width: []
    LOOP
;

exists? OB.AMIGA.INSTRUMENT
.IF
: RECORD.AMIGA.TRACKS  ( -- , setup 4 amiga tracks on 13-16 )
    ins-amiga-4 ins-amiga-3 ins-amiga-2 ins-amiga-1
    4 0
    DO  -36 over put.offset: []   ( lower to MIDI levels )
        tuning-equal over put.tuning: []  ( how boring )
        dup use.poly.interp ( for separate notes off )
        i 13 + track.player put.instrument: []
    LOOP
    ." Record AMIGA voices on tracks 13-16" cr
;
.THEN

: TRACKS.TERM  ( free all objects )
    free.hierarchy: all-tracks
    free: all-tracks
;

if.forgotten tracks.term


\ MIDIFile Support for Tracks ------------------------------------
: MF.WRITE.SHAPES  ( objlist $filename -- , write all shapes in list )
    new $mf.open
\ Format 1 file, many+1 tracks
    1 over many: [] 1+ rtc.rate@ mf.write.header
    mf.begin.track
    4 2 ticks/beat @ 8 mf.write.timesig
    rtc.rate@ rate->mics/beat mf.write.tempo
    mf.end.track
    dup many: [] 0
    DO mf.begin.track  ( -- objlist pos )
        over i get: []   mf.write.abs.shape
       mf.end.track
    LOOP
;

: COUNT.USED.TRACKS  ( -- N )
    0 rc_max_tracks 0
    DO i 1+ track.shape many: [] 0>
        IF 1+
        THEN
    LOOP
;

: (SAVE.TRACKS)  ( -- , write tracks with data to metafile )
\ Format 1 file, many+1 tracks
    1  count.used.tracks 1+  ticks/beat @ mf.write.header
\
\ write tempo and time signature
    mf.begin.track
    timesig-numer @ timesig-denom @ logbase2
    ticks/beat @ 8 mf.write.timesig
    rtc.rate@ rate->mics/beat mf.write.tempo
    mf.end.track
\
\ Write each track with sequence number
    rc_max_tracks 1+ 1
    DO i track.shape many: [] 0>
       IF mf.begin.track  ( -- pos )
          i mf.write.seq#
          i track.shape mf.write.abs.shape
          mf.end.track
       THEN
    LOOP
    mf.close
;

: SAVE.TRACKS  ( fileptr -- , write tracks with data to metafile )
    mf.set.file  (save.tracks)
;

: $SAVE.TRACKS  ( $filename -- , write tracks with data to metafile )
    new $mf.open  (save.tracks)
;

: LOAD.TRACK  ( size track# -- )
    1 mf-sequence# +! \ 00001
    mf.load.track
    mf-sequence# @ 1 rc_max_tracks within?
    IF mf-sequence# @ track.shape clone: mf-shape
    THEN
;

: LOAD.TRACKS  ( fileptr -- , load tracks into shapes )
    0 mf-sequence# ! \ 00001
    what's mf.process.track
    'c load.track is mf.process.track
    swap mf.set.file (mf.dofile)
    is mf.process.track
;

: $LOAD.TRACKS  ( $filename -- , load tracks into shapes )
    what's mf.process.track
    'c load.track is mf.process.track
    swap $mf.dofile
    is mf.process.track
;


\ Use Score Entry System to load a track
variable TRACK-CUR
: TRACK{  ( track# -- , load shape in track )
    track-cur !
    200 4 new: mf-shape
    mf-shape track-cur @ track.instr shapei{
;

: }TRACK (  -- , convert to absolute expanded )
    }instr  \ leave shape times in absolute form
    mf-shape track-cur @ track.shape
    dup empty: []
    sh.expand.notes
\ adjust stop and repeat delay to fill out time
\ after last note off
    ns.elapsed
    track-cur @ track.shape dup many: [] 1- 0 max
    0 rot ed.at: [] -  ( time_gap )
    track-cur @ track.player
    2dup put.repeat.delay: []
    put.stop.delay: []
;

