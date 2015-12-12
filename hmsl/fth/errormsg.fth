\ @(#) errormsg.fth 96/06/11 1.1
\ Error Reporting
\ This is used by ODE.
\ I would not recommend using this for other programs.
\ It was developed for host independance.
\
\ For a turnkey application, you may want to modify this code.
\
\ Author: Phil Burk
\ Copyright 1986 Delta Research
\
\ MOD: PLB 4/27/88 Toned down error messages, FATAL -> ERROR-STOP
\ MOD: PLB 3/21/90 Removed call to TIB.DUMP
\ 00001 PLB 1/22/92 Use 0 ERROR instead of ABORT

ANEW TASK-ERRORMSG.FTH

: $. ( $string -- , print it )
	count type
;

: UNRAVEL  ( -- , show names on stack )
	>newline ." Calling sequence:"
\    r0 @ rp@ - cell/ 2+
\	50 min 0
	20 0
	DO  4 spaces
		rp@ i 2+ cell* + @
		dup code> >name ?dup
		IF id. drop
		ELSE .hex
		THEN cr?
	LOOP cr
;

0 CONSTANT ER_WARNING    ( Declare levels. )
1 CONSTANT ER_RETURN
2 CONSTANT ER_FATAL

CREATE ER-TRACEBACK? FALSE ,  ( should we trace back if bombed)

: ER.TRACEBACK
	er-traceback? @
	IF ." Calling Sequence: "
		unravel cr ." Hit any key to continue!" key drop cr
	THEN
;

( Report location of error and cause, abort if FATAL )
: ER.SHOW ( $PLACE $MESSAGE $LEVEL -- , SHOW ERROR )
	cr ." !!! " $. ."  in " swap $.
	."  - " $. ." !" bell cr
;

: (ER.REPORT) ( $PLACE $MESSAGE LEVEL -- , reports error )
\     cr ." TIB = " tib.dump cr
\     ." Hit key to continue." cr key drop
	>newline
	CASE
		ER_WARNING OF " WARNING" er.show
		ENDOF
		ER_RETURN OF er.traceback " ERROR" er.show
		ENDOF
		ER_FATAL OF er.traceback " ERROR-STOP"
			er.show abort
		ENDOF
		." Unrecognized Error LEVEL = " . CR
		er.traceback " UNKNOWN" er.show abort
	ENDCASE
;

defer ER.REPORT
'c (er.report) is er.report

: TEST.ERROR  " TEST.ERROR" " Something Terrible Happened!"
	ER_RETURN   ER.REPORT
;

