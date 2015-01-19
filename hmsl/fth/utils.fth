\ @(#) utils.fth 96/06/11 1.1
\ General Utilities to support JForth & HMSL
\ These utilities are useful words which are not likely to be
\ supported by a typical Forth.  Words which some Forths support
\ but some not, should be defined in XXX_BASE.
\
\ Author: Phil Burk
\ Copyright 1986
\
\ MOD: PLB 11/9/86 Add SERVICE.TASKS/16
\ MOD: PLB 3/2/87 Use abort" in stack.check.
\ MOD: PLB 4/29/87 Remove include? , change V: to VARIABLE
\ MOD: PLB 9/3/87 Add DEBUG.TYPE
\ MOD: PLB 5/17/91 Merged with ho:more_utils

ANEW TASK-UTILS.FTH

VARIABLE IF-DEBUG   ( debug trace flag )
VARIABLE IF-TESTING ( flag for loading test code )

: DEBUG.TYPE ( $string -- , type if debugging )
    if-debug @
    IF >newline count type space
    ELSE drop
    THEN
;

: ?MORE   ( count -- flag , pause every 20, true if "Q")
    20 mod 0=     dup
    IF drop
       ." Q to quit, <CR> to continue ----" CR
       KEY ascii q =
    THEN
;


\ Stack depth checking , useful for catching leftovers --------
VARIABLE STACK-HOLD
: STACK.MARK  ( -- , record depth of stack )
    depth stack-hold !
;
: STACK.CHECK  ( -- , check to make sure stack hasn't been damaged )
    depth stack-hold @ = NOT
    IF  ." Old stack depth = " stack-hold @ .
        .s
        true abort" STACK.CHECK - Change in stack depth!"
    THEN
;


: $EQUAL  ( $string1 $string2 -- true_if_= , case insens. )
	>r count
	r> count 2 pick =
	IF text=?
	ELSE
		2drop drop false
	THEN
;


hex
: NFA.MOVE ( nfa addr -- , copy name field to address and fix like string )
    >r count 1f and ( n+1 c ,  remove immediate bit )
    dup r@ c! ( set length at pad )
    r> 1+ rot rot 0 ( a+1 n+1 c 0 )
    ?DO
        2dup c@ 7f and  ( remove flags from characters )
        swap c!
        1+ swap 1+ swap ( advance )
    LOOP 2drop
;

: NFA->$ ( nfa -- $string , copy to pad )
    pad nfa.move pad
;
decimal

\ Assistance for debugging.
: BREAK ( -- , dump stack and allow abort )
    .s cr ." BREAK - Enter A to abort" cr
    key toupper ascii A =
    IF abort THEN
;

: BREAK" ( xxxx" -- , give message and break )
    [compile] ."
    compile break
; immediate

\ ?terminal that only happens so often to avoid slowing down system
V: ?term-count
: ?TERMINAL/64  ( -- key? , true if key pressed, sometimes )
    ?term-count @ dup
    1+ 63 AND ?term-count !
    0= IF ?terminal
    ELSE false
    THEN
;
: ?TERMINAL/8  ( -- key? , true if key pressed, sometimes )
    ?term-count @ dup
    1+ 7 AND ?term-count !
    0= IF ?terminal
    ELSE false
    THEN
;

\ Range checking and clipping tools.
: INRANGE? ( n lo hi -- flag , Is LO <= N <= HI ? )
    2 pick <
    IF 2drop false
    ELSE >=
    THEN
;

: CLIPTO ( n lo hi -- nclipped , clip N to range )
    >r max r> min
;

: BAD.CHAR? ( CHAR -- FLAG , true if non printing)
    32 126 inrange? not
;

: SAFE.EMIT ( char -- , emit if safe or '.' )
    dup bad.char?
    IF drop ascii . emit
    ELSE emit
    THEN
;

: BAD.STR? ( addr count -- , scan string for bad chars)
    0
    ?DO  dup i + c@ bad.char?
        IF  cr dup i + dup h. c@ h.
        THEN
    LOOP drop
;

: Y/N  ( -- , ask for key )
	BEGIN
		." (y/n) " key dup emit tolower
		dup [char] y = over [char] n = or 0=
	WHILE drop cr
	REPEAT [char] y =
;

: Y/N/Q  ( -- true_if_y , ask for key , abort on 'Q')
	BEGIN
		." (y/n/q) " key dup emit tolower
		dup [char] q =
		IF cr abort
		THEN
		dup [char] y = over [char] n = or 0=
	WHILE drop cr
	REPEAT [char] y =
;

