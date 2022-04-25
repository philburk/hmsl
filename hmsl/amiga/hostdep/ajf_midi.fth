\ Direct to Hardware MIDI driver
\ Special Thanks to Michael Schwartz for his assistance.
\
\ This driver goes directly to the chip.  It supports
\ circular buffers for input and output.
\
\ Author: Phil Burk
\ Copyright 1989 Phil Burk
\
\ MOD: PLB 5/31/89 Turn off interrupt request bit immediately
\     after getting data to avoid overruns.
\ MOD: PLB 8/29/89 Only disable() cb.out in MIDI.RECV
\          Use DISABLE.RX DISABLE.TX
\ MOD: PLB 2/16/90 Changed BAUD_PERIOD from 113 to 114.
\ MOD: PLB 3/12/90 Fix 1 byte overflow in MIDI.XMIT
\            Fix allocation of STAMP input, use MIDI-RECV-SIZE
\ MOD: PLB 4/13/90 Signal HMSL when byte comes.
\ MOD: PLB 6/7/90 MIDI would hang if bytes coming in during init.
\          Added missing label in RBF.STAMP.HANDLER
\ MOD: PLB 1/18/91 Allocate Resources for serial port.
\ MOD: PLB 9/5/91 Make work with MIDI_GLOBALS file. Add TIME.INIT
\             and TIME.TERM
\ 00001 PLB 11/20/91 Call MIDI.EB.ON and OFF in INIT and TERM so
\       that MIDI.WRITE vector doesn't get mangled.

decimal
getmodule includes
getmodule hmod:hmsl-includes
include? interrupt ji:exec/interrupts.j
include? INTB_TBE ji:hardware/intbits.j
include? cb.ll.in h:circbuff
include? value ju:value

ANEW TASK-AJF_MIDI

.NEED FREEVAR 
: FREEVAR  ( variable -- , free pointer )
    dup @ ?dup
    IF freeblock
    THEN
    off
;
.THEN
." Move FREEVAR" cr

.NEED FORBID()
: FORBID() ( -- , forbid all other tasks )
    callvoid exec_lib forbid ;
: PERMIT() ( -- , forbid all other tasks )
    callvoid exec_lib permit ;
.THEN


\ Resource Support ---------------------------------------

: FlushDevice ( 0name -- , flush in case held but not used )
	forbid()
	exec_lib @ >rel .. eb_DeviceList
	swap
	call>abs exec_lib findname ?dup
	IF ." Removing device." cr
		callvoid exec_lib RemDevice
	THEN
	permit()
;

\ I have put a space in here and only do 1- in (SERIAL?)
\ so that CLONE doesn't get an odd address!
0"  misc.resource" 0string MISC_RESOURCE_NAME
0"  HMSL_MIDI_RSRC" 0string HMSL_MIDI_RSRC_NAME

variable SERIAL-RSRC

ASM (SERIAL?) ( -- absrsrc | 0 )
	move	d7,-(dsp)
	movem.l	d5-d6/a2-a6,-(rp)
	move	4,a6		\ get exec_lib
	lea		[MISC_RESOURCE_NAME HERE - 1-](PC),A1
	jsr		$-1F2(a6)	\ OpenResource()
	move	d0,d7
	bne		1$
	moveq	#0,d7
	movem.l	(rp)+,d5-d6/a2-a6
	rts
1$:
	exg		d7,a6		\ resource base in A6
	move	#[MR_SERIALBITS],d0
	lea		[HMSL_MIDI_RSRC_NAME HERE - 1-](PC),A1
	jsr		[MR_ALLOCMISCRESOURCE](a6)		
	tst.l	d0
	bne		3$
	move	#[MR_SERIALPORT],d0
	lea		[HMSL_MIDI_RSRC_NAME HERE - 1-](PC),A1
	jsr		[MR_ALLOCMISCRESOURCE](a6)		
	tst.l	d0
	bne		2$
	exg		a6,d7
	movem.l	(rp)+,d5-d6/a2-a6
	rts				\ return abs resource
