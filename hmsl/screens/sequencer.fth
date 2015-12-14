\ Control Multi Track Recorder with grids.
\ This provides a simple sequencer
\
\ Author: Phil Burk
\ Copyright 1989 Phil Burk
\ All Rights Reserved
\
\ MOD: PLB 10/3/90 Add Monitoring
\ MOD: PLB 1/25/91 Add GET.FILE from ARP
\ 00001 PLB 9/20/91 Set File Creator and TYPE for Mac
\       Use DIALOG.GET.FILE and PUT
\ MOD: PLB Moved $ROM to system.

false .IF  \ things to do!
    Display notes recorded as they come in periodically
    Fast Forward and reverse, etc. in Players,
        handle repeats
    Resolve to measure
    Copy track to track
    Maybe use separate screen for track editing
.THEN

host=amiga .IF
include? get.file hh:arpFileRequest.f
.THEN

include? shapei{ ht:Score_Entry
include? capture{ ht:MIDIFile
include? track.shape ht:Tracks

ANEW TASK-SEQUENCER

decimal
OB.COLLECTION TRACKS-TO-PLAY

rc_max_tracks constant RG_NUM_TRACKS

\ Declare Control Grids for Sequencer
OB.RADIO.GRID SEQ-MODE
OB.MENU.GRID  SEQ-MENU
OB.CHECK.GRID SEQ-PLAY
OB.RADIO.GRID SEQ-RECORD
OB.RADIO.GRID SEQ-SELECT
OB.CHECK.GRID SEQ-OPTIONS
OB.CHECK.GRID SEQ-PAUSE
OB.NUMERIC.GRID SEQ-CG-RATES
OB.NUMERIC.GRID SEQ-CG-TIMES
OB.NUMERIC.GRID SEQ-METRO
OB.NUMERIC.GRID SEQ-TR-VALUES
OB.NUMERIC.GRID SEQ-TR-DELAYS

\
\ Declare a screen to hold them.
OB.SCREEN     seq-SCREEN

\ Variables used by RG
variable seq-RECORD-TRACK# ( track 1-N )
variable seq-ACCOMPANY     ( Holds any morphs to use with tracks. )
variable seq-IF-METRO      ( true if metronome used )
variable seq-IF-PAUSED
variable seq-SELECTED      ( currently selected track )
variable seq-COUNTIN       ( true if we should do a countin )
variable SEQ-TIME-START    ( virtual time of start )

seq-countin off

defer SEQ.USER.START
defer SEQ.USER.STOP

: $seq.MSG ( $string -- )
    0 gr.color! 1000 0 4000 240 scg.rect
    3 gr.color! 1000 200 scg.move gr.text
;

\ Operations on selected Track -------------------------

TEXTROM TRDEL-LABELS  ," Start" ," Repeat"  ," Stop"

: seq.TRVAL.FUNC ( value part -- )
    CASE
      0 OF seq-selected @ track.player put.repeat: []  ENDOF
      1 OF seq-selected @ track.instr
           put.channel: []  ENDOF
      2 OF seq-selected @ track.instr put.offset: []  ENDOF
      3 OF seq-selected @ track.instr preset: []  ENDOF
    ENDCASE
;

: seq.TRDEL.FUNC ( value part -- )
    CASE
      0 OF seq-selected @ track.player put.start.delay: []  ENDOF
      1 OF seq-selected @ track.player put.repeat.delay: []  ENDOF
      2 OF seq-selected @ track.player put.stop.delay: []  ENDOF
    ENDCASE
;

: seq.UPDATE.TRVALS  ( track# -- , update values for track )
    dup track.player get.repeat: [] 0 put.value: seq-tr-values
    dup track.instr get.channel: [] 1 put.value: seq-tr-values
    dup track.instr get.offset: []  2 put.value: seq-tr-values
    dup track.instr get.preset: []  3 put.value: seq-tr-values
    dup track.player get.start.delay: []  0 put.value: seq-tr-delays
    dup track.player get.repeat.delay: [] 1 put.value: seq-tr-delays
        track.player get.stop.delay: []   2 put.value: seq-tr-delays
;

: seq.RECORD.func ( value part -- , Set record channel )
    nip dup 1+ seq-record-track# !
    0 swap put.value: seq-play
;

: seq.SELECT.func ( value part -- , Select a track )
    nip 1+ dup seq-selected !
    seq.update.trvals draw: seq-tr-values  draw: seq-tr-delays
\
\ display how many events
    seq-selected @ track.shape many: []
    2000 4000 scg.move gr.number
;

\ Action for Play Track ------------------------------
: seq.RECORD.OFF ( part -- )
    0 swap put.value: seq-record
    -1 seq-record-track# !
;

: seq.PLAY.FUNC   ( value part -- , Turn off record if on. )
    nip
    dup get.value: seq-record
    IF seq.record.off
    ELSE drop
    THEN
;

: seq.ENABLE.ROWS ( flag -- , enable or disable rows )
    rg_num_tracks 0
    DO  dup i put.enable: seq-record
        dup  i 1+ track.shape many: [] 0> and
            i put.enable: seq-play
    LOOP drop
;

: }TRACK  ( -- , enable tracks loaded )
    }track
    true seq.enable.rows
;

\ Control Menu Functions: ------------------------------
\   Start = Start Recording or Playing the indicated tracks.
\   Stop  = Stop Recording or Playing.

: seq.METRO.REPF  ( player -- )
    get.repetition: [] dup 1 =
    IF drop " CountIn 1" $seq.msg
    ELSE 2 =
        IF " Begin" $seq.msg
        THEN
    THEN
;

: SEQ.CUR.TIME  ( -- time )
    0 get.value: seq-cg-times
;

: seq.START ( -- )
\ Restart clock if paused
    seq-if-paused @
    IF rtc.start seq-if-paused off
    THEN
\
\ Disable rows.
    false seq.enable.rows
    draw: seq-play
    draw: seq-record
    false 1 put.enable: seq-tr-values
\
\ COllect tracks to be played.
    clear: tracks-to-play
    rg_num_tracks 0
    DO  i get.value: seq-play
        IF  i get: all-tracks  ( player )
            seq.cur.time ?dup
            IF over set.timer: []
            THEN
            add: tracks-to-play
        THEN
    LOOP
\
\ Add accompaniment tracks if any.
    seq-accompany @ ?dup
    IF add: tracks-to-play
    THEN
\
\ Get time for following stuff.
    time@
    dup seq.cur.time - seq-time-start !

\ Add metronome if selected.
    seq-if-metro @
    IF metro.setup
       seq-countin @
       IF 'c seq.metro.repf " CountIn 2" $seq.MSG
       ELSE 'c drop  " Begin" $seq.MSG
       THEN  put.repeat.function: player-metro
       seq.cur.time ?dup
       IF set.timer: player-metro
       THEN
       dup 0 execute: player-metro  ( start this now )
    ELSE " Begin" $seq.MSG
    THEN
\
\ Offset other tracks if countin active
    seq-countin @
    IF ticks/beat @ timesig-numer @ *  +
    THEN
\
\ Is any track being recorded this time.
    seq-record-track# @ 0>
    IF  dup seq-record-track# @ record.track.start
    THEN
    dup 0 execute: tracks-to-play
    seq.user.start
;

: SEQ.NOTE.ON  ( note vel -- , used for monitoring when not recording )
    seq-record-track# @ dup 0>
    IF  track.instr get.channel: [] midi.channel!
        midi.noteon
    ELSE drop 2drop
    THEN
;

: SEQ.NOTE.OFF  ( note vel -- )
    seq-record-track# @ dup 0>
    IF  track.instr get.channel: [] midi.channel!
        midi.noteoff
    ELSE drop 2drop
    THEN
;

: SEQ.PRESET  ( preset -- )
    seq-record-track# @ dup 0>
    IF  track.instr dup>r get.channel: [] midi.channel!
        dup midi.preset
        r> put.preset: []
    ELSE 2drop
    THEN
;

: SEQ.MONITOR  ( -- )
    'c seq.note.on mp-on-vector !
    'c seq.note.off mp-off-vector !
    'c seq.preset mp-program-vector !
    midi.parser.on
;

: SEQ.SHOW.TIME  ( -- )
    draw: seq-cg-times
;

: SEQ.LONGEST.TRACK  { | player longest accum -- time , of longest track }
    100 -> longest
    rg_num_tracks 1+ 1
    DO  i track.shape dup many: [] ?dup
        IF  1-  0 rot ed.at: [] -> accum
            i track.player -> player
            player get.repeat.delay: [] accum + -> accum
            player get.repeat: [] accum * -> accum
            player get.start.delay: [] accum + -> accum
            accum longest max -> longest
        ELSE drop
        THEN
    LOOP
    longest
;

: seq.STOP ( -- )
    seq-if-paused @
    IF rtc.start seq-if-paused off
    THEN
\ reset piece relative time
    rtc.time@ seq-time-start @ -
        0 put.value: seq-cg-times seq.show.time
    seq.longest.track 0 put.max: seq-cg-times
\
    stop: tracks-to-play
    stop: player-metro
    seq-record-track# @ dup 0>
    IF  mp.reset
        dup track.shape many: []
            swap 1- put.value: seq-play
        seq-record-track# @ 1- seq.record.off
    ELSE drop
    THEN
    record.track.stop
\
    true seq.enable.rows
    draw: seq-play
    draw: seq-record
    true 1 put.enable: seq-tr-values
\
    seq.monitor
;

variable SEQ-LAST-MODE

: SEQ.MODE.STOP ( -- )
    seq-last-mode @ 1 =
    IF seq.stop
    THEN
    0 seq-last-mode !
;

: seq.MODE.FUNC  ( value part -- )
    nip
    CASE
        0 OF seq.mode.stop
        ENDOF
        1 OF seq-last-mode @ 0=
            IF seq.start
            THEN
            1 seq-last-mode !
        ENDOF
        2 OF seq.mode.stop
            true 0 put.value: seq-mode
            0 0 put.value: seq-cg-times
            seq.show.time
        ENDOF
        ." Unknown Mode!" cr
    ENDCASE
;

\ ----------------------------------------------
\ Time Control Grids

TEXTROM TIMER-LABELS ," Ticks/Sec" ," Ticks/Beat"

: seq.RATES.FUNC  ( value part -- , change TIME stuff )
    CASE
        0 OF rtc.rate! ( now see what real rate is )
             rtc.rate@ 0 put.value: seq-cg-rates ENDOF
        1 OF ticks/beat ! ENDOF
    ENDCASE
;

TEXTROM METRO-LABELS ," Channel" ," Note" ," TimeSig" ," TimeSig"

: seq.METRO.FUNC   ( value part -- )
    CASE
        0 OF put.channel: ins-metro
          ENDOF
        1 OF dup metro-note !
             1 fill.dim: shape-metro
          ENDOF
        2 OF timesig-numer ! ENDOF
        3 OF timesig-denom ! ENDOF
    ENDCASE
;

\ ----------------------------------------------

: seq.PAUSE ( flag part -- )
    drop
    IF  seq-if-paused @ 0=
        IF rtc.stop seq-if-paused on
        THEN
    ELSE seq-if-paused @
        IF rtc.start seq-if-paused off
        THEN
    THEN
;


\ --------------------------------------------------
: seq.CLEAR  ( -- )
    many: all-tracks 0
    DO  i 1+ track.shape dup many: [] 0>
        IF clear: []
        ELSE drop
        THEN
    LOOP
    rg_num_tracks 0
    DO false i put.value: seq-play
    LOOP
    true seq.enable.rows
    draw: seq-play
    draw: seq-record
;

: seq.PLAY.ALL  ( -- )
    rg_num_tracks 0
    DO i get.enable: seq-play i put.value: seq-play
       i seq.record.off
    LOOP
    draw: seq-play
    draw: seq-record
;

host=mac .IF
: SEQ.SAVE ( -- , save all tracks with data )
    mf.set.fileinfo \ 00001
    " hmsl.data" 50 50 " Save as..."
    " Untitled.mf" " Enter name:" dialog.put.file \ 00001
    IF watch.cursor save.tracks arrow.cursor drop
    ELSE " Could not open file:" $seq.MSG gr.text
    THEN
;
: SEQ.LOAD ( -- , save all tracks with data )
    mf.set.fileinfo \ 00001
    " Select MIDI File" dialog.get.file \ 00001
    IF
        nip watch.cursor
        load.tracks
        true seq.enable.rows  ( enable new tracks )
        draw: seq-play
        arrow.cursor
    ELSE " Could not open: " $seq.MSG gr.text
    THEN
;
.ELSE

: seq.SAVE ( -- , save all tracks with data )
    put.file
    IF $save.tracks
    THEN
;

: seq.LOAD ( -- , load all tracks from file )
    get.file
    IF $load.tracks
       true seq.enable.rows  ( enable new tracks )
       draw: seq-play
    THEN
;
.THEN

: seq.MENU.func  ( value part -- )
    nip
    CASE
       0 OF midi.panic ENDOF
       1 OF seq.clear ENDOF
       2 OF seq.play.all ENDOF
       3 OF seq.save ENDOF
       4 OF seq.load ENDOF
    ENDCASE
;

\ --------------------------------------------------
: seq.OPTIONS.func  ( value part -- )
    CASE
       0 OF seq-if-metro !
         ENDOF
       1 OF 1 put.enable: seq-menu  ( enable clear )
            draw: seq-menu ( %Q )
         ENDOF
         drop
    ENDCASE
;

\ --------------------------------------------------
: seq.TEXT.FUNC  ( part# -- addr count )
    1+ n>text
;

: seq.SET.ROW  ( cfa object -- )
    dup>r put.down.function: []
    'c seq.text.func  r> put.text.function: []
;

TEXTROM SEQ.MODE.TEXT ," Stop" ," Start" ," Rewnd"

    
: seq.INIT ( -- )
    rg_num_tracks 2+ new: tracks-to-play
\
\ Mode grid
    3 1 new: seq-mode
    'c seq.mode.func put.down.function: seq-mode
    'c seq.mode.text put.text.function: seq-mode
\
\ Pause grid
    1 1 new: seq-pause
    'c seq.pause put.down.function: seq-pause
    " Pause" 0 put.text: seq-pause
\
\ Menu grid
    1 5 new: seq-menu
    'c seq.menu.func put.down.function: seq-menu
    stuff{ " Silence" " Clear All" " Play All"
      " Save" " Load"
    }stuff.text: seq-menu
    false 1 put.enable: seq-menu
    " Commands" put.title: seq-menu
\
\ Options grid
    1 2 new: seq-options
    'c seq.options.func put.down.function: seq-options
    stuff{ " Metronome" " Enable Clear" }stuff.text: seq-options
    " Options" put.title: seq-options
\
\ Set up Play grid.
    rg_num_tracks 2/ 2 new: seq-play
    'c seq.play.func seq-play seq.set.row
    " Play" put.title: seq-play
\
\ Set up Record grid
    rg_num_tracks 2/ 2 new: seq-record
    'c seq.record.func seq-record seq.set.row
    " Record" put.title: seq-record
\
\ Set up Select grid
    rg_num_tracks 2/ 2 new: seq-select
    'c seq.select.func seq-select seq.set.row
    " Select" put.title: seq-select
\
\ Setup Times Control Grid
    1 1 new: seq-cg-times
    'c 2drop put.up.function: seq-cg-times
    0 -1 put.min: seq-cg-times
    1000 -1 put.max: seq-cg-times
    0 0 put.value: seq-cg-times
\
\ Setup Rates Control Grid
    1 2 new: seq-cg-rates
    'c seq.rates.func put.up.function: seq-cg-rates
    'c timer-labels put.text.function: seq-cg-rates
    12 -1 put.min: seq-cg-rates
    500 -1 put.max: seq-cg-rates
    rtc.rate@ 0 put.value: seq-cg-rates
    " Rates" put.title: seq-cg-rates
\
\ Setup Metro Control Grid
    1 4 new: seq-metro
    'c seq.metro.func put.up.function: seq-metro
    'c metro-labels put.text.function: seq-metro
     1 0 put.min: seq-metro   ( channel )
    16 0 put.max: seq-metro
    36 1 put.min: seq-metro   ( note )
    92 1 put.max: seq-metro
     1 2 put.min: seq-metro   ( time-sig  numer)
    32 2 put.max: seq-metro
     1 3 put.min: seq-metro   ( time-sig  denom )
    32 3 put.max: seq-metro
    get.channel: ins-metro 0 put.value: seq-metro
    metro-note @ 1 put.value: seq-metro
    timesig-numer @ 2 put.value: seq-metro
    timesig-denom @ 3 put.value: seq-metro
    " Metronome" put.title: seq-metro
\
\ Setup Track Value Grid
    1 4 new: seq-tr-values
    'c seq.trval.func put.up.function: seq-tr-values
\ Set labels for side.
    stuff{ " Reps"  " Chan"
       " Tran"  " Prog"
    }stuff.text: seq-tr-values
\ repeats channel transpose program
      1 0 put.min: seq-tr-values \ repeat
    256 0 put.max: seq-tr-values
      1 1 put.min: seq-tr-values \ channel
     16 1 put.max: seq-tr-values
    -36 2 put.min: seq-tr-values \ offset
     36 2 put.max: seq-tr-values
     -1 3 put.min: seq-tr-values \ program
    128 3 put.max: seq-tr-values
    " Track" put.title: seq-tr-values
\
\ Setup Track Delay Grid
    1 3 new: seq-tr-delays
    'c seq.trdel.func put.up.function: seq-tr-delays
    'c trdel-labels put.text.function: seq-tr-delays
    0 -1 put.min: seq-tr-delays
    1000 -1 put.max: seq-tr-delays
    " Delays" put.title: seq-tr-delays
\
    1 seq-selected !
    1 seq.update.trvals
\
    true seq.enable.rows
    1 seq-record-track# !
\
    186 256  put.wh: seq-cg-rates
    400 256  put.wh: seq-cg-times
    186 256  put.wh: SEQ-METRO
    618 279  put.wh: SEQ-MENU
    797 279  put.wh: SEQ-OPTIONS
    186 302  put.wh: SEQ-SELECT
    186 302  put.wh: SEQ-PLAY
    186 302  put.wh: SEQ-RECORD
    379 302  put.wh: SEQ-PAUSE
    372 325  put.wh: SEQ-MODE
    186 256  put.wh: SEQ-TR-VALUES
    285 256  put.wh: SEQ-TR-DELAYS

    16  3 new: SEQ-SCREEN
    seq-cg-rates         3592   2682  add: SEQ-SCREEN
    seq-cg-times           520     740  add: SEQ-SCREEN
    SEQ-METRO            3105   1373  add: SEQ-SCREEN
    SEQ-MENU             1708     488  add: SEQ-SCREEN
    SEQ-OPTIONS          2493     488  add: SEQ-SCREEN
    SEQ-SELECT              50   3000  add: SEQ-SCREEN
    SEQ-PLAY                50   2000  add: SEQ-SCREEN
    SEQ-RECORD              46   1024  add: SEQ-SCREEN
    SEQ-PAUSE               50     400  add: SEQ-SCREEN
    SEQ-MODE               520     400  add: SEQ-SCREEN
    SEQ-TR-VALUES        1997   2437  add: SEQ-SCREEN
    SEQ-TR-DELAYS        2635   2711  add: SEQ-SCREEN

    " Multi-Tracker" put.title: seq-screen
    ascii M put.key: seq-screen  \ 'M'ulti track
\
    seq.monitor
\
    'c drop is seq.user.start
    'c drop is seq.user.stop
;

: seq.TERM  ( -- )
    freeall: seq-screen
    free: seq-screen
;

: seq.TEST
    seq.init
    hmsl
    seq.term
;

: SEQ.INIT  ( -- )
    metro.init
    tracks.init
    seq.init
    >newline ." Sequencer Initialized!" cr
;

: SEQ.TERM ( -- )
    seq.term
    metro.term
    tracks.term
;

: USER.INIT  user.init seq.init ;
: USER.TERM  seq.term user.term ;

if.forgotten seq.term

cr ." Enter:  SEQ.INIT   before using Sequencer." cr
." Then run HMSL" cr

