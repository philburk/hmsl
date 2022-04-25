\ Real time clock for HMSL
\
\ Use the CIAB timer A,
\ or the vertical blanking interrupt,
\ or the AUD3 as a timer.
\
\ Author: Phil Burk
\ Copyright 1989 Phil Burk, Larry Polansky, David Rosenboom
\
\ MOD: PLB 6/17/89 Changed from CIAA to CIAB because of
\      potential conflict with keyboard!
\ MOD: PLB ?? Timer now signals a task when it increments.
\      This can be used to keep the Event Buffer alive.
\ MOD: PLB 11/17/89 Added RTC.SIGNAL RTC.TIME+!
\ MOD: PLB 3/26/90 Add MOVE.L $4,A6 to server, thanks Martin Kees.
\ MOD: PLB 4/14/90 Add second signal for HMSL.SCAN
\ MOD: PLB 4/14/90 Added timer based on Audio3
\ MOD: PLB 10/25/90 Add DROP to VERTB.NORATE!
\ MOD: PLB 9/5/91 Make work with MIDI_GLOBALS file.
\ 00001 PLB 10/23/91 Improved error rep.

getmodule includes
getmodule hmod:hmsl-includes
include? interrupt ji:exec/interrupts.j
include? INTB_VERTB ji:hardware/intbits.j
include? CIAICRB_TA ji:hardware/cia.j

ANEW TASK-AJF_RTC

\ Deferred words used by each timer subsystem.

variable RTC-IF-RUNNING

' noop is rtc.term

\ Exec calls to support interrupts.
.NEED AddIntServer()
: ADDINTSERVER() ( type interrupt -- )
    callvoid>abs exec_lib addintserver
;

: REMINTSERVER() ( type interrupt -- )
    callvoid>abs exec_lib remintserver
;
.THEN

.NEED SetIntVector()
: SetIntVector() ( type interrupt -- prior_interrupt )
    if>abs call exec_lib SetIntVector if>rel
;
.THEN

.NEED Disable()
: Disable() (  --  )
    callvoid exec_lib Disable
;
: Enable() (  --  )
    callvoid exec_lib Enable
;
.THEN

: DUMP.INT ( int -- )
    ." Interrupt name is: "
    .. is_node ..@ ln_name >rel 0count type cr
;

decimal