2$:
	move	#[MR_SERIALBITS],d0
	jsr		[MR_FREEMISCRESOURCE](a6)
3$:
	move	#0,D7
	movem.l	(rp)+,d5-d6/a2-a6
	rts
END-CODE


ASM (-SERIAL) ( absrsrc -- )
	movem.l	d5-d6/a2-a6,-(rp)
	exg		d7,a6		\ resource base in A6
	move	#[MR_SERIALBITS],d0
	jsr		[MR_FREEMISCRESOURCE](a6)
	move	#[MR_SERIALPORT],d0
	jsr		[MR_FREEMISCRESOURCE](a6)
	movem.l	(rp)+,d5-d6/a2-a6
	move	(dsp)+,D7
	rts
END-CODE

: SERIAL?  ( -- absrsrc , allocate serial resource )
	serial-rsrc @ 0=
	IF
		0" serial.device" FlushDevice
		(serial?) dup serial-rsrc !
		dup 0=
		IF ." Serial device in use! No MIDI" cr
		THEN
	ELSE serial-rsrc @
	THEN
;

: -SERIAL ( -- )
	serial-rsrc @ ?dup
	IF	(-serial)
		serial-rsrc off
	THEN
;

\ Low Level Chip Access -------------------------------------

decimal
31250 constant MIDI_BAUD
3579545 MIDI_BAUD / value BAUD_PERIOD 

HEX
: MIO.SET.PERIOD ( period -- )
    dff032 absw!
;
: MIO.ON ( -- , initialize serial I/O hardware, turn on INTs )
    baud_period mio.set.period ( set baud rate )
    800 DFF09C absw!   ( clear recv buffer full & overrun bit )
    8800 DFF09A absw!  ( reenable rx interrupt )
;

: MIO.OFF ( -- , turn off interrupts )
    0801 DFF09A absw!  ( rx and tx interrupt disable )
;

DECIMAL
variable RBF-INTR
variable TBE-INTR
variable PRIOR-RBF-INTR
variable PRIOR-TBE-INTR
variable RBF-COUNT
circular.buffer MIO-IN-CB
circular.buffer MIO-OUT-CB

variable MIDI-STAMP-INPUT   \ If true, time stamp input.

:STRUCT MIO.CONTROL
    long   mioc_time_ptr   \ abs address of time
    long   mioc_char_ptr   \ abs address of circular buffer
    long   mioc_stamp_ptr  \ abs address of time stamp array
    aptr   mioc_sigtask    \ abs address of task to signal
    long   mioc_sigmask    \ mask to signal task with
;STRUCT

mio.control MIO-CONTROL

variable MIO-IN-DATA
variable MIO-OUT-DATA

2048 midi-recv-size !
1024 midi-xmit-size !
midi-stamp-input on

: BSRTO ( <name> -- , compile BSR code )
    $ 6100 w,
    [compile] ' here - 
    dup abs $ 7FFF >
    IF ." BSR too far!" abort
    ELSE w,
    THEN
;

ASM RBF.INT.HANDLER ( -- , called when character received )
\ A0 = address of custom chips, then char buffer
\ A1 = pointer to mio-control
    move.w   $18(A0),d0  \ get data and flags
    move.w   #[intf_rbf],$9C(A0)     \ clear interrupt request
    move.l   [mioc_char_ptr](a1),a0  \ char buffer -> a0
    btst     #15,d0      \ check overrun bit
    beq      1$
      move.b   #$FF,[cb_overrun](a0)
1$: cmpi.b   #$FE,d0     \ is it the dreaded FE from Yamaha??
    beq.l    2$          \ don't keep it.
      move.l   a1,a5     \ save in A5 for SIGNAL
      forth{ bsrto cb.ll.in }   \ else put in buffer
      
\ Signal HMSL that a byte has arrived.
      move.l   [mioc_sigmask](a5),d0
      beq      2$
      move.l   [mioc_sigtask](a5),a1
      move.l   $4,a6       ( load EXEC_LIB )
      jsr      [_LVOSignal](a6)
