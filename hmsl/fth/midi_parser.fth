\ Parse MIDI input.
\
\ Vector response to channel voice messages.
\ Does not parse sys ex data.
\ This allows you to have special operations occur
\ when a specific MIDI event is recieved.
\ You must set the vectors, then call MIDI.PARSE from a loop.
\ HMSL will call the MIDI Parser for you if you turn it on.
\ The word that you set the vector for must eat the
\ appropriate number of bytes off the stack for that command.
\
\ MIDI Parser State Machine:
\   To avoid having HMSL hanging while waiting for a
\   complete message to arrive we can accumulate messages
\   using a state machine.
\   For each Port we will have a Parser State Structure
\   that has a pad for up to 4 bytes, a counter, and a limit.

\ Author: Phil Burk
\ Copyright 1987 Delta Research
\
\ MOD: PLB 3/31/87 Handle single byte SYSEX codes.
\ MOD: PLB 4/2/87 Changed ' to 'C for Mac.
\ MOD: PLB 4/15/87 Changed vector scheme to relocatable.
\ MOD: PLB 5/13/87 Add MP.CHANNEL@
\ MOD: PLB 6/1/87 Added SYSTEM messages, fixed lost data.
\ MOD: PLB 11/16/87 Changed C@ to @ in MP.CHANNEL@
\ MOD: PLB & SC 3/15/88 Changed to two port MIDI
\ MOD: PLB 7/17/88 Added scan in MIDI.PARSE.
\ MOD: PLB 5/26/89 Add state machine, Eats sysex.
\ MOD: PLB 9/22/89 Call MP-OFF-VECTOR for 0 velocity notes.
\ MOD: PLB 11/9/89 Add 01 to MP-#BYTES for F1 Time Code
\ MOD: PLB 10/6/90 Add timeout to MP.EAT.SYSEX
\ MOD: PLB 10/22/91 Add MIDI.PARSE.CURRENT, check for stack errors
\ 00001 PLB 2/16/92 Remove annoying message from MP.EAT.SYSEX
\ 00002 PLB 10/5/2015 Fix endian issue in MP-#BYTES

decimal

ANEW TASK-MIDI_PARSER

: MP!, ( addr value -- addr+cell , store into vectors and advance pointer )
    midi_num_ports 0
    DO  swap 2dup !
        cell+ swap
    LOOP drop
;
\ Compile time code.
\ Execution array for parsing.
\ 8 regular, 16 for system, 1 for special ON-VECTOR
CREATE MP-VECTORS 8 16 + 1+ MIDI_NUM_PORTS * cells allot

