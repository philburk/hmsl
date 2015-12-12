\ @(#) circular.fth 96/06/11 1.1
\ Circular Buffer for FIFO queue.
\
\ New values will be added to the circular buffer
\ using ADD: and read out using NEXT:
\
\ An error message will be printed if too many values
\ are added or removed.
\
\ Author: Phil Burk
\ Copyright 1987 Phil Burk, Larry Polansky, David Rosenboom
\
\ MOD: PLB 11/18/87 Use IV-CIRC-MANY for housekeeping.

EXISTS? OB.ELMNTS NOT .IF
	MRESET ADD:
.THEN

ANEW TASK-CIRCULAR

.NEED ADD:
METHOD ADD:
METHOD NEXT:
METHOD MANY:
.THEN

:CLASS OB.CIRCULAR <SUPER  OB.ARRAY
	IV.LONG IV-CIRC-WRITE  ( points to next empty hole )
	IV.LONG IV-CIRC-READ   ( points to first unread value )
		IV.LONG IV-CIRC-MANY

:M MANY:  ( -- number_values , number of values in buffer )
	iv-circ-many
;M

:M CLEAR: ( -- )
	0 iv=> iv-circ-write
	0 iv=> iv-circ-read
	0 iv=> iv-circ-many
;M

:M NEW: ( #elements -- )
	new: super
	clear: self
;M

:M ADD: ( value -- , add to FIFO queue )
	iv-circ-write dup iv-#cells <
	IF  to.self
		1 iv+> iv-circ-write
	ELSE drop 0 to.self
		1 iv=> iv-circ-write
	THEN
	1 iv+> iv-circ-many
	iv-circ-many iv-#cells >
	IF " ADD: OB.CIRCULAR" " Too much data in circular buffer!"
		er_return ob.report.error
	THEN
;M

:M NEXT: ( -- value , get next value from FIFO )
	iv-circ-read dup iv-#cells =
	IF drop 0 0 iv=> iv-circ-read
	THEN
	at.self
	-1 iv+> iv-circ-many
	iv-circ-many 0<
	IF " NEXT: OB.CIRCULAR" " Attempt to get more data than there is!"
		er_return ob.report.error
	ELSE
		1 iv+> iv-circ-read
	THEN
;M

:M PRINT: ( -- )
	cr many: self 0 max 0
	?DO  i iv-circ-read + iv-#cells mod
		dup . self at: [] . cr
		?pause
	LOOP
;M

;CLASS

if-testing @ .IF
OB.CIRCULAR CIRC-1
: TEST.CIRC
	8 new: circ-1
	0 add: circ-1 0
	50 1
	DO i add: circ-1 i
		many: circ-1 2 -
		IF ." MANY: doesn't work! = " many: circ-1 . cr
		THEN
		next: circ-1 rot .s = NOT
		IF ." Bad Value!"
		THEN
		?pause
	LOOP
	drop
	free: circ-1
;
.THEN
