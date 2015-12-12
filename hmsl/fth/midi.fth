\ Host Independant MIDI Support
\ This module requires host dependant words
\ for MIDI.XMIT , MIDI.RECV , MIDI.SER.INIT , MIDI.SER.TERM
\ MIDI.FLUSH , MIDI.RECV? , MIDI.#RECV?
\
\ This code was originally developed as part of HMSL,
\ an experimental music language for Mills College.
\
\ Author: Phil Burk
\ Copyright 1986 -  Phil Burk, Larry Polansky, David Rosenboom.
\ All Rights Reserved
\
\ MOD: Test channel voice message to avoid sending unnecessary data.
\ MOD: PLB 10/9/86 Fixed CVM for different channels.
\                  Added range check for MIDI.CHANNEL!
\ MOD: PLB 12/4/86 Moved MIDI.INIT from host file.
\ MOD: PLB 12/9/86 Fixed MIDI.SCOPE names.
\ MOD: PLB 12/21/86 Added tracking of last notes, OPT option
\ MOD: PLB 3/3/87 Use WARNING" in MIDI.CHANNEL! , V: to VARIABLE
\ MOD: PLB 5/24/87 Add MIDI.CLEAR
\ MOD: PLB 8/14/87 Set HI & LOW in MIDI.WALK for Mac.
\ MOD: PLB 10/22/87 Add MIDI.RECALL.PRESET and MIDI.RECALL.BEND
\                  Add PROGRAM synonyms for PRESET
\ MOD: PLB 2/19/89 Add 7 bit packing words, improve MIDI.SCOPE
\ MOD: PLB 3/30/89 Change 7LO7HI words to hex numbers, fix.
\ MOD: PLB 4/24/89 Fix stack error in MIDI.PRESSURE
\ MOD: PLB 8/28/89 MIDI.TEST - set back to channel 1.
\ MOD: PLB 11/16/89 Add MIDI.PANIC
\ MOD: PLB 12/6/89 Speed up MIDI.SCOPE
\ MOD: PLB 3/12/90 Add MIDI.KEY & MIDI.GET.BYTE
\ MOD: PLB 4/14/90 Add MIDI.PITCH.BEND
\ MOD: PLB 7/18/90 Put TAB in MIDI.SCOPE
\ MOD: PLB 10/29/90 Change MIDI.TEST
\ MOD: PLB 5/21/91 Add MIDI.NORMALIZE
\ MOD: PLB 8/8/91 Moved Running Status Optimization to lowest level
\               so that it will work with event buffering.
\               Make MIDI.LASTOFF use 0 OFF to allow optimization.

include? msec ju:msec
include? choose ju:random

ANEW TASK-MIDI
decimal
VARIABLE MIDI-CHANNEL  ( current channel )
VARIABLE MIDI-LASTCVM  ( last channel voice message )

: MIDI.CHANNEL!  ( channel -- , sets channel for midi output )
\ One word for vectored voice setting.
    dup 1 16 within?
    IF  midi-channel !
    ELSE true
        warning" MIDI.CHANNEL! - Channel number out of range! = " . cr
    THEN
;

: MIDI.ORCH  ( status -- status+channel )
     midi-channel @ 1- or
;
HEX
: MIDI.DATA.XMIT ( data -- , send valid data )
     7F AND midi.xmit
;

: MIDI.CVM  (  status-byte -- , send channel voice message  )
    midi.orch midi.xmit
;

: MIDI.CVM+1D ( data st -- , send cvm + 1 data byte  )
     midi.cvm
     midi.data.xmit   midi.flush
;

: MIDI.CVM+2D  (  data1 data2 st -- , send cvm + 2 data bytes )
     midi.cvm swap
     midi.data.xmit  midi.data.xmit
     midi.flush
;

: MIDI.CVM+3D  (  data1 data2 data3 st -- , send cvm + 3 data bytes )
     midi.cvm
     >r >r midi.data.xmit
     r> midi.data.xmit
     r> midi.data.xmit
     midi.flush
;

\ MIDI requires you to turn off any note that you turn on.
\ To make this easier we will keep track of the last note for
\ each channel.  This works best with multiple monophonic channels.
CREATE MIDI-LAST-NOTES 12 ALLOT  ( HEX , allow room for 1-16 offset )
CREATE MIDI-LAST-VELS  12 ALLOT
CREATE MIDI-LAST-PROGRAMS 12 ALLOT
CREATE MIDI-LAST-BENDS 24 ALLOT  ( word wide )

: MIDI.TRACK.NOTE  ( note -- , Store note for channel )
    midi-channel @ midi-last-notes + c!
;
: MIDI.TRACK.VEL  ( vel -- , Store velocity for channel for crescendos )
    midi-channel @ midi-last-vels + c!