( set # data bytes per message type )
CREATE MP-#BYTES
    2 c, 2 c, 2 c, 2 c,  ( for channel mesages )
    1 c, 1 c, 2 c, 0 c,
    1 c, 1 c, 2 c, 1 c,
    0 c, 0 c, 0 c, 0 c,  ( System Common F0 -> F7 )
    0 c, 0 c, 0 c, 0 c,
    0 c, 0 c, 0 c, 0 c,  ( System Real Time F8 -> FF )
    
\ Names for vectors
midi_num_ports 1 > [IF]  \ fancy version for multiple ports.
: MP:VECTOR  ( offset -- offset' , generate address off mp-vectors )
    CREATE dup , cell midi_num_ports *  +
    DOES> @ mp-vectors +
        midi-port @ cell* +

;
[ELSE]  \ Faster version for single channel
: MP:VECTOR  ( offset -- , generate address off mp-vectors )
    CREATE dup , cell+
    DOES> @ mp-vectors +
;
[THEN]

\ CHANNEL MESSAGES
0  mp:vector MP-OFF-VECTOR   ( 80 )
mp:vector MP-SMART-ON-VECTOR ( 90 )    \ INTERNAL - Calls ON or OFF
mp:vector MP-NOTEPR-VECTOR   ( A0 )
mp:vector MP-CONTROL-VECTOR  ( B0 )
mp:vector MP-PROGRAM-VECTOR  ( C0 )
mp:vector MP-PRESSURE-VECTOR ( D0 )
mp:vector MP-BEND-VECTOR     ( E0 )
\ SYSTEM MESSAGES
mp:vector MP-OBSOLETE-VECTOR ( Fx )  ( automatically uses following )
mp:vector MP-SYSEX-VECTOR    ( F0 )
mp:vector MP-F1-VECTOR       ( F1 )
mp:vector MP-POINTER-VECTOR  ( F2 )
mp:vector MP-SELECT-VECTOR   ( F3 )
mp:vector MP-F4-VECTOR       ( F4 )
mp:vector MP-F5-VECTOR       ( F5 )
mp:vector MP-TUNE-VECTOR     ( F6 )
mp:vector MP-EOX-VECTOR      ( F7 )
mp:vector MP-CLOCK-VECTOR    ( F8 )
mp:vector MP-F9-VECTOR       ( F9 )
mp:vector MP-START-VECTOR    ( FA )
mp:vector MP-CONTINUE-VECTOR ( FB )
mp:vector MP-STOP-VECTOR     ( FC )
mp:vector MP-FD-VECTOR       ( FD )
mp:vector MP-SENSING-VECTOR  ( FE )
mp:vector MP-RESET-VECTOR    ( FF )
mp:vector MP-ON-VECTOR       ( called by MP-SMART-ON-VECTOR )
drop

\ Parsing Run Time Words ------------------------------
:STRUCT MP.STATE  \ MIDI Parser State Control Block
    byte  mp_count      ( bytes collected )
    byte  mp_needed     ( bytes needed to complete message )
    byte  mp_cvm_index  ( index bits 4,5,6 )
    byte  mp_channel    ( channel, 0based )
    long  mp_msg_count  ( number of messages sent this time )
    byte  mp_byte0      ( first raw byte, CVM )
    byte  mp_byte1      ( first data byte )
    byte  mp_byte2
    byte  mp_byte3
;STRUCT

: MP.DUMP ( state -- )
    dup ..@ mp_needed ." #data = " . cr
    ." Message = "
    4 0
    DO
        dup .. mp_byte0 i + c@ .hex
    LOOP cr
    drop
;
    
\ Declare structures for each port.

midi_num_ports 1 =
[IF]
MP.STATE MP-STATE
: MP.&CFA  ( index -- addr )
    cells mp-vectors +
;
[THEN]

midi_num_ports 2 =
[IF]
CREATE MP-STATE-BASE sizeof() mp.state midi_num_ports * allot
: MP-STATE  ( -- address , control block for current port )
    mp-state-base
    midi-port @
    IF sizeof() mp.state +  ( go for second one )
    THEN
;
: MP.&CFA  ( index -- addr )
    3 lshift mp-vectors +
    midi-port @ cells +
;
[THEN]

midi_num_ports 2 >
[IF]
CREATE MP-STATE-BASE sizeof() mp.state midi_num_ports * allot
: MP-STATE  ( -- address , control block for current port )
    midi-port @ sizeof() mp.state w* mp-state-base +
;
: MP.&CFA  ( index -- addr )
    midi_num_ports cells w* mp-vectors +
    midi-port @ cells +
;
[THEN]

: MP.CHANNEL@  ( -- channel , get channel# of last message )
    mp-state ..@ mp_channel 1+  ( convert to human form )
;

: MP.EXECUTE ( ????? -- , execute user parser )
    rnow
    mp-state ..@ mp_cvm_index mp.&cfa @ execute
;

: MP.PUSH.DATA  ( n -- , push n data bytes)
    mp-state .. mp_byte1 ( n addr )
    dup>r + r> ( -- addr+n addr )
    ?DO i c@
    LOOP
;

: MP.GET.ADDR#  ( -- addr count , message as received )
    mp-state .. mp_byte0
    mp-state ..@ mp_count 1+
;

: MP.CHECK.STACK ( depth1 depth2 -- )
    -
    IF
        mp-state mp.dump .s cr
        ." MIDI PARSER - User function stack error in: "
        mp-state ..@ mp_cvm_index mp.&cfa @ >name id.
        abort
    THEN
;

: MP.FLUSH  ( -- , execute currently accumulated command )
    depth >r
    mp-state ..@ mp_needed ?dup
    IF
        mp.push.data
    THEN
    mp.execute
    depth r> mp.check.stack
    0 mp-state ..! mp_count
    1 mp-state .. mp_msg_count +!
;

: MP.COMMAND>INDEX  ( cvm-byte -- index )
    dup 4 rshift dup $ 0F =
    IF  ( -- cvm 0F , system message )
        drop $ 0F and 8 +
    ELSE  nip 7 and
    THEN
;

: MP.#BYTES  ( cvm-byte -- #databytes )
    mp.command>index mp-#bytes + c@
;

: MP.HANDLE.COMMAND  ( cvm-byte -- )
    dup mp-state ..! mp_byte0
    0 mp-state ..! mp_count
    dup $ 0F and mp-state ..! mp_channel
    mp.command>index
    dup mp-state ..! mp_cvm_index
    mp-#bytes + c@ dup
    mp-state ..! mp_needed 0= ( date bytes needed for msg )
    IF ( complete, do it now )
        depth >r
        mp.execute
        depth r> mp.check.stack
        0 mp-state ..! mp_count
        1 mp-state .. mp_msg_count +!
    THEN
;

: MP.HANDLE.DATA ( data-byte -- )
    mp-state ..@ mp_needed dup 0>
    IF  >r  ( save #needed )
        mp-state ..@ mp_count
        dup>r mp-state .. mp_byte1 + c!  ( save data byte )
        r> 1+ dup mp-state ..! mp_count
        r> =
        IF mp.flush
        THEN
    ELSE .hex .hex
        true warning" MP.HANDLE.DATA -  Stray data byte!" cr
    THEN
;

: MIDI.PARSE.BYTE  ( byte -- , parse MIDI byte )
    dup $ 80 and  ( -- byte hi-bit , is it a control byte? )
    IF mp.handle.command
    ELSE ( Data with running status )
        mp.handle.data
    THEN
;

variable MP-LAST-TIME

: MP.EAT.SYSEX  ( vendor -- , eat bytes until F7 )
    drop \ ." Eating MIDI SYSEX till F7 !" cr \ 00001
    midi.rtc.time@ mp-last-time !
    BEGIN
        midi.recv
        IF midi.rtc.time@ mp-last-time !
            $ F7 =
        ELSE rtc.time@ mp-last-time @ - rtc.rate@ / 10 >
            abort" MP.EAT.SYSEX - timed out!"
            false
        THEN
    UNTIL
;

: MP.SMART.ON  ( note velocity -- , handle 0 velocity )
    dup
    IF mp-on-vector @ execute
    ELSE mp-off-vector @ execute  ( 0 velocity means off )
    THEN
;

: MP.RESET ( -- , resets vectors to appropriate drops )
    mp-vectors
\ Set 8 command vectors
    'c 2drop MP!,    'c mp.smart.on MP!,  ( off, on )
    'c 2drop MP!,    'c 2drop MP!,  ( notepr, control )
    'c drop  MP!,    'c drop  MP!,  ( program, pressure )
    'c 2drop MP!,    'c abort MP!,  ( bend, system )
\
\ Set 16 system vectors
    'c mp.eat.sysex  MP!,
    'c noop  MP!,
    'c 2drop MP!,    'c drop  MP!,
    8 4 + 0
    DO 'c noop MP!,
    LOOP
\ Set special MIDI ON Vector
    'c 2drop MP!,
    DROP
;
\ mp.reset

: MIDI.PARSE  ( -- , call appropriate function based on MIDI input)
    midi-port @
    midi_num_ports 0
    DO  i midi-port !
        0 mp-state ..! mp_msg_count
        BEGIN
            midi.recv
            IF  midi.parse.byte false
            ELSE true
            THEN
            mp-state ..@ mp_msg_count 0> OR
        UNTIL
    LOOP
    midi-port !
;

VARIABLE MIDI-PARSE-MAX

\ these versions are different for speed reasons
midi_num_ports 1 = [IF]
: MIDI.PARSE.MANY ( -- , parse currently set port )
    0 mp-state ..! mp_msg_count
    BEGIN
        midi.recv
        IF  midi.parse.byte false
        ELSE true
        THEN
        mp-state ..@ mp_msg_count midi-parse-max @ > OR
    UNTIL
;
: MIDI.PARSE.CURRENT ( -- , parse bytes recvd until now )
    rtc.time@ 1+
    BEGIN
        midi.recv
        IF
            midi.parse.byte
  \ quit if we are getting leter bytes
            dup midi.rtc.time@ time<
        ELSE true
        THEN
    UNTIL
    drop
;
[ELSE]
: (MIDI.PARSE.MANY) ( -- , parse currently set port )
    0 mp-state ..! mp_msg_count
    BEGIN
        midi.recv
        IF  midi.parse.byte false
        ELSE true
        THEN
        mp-state ..@ mp_msg_count midi-parse-max @ > OR
    UNTIL
;
: (MIDI.PARSE.CURRENT) ( -- , parse bytes recvd until now )
    rtc.time@ 1+
    BEGIN
        midi.recv
        IF
            midi.parse.byte
  \ quit if we are getting leter bytes
            dup midi.rtc.time@ time<
        ELSE true
        THEN
    UNTIL
    drop
;
[THEN]

midi_num_ports 2 = [IF] \ for 2 port systems
: MIDI.PARSE.MANY  ( -- , call appropriate function based on MIDI input)
    midi-port @
    0 midi-port !
    (midi.parse.many)
    1 midi-port !
    (midi.parse.many)
    midi-port !
;
: MIDI.PARSE.CURRENT  ( -- , call appropriate function based on MIDI input)
    midi-port @
    0 midi-port !
    (midi.parse.current)
    1 midi-port !
    (midi.parse.current)
    midi-port !
;
[THEN]

midi_num_ports 1 > [IF] \ for multi port systems
: MIDI.PARSE.MANY  ( -- , call appropriate function based on MIDI input)
    midi-port @
    midi_num_ports 0
    DO  i midi-port !
        (midi.parse.many)
    LOOP
    midi-port !
;
: MIDI.PARSE.CURRENT  ( -- , call appropriate function based on MIDI input)
    midi-port @
    midi_num_ports 0
    DO  i midi-port !
        (midi.parse.current)
    LOOP
    midi-port !
;
[THEN]

: MIDI.PARSE.LOOP
    stack.mark
    BEGIN
        midi.parse.current
        stack.check
        ?terminal
    UNTIL
;


variable MIDI-PARSER ( used as a control for higher level code )

: MIDI.PARSER.ON ( -- , turn on midi parsing )
    true midi-parser !
;
: MIDI.PARSER.OFF ( -- , turn off midi parsing )
    false midi-parser !
;

: MP.INIT ( -- , also reset vectors )
    mp.reset
    4 midi-parse-max !
    midi-port @
    midi_num_ports 0
    DO  i midi-port !
        0 mp-state ..! mp_needed
        0 mp-state ..! mp_count
    LOOP
    midi-port !
    midi.parser.off
;

: SYS.INIT sys.init mp.init ;


\ Test -----------------------------------------
1 [IF]
: MP.ON.RESP ( note velocity -- ) DUP
    ." Port = " midi-port ? ." , ON " swap . . cr
;

: MP.PROGRAM.RESP ( program# -- )
   ." Port = " midi-port ? ." , PRESET " . cr
;

: MP.SET.TEST  ( -- ,set vectors for test )
    mp.init
    midi-port @
    midi_num_ports 0
    DO  i midi-port !
        'c mp.on.resp mp-on-vector !
        'c mp.program.resp mp-program-vector !
    LOOP
    midi-port !
;

: MP.TEST mp.set.test midi.parse.loop mp.reset ;

[THEN]
decimal