2$: rts
END-CODE

variable TIME-STAMPS-PTR   \ holds address of time stamp array

variable MC-IF-INIT

ASM RBF.STAMP.handler ( -- , called when character received )
\ On Input
\   A0 = address of custom chips
\   A1 = pointer to mio control structure
\ Then
\   D0 = character data
\   D1 = time
\   A0 = set to address of char buffer
\   A1 = addr of time storage
\   A6 = address of custom chips
\   A5 = pointer to mio control structure
\
    move.l   a0,a6
    move.l   a1,a5
    move.w   $18(A6),d0              \ get data and flags
3$: move.w   #[intf_rbf],$9C(a6)     \ clear interrupt request
    move.l   [mioc_char_ptr](a5),a0  \ char buffer
    btst     #15,d0                  \ check overrun bit
    beq      1$
\
      move.b   #$FF,[cb_overrun](a0)   \ set error flag
\ Put dummy value in buffer in attempt to preserve reg.
      move.l   (a5),a1            \ move time address to A1
      move.l   (a1),d1            \ get time in d1
      move.l   [mioc_stamp_ptr](a5),a1
      move.w   d0,-(a7)           \ save char on return stack
      move.l   [cb_in](a0),d0     \ get index of next char
      lsl.l    #2,d0              \ convert byte index to cell offset
      add.l    d0,a1              \ address to store to
      move.l   d1,(a1)+           \ save time in array twice
      move.l   d1,(a1)+           \ save time in array twice
      moveq.l  #0,d0              \ dummy char
      forth{ bsrto cb.ll.in }     \ put in buffer (d0,a0)
      move.w   (a7)+,d0           \ restore char
      forth{ bsrto cb.ll.in }     \ put in buffer (d0,a0)
      bra      2$
\
1$: cmpi.b   #$FE,d0     \ is it the dreaded FE from Yamaha??
    beq.l    2$          \ don't keep it.
      move.l   (a5),a1            \ move time address to A1
      move.l   (a1),d1            \ get time in d1
      move.l   [mioc_stamp_ptr](a5),a1
      move.w   d0,-(a7)           \ save char on return stack
      move.l   [cb_in](a0),d0     \ get index of next char
      lsl.l    #2,d0              \ convert byte index to cell offset
      move.l   d1,$0(a1,d0.l)     \ save time in array
      move.w   (a7)+,d0           \ restore char
      forth{ bsrto cb.ll.in }     \ else put in buffer (d0,a0)
\
2$: move.w   $18(A6),d0           \ has another char arrived
    btst     #14,D0               \ check RBF mirrored with data
    bne      3$                   \ go back and get it now if so
\
\ Signal HMSL that a byte has arrived.
    move.l   [mioc_sigmask](a5),d0
    beq      4$
    move.l   [mioc_sigtask](a5),a1
    move.l   $4,a6       ( load EXEC_LIB )
    jsr      [_LVOSignal](a6)
\
4$: rts
END-CODE

: SET.MIO-CONTROL  ( -- , setup shared structure)
    time-current >abs mio-control ..! mioc_time_ptr
    mio-in-cb >abs mio-control ..! mioc_char_ptr
    time-stamps-ptr @ >abs mio-control ..! mioc_stamp_ptr
;

: SET.RBF.SIGNAL  ( task sigmask -- , for received MIDI )
    disable()
    mio-control ..! mioc_sigmask
    if>abs mio-control ..! mioc_sigtask
    enable()
;

: RBF.SET.VECTOR  ( interrupt -- , set for desired handler )
    >r
    set.mio-control
    mio-control >abs r@ ..! is_data  
    midi-stamp-input @
    IF  ' RBF.stamp.handler >abs r@ ..! is_code
    ELSE
        ' RBF.int.handler >abs r@ ..! is_code
    THEN
    rdrop
;

: RBF.INT.INIT  ( -- , setup interrupt)
    rbf-intr @ 0=  ( make sure not done twice )
    IF
        MEMF_PUBLIC sizeof() interrupt allocblock ?dup
        IF  
            dup>r rbf-intr !  ( save for TERM )