;
: MIDI.TRACK.PROGRAM  ( program -- , Store program for channel.)
    midi-channel @ midi-last-programs + c!
;
: MIDI.TRACK.BEND  ( bend -- , Store bend for channel.)
    midi-channel @ 2* midi-last-bends + w!
;

: MIDI.RECALL.NOTE  ( -- note , Recall note for channel )
    midi-channel @ midi-last-notes + c@
;
: MIDI.RECALL.VEL  ( -- vel , Recall velocity for channel for crescendos )
    midi-channel @ midi-last-vels + c@
;
: MIDI.RECALL.PROGRAM  ( -- preset , Recall program for channel.)
    midi-channel @ midi-last-programs + c@
;
: MIDI.RECALL.PRESET  ( -- preset , Recall preset for channel.)
    midi.recall.program
;
: MIDI.RECALL.BEND  ( -- bend , Recall bend for channel.)
    midi-channel @ 2* midi-last-bends + w@
;

: MIDI.NOTEOFF  ( note vel -- , turn note off )
    80 midi.cvm+2d
;

: MIDI.NOTEON  ( note vel -- turn on note  )
    2dup midi.track.vel midi.track.note
    90 midi.cvm+2D
;

: MIDI.LASTOFF ( -- , turn off last note )
    midi.recall.note 0 midi.noteon \ use zero velocity
;

: MIDI.NOTE.PRESSURE  ( note pressure -- , set aftertouch for note )
\ This command is rarely supported by synthesizers.
    A0 midi.cvm+2D
;

