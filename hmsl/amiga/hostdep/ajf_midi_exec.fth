\ MIDI support for Delta Research JForth
\
\ These are the low level, HOST  Dependant words that
\ are required to support the HOST Independant words
\ in the file "MIDI". 
\
\ Author: Phil Burk
\ Copyright 1986 -  Phil Burk, Larry Polansky, David Rosenboom.
\
\ MOD: PLB 8/25/88 Support double buffered MIDI for speed
\    and to avoid overlap.

include? serial.open ju:serial

ANEW TASK-AJF_MIDI

\ Supported words:
\   MIDI.SER.INIT ( -- )
\   MIDI.XMIT ( byte -- )
\   MIDI.FLUSH ( -- )
\   MIDI.SER.TERM  ( -- )
\   MIDI.RECV  ( -- byte true | false )
\   MIDI.RECV? ( -- flag )

variable MIDI-IF-INIT
variable MIDI-NUMOUT
variable MIDI-BUF0? ( TRUE = 0, FALSE = 1)
variable MIDI-IORQ-OUT0
variable MIDI-IORQ-OUT1
variable MIDI-IORQ-IN
variable MIDI-WARNINGS
variable MIDI-ERRORS

64 constant MIDI-MAXBUF  ( write buffer for MIDI.XMIT )
variable MIDI-OUTBUF0 midi-maxbuf 2+ allot
variable MIDI-OUTBUF1 midi-maxbuf 2+ allot
variable MIDI-PAD

: MIDI-OUTBUF  ( -- addr )
    midi-buf0? @
    IF midi-outbuf0
    ELSE midi-outbuf1
    THEN
;

: MIDI-IORQ-OUT  ( -- addr )
    midi-buf0? @
    IF midi-iorq-out0
    ELSE midi-iorq-out1
    THEN
;

: MIDI.START.WRITE ( -- , begin asynchronous write )
    midi-outbuf midi-numout @ midi-iorq-out @ serial.write.async
;

: MIDI.SWITCH  ( -- , switch to other buffer )
    midi-buf0? @ 0= midi-buf0? !
;

: MIDI.FLUSH ( -- , flush any bytes in buffer )
    midi-numout @ 0 >
    IF midi-iorq-out @ waitio()
       IF ." MIDI write error = " .hex cr
       THEN
       midi.start.write
       0 midi-numout !
       midi.switch  ( fill other buffer while transmitting)
    THEN
;

: MIDI.XMIT ( byte -- , Add byte to MIDI output buffer )
    midi-numout @ midi-maxbuf >
    IF midi.flush
    THEN
    midi-numout @ midi-outbuf + c!
    1 midi-numout +!
;

\ MIDI Input ------------------------------------------------    
: MIDI.START.READ ( -- , begin asynchronous read)
    midi-pad 1 midi-iorq-in @ serial.read.async
;

: MIDI.CHECK.ERRORS  ( -- , report errors if any )
    midi-warnings @
    IF midi-errors @ ?dup
        IF ." MIDI read error = " .hex cr
    	   midi-errors off
        THEN
    THEN
;

: MIDI.FINISH.READ ( -- byte , complete asynch read )
    midi-iorq-in @ waitio() ?dup
    IF  midi-warnings @
        IF ." MIDI read error = " .hex cr
        ELSE midi-errors !
        THEN
    THEN
    midi-pad c@
;

: MIDI.RECV? ( -- flag , are there bytes in recieve buffer? )
    midi-iorq-in @ checkio()
;

: MIDI.ABORT.READ ( -- )
    midi-iorq-in @ abortio() drop
;


: MIDI.RECV ( -- byte true | false , receive MIDI data )
    midi.recv?
    IF 
       midi.finish.read true
       midi.start.read    ( start next request )
    ELSE false
    THEN
;

: MIDI.#RECV? ( -- #bytes , How many bytes are in recieve buffer? )
    midi.recv?
    IF 1  ( we don't currently have a way to figure this out! %Q)
    ELSE 0
    THEN
;

: MIDI.SETUP ( serreq bufsize -- )
    over ..! io_rbuflen
    8 over ..! io_ReadLen
    8 over ..! io_WriteLen
    31250 over ..! io_Baud
    1 over ..! io_stopbits
    SERF_RAD_BOOGIE over ..! io_serflags
    serial.setparams
    abort" MIDI.SETUP failed!"
;

VARIABLE MIDI-READBUF-SIZE 
2048 midi-readbuf-size !

: MIDI.SER.INIT
    midi-if-init @ not
    IF
\ Open two output channels.
        SERF_SHARED 0" hmidi-out0" serial.open ?dup
        IF ." MIDI output open error = " .hex
        THEN
        dup midi-iorq-out0 !
        512 midi.setup

        SERF_SHARED 0" hmidi-out1" serial.open ?dup
        IF ." MIDI output open error = " .hex
        THEN
        dup midi-iorq-out1 !
        512 midi.setup

        SERF_SHARED 0" hmidi-in" serial.open ?dup
        IF ." MIDI input open error = " .hex
        THEN
        dup midi-iorq-in !
        midi-readbuf-size @ midi.setup
\
\ Set up asynchronous I/O
        0 midi-numout !
        0 midi-buf0? !
        midi.start.read
        midi.start.write
        midi.switch
        midi.start.write
        midi-if-init on
        midi-warnings on
    THEN
    midi.flush
;
    
: MIDI.RTC.TIME@  ( -- time )
    rtc.time@
;
: MIDI.TIME@  ( -- time )
    time@
;

: MIDI.SER.TERM
    midi-if-init @
    IF
        midi.flush
        midi.abort.read
        midi-iorq-out0 @ serial.close
        midi-iorq-out1 @ serial.close
        midi-iorq-in @ serial.close
        false midi-if-init !
    THEN
;