\ Set values in structure.
            NT_INTERRUPT r@ .. is_node ..! ln_type
            0  r@ .. is_node ..! ln_pri
            0" HMSL-RBF Handler" >abs r@ .. is_node ..! ln_name
            r@ rbf.set.vector
\
\ Make this the interrupt handler
            INTB_RBF r> SetIntVector()  dup prior-rbf-intr !
            ?dup IF ." Previous = " dump.int THEN
       ELSE
           ." RBF.INT.INIT - Not enough space for RBF interrupt!" cr
           abort
       THEN
    THEN
;

: RBF.INT.TERM ( -- , remove and free RBF interrupt )
    rbf-intr @
    IF  intb_rbf prior-rbf-intr @ SetIntVector() dump.int
        rbf-intr @ freeblock
        0 rbf-intr !
    THEN
;

decimal
\ Interrupt handler.
\ Check to see if buffer's empty.
\ If not grab byte and xmit.

ASM TBE.INT.handler ( -- , called when character finished xmitting )
\ A1 contains pointer to circbuff
    move.w   #[intf_TBE],$DFF09c    \ clear interrupt flag
    move.l   a1,a0    \ user data points to cb
    move.l   [cb_count](a0),d0
    beq      1$           \ branch if queue empty
    forth{ bsrto cb.ll.out }   \ get byte from queue
\    andi.l   #$FF,d0     \ not needed
    ori.w    #$100,d0     \ set stop bit
    move.w   d0,$dff030   \ xmit it
    move.l   [cb_count](a0),d0
    beq      1$           \ branch if queue empty
    rts
1$: move.w   #$0001,$DFF09A    \ disable xmit interrupt
    rts
END-CODE

: TBE.INT.INIT  ( -- , setup interrupt)
    TBE-intr @ 0=  ( make sure not done twice )
    IF
        MEMF_PUBLIC sizeof() interrupt allocblock ?dup
        IF  
            dup>r TBE-intr !  ( save for TERM )
\ Set values in structure.
            NT_INTERRUPT r@ .. is_node ..! ln_type
            0  r@ .. is_node ..! ln_pri
            0" HMSL-TBE handler" >abs r@ .. is_node ..! ln_name
            mio-out-cb >abs r@ ..! is_data
            ' TBE.int.handler >abs r@ ..! is_code
\
\ Make this the interrupt handler
            INTB_TBE r> SetIntVector()  dup prior-TBE-intr !
drop \            ?dup IF dump.int THEN
       ELSE
           ." TBE.INT.INIT - Not enough space for TBE interrupt!" cr
           abort
       THEN
    THEN
;

: TBE.INT.TERM ( -- , remove and free TBE interrupt )
    TBE-intr @
    IF  intb_tbe prior-TBE-intr @ SetIntVector() dump.int
        TBE-intr @ freeblock
        0 TBE-intr !
    THEN
;

ASM MIO.XMIT.LL ( d0:byte a0:circbuff -- , called from foreground )
    move.w    #$0001,$dff09a  \ tx interrupt disable
    move.l   [cb_count](a0),d1
    bne      1$                  \ branch if queue not empty
    move.w   $dff018,d1
    btst     #13,d1              \ branch if xmit buffer full
    beq      1$
      andi.l   #$FF,d0
      ori.w    #$100,d0     \ set stop bit
      move.w   d0,$dff030   \ xmit it
    bra      2$
1$: callcfa  cb.ll.in        \ hold in buffer
2$: move.w   #$8001,$DFF09A  \ enable interrupt
    rts
END-CODE

: MIO.XMIT  ( data -- )
    mio-out-cb >abs stack>d0/a0
    mio.xmit.ll
;