\ This code is shared by all timer systems -------------------
\ Simple structure used by timer interrupt
create TIME-CURRENT
    0 , ( cell which is incremented by interrupts )
    0 , ( first task to signal, abs )
    0 , ( signal mask , don't signal if zero )
    0 , ( second task to signal, abs )
    0 , ( signal mask , don't signal if zero )

: SET.TIMER.SIGNAL1  ( task signal -- )
    disable()
    time-current 8 + !
    if>abs time-current cell+ !
    enable()
;

: SET.TIMER.SIGNAL2  ( task signal -- )
    disable()
    time-current 16 + !
    if>abs time-current 12 + !
    enable()
;

: RTC.SIGNAL  ( -- , signal other tasks if they are installed )
    time-current 8 + @ ?dup
    IF time-current cell+ @ swap callvoid exec_lib signal
    THEN
;

$ -144 constant _LVOSignal

ASM RTC.INT.HANDLER ( -- , service each timer interrupt )
    addq.l    #1,(a1)     ( increment counter )
\
\ first task
    move.l    $8(a1),d0   ( get signal mask )
    beq       2$
    move.l    a1,-(a7)    ( save A1 past SIGNAL )
    move.l    4(a1),a1
    move.l    $4,a6       ( load EXEC_LIB )
    jsr       [_LVOSignal](a6)
\
\ second task
    move.l    (a7)+,a1
    move.l    $10(a1),d0   ( get signal mask )
    beq       2$
    move.l    $C(a1),a1
    move.l    $4,a6       ( load EXEC_LIB )
    jsr       [_LVOSignal](a6)
\
2$: moveq.l   #0,d0       ( continue chain )
    rts
END-CODE

\ Vertical Blanking System -------------------------------

variable VERTB-INTR

: RTC.VERTB.INIT  ( -- , setup interrupt)
    rtc.term
    0 time-current !
    vertb-intr @ 0=  ( make sure not done twice )
    IF
        MEMF_PUBLIC sizeof() interrupt allocblock ?dup
        IF  
            dup>r vertb-intr !  ( save for TERM )
\ Set values in structure.
            NT_INTERRUPT r@ .. is_node ..! ln_type
            -60  r@ .. is_node ..! ln_pri
            0" HMSL VertB Timer" >abs r@ .. is_node ..! ln_name
            time-current >abs r@ ..! is_data
            ' rtc.int.handler >abs r@ ..! is_code
\
\ Add to EXEC List of Interrupt Servers for VERTB.
            INTB_VERTB r> addintserver()
            >newline
            ." Using 60 hz Vertical Blanking Interrupt for Time!" cr
       ELSE
           ." RTC.VERTB.INIT - Not enough memory for timer interrupt!" cr
           abort
       THEN
    THEN
    rtc-if-running on
;

: RTC.VERTB.TERM ( -- , remove and free timer interrupt )
    vertb-intr @ ?dup
    IF  INTB_VERTB over remintserver()
        freeblock
        0 vertb-intr !
    THEN
;

: VERTB.SORRY  ( -- )
    ." Sorry - Vertical Blanking Interrupt Timer can't"
;
: VERTB.NOSTOP  ( -- )
    vertb.sorry ."  STOP!" cr
;
: VERTB.NORATE!  ( rate -- )
    drop vertb.sorry ."  RATE!" cr
;

60 constant VERTB.RATE@

: RTC.USE.VERTB  ( -- , use vertical blanking interrupt )
    rtc.term
    'c vertb.rate@ is rtc.rate@
    'c vertb.norate! is rtc.rate!
    'c vertb.nostop is rtc.stop
    'c noop is rtc.start
    'c rtc.vertb.init is rtc.init
    'c rtc.vertb.term is rtc.term
;

\ Audio Channel 3 based timer. ----------------------------------

variable AUD3-INTR
variable PRIOR-AUD3-INTR

ASM RTC.AUD3.HANDLER  ( -- )
    move.w    #$0400,$DFF09C  ( turn off audio3 interrupt request )
    callcfa   rtc.int.handler
END-CODE
    
: RTC.SET.AUD3  ( -- , setup interrupt using audio 3 )
    0 time-current !
    aud3-intr @ 0=  ( make sure not done twice )
    IF
        MEMF_PUBLIC sizeof() interrupt allocblock ?dup
        IF  >newline
            ." Using Audio Channel 3 Interrupt for Time!" cr
            dup>r aud3-intr !  ( save for TERM )
\ Set values in structure.
            NT_INTERRUPT r@ .. is_node ..! ln_type
            0  r@ .. is_node ..! ln_pri
            0" HMSL AUD3 Timer" >abs r@ .. is_node ..! ln_name
            time-current >abs r@ ..! is_data
            ' rtc.aud3.handler >abs r@ ..! is_code
\
\ Set Exec Handler.
            INTB_AUD3 r> SetIntVector()  dup prior-aud3-intr !
            ?dup IF ." Previous = " dump.int THEN
       ELSE
           ." RTC.SET.AUD3 - Not enough memory for interrupt!" cr
           abort
       THEN
    THEN
;

: AUD3.STOP  ( -- , disable interrupt , stop DMA )
    $ 0008 $ DFF096 ABSW!  ( channel 4 DMA )
    $ 0400 $ DFF09A ABSW!  ( interrupt )
    rtc-if-running off
;

: AUD3.START  ( -- , enable interrupt, start DMA )
    $ 8400 $ DFF09A ABSW!  ( interrupt )
    $ 8208 $ DFF096 ABSW!  ( channel 4 DMA on )
    rtc-if-running on
;

variable AUD3-PERIOD

: AUD3.RATE@  ( -- ticks/second )
    aud3-period @
    2* 3,579,547 swap /
;

: AUD3.RATE!  ( ticks/second -- )
    dup 28 <
    IF ." 28 = minimum AUD3 rate!" drop 11
    ELSE   dup 1000 >
        IF ." 1000 = maximum rate!" drop 1000
        THEN
    THEN
    2* 3,579,547 swap / dup aud3-period !
    $ DFF0D6  absw!  ( set period )
;

: RTC.AUD3.TERM (  -- , remove and free timer interrupt )
    aud3-intr @ ?dup
    IF  aud3.stop
        intb_aud3 prior-aud3-intr @ ?dup
        IF SetIntVector() dump.int
        ELSE 2drop
        THEN
        freeblock
        aud3-intr off
[ exists? da-max-channel .IF ]
        3 da-max-channel !
[ .THEN ]
    THEN
;

: RTC.AUD3.INIT  ( -- )
    rtc.term
    60 aud3.rate!
    0 $ DFF0D8 absw!  ( set volume )
    1 $ DFF0D4 absw!  ( set word count , 2 bytes )
    $ 100 $ DFF0D0 abs! ( set address )
    rtc.set.aud3
    aud3.start
    0 $ DFF0DA  absw!  ( set data register to start interrupts )
[ exists? da-max-channel .IF ]
    2 da-max-channel !
[ .THEN ]
;

: RTC.USE.AUD3  ( -- , use audio3 interrupt )
    rtc.term
    'c aud3.rate@ is rtc.rate@
    'c aud3.rate! is rtc.rate!
    'c aud3.stop  is rtc.stop
    'c aud3.start is rtc.start
    'c rtc.aud3.init is rtc.init
    'c rtc.aud3.term is rtc.term
;

\ -------------------------------------
\ CIA based timer support

variable CIA-INTR
$ BFD000 constant CIAB_ABS

variable CIARSRC_LIB   ( has to be called LIB to trick CALL )

: CIAB?  ( -- , open CIAB resource )
    0" ciab.resource" call>abs exec_lib OpenResource  ?dup
    IF  ciarsrc_lib !
    ELSE ." CIAB? - Couldn't open Resource!" abort
    THEN
;

: CIAB  ( -- rel_cia_addr )
    CIAB_abs >rel
;

\ CIA Resource Calls
: ADDICRVector() ( iCRBit interrupt -- old | 0 )
    call>abs ciarsrc_lib addICRVector if>rel
;
: REMICRVector() ( iCRBit interrupt -- )
    callvoid>abs ciarsrc_lib remICRVector
;

: ABLEICR() ( mask -- )
    callvoid ciarsrc_lib AbleICR
;

: SETICR() ( newmask -- oldmask )
    call ciarsrc_lib SetICR
;

0 constant CLEAR

: CIA.START   ( -- , start real time clock running )
    CIAB ..@ ciacra
        CIACRAF_RUNMODE comp AND  ( reset that bit )
        CIACRAF_LOAD | CIACRAF_START |
    CIAB ..! ciacra
;

: CIA.SET.INTR  ( -- , set interrupt bits )
    CLEAR CIAICRF_TA |  SetICR() drop
    CIAICRF_SETCLR CIAICRF_TA | AbleICR()
;

: CIA.START.TIMER ( -- , start timer and interrupts )
    cia.start
    cia.set.intr
;

: CIA.RESET.INTR ( -- , clear interupts )
    CLEAR CIAICRF_TA |  AbleICR()
;

: CIA.STOP ( -- , stop timer advance )
    CIAB ..@ ciacra
        CIACRAF_START comp AND  ( reset that bit )
    CIAB ..! ciacra
;

: CIA.STOP.TIMER ( -- , turn off timer )
    cia.reset.intr
    cia.stop
;

variable CIA-LATCH  ( cuz the real latch is write only )

: CIA.SET.LATCH  ( count-down-value -- , used to set rate )
    $ FFFF min
    dup cia-latch !
    dup $ ff and CIAB ..! ciatalo
    -8 ashift CIAB ..! ciatahi
;

: CIA.READ  ( -- count , for testing )
    CIAB ..@ ciatalo
    CIAB ..@ ciatahi 8 ashift or
;
    
: (RTC.CIA.INIT)  ( -- ok? , setup interrupt)
    rtc.term
    CIAB?   ( open resource )
    0 time-current !
    cia-intr @ 0=  ( make sure not done twice )
    IF
        MEMF_PUBLIC sizeof() interrupt allocblock ?dup
        IF  
            dup>r cia-intr !  ( save for TERM )
\ Set values in structure.
            NT_INTERRUPT r@ .. is_node ..! ln_type
            0  r@ .. is_node ..! ln_pri
            0" HMSL CIA Timer" >abs r@ .. is_node ..! ln_name
            time-current >abs r@ ..! is_data
            ' rtc.int.handler >abs r@ ..! is_code
\
\ Add ICR interrupt vector.
            CIAICRB_TA r> addICRVector() dup
            IF ." CIA Interrupt already owned by" cr
               .. is_node ..@ ln_name >rel 0count type cr
               cia-intr @ freeblock
               cia-intr off
               false
            ELSE drop cia.start.timer true
            THEN
       ELSE
           ." TIME.INT.INIT - Not enough space for timer interrupt!" cr
           false
       THEN
    ELSE true
    THEN
    60 rtc.rate!
    rtc-if-running on
;

: RTC.CIA.INIT  ( -- )
    (rtc.cia.init) 0=
    IF >NEWLINE ." RTC.CIA.INIT - Could not start CIAB timer!" cr
    THEN
;

: RTC.CIA.TERM ( -- , remove and free timer interrupt )
    cia-intr @ ?dup
    IF  cia.stop.timer
        CIAICRB_TA over remICRVector()
        freeblock
        0 cia-intr !
        0 ciarsrc_lib !
    THEN
;

: CIA.RATE@ ( -- ticks/second )
    cia-latch @ 0=
    IF 60
    ELSE 715,819 cia-latch @ /
    THEN
;

: CIA.RATE! ( ticks/second -- )
    dup 11 <
    IF ." 11 = minimum CIAB rate!" drop 11
    ELSE   dup 1000 >
        IF ." 1000 = maximum rate!" drop 1000
        THEN
    THEN
    715,819 swap / cia.set.latch
;


: RTC.USE.CIAB  ( -- , use CIA interrupt )
    rtc.term
    'c cia.rate@ is rtc.rate@
    'c cia.rate! is rtc.rate!
    'c cia.stop  is rtc.stop
    'c cia.start is rtc.start
    'c rtc.cia.init is rtc.init
    'c rtc.cia.term is rtc.term
;

\ General RTC support --------------------------------------
: (RTC.TIME@)  ( -- time )
    time-current @
;

: (RTC.TIME!)  ( time -- , set and signal )
    time-current !
    rtc.signal
;

: (RTC.TIME+!)  ( delta -- , set and signal )
    time-current +!
    rtc.signal
;

' (rtc.time@) is rtc.time@
' (rtc.time!) is rtc.time!
' (rtc.time+!) is rtc.time+!
if.forgotten rtc.term

\ Set default timer to VERTB
RTC.USE.VERTB

