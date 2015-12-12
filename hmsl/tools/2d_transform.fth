\ Transformation matrices.
\
\ Generate matrices from rotation, translation specs.
\ Multiply ELMNTS by a matrix.
\
\ Results are scaled by a shifter.
\
\ Derivation of rotation about a point xc,yc.
\ Involves translation by -xc, -yc
\ Followed by rotation about 0,0
\ Followed by translation by xc,yc.
\
\ MAT = (   1   0   0 )   ( cos -sin  0 )   (   1   0   0 )
\       (   0   1   0 ) * ( sin  cos  0 ) * (   0   1   0 )
\       ( -xc -yc   1 )   (   0    0  1 )   (  xc  yc   1 )
\
\     = ( c  -s 0 )                    (   1   0   0 )
\       ( s  c  0 )                  * (   0   1   0 )
\       ( -(xc + ys) (xs - yc) 1 )     (   x   y   1 )
\
\     = ( c -s 0 )
\       ( s  c 0 )
\       ( x-(xc+ys) y+(xs-yc) 1)
\
\ Author: Phil Burk
\ Copyright 1987 Phil Burk
\ All Rights Reserved

include? task-sine_table ht:sine_table

decimal

ANEW TASK-2D_TRANSFORM

METHOD POINT.MULTIPLY:
METHOD ARRAY.MULTIPLY:
METHOD PUT.SHIFT:
METHOD GET.SHIFT:
METHOD CALC.ROTATE.POINT:

\ Multiply Dimensions of an ELMNTS array by a matrix.
:CLASS OB.2D.TRANSFORM <SUPER OB.ELMNTS
    IV.LONG IV-MX-SHIFTER

:M INIT:
    init: super
    16 iv=> iv-mx-shifter
;M

:M NEW:
    3 2 new: super
;M

\ Assume order in matrix is:
\    0  1
\    2  3
\    4  5
:M POINT.MULTIPLY: ( x y -- x' y' )
    2dup 2 at.self * >r
    0 at.self * r> +
    4 at.self +  iv-mx-shifter negate ashift  ( -- x y x' )
    -rot 3 at.self * >r
    1 at.self * r> +
    5 at.self + iv-mx-shifter negate ashift  ( -- x' y' )
;M

:M ARRAY.MULTIPLY: { dim1 dim2 elmnts -- , multiply matrix }
    elmnts many: [] 0
    DO ( -- dim1 dim2 elmnts )    
        i dim1 elmnts ed.at: []
        i dim2 elmnts ed.at: []  ( -- x y )
        point.multiply: self
        i dim2 elmnts ed.to: []
        i dim1 elmnts ed.to: []
    LOOP
;M

:M CALC.ROTATE.POINT: ( xcenter ycenter angle  -- )
    3 set.many: self
    dup icos dup 0 to.self 3 to.self
    isin dup 2 to.self negate 1 to.self  ( -- x y )
    2dup 2 at.self * ( -- x y x ys )
    over 0 at.self * + ( -- x y x [xc+ys] )
    swap iv-mx-shifter ashift swap -
    4 to.self ( -- x y )
    tuck 0 at.self * ( -- y x yc  )
    swap 2 at.self * swap - ( -- y [xs-yc] )
    swap iv-mx-shifter ashift +
    5 to.self
;M

;CLASS

true .IF
OB.2D.TRANSFORM MAT1
OB.SHAPE ELMR
hex
: BUILD.MAT1
    new: mat1
    stuff{ 10000 0
    0 10000
    0 0     }stuff: mat1
;
decimal
: BUILD.ELMR
    10 2 new: elmr
    156 13 add: elmr
    127 72 add: elmr
    192 40 add: elmr
    221 23 add: elmr
    111 54 add: elmr
;

: DRAW.ELMR
    gr.check
    0 get: elmr gr.move
    many: elmr 1
    DO  i get: elmr gr.draw
    LOOP
;

: TEST1 ( -- )
    gr.clear
    BEGIN
        0 1 elmr array.multiply: mat1
        gr.color@ 3 mod 1+ gr.color!
        draw.elmr
        ?terminal
    UNTIL
;

: TEST2 ( angle -- )
    calc.stats: elmr
    0 get.dim.mean: elmr
    1 get.dim.mean: elmr
    rot calc.rotate.point: mat1
    test1
;

: MAT.INIT
    build.mat1
    build.elmr
;

: MAT.TERM
    free: mat1
    free: elmr
;
.THEN