ASM (MIDI.WRITE)   ( addr count -- , write out data to port )
      callcfa   mio-out-cb  \ get address of buffer
      move.l    d7,a0
      add.l     org,a0      \ convert to absolute
      move.l	(a6)+,d7    \ restore count in D7
      move.l    a2,-(a7)    \ save A2
      move.l    (a6)+,a2
      add.l     org,a2      \ convert to absolute
      subq.l    #1,d7       \ setup count in D7 for DBRA
      blt       2$
1$:   move.b    (a2)+,d0    \ get next data byte
      callcfa   mio.xmit.ll  \ send it
      dbra.w    d7,1$
2$:   move.l    (a7)+,a2    \ restore A2
      move.l    (a6)+,d7    \ restore TOS
      rts
END-CODE

\ : (MIDI.WRITE)  ( addr count -- )
\     0 DO dup i + c@ mio.xmit LOOP drop
\ ;

: MIDI.NOWRITE ( addr count -- )
	2drop ." MIDI not on!" cr
;

'c midi.nowrite is midi.write

: (MIDI.RTC.TIME@)  ( -- real-time , of last byte received )
    midi-stamp-input @
    IF  mio-in-cb ..@ cb_out 1- dup 0<
        IF drop mio-in-cb ..@ cb_size 1-
        THEN cells
        time-stamps-ptr @ + @
    ELSE
        rtc.time@
    THEN
;

: MIDI.TIME@  ( -- , add time-advance to MIDI.RTC.TIME )
    midi.rtc.time@
    time-advance @ +
;

: MIDI.CHECK.ERRORS ( -- , report errors if any )
    mio-in-cb ..@ cb_overflowed
    IF  false mio-in-cb ..! cb_overflowed
        ." MIDI Input Overflowed Buffer." cr
    THEN
    mio-in-cb ..@ cb_overrun
    IF  false mio-in-cb ..! cb_overrun
        ." MIDI Input OverRan Port." cr
    THEN
;

: (MIDI.RECV) ( -- data true | false )
    mio-in-cb ..@ cb_count
    IF mio-in-cb  cb.out  true
\ We don't need to turn off interrupts because the
\ CB.OUT.LL routine only shares one value with CB.IN.LL
\ and it is decremented in one instruction.  If we turn
\ off interrupts, then we get more Byte OverRuns!!
\ Check for errors.
       midi-warnings @
       IF  midi.check.errors
       THEN
    ELSE false
    THEN
;


: MIO.ALLOC.BUF  ( size -- addr )
    memf_clear swap allocblock dup 0=
    IF ." MIDI.SER.INIT - Couldn't allocate MIDI buffers!" cr
       abort
    THEN
;

1 constant MIDI_NUM_PORTS  ( just one on Amiga )

: MC.SER.INIT ( -- )
    mc-if-init @ 0=
    IF  serial?
    	IF
    	mio.off
        midi-recv-size @ mio.alloc.buf dup mio-in-data !         
        midi-recv-size @ mio-in-cb cb.init
        midi-xmit-size @ mio.alloc.buf dup mio-out-data !         
        midi-xmit-size @ mio-out-cb cb.init
        midi-stamp-input @
        IF  midi-recv-size @ cells mio.alloc.buf time-stamps-ptr !
        THEN   
        rbf.int.init
        tbe.int.init
        ' (midi.write) is midi.write
        ' (midi.rtc.time@) is midi.rtc.time@
        ' (midi.recv) is midi.recv
        mc-if-init on
        midi-warnings on
        0 midi-port !
        mio.on
        time.init
        midi.eb.on \ 00001
        THEN
    THEN
;

: MC.SER.TERM ( -- )
    mc-if-init @
    IF
    	midi.eb.off \ 00001
    	time.term
    	mio.off
        rbf.int.term
        tbe.int.term
        ' midi.nowrite is midi.write
        ' false is midi.rtc.time@
        ' false is midi.recv
        mio-in-data freevar
        mio-out-data freevar
        time-stamps-ptr freevar
        mio.off
        mc-if-init off
        -serial
    THEN
;

\ just one kind of MIDI right now!

'c mc.ser.init is midi.ser.init
'c mc.ser.term is midi.ser.term
if.forgotten mc.ser.term
