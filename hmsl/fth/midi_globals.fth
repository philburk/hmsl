\ MIDI Global deferred words used by both MIDI systems.

ANEW TASK-MIDI_GLOBALS.FTH

\ -------------------------------MIDI Globals--------------------------------
0   CONSTANT Modem_Port
1   CONSTANT Printer_Port
VARIABLE MIDI-PORT		\  Current port being used; 0=modem, 1=printer
2 constant MIDI_NUM_PORTS

variable MIDI-ERROR
variable MIDI-WARNINGS   ( true to enable warnings )
variable MIDI-RECV-SIZE
4096 MIDI-RECV-SIZE !
variable MIDI-XMIT-SIZE  ( this is used only by the Echo Ports )
4096 2* MIDI-XMIT-SIZE !

defer MIDI.WRITE ( addr count -- )

defer MIDI.RECV  ( -- byte true | false )

defer MIDI.RTC.TIME@  ( -- rtime , of last byte received )

defer MIDI.SER.INIT ( -- ) ' noop is MIDI.SER.INIT
defer MIDI.SER.TERM ( -- ) ' noop is MIDI.SER.TERM

\ Deferred Time Support

( time that current event is supposed to happen )
variable TIME-VIRTUAL

variable TIME-ADVANCE  ( time in advance that event buffered HMSL runs )
600 time-advance !

defer RTC.START ( -- )
defer RTC.STOP ( -- )
defer RTC.RATE! ( ticks/second -- )
defer RTC.RATE@ ( -- ticks/second )
defer RTC.TIME@  ( -- time )
defer RTC.TIME! ( time -- )
defer RTC.TIME+! ( n -- )
defer RTC.INIT  ( -- )
defer RTC.TERM ( -- )
' noop is rtc.init
' noop is rtc.term

variable RTC-USE-MIDI  ( if true use MIDI for time )

: MIDI.RESET.VECTORS  ( -- )
	'c false is midi.recv
	'c false is midi.rtc.time@
	'c 2drop is midi.write
;

: MIDI.CHECK.ERRORS  ( -- , report errors )
	midi-warnings @
	IF midi-error @
		CASE
			0 OF ( no error ) ENDOF
			>newline
			1 OF ." MIDI Buffer Overflow!" ENDOF
			2 OF ." MIDI Serial Transmission Error!" ENDOF
			3 OF ." MIDI Msg had Incorrect Length!" cr 
				." Perhaps a MIDI Cable was plugged in or unplugged!" ENDOF
			." MIDI Error# = " dup .
		ENDCASE cr
		midi-error off
	THEN
;

\ MIDI Transmit is Buffered and passed to MIDI.WRITE for time stamping
\ and event buffering.

64 constant MIDI_XPAD_MAX
create MIDI-XMIT-PAD midi_xpad_max allot
variable MIDI-XMIT-COUNT

: MIDI.FLUSH  ( -- )
	midi-xmit-count @ ?dup
	IF
		midi-xmit-pad swap midi.write
		0 midi-xmit-count !
	THEN
;

: MIDI.XMIT ( byte -- )
\ is the holding buffer full?
	midi-xmit-count @ dup>r
	[ midi_xpad_max 1- ] literal >
	IF
		rdrop 0 >r midi.flush
	THEN
	midi-xmit-pad r@ + c!   \ save in buffer
	r> 1+ midi-xmit-count ! \ advance counter
;

: HOST.MIDI.WRITE ( addr count -- )
	time-virtual @ hostMIDI_Write()
;

: HOST.MIDI.WRITE.DEBUG ( addr count -- , print MIDI as it goes by )
	2dup host.midi.write
	cr? ." MIDI: " time-virtual @  . ." - "
	0 ?DO dup i + c@ .hex LOOP drop cr
;

: HOST.MIDI.RECV  ( -- byte true | false )
	hostMIDI_Recv() dup 0<
	IF
		drop false
	ELSE
		true
	THEN
;

: USE.HOST.MIDI ( -- )
	." Use HOST MIDI." cr
	['] host.midi.write is midi.write
	['] host.midi.recv  is midi.recv
	['] hostMIDI_Init() is midi.ser.init
	['] hostMIDI_Term() is midi.ser.term
;
use.host.midi

: USE.HOST.CLOCK ( -- )
	." Use HOST Clock." cr
	['] hostStartClock() is rtc.start
	['] hostStopClock() is rtc.stop
	['] hostSetClockRate() is rtc.rate!
	['] hostQueryClockRate() is rtc.rate@
	['] hostQueryTime() is rtc.time@
	['] hostSetTime() is rtc.time!
	['] hostAdvanceTime() is rtc.time+!
	['] hostClockInit() is rtc.init
	['] hostClockTerm() is rtc.term
	['] hostSleep() is msec
;
use.host.clock
