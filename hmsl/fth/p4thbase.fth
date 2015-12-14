\ @(#) p4thbase.fth 96/06/11 1.1
\ Basic Host Dependant Forth words.
\ These are provided to make H4th into a generic Forth.
\
\ Author: Phil Burk
\ Copyright 1989 Phil Burk
\ All Rights Reserved
\
\ MOD: PLB 2/13/91 c/ashift/shift/ in CHOOSE for 62000 CHOOSE
\ MOD: PLB 6/24/91 Add WARRAY BARRAY
\ 00001 PLB 11/20/91 New EXIT, better DUP>R
ANEW TASK-P4THBASE

decimal
0 constant #HOST_AMIGA_JFORTH
0 constant #HOST_MAC_H4TH
1 constant #HOST_PFORTH

\ why isn't this in members.fth???
: RPTR    ( <name> -- ) -4 bytes ; \ relative relocatable pointer 00001
: ..!
    state @
    IF
        postpone s!
    ELSE
        [compile] s!
    THEN
; immediate

: ..@
    state @
    IF
        postpone s@
    ELSE
        [compile] s@
    THEN
; immediate

:  N>TEXT ( number -- addr count , convert number to text )
    (.)
;

: TEXT>STRING ( address count -- $string , convert to string on pad )
    dup pad c!  ( set count )
    pad 1+ swap cmove
    pad
;

: H. ( N -- , print a number in HEX )
    base @ swap hex . base !
;

: BELL  ( -- , ring bell )
    cr ." BEEP!" cr
;

: NOTYET  ( -- )
    ." NOT YET IMPLEMENTED!!" cr
;

decimal

\ Many FORTHS differ in the way that they implement -FIND
\ ' CFA PFA etc.  These should be avoided.
\ For the sake of consistency I shall define how I am using these terms:
\    CFA = address that can be passed to EXECUTE
\    PFA = address of data in a create does word.
\    LFA = address of backward link for dictionary.
\    NFA = address of count byte for word name.
HEX
    
: CFA->PFA  ( cfa -- pfa )
    >body
;
DECIMAL

: CFA->NFA  ( cfa -- nfa )
    >name
;

0 [if]
: LFA->NFA  ( lfa -- nfa )
    10 +
;
: LFA->CFA  ( lfa -- cfa )
    lfa->nfa nfa->cfa
;
: CFA->LFA  ( cfa -- lfa )
    cfa->nfa nfa->lfa
;
[then]

: PFA->NFA   ( pfa -- nfa , convert )
     body> >name
;

: NFA->PFA ( nfa -- pfa )
    name> >body
;


: HO.FIND.PFA   ( -- , pfa true | false , look for word in dict. )
\ Return address of parameter data.
     32 word find
     IF  >body true
     ELSE drop false
     THEN
;

: HO.FIND.CFA   ( -- , cfa true | 0 , look for word in dict. )
\ Return address of identifying address
\ Returns code address for dumping or comparison.
     32 word find
     IF  true
     ELSE ." Couldn't find " id. false
     THEN
;

: V: ( -- , declare variable and set to zero )
    variable
;

\ H4th uses absolute addresses.
: USE->ABS
; immediate
: ABS->USE
; immediate

: u2/  1 rshift ;
-1 u2/ constant HO_MAX_INT
HO_MAX_INT 1+ CONSTANT HO_MIN_INT

\ Used for debugging.
: TIB.DUMP ( -- , Dump current line )
    source type
;

\ ======= ====== ARITHMETIC GOODIES ======== ========
: | ( n m -- n|m , for easy AMIGA calls )
    OR
;

\ ======= ====== Memory Access ==== ======== =========
\ These words are used for accessing absolute memory locations
\ like registers, etc.
: ABS!   ( value absolute_address -- , store value )
    !
;
: ABSW!   ( value absolute_address -- , store value )
    w!
;
: ABSC!   ( value absolute_address -- , store value )
    c!
;

: ABS@   ( absolute_address -- value , fetch value )
    @
;
: ABSW@   ( absolute_address -- value , fetch value )
    w@
;
: ABSC@   ( absolute_address -- value , fetch value )
    c@
;

\ FORTH83 uses a different system for PICK !!!
\ Mach2 conforms to Forth83, -> PICK is 0 based.
: PICK83 PICK ;
: PICK79 1- PICK ;

0 constant NULL  ( for pointers )

: HOST"  ( <text>" -- , compile a host string )
    [compile] "  ( Mac uses count byte like Forth )
