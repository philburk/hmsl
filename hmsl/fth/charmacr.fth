\ @(#) charmacr.fth 96/06/11 1.1
\ These words supports character and string manipulation.
\ These words are like the 'C' macros.
\
\ *********************************************************************
\ * HMSL Forth System                                                 *
\ * Author: Phil Burk                                                 *
\ * Copyright 1989 Phil Burk , All Rights Reserved                    *
\ *********************************************************************

ANEW TASK-CHARMACR

HEX

: ISUPPER ( char -- true_if_uppercase )
    41  5A within?
;

: ISLOWER ( char -- true_if_lowercase )
    61 7B within?
;

: ISDIGIT ( char -- true_if_digit )
    30 39 within?
;

: TOLOWER ( char -- lowercase_char , convert )
    dup isupper
    IF 20 +
    THEN
;

: TOUPPER ( char -- uppercase_char , convert )
    dup islower
    IF 20 -
    THEN
;

: ISPRINT ( char -- true_if_printable )
    20 7E within?
;

: ISBLACK ( char -- true_if_black )
    21 7E within?
;

: ISLETTER  ( char -- flag , is char a letter )
    dup isupper
    swap islower OR
;

: ISSPACE ( char -- flag , SPACE , TAB or NEWLINE )
    dup BL = 
    over 09 = OR
    swap 0A = OR
;

DECIMAL
