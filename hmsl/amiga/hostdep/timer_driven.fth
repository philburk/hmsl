\ Background Task that is driven by the RTC clock.
\ This task gets signalled every tick.
\ It calls the Event Buffering Code.
\ By running the event buffering in a background task
\ instead of a direct timer interrupt
\ we avoid locking out the serial interrupts.
\ The RTC clock is at a higher priority then the serial port!
\
\ Author: Phil Burk
\ Copyright 1989 -  Phil Burk, Larry Polansky, David Rosenboom.
\ All Rights Reserved
\
\ MOD: PLB 10/17/90 Raise priority from 20 to 21 in TDR.INIT
\          to avoid delays
\ MOD: PLB 5/20/91 RemTask() and FREE.TASK when done.
\ 00001 PLB 2/17/92 Use variable for priority.

ANEW TASK-TIMER_DRIVEN
decimal
\ Global variables for communicating with background task.

variable SIGNAL-COUNT
variable TIME-SIGNAL#
variable TIME-SIGNALMASK
variable KILL-SIGNAL#
variable KILL-SIGNALMASK
variable SIGNALMASK
variable BACK-ERROR
variable BACK-TASK     \ non-zero if task running
variable TDR-TASK
variable TDR-PRIORITY  25 tdr-priority ! \ 00001

: START.TIME.SIGNAL  ( -- )
    0 findtask() dup back-task !
    -1 allocsignal() ?dup
    IF dup time-signal# !
       1 swap shift
       dup signalmask !
       dup time-signalmask !  ( -- task mask )
       set.timer.signal1
    ELSE drop  back-error on abort
    THEN
;

: START.KILL.SIGNAL  ( -- )
    -1 allocsignal() ?dup
    IF dup kill-signal# !
       1 swap shift 
       kill-signalmask !
    ELSE back-error on abort
    THEN
;

: START.SIGNALS  ( -- )
    start.time.signal
    start.kill.signal
    time-signalmask @ kill-signalmask @ or signalmask !
;

: WAIT.SIGNAL  ( -- mask )
    signalmask @ wait()
;

: STOP.SIGNALS  ( -- )
    0 0 set.timer.signal1
    time-signal# @ freesignal()
    kill-signal# @ freesignal()
;

: KILL.BACKGROUND  ( -- )
    back-task @ ?dup
    IF  kill-signal# @ 1 swap shift Signal()
    THEN
;


: TEST.SIGNAL ( -- )
    start.signals
    signal-count off
    BEGIN 1 signal-count +!
        wait.signal kill-signalmask @ and
    UNTIL
    stop.signals
;

: DRIVEN.TASK ( -- , run this as a background process )
    start.signals
    back-error @ 0=
    IF  rtc.time@ 1- eb-last-time !  ( set initial time )
\ Do this a long time -----------------------------------
        BEGIN
            eb.task
            wait.signal   ( WAIT here until timer signals )
            kill-signalmask @ and
        UNTIL
\ -------------------------------------------------------
        stop.signals
    THEN
    back-task off
;

: TDR.INIT  ( -- , launch event buffering as background task )
    " TDR.INIT" debug.type
    eb.init
    back-error off
	tdr-task @ 0=
    IF
    	0" HMSL_Event_Buffer" tdr-priority @ \ 00001
    	'c driven.task spawn.task
		dup tdr-task !
		0= abort" Couldn't spawn Background Event Processing"
    THEN
    back-error @
    IF ." TDR.INIT Background Event Buffering ran out of signals!" cr
       ." Someone in the system is hogging the signals!" cr
       abort
    THEN
;

: TDR.TERM ( -- )
    " TDR.TERM" debug.type
    kill.background
    8 0
    DO 100 msec back-task @ 0=  ( task signalled completion )
        IF eb.term leave
        THEN
    LOOP
    back-task @ 0=
    IF
    	tdr-task @ ?dup
    	IF	free.task
    		tdr-task off
    	THEN
    ELSE
    	." TDR.TERM - Couldn't get rid of task!" cr
    THEN
;

: SYS.INIT  sys.init tdr.init ;
: SYS.TERM  tdr.term sys.term ;

if.forgotten tdr.term

