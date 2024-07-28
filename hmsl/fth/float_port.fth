\ Floating point words from HMSL redefined using ANSI Forth
\
\ Author: Phil Burk
\ Copyright 2016 -  Phil Burk, Larry Polansky, David Rosenboom.
\ All Rights Reserved

ANEW TASK-FLOAT_PORT

: FPINIT ; \ not needed, floats always available
: FPTERM ;

: FMOD ( r1 r2 -f- rem{f1/f2} , calc remainder )
    fover fover f/
    f>s s>f
    f* f-
;

: F= ( r1 r2 -f- , -- flag )
    f- f0=
;

: F>  ( r1 r2 -f- , -- flag )
    fswap f<
;

: F>I ( r -f- , -- n )
    f>s
;

: FIX  ( r -f- , -- n , rounds )
    fround
    f>s \ fround leaves the result on the float stack!
    \ See https://github.com/philburk/hmsl/issues/161
;

: FLOAT ( n -- , -f- r , convert to float )
    s>f
;

: I>F ( n -- , -f- r , convert to float )
    s>f
;

: INT ( r -f- , -- n )
    f>s
;

: F>TEXT ( r -f- addr count , converts fp to text )
    (f.)
;

: F.R ( r -f- , width -- , set width of field, print )
    >r   \ save width
    (f.)
    r> over - spaces
    type
;

: PLACES ( n -- , sets default number of fractional digits )
    set-precision    \ this is not quite right, this sets significant digits
;

: FNUMBER? ( $string -- true | false , -f- r )
    number?       \ handles both ints and floats
;
