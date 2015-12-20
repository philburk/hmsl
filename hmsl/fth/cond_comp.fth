\ Conditional Compilation
\
\ *********************************************************************
\ * HMSL Forth System                                                 *
\ * Author: Phil Burk                                                 *
\ * Copyright 1989 Phil Burk , All Rights Reserved                    *
\ *********************************************************************
\
\ MOD: PLB 10/9/90 Removed check for ?TERMINAL in .ELSE
decimal
ANEW TASK-COND_COMP

\ Lifted from X3J14 dpANS-6 document.

: .ELSE  ( -- )
    1
    BEGIN                                 \ level
      BEGIN
        BL WORD                           \ level $word
        COUNT  DUP                        \ level adr len len
      WHILE                               \ level adr len
        2DUP  S" .IF"  COMPARE 0=
        IF                                \ level adr len
          2DROP 1+                        \ level'
        ELSE                              \ level adr len
          2DUP  S" .ELSE"
          COMPARE 0=                      \ level adr len flag
          IF                              \ level adr len
             2DROP 1- DUP IF 1+ THEN      \ level'
          ELSE                            \ level adr len
            S" .THEN"  COMPARE 0=
            IF
              1-                          \ level'
            THEN
          THEN
        THEN
        ?DUP 0=  IF EXIT THEN             \ level'
      REPEAT  2DROP                       \ level
    REFILL 0= UNTIL                       \ level
    DROP
;  IMMEDIATE

: .IF  ( flag -- )
	0=
	IF POSTPONE .ELSE
	THEN
;  IMMEDIATE

: .THEN  ( -- )
;  IMMEDIATE

: .NEED ( <name> -- start compiling if not found )
    [compile] exists? not [compile] .IF
;

: $REMOVE" ( $string -- , remove trailing " )
    dup count 1- + c@ ascii " =
    IF cr ." Removing extraneous " ascii " emit ."   from name!" cr
        dup c@ 1- swap c!
    ELSE drop
    THEN
;