; immediate

." Declaring fake user variable!" cr
: U: ( <name> -- , Make a variable )
    V:
;

: XDUP ( x1 x2 x3 .. xN N -- x1 x2 .. x1 x2  , duplicate N items )
    dup 1+ swap 0
    ?DO dup pick79 swap
    LOOP drop
    ;


: WITHIN? ( N LO HI -- flag , true if within inclusive range )
    1+ within
;

: IN.DICT?  ( address -- flag , inside dictionary? )
    codebase here within?
;


: INLINE ; IMMEDIATE
: BOTH ;   IMMEDIATE

: DUP>R ( -- , must be inline , 00001 )
    postpone dup
    postpone >r
; immediate

\ Benchmark Forth words.
: PRINT.TIME  ( #ticks -- , print as seconds )
    100 *
    60 /mod
    swap 60 / + 0
    <# # # ascii . hold #s #> type space
;

0 [if]
: MEASURE ( <tib> -- , benchmark whatever follows )
    Tickcount() >r interpret Tickcount()
    r> - 
    cr ." That took " print.time ." seconds." cr
;
: RDEPTH ( -- return_stack_depth )
    r0 @ rp@ - cell/
;
[then]

V: MAX-INLINE   ( stub for JForth compatibility )

: VALLOT ALLOT ;

: RO.EXECUTE  ( rel_cfa -- )
    rel->use execute
;

\ Support to allow the debugger to work with ODE.
variable CURRENT-METHOD

\ Initialization needed for all variables!!!
: BASE.INIT
      8 tab-width !
      here rand-seed !
;

: BASE.TERM ;

: S->D  ( s -- d  )
    dup 0<
    IF -1
    ELSE 0
    THEN
;

: 2**N  ( n -- 2**n )
    1 swap shift
;

HEX
0 [if]
: ODD@  ( addr -- val , fetch from an odd address )
    [   5896 w,   \   addq.l  #4,(a6)
        205e w,   \   move.l  (a6)+,a0
        1d20 w,   \   move.l  -(a0),-(a6)
        1d20 w, 1d20 w, 1d20 w,
    ]
;
." Fix RETURN so that it works with DO LOOPs" cr bell
: RETURN ( -- )
    compile exit
; immediate

[then]

: 4/  2 arshift ;
: CELL/  2 arshift ;

: EMIT-TO-COLUMN  ( char col -- )
    out @ -
    0 max 80 min  0
    ?DO dup emit
    LOOP drop
;

\ Debug help
variable if-compile-debug
variable if-print-debug

if-compile-debug off
if-print-debug on

: DBUG.TYPE ( addr cnt -- )
    if-print-debug @
    IF
        type cr .s
    ELSE
        2drop
    THEN
;

: (DBUG")  ( -- , type following string )
    r> count 2dup + aligned >r
    dbug.type
;

: DBUG"  ( string" -- )
    if-compile-debug @
    IF
        state @
        IF  compile (dbug")  ,"
        ELSE ascii " parse dbug.type
        THEN
    ELSE
        ascii " parse 2drop
    THEN
; immediate

." WARNING: DO redefined as ?DO" cr
: DO  ( l s -- , should we use ?DO )
    postpone ?DO
; immediate

: ASHIFT  ( n shifter -- , shift left if positive, right if negative )
    dup 0>
    IF
        lshift
    ELSE
        negate
        arshift
    THEN
;

variable time-current

: 4+ 4 + ;
: 4- 4 - ;
: 4* 2 lshift ;

: ?QUIT ( -- false ) false ;
: ?STOP ( -- false ) false ;

: ? ( addr - , print contents of variable )
    @ .
;

$ 1D constant RIGHT_ARROW
$ 1C constant LEFT_ARROW
$ 1E constant SHIFT_RIGHT_ARROW
$ 1F constant SHIFT_LEFT_ARROW
