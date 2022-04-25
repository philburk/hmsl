\ Common Host dependant FORTH words.
\
\ This file is used to enhance the portability of code between
\ different Forths.  A large application that has been ported
\ between 7 different Forth environments was examined.  Any simple
\ words that seemed to be Host or Forth dependant were put in
\ this file. 
\
\ This file was originally part of HMSL.
\ HMSL is a music language written by Phil Burk,
\ Larry Polansky, and David Rosenboom at Mill's college CCM.
\ The Object Development Environment , graphics language, ajf_base,
\ and utils are part of that system.
\ Constants are set in this file that control conditional
\ compilation in other files.
\ This is so that the same source code can be used with several
\ different Forths.  If you are supporting more than one machine
\ with your code, you may want to use a technique similar to this.
\ HMSL also runs on the Macintosh under MACH2, another
\ excellent Forth.
\
\ These are the definitions required for HMSL using
\ JForth on the Amiga.
\
\ Some related files are ajf_dict , ajf_debug
\
\ Author: Phil Burk
\ Copyright 1986 Delta Research
\
\ MOD: PLB 1/29/88 Add CFA->NFA
\ MOD: PLB 2/19/89 Add flushemit to BELL
\ MOD: PLB 8/31/89 Add IF.REL->USE
\ MOD: PLB 4/26/91 Make CELL* BOTH
\ MOD: PLB 6/5/91 Add ?QUIT, moved from MISC_TOOLS

ANEW TASK-AJF_BASE
decimal

: H. ( num -- , print a number in HEX )
    base @ swap hex . base !
;

: V: ( -- , declare variable and set to zero )
    variable
;

: BELL  ( -- , ring bell or flash screen )
    7 emit flushemit
;

\ Used for relocation of addresses between snapshots.
\ These words are needed for Forths that use absolute addressing.
: REL->USE  ( REL_address -- USEABLE_address )
; immediate
: USE->REL  ( USEABLE_address -- REL_address )
; immediate

: IF.REL->USE  ( REL_address -- USEABLE_address )
; immediate
: IF.USE->REL  ( USEABLE_address -- REL_address )
; immediate

: USE->ABS
   >abs
;
: ABS->USE
   >rel
;

-1 -1 shift constant HO_MAX_INT
HO_MAX_INT 1+ CONSTANT HO_MIN_INT

V: TAB-WIDTH  8 TAB-WIDTH !
: TAB  ( -- , tab over to next stop )
    space out @ tab-width @ mod
    tab-width @   swap - spaces
;


: CELL*  ( n -- n*cell , useful for indexing into tables )
    cells
    both
;

: VALLOT ( #bytes -- , allot space in VARIABLE area )
    allot   ( in dictionary for JFORTH )
;

\ FORTH83 uses a different system for PICK !!!
\ JForth conforms to Forth83, -> PICK is 0 based.
: PICK83 PICK ;
: PICK79 1- PICK ;

: HOST"  ( <text>" -- , compile a host string )
    [compile] 0"  ( Amiga 'C' library NUL terminated string.)
; immediate

\ Fast Math
\ These operate directly on TOS which is cached in D7
HEX
: 4+ [ 5887 w, ] inline ; ( ADDQ.L #4,D7 )
: 4- [ 5987 w, ] inline ;
: 4/ [ E487 w, ] inline ;
: 4* [ E587 w, ] inline ;
DECIMAL

\ Some systems have difficult USER variables.
: U:  ( -- , Make a USER variable, automatically allocated )
    USER
;

\ Dictionary conversion support.
: CFA->NFA ( cfa -- nfa )
    >name
;

false constant #HOST_MAC_H4TH

.NEED ?QUIT
: ?QUIT ( -- flag , Pause, true if 'q' )
    ." Hit any key to continue, 'q' to quit:"
    key cr ascii q =
;
.THEN

