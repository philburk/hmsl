\ This Morph provides a simple container for
\ functions that need to be tasked in a pseudo-multitasking
\ environment.
\
\ Each function is passed the job's address
\ which provides access to the duration, the done
\ flag, the instrument, etc.
\
\ ( job_addr -- , stack diagram for a job function.)
\
\ Author: Phil Burk
\ Copyright 1986 -  Phil Burk, Larry Polansky, David Rosenboom.
\ All Rights Reserved
\
\ MOD: PLB 5/23/87 Added STOP:
\ MOD: PLB 6/1/87 Changed STACK for JOBs. Add SET.DONE:
\ MOD: PLB 6/15/87 Add DEFAULT:
\ MOD: PLB 7/22/87 Add SEND.DONE: to TASK:
\ MOD: PLB 10/7/87 Fix repeat count handling in TASK:
\ MOD: PLB 10/22/87 FREE instrument in hierarchy.
\ MOD: PLB 2/18/89 Don't use RTC.RATE@ to set TOO-LATE.
\ MOD: PLB 5/24/89 Change to new design.
\ MOD: PLB 2/27/90 Moved BUILD: from Player
\ MOD: PLB 4/5/90 Rewrote STOP code
\ 00001 PLB 12/4/91 Moved DONE check before execution of function
\   of functions.  Check stack for depth changes.

ANEW TASK-JOB.FTH

METHOD PUT.DURATION:        METHOD GET.DURATION:
METHOD PUT.INSTRUMENT:      METHOD GET.INSTRUMENT:
METHOD USE.DURATIONAL:      METHOD USE.EPOCHAL:
METHOD PUT.TOO.LATE:        METHOD GET.TOO.LATE:

:CLASS OB.JOB <SUPER OB.PRODUCTION
    IV.LONG  IV-JB-DURATION
    IV.LONG  IV-JB-INSTRUMENT
    IV.SHORT IV-JB-EPOCHAL?   ( Use epochal scheduling? )
    IV.LONG  IV-JB-TOO-LATE   ( When too late to play an element )

:M DEFAULT: ( -- )
    default: super
    0 iv=> iv-jb-instrument
    1 iv=> iv-jb-duration
    true iv=> iv-jb-epochal?
\ If more than five minutes late, forget it. Based on 60 hz clock.
    rtc.rate@ 300 * iv=> iv-jb-too-late
;M

:M DEFAULT.HIERARCHY: ( -- , reset instrument too )
    iv-jb-instrument ?dup
    IF default: []
    THEN
    default.hierarchy: super
;M

:M FREE.HIERARCHY: ( -- , free instrument too )
    iv-jb-instrument ?dup
    IF free: []
    THEN
    free.hierarchy: super
;M

:M PUT.INSTRUMENT: ( instrument -- )
    iv=> iv-jb-instrument
;M

:M GET.INSTRUMENT: ( -- instrument)
    iv-jb-instrument
;M

:M PUT.DURATION: ( duration -- )
    iv=> iv-jb-duration
;M

:M GET.DURATION: ( -- duration)
    iv-jb-duration
;M

:M USE.EPOCHAL:  ( -- , Use epoch for scheduling )
    true iv=> iv-jb-epochal?
;M
:M USE.DURATIONAL:  ( -- , Use duration for scheduling )
    false iv=> iv-jb-epochal?
;M

:M PUT.TOO.LATE: ( #ticks -- , set max allowed lateness )
    iv=> iv-jb-too-late
;M
:M GET.TOO.LATE: ( -- #ticks, fetch max allowed lateness )
    iv-jb-too-late
;M

: JB.SET.DELAY ( delay -- , set timenext to delay )
    iv-jb-epochal?
    IF ?dup  ( non-zero delay? )
       IF iv+> iv-time-next
       ELSE time@ iv=> iv-time-next  ( advance timenext anyway !!!)
       THEN
    ELSE time@ + iv=> iv-time-next
    THEN
;

: JB.IN.TIME?  ( -- if_not_too_late , are we outside window? )
   iv-jb-epochal?
   IF iv-time-next iv-jb-too-late + time@ time>
   ELSE true
   THEN
;

:M CUSTOM.EXEC: ( -- false )
	many: self 0>
	IF
    	false iv=> iv-col-done?
    	iv-jb-instrument ?dup
    	IF open: []
    	THEN
    	self ao.post false
	ELSE
		vtime@ true
	THEN
;M

: JOB.STOP  ( -- , stop job , don't send DONE )
    iv-time-next vtime!  ( set vtime so note OFFS are not before ON )
    iv-jb-instrument ?dup
    IF close: []
    THEN
    self ao.unpost
;

:M TERMINATE: ( time -- , stop tasking )
    iv-if-active
    IF  job.stop
    	morph.stop
    ELSE drop
    THEN
;M

: JOB.EXEC.STUFF ( -- , execute job's functions )
	jb.in.time?  ( is it too late? )
	IF  ( -- done? default_dur self )
		depth >r
		reset: self
		BEGIN manyleft: self
		WHILE self next: self execute
		REPEAT
		depth r> = not
		IF
			" TASK:" " Stack error in job function"
				er_fatal ob.report.error
		THEN
	THEN
	iv-jb-duration jb.set.delay
;

:M TASK: ( -- , perform jobs if time )
\ This used to be after the next block but was moved here so that
\ jobs will always wait their duration before terminating or repeating.
\ Check for done? , repeat if counts left. 00001
\
    iv-time-next doitnow?
    IF
    	iv-col-done?
    	IF
    		col.do.repeat iv-repcount 0=
        	IF
        		iv-time-next self terminate: []
        	ELSE
        		false iv=> iv-col-done?
    			iv-time-next doitnow?   \ in case of repeat delay
    			IF
    				job.exec.stuff
    			THEN
        	THEN
    	ELSE
    		job.exec.stuff
    	THEN
    THEN
;M

:M PRINT: ( -- )
    print: super ?pause
    ." Instrument    = " iv-jb-instrument ob.name cr
    iv-jb-epochal?
    IF ." Epochal scheduling." cr
       ." Too late window = " iv-jb-too-late . cr
    ELSE ." Durational scheduling." cr
    THEN ?pause
    ." Duration = " iv-jb-duration . cr
;M

:M BUILD:  ( shape instrument -- )
    put.instrument: self
    1 new: self
    add: self
;M

;CLASS

if-testing @ [IF]

: TEST.JOB ( job -- )
    100 choose 50 + swap put.duration: [] ( set new duration )
   ." Yowzah" cr
;

OB.JOB JOB-T
2 new: job-t

'c test.job add: job-t

[THEN]
