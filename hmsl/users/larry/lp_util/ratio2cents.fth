\ Calculate the relative cents value for a given ratio.
\
\ Author: Phil Burk
\ Copyright 1986 -  Phil Burk, Larry Polansky, David Rosenboom.
\ All Rights Reserved
\
\ This file was originally written for JForth on the Amiga.
\ It has been ported to ANS Forth floating point, as used by pForth in HMSL.
\
\ Differences between JForth and ANS Forth floating point:
\
\ 1) JForth kept floating point numbers on the data stack, mixed in with
\    integers. ANS Forth keeps them on a separate floating point stack.
\    So words like SWAP, DUP and DROP no longer affect floats.
\    Use FSWAP, FDUP and FDROP for floats.
\    The old code used  FLOAT SWAP FLOAT SWAP  to convert both integers and
\    then swap the two floats. Now we SWAP the integers first, then convert.
\
\ 2) LITERAL compiles a number from the data stack. In JForth that worked
\    for floats too. In ANS Forth, a float calculated between [ and ]
\    is left on the floating point stack, so LITERAL would find an empty
\    data stack and fail with "Stack underflow". Use FLITERAL instead.
\    The [ and ] words work the same in both: they interpret the words
\    between them while compiling, so the value is calculated only once.
\
\ 3) In JForth, FIX truncated, so the code added 0.5 to round to the
\    nearest cent. In HMSL, FIX rounds, see fth/float_port.fth,
\    so adding 0.5 would round twice, eg. 2/1 gave 1201 cents.
\
\ 4) Standard ANS Forth needs an exponent in a float literal, eg. 1200.0E0.
\    pForth also accepts 1200.0 as a float, so it is used here as before.
\
\ MOD: 10/24/26 Port to ANS Forth floating point for pForth.

\ These are only needed for JForth. In HMSL, F* already exists so the
\ include is skipped, and FPINIT does nothing.
include? f* ju:float.ffp
FPINIT   ( initialize for later call to FLOG )

ANEW TASK-RATIO2CENTS

decimal
: RATIO->CENTS  ( numerator denominator -- cents )
\ Equation:  cents = round(log(nm/dn) / log(2.0) * 1200.0)
\ Any base of logarithm works because only the ratio of two logs is used.
    swap float float f/                \ -f- nm/dn
    flog [ 2 float flog ] fliteral f/  \ log(2) is calculated when compiled
    1200.0  f*
    fix                                \ rounds to the nearest integer
;

: RATIO.TABLE  ( max_numerator -- , print table of ratios and cents )
\ Print horizontal axis legend.
    cr 2 spaces
    dup dup 8 - 1 max
    DO i 8 .r  ( print numerators )
    LOOP cr
    ( -- max )
    dup 1
    DO  i 2 .r  ( print denominators )
        dup dup 8 - 1 max
        DO
            i j ratio->cents 8 .r  ( print cents )
        LOOP cr
    LOOP
    drop
;
