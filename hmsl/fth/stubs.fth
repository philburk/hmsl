\ Words needed to compile HMSL on pForth
\
\ History:
\ 050106 - unstub some MIDI and clock commands
\ 060108 - change behavior of DO to match F83 style

anew task-stubs.fth

variable host-debug
host-debug on

\ Unimplemented Host specific words
: hostSetClockRate() ( ticks/second -- )
	host-debug @ IF ." hostSetClockRate()" cr THEN
	DROP
;
: hostAdvanceTime() ( ticks -- )
	host-debug @ IF ." hostAdvanceTime()" cr THEN
	DROP
;

: hostStartClock() ( -- )
	host-debug @ IF ." hostStartClock()" cr THEN
;
: hostStopClock() ( -- )
	host-debug @ IF ." hostStopClock()" cr THEN
;
: hostClockInit() ( -- )
	host-debug @ IF ." hostClockInit()" cr THEN
;
: hostClockTerm() ( -- )
	host-debug @ IF ." hostClockTerm()" cr THEN
;
: hostSetTime() ( ticks -- )
	host-debug @ IF ." hostSetTime()" cr THEN
	DROP
;

\ init and term chain starts here -----------------------

exists? SYS.INIT not [if] 
    : SYS.INIT hostInit() drop ;
    : SYS.TERM hostTerm() ;
    : SYS.RESET ;
[THEN]

