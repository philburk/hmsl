\ Words needed to compile HMSL on pForth
\
\ History:
\ 050106 - unstub some MIDI and clock commands
\ 060108 - change behavior of DO to match F83 style

anew task-stubs.fth

variable host-debug
host-debug on

: hostStartClock() ( -- )
	host-debug @ IF ." hostStartClock() is a noop" cr THEN
;
: hostStopClock() ( -- )
	host-debug @ IF ." hostStopClock() is a noop" cr THEN
;


\ init and term chain starts here -----------------------

exists? SYS.INIT not [if] 
    : SYS.INIT hostInit() drop ;
    : SYS.TERM hostTerm() ;
    : SYS.RESET ;
[THEN]