\ MIDI CONTROL and related words. -----------------
: MIDI.CONTROL  ( c# val -- , send control value )
    B0 midi.cvm+2D
;

: MIDI.ALLOFF  (  -- , turn all notes off  )
    7B 00 midi.control
;

: MIDI.LOCAL.ON ( -- , allow keyboard input )
    7A 7F midi.control
;
: MIDI.LOCAL.OFF ( -- , disallow keyboard input )
    7A 0  midi.control
;

\ More MIDI Channel Voice Messages ----------------------
: MIDI.PROGRAM  ( program -- , change program, range = 1...128 )
    dup midi.track.program
    1- C0 midi.cvm+1D
;
: MIDI.PRESET  ( preset -- , same as MIDI.PROGRAM )
    midi.program
;

: MIDI.PRESSURE  ( pressure -- , set aftertouch for channel )
    D0 midi.cvm+1D
;

: MIDI.BEND  ( raw-bend  -- , send pitch wheel change command )
    dup midi.track.bend
    dup 7 arshift E0 midi.cvm+2d
;

: MIDI.PITCH.BEND ( +/-bend -- , 0 means no bend )
    $ 2000 + midi.bend
;

\ These are for reorganizing binary data into forms
\ suitable for MIDI transmission.
: 14->7LO7HI  ( 14_bits -- lo7 hi7 )
    dup 7F and
    swap 7 arshift
;

: 7LO7HI->14  ( lo7 hi7 -- 14_bits )
    7F and 7 lshift
    swap 7F and OR
;

: BYTE->HILO ( byte -- hi lo )
    dup 4 rshift 0F and
    swap 0F and
;

: HILO->BYTE ( hi lo -- byte )
    swap 4 lshift or
;

: MIDI.XMIT.HILO ( byte -- , send as hi and lo nibbles )
    byte->hilo
    swap midi.xmit midi.xmit
;

: MIDI.XMIT.LOHI ( byte -- , send as hi and lo nibbles )
    byte->hilo
    midi.xmit midi.xmit
;
\ Extract high bits from string.
\ These are used for packing and unpacking 8 bit data into
\ 7 bit data.
: GET.HIGH.BITS ( addr count -- highbits )
    dup 7 > abort" GET.HIGH.BITS > 7 !!"
    0 swap 0
    ?DO ( addr accum ) 2*
        over i + c@ $ 80 and  ( -- addr accum 80/00 )
        IF 1 or
        THEN
    LOOP nip
;

: PUT.HIGH.BITS ( addr count highbits -- )
    over 7 > abort" PUT.HIGH.BITS > 7 !!"
    over >r >r + 1-
    r> r> 0
    ?DO ( addr+i-1 highbits )
        dup 1 and
        IF ( addr highbits )
            over dup c@ $ 80 OR  ( -- addr high addr char )
            swap c!
        THEN 2/ swap 1- swap
    LOOP 2drop
;


: MIDI.START.SYSEX ( -- , send start SYSEX byte )
    midi.flush
    F0 midi.xmit
;

: MIDI.END.SYSEX ( -- , stop SYSEX )
    F7 midi.xmit
    midi.flush
;

\ System Common Messages - Sent to All Channels.
: MIDI.COMMON ( status -- , Send status byte for Common Message)
    dup midi-lastcvm !  ( change default status )
    midi.xmit
;

: MIDI.SONG.POINTER  ( position  -- , send Song Position Pointer)
     F2 midi.common
     dup 7 arshift E0
     swap midi.data.xmit
     midi.data.xmit midi.flush
;

: MIDI.SONG.SELECT ( song# -- , send Song Select )
    F3 midi.common
    midi.data.xmit midi.flush
;

\ MIDI Real Time Mesages - Sent to all channels.
\ These do not interfere with running status.
: MIDI.REAL.TIME ( byte -- , Send Real time messgae )
    midi.xmit midi.flush
;

: MIDI.CLOCK ( -- , Send MIDI clock tick, BOGS THINGS DOWN! )
    F8 midi.real.time
;

: MIDI.START ( -- , Start slave sequencers )
    FA midi.real.time
;

: MIDI.CONTINUE ( -- , Continue after Stop )
    FB midi.real.time
;

: MIDI.STOP ( -- , Stop slave sequencers )
    FC midi.real.time
;

\ Virtual Time dependant tools --------------------------
: MIDI.TIME@  ( -- time , advance time byte received )
    midi.rtc.time@ time-advance @ +
;

\ Unclog Event Buffer by setting time to a high value.
: MIDI.UNCLOG  ( -- , send all pending messages )
    rtc.time@
    -1 -1 shift 5000 - rtc.time!
    1000 msec
    rtc.time!
;

: MIDI.NOTEON.AT  ( note vel time -- )
    midi.flush
    vtime!
    midi.noteon
;

: MIDI.NOTEON.FOR  ( note vel ontime -- )
    midi.flush
    vtime@ >r >r
    midi.noteon r> vtime+! midi.lastoff
    r> vtime!
;

: MIDI.NOTEON.LATER  ( note vel delta -- )
\ turn on note relative to current real time
    rtc.time@ +
    midi.noteon.at
;

\ MIDI control -----------------------------------
DECIMAL
: MIDI.INIT  ( -- , Initialize MIDI system. )
    " MIDI.INIT" debug.type
    midi.ser.init
    -1 midi-lastcvm !
    16 0
    DO  i 1+ midi.channel!
        255 midi.track.note ( set to off )
        255 midi.track.vel
    LOOP
    1  midi.channel!
;

: MIDI.TERM ( -- , Terminate MIDI system. )
    " MIDI.TERM" debug.type
    midi.ser.term
;

\ For cascading initialization.
: SYS.INIT sys.init midi.init ;
: SYS.TERM midi.term sys.term ;

\ MIDI Utilities ---------------------------------
DECIMAL
: MIDI.CZ.KILL  ( -- , Turn OFF notes on CZ-101 )
    midi.local.off   midi.local.on
;

: MIDI.CZ.KILLALL  ( -- , Kill all channels on CZ-101 )
      midi-channel @  ( save )
      17 1 DO ( 16 channels )
         i midi.channel!
         midi.cz.kill
      LOOP
      midi.channel! ( restore )
;

: MIDI.PANIC  ( -- , send allof to all 16 channels )
    midi-channel @
    17 1
    DO i midi.channel! midi.alloff
    LOOP
    midi.channel!
;

: MIDI.NORMALIZE  ( -- , reset controllers on all channels )
    midi-channel @
    17 1
    DO
        i midi.channel!
        0 midi.pitch.bend  \ zero out pitch bend
        7 127 midi.control  \ full volume
        1 0 midi.control  \ modulation wheel off
        5 0 midi.control  \ portamento time
        64 0 midi.control \ sustain pedal off
        65 0 midi.control \ portamento off
        0 midi.pressure
    LOOP
    midi.channel!
;
: MIDI.KILL ( -- , Kill all notes on current channel )
\ This is for use with devices that don't support MIDI.ALLOFF
      128 0 DO
        i 0 midi.noteoff
      LOOP
;

: MIDI.KILLALL  ( -- , Kill all channels )
      midi-channel @  ( save )
      17 1 DO 
         i midi-channel !
         midi.kill
      LOOP
      midi-channel ! ( restore )
;

: MIDI.THRU ( -- , echo to output )
    BEGIN  8 0
        DO  midi.recv
            IF midi.xmit midi.flush
            THEN
        LOOP
        ?terminal
    UNTIL
;

HEX
: MIDI.SYSDIS ( system_byte -- , display system message )
    dup 0F and
    CASE
      0 OF ." SysEx" ENDOF
      1 OF ." MTC" ENDOF
      2 OF ." SongPos" ENDOF
      3 OF ." SongSel" ENDOF
      6 OF ." TuneReq" ENDOF
      7 OF ." EndSysEx" ENDOF
      8 OF ." Clock" ENDOF
      A OF ." Start" ENDOF
      B OF ." Continue" ENDOF
      C OF ." Stop" ENDOF
      E OF ." ActSens" ENDOF
      F OF ." Reset" ENDOF
         ." Undefined " dup 3 .r
    ENDCASE
    drop
;

: MIDI.CVMDIS ( cvm_byte -- , display name of command)
    tab
    dup F0 and F0 -  ( not a System Message? )
    IF  ." /"dup 0F and 1+ 1 .r  ( show channel )
    THEN
    ." /"
    dup F0 AND
    CASE
        80 OF ." Off" ENDOF
        90 OF ." On" ENDOF
        A0 OF ." AfterNote" ENDOF
        B0 OF ." Control" ENDOF
        C0 OF ." Program" ENDOF
        D0 OF ." AfterChan" Endof
        E0 OF ." Bend" ENDOF
        F0 OF dup midi.sysdis ENDOF
        dup 3 .r  ( others not yet named )
    ENDCASE
    ." / "
    drop
;

: MIDI.SCOPE ( -- , Dump midi data to screen. )
    base @ cr
    ." MIDI Scope - Hit any key to stop." cr
    ." Channel/Command/Data" cr
    BEGIN
        midi.recv
        IF dup 80 and
            IF midi.cvmdis
            ELSE 4 .r cr?
            THEN  flushemit
        THEN
        ?terminal
    UNTIL
    base !
;    

: MIDI.MONITOR ( -- , Dump raw midi data to screen. )
    base @ hex cr
    ." MIDI HEX Monitor - Hit any key to stop." cr
    BEGIN
        midi.recv
        IF 3 .r cr? flushemit
        THEN
        ?terminal
    UNTIL
    base !
;    

: MIDI.CLEAR   ( -- , clear all bytes from MIDI input stream)
    midi-warnings @ midi-warnings off
    0 BEGIN midi.recv
    WHILE drop 1+
    REPEAT cr . ." MIDI input bytes cleared." cr
    midi-warnings ! midi.check.errors
;

: MIDI.KEY ( -- byte )
    BEGIN
        ?terminal IF ." MIDI.KEY " ?quit abort" Aborted!" THEN
        midi.recv
    UNTIL
;

: MIDI.GET.BYTE ( byte -- )
    midi.key 2dup =
    IF 2drop
    ELSE ." Expected " swap . ." , got " . cr abort
    THEN
;

\ TEST TEST TEST (play) -------------------------------------
DECIMAL
: MIDI.ORGAN  ( play on keyboard  )
     ." PRESS NUMBER KEYS, 'q' to quit!" CR
     BEGIN
        key dup 20 - dup cr ." note = " .
        127 midi.noteon
        300 msec midi.lastoff
        ascii q =
     UNTIL
;

HEX
: MIDI.CONT  ( -- , Continuous stream for hardware testing. )
    BEGIN
       45 7F midi.noteon
       45 7F midi.noteoff
       ?terminal
   UNTIL
;
DECIMAL

: MIDI.NOTE ( note -- , play note )
       100 midi.noteon
       300 msec
       midi.lastoff
       200 msec
;

: MIDI.BLAST ( note -- , keep hitting )
    BEGIN dup midi.note ?terminal
    UNTIL drop
;

: MIDI.TEST  ( -- , simple test to see if MIDI is alive )
    >newline ." Sending Middle C on channel 1" cr
    ." Hit <RETURN> to stop." cr
    rnow
    1 midi.channel!
    60 midi.blast
;

( Simple MIDI piece )
VARIABLE MD-LOW  VARIABLE MD-HI

: MD-CLIP   ( v -- v' )
       md-low @ max md-hi @ min
;

: MIDI.WALK  ( N -- ,  Random walk )
    40 md-low !  90 md-hi !
    50 midi.track.note  ( set start for random walk )
    0 ?DO  midi.recall.note
        3 choose 1- +  md-clip
        127 choose midi.noteon
        4 choose 1+ 100 * msec
        midi.lastoff
        60 choose midi.preset
        ?terminal IF leave THEN
    LOOP
;

decimal
: MIDI.SEQOUT   ( -- , Simple sequence )
    6 0
    DO  i 4 * 40 + 120 midi.noteon
        200 msec  midi.lastoff
    LOOP
;

: MIDI.TESTPR ( N -- , test presets )
     0 ?DO
        i midi.preset cr ." PR = " i .
        midi.seqout
     LOOP
;

: SYS.STATUS sys.status
    midi-channel @ 3 .r ."  = MIDI Channel" cr
;
