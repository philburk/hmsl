\ Graphics Utilities for HMSL to support control grids.
\
\ Author: Phil Burk
\ Copyright 1986 -  Phil Burk, Larry Polansky, David Rosenboom.
\ All Rights Reserved
\
\ MOD: PLB 9/30/86 Changed NDUP to XDUP, PICK to PICK83.

ANEW TASK-GRAPH_UTIL

V: UG-DELTAX    V: UG-DELTAY
: UG.HBARS ( X1 Y1 DX DY NBARS -- , Draw NBARS horizontal bars )
    rot ug-deltax !   swap ug-deltay !   ( Save increments )
    0 ?DO   ( Loop NBARS Times )
       2dup gr.move   2dup swap  ug-deltax @ + swap gr.draw
       ug-deltay @ +
    LOOP     2drop
;
: UG.VBARS ( X1 Y1 DX DY NBARS -- , Draw NBARS vertical bars )
    rot ug-deltax !   swap ug-deltay !   ( Save increments )
    0 ?DO   ( Loop NBARS Times )
       2dup gr.move   2dup  ug-deltay @ + gr.draw
       swap ug-deltax @ + swap
    LOOP     2drop
;

: UG.GRID ( X1 Y1 DX DY NX NY -- , DRAW A GRID )
    6 xdup   ( Duplicate all parameters )
    rot * swap 1+ ug.vbars   ( DRAW VERTICAL BARS )
    >r rot * swap r> 1+ ug.hbars ( Horizontal bars )
;

: UG.POS2I  ( X X0 DX -- CALCULATE INDEX FOR X )
     -rot -   dup 0>
     IF    swap /
     ELSE  swap / 1-
     THEN
;

: UG.INRANGE ( X X1 X2 -- FLAG , Check for x in range )
    1- within?
\    rot swap over >
\    -rot <= and
;

: UG.?HIT ( X X0 DX NX -- [INDEX] 0/1 , Calc index if in )
     >r ug.pos2i dup 0  r> ug.inrange
     IF 1 ELSE drop 0 THEN
;

: UG.BOX ( x1 y1 x2 y2 -- , Draw a box polyline )
    2over gr.move
    3 pick83 over gr.draw
    2dup gr.draw
    drop over gr.draw
    gr.draw
;
