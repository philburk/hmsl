\ Some miscellaneous tools that might be useful and 
\ are used in HMSL.
\
\ Author: Phil Burk
\ Copyright 1986 -  Phil Burk, Larry Polansky, David Rosenboom.
\ All Rights Reserved
\
\ MOD: PLB 10/22/87 Moved 3DROP from INSTRUMENTS file.
\ MOD: PLB 11/16/87 Added ?QUIT
\ MOD: PLB 6/17/89 Add CHOOSE+/-
\ MOD: PLB 11/16/89 Add LOGBASE2
\ MOD: PLB 9/25/91 Added REDUCE.FRACTION , RATIO+
\ 00001 PLB 2/6/92 Add ?EXECUTE and EXEC.STACK?

ANEW TASK-MISC_TOOLS.FTH

\ Larry's Utilities ========================================

\ set and reset a variable
: ENABLE ( a -- ) on ; ( e.g. V.FOO ENABLE )
: DISABLE ( a -- ) off ; ( e.g V.FOO DISABLE )

\ alternate for ?terminal ...
: ESC ?terminal ;

\ alternate shorter words for  and constant 
: K: constant ;

\ ******************************************

\ some simple utilities from dr.dobbs 83 "almost standard" extensions
: INCR ( a - ) 1 swap +! ; ( increments a variable -- like c 1++ )
: DECR ( a - ) -1 swap +! ; ( decrements a variable )
\ ==========================================================

: ESCAPE?  ( -- , ABORTS if key hit )
    ?TERMINAL IF cr ." Abort with ESCAPE?" cr ABORT THEN
;

\ Aliases for existing words.
: BEEP bell ;
: MS msec ;

\ Bit manipulation.
: SET.BITS  ( flag mask value -- -- value' , set or reset bits )
    over -1 xor and
    swap rot
    IF or
    ELSE drop
    THEN
;

\ Interpolate a value along a line defined by two points
\ (x1,y1) and (x2,y2).
\ by Phil Burk
v: INTERP-X1  v: INTERP-Y1
v: INTERP-DX  v: INTERP-DY

\ pass in endpoints
: SET.INTERP  ( x1 y1 x2 y2 -- , define line for interpolation )
    rot dup interp-y1 !  - interp-dy !
    swap dup interp-x1 ! - interp-dx !
;

: INTERP ( x -- y , interpolate value along line )
\  y = ((x-x1) *  dy / dx)  + y1
    interp-x1 @ -
    interp-dy @ interp-dx @ */
    interp-y1 @ +
;

\ Return value which randomly deviates from 'last1' by a 
\ 1/f distribution
\
\ output range: 0<=1/f-next<=2*1/f-bitmask
\ scale like: 1/f  200 * 128 / to get 0 200 range,
\ given 0, 128 output

\ author: Ken Worthy, from an algorithm from Bell Labs
\ by Charles Dodge
V: 1/F-LAST1 V: 1/F-NEXT
V: 1/F-BITMASK V: 1/F-PROBIT
V: 1/F-FLIPFLOP

\ This distribution uses 1/f-last1 as the "seed" for successive
\ calls. 
decimal
: 1/F ( 1/f-last1 -- 1/f-next , generate next 1/f value)
        1/f-last1 !
        0 1/f-next !
        64 1/f-bitmask !
        78125 1/f-probit !
        BEGIN
                1/f-last1 @ 1/f-bitmask @ / 1/f-flipflop !
                1/f-flipflop @ 1 =
                IF
                        1/f-last1 @ 1/f-bitmask @ - 1/f-last1 !
                THEN
                10000 choose 1000 * 1/f-probit @ < ( yields 0-10000000)
                IF
                        1 1/f-flipflop @ - 1/f-flipflop !
                THEN
                1/f-next @ 1/f-flipflop @ 1/f-bitmask @ * + 1/f-next !
                1/f-bitmask @ 2/ 1/f-bitmask !
                1/f-probit @ 2* 1/f-probit !
                1/f-bitmask @ 1 < 
        UNTIL
        1/f-next @
;


\ ----------- more goodies ------------
: 3DROP ( a b c -- )
    2drop drop
;

: CHOOSE+/-  ( N -- r , calc number from +/- N inclusive )
    dup 2* 1+ choose swap -
;

\ ---------------------------
: CFA.  ( cfa | 0 -- , print CFA safely )
    ?dup
    IF >name id.
    ELSE 0 .
    THEN
;


: LOGBASE2  ( n -- log2[n] , position of highest bit )
    -1 swap
    BEGIN dup 0>
    WHILE >r 1+ r> -1 shift
    REPEAT drop
;

\ --------------------------------------
: IN.DICT?  ( addr -- flag , true if in dictionary )
    0 rel->use
    here
    within?
;


\ handy tool
create PRIMES
here 2 , 3 , 5 , 7 , 11 , 13 , 17 , 19 , 23 , 29 , 31 , 37 ,
here swap - cell/ constant NUM_PRIMES

: REDUCE.FRACTION  { top bot | prime -- top' bot' }
	num_primes 0
	DO
		i cell* primes + @ -> prime
		prime top >
		prime bot > OR
		IF leave
		THEN
\
		BEGIN
			top prime /mod  ( rem quo )
			swap 0=
			IF ( tquo )
				bot prime /mod
				swap 0=
				IF ( -- tquo bquo )
					-> bot
					-> top false
				ELSE 2drop true \ try next prime
				THEN
			ELSE
				drop true
			THEN
		UNTIL
	LOOP
	top bot
;

: CLIP.FRACTION { numer denom maxden -- numer denom }
\ force to below max denominator
	denom maxden >
	IF
		numer maxden denom */
		maxden
		reduce.fraction -> denom -> numer
	THEN
	numer denom
;

: RATIO+  { n1 d1 n2 d2 -- n3 d3 }
	d1 d2 =
	IF
		n1 n2 + d1
	ELSE
    	n1 d2 *  n2 d1 * +
    	d1 d2 *
	THEN
;

defer DEFERRED.EXECUTE
' EXECUTE is DEFERRED.EXECUTE

: ?EXECUTE ( cfa -- , execute if non zero )
    ?dup
    IF deferred.execute
    THEN
;

: EXEC.STACK? { usercfa depthchange | saved -- , execute if non zero }
	depth depthchange + -> saved
\
    usercfa deferred.execute
\
	depth saved -
    IF
    	>newline
    	." Stack error in user function: " usercfa >name id.
    	abort
    THEN
;
