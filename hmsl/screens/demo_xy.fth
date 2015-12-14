\ Test 2D XY controllers and horizontal and vertical faders.

include? ob.xy.controller h:ctrl_xy

ANEW TASK-DEMO_XY

OB.XY.CONTROLLER  CG-XY-2D
OB.XY.CONTROLLER  CG-XY-HORIZONTAL
OB.XY.CONTROLLER  CG-XY-VERTICAL
OB.SCREEN   SCR-XY

\ Define constants for displaying results.
3100 constant DXY_TEXT_X
3000 constant DXY_TEXT_Y
300 constant DXY_TEXT_DX

\ This is a fancy extension to drawing that is entirely optional.
: DXY.DRAW { | hi_x hi_y lo_x lo_y dxval -- }
\ draw tick marks along bottom edge of control
    1 gr.color!
    0 get.rect: cg-xy-2d
    -> hi_y -> hi_x -> lo_y -> lo_x
\
\ draw a tick mark every 50 units of value
    xy_horizontal_part get.max: cg-xy-2d 1+
    xy_horizontal_part get.min: cg-xy-2d
    DO  i  value>x: cg-xy-2d
        hi_y 2dup 10 + gr.move gr.draw
        50
    +LOOP
    1 gr.color!
;

: DXY.TELL.XY ( xval yval -- )
    dxy_text_x dxy_text_y scg.move \ move graphics cursor to scaled graphics xy
    " X,Y = " gr.text  \ draw text at that position
    swap gr.number " , " gr.text
    gr.number "     " gr.text
;

: DXY.2D.INIT  ( -- , setup theremin control )
    new: cg-xy-2d
    3000 2000 put.wh: cg-xy-2d
    'c dxy.draw put.draw.function: cg-xy-2d
\
\ Set horizontal range
    0 xy_horizontal_part put.min: cg-xy-2d
    1000 xy_horizontal_part put.max: cg-xy-2d
    500 xy_horizontal_part put.value: cg-xy-2d
\
\ Set horizontal range
    100 xy_vertical_part put.min: cg-xy-2d
    400 xy_vertical_part put.max: cg-xy-2d
    200 xy_vertical_part put.value: cg-xy-2d
\
\ set knob sizes
\ positive numbers imply world coordinates like PUT.WH:
    100 xy_horizontal_part put.knob.size: cg-xy-2d
\ negative numbers imply device coordinates
    -10 xy_vertical_part put.knob.size: cg-xy-2d
\
\ Specify which function should be called for which action
    'c dxy.tell.xy put.down.function: cg-xy-2d
    'c dxy.tell.xy put.move.function: cg-xy-2d
    'c dxy.tell.xy put.up.function: cg-xy-2d
;

: DXY.TELL.H ( xval yval -- )
\ move graphics cursor to scaled graphics xy
    dxy_text_x dxy_text_y dxy_text_dx + scg.move
\
    " H = " gr.text  \ draw text at that position
    drop gr.number "     " gr.text
;

: DXY.HORIZONTAL.INIT  ( -- , setup horizontal controller )
    new: cg-xy-horizontal
    2000 300 put.wh: cg-xy-horizontal
    " Title" put.title: cg-xy-horizontal
    stuff{ " Label" }stuff.text: cg-xy-horizontal
\
\ Set horizontal range
    0 xy_horizontal_part put.min: cg-xy-horizontal
    80 xy_horizontal_part put.max: cg-xy-horizontal
\
\ Disable vertical motion, sets vertical knob size
    cg-xy-horizontal xy.only.horizontal
\
    100 xy_horizontal_part put.knob.size: cg-xy-horizontal
\
    'c dxy.tell.h put.down.function: cg-xy-horizontal
    'c dxy.tell.h put.move.function: cg-xy-horizontal
    'c dxy.tell.h put.up.function: cg-xy-horizontal
;

: DXY.TELL.V ( xval yval -- )
\ move graphics cursor to scaled graphics xy
    dxy_text_x dxy_text_y dxy_text_dx 2* + scg.move
\
    " V = " gr.text  \ draw text at that position
    nip gr.number "     " gr.text
;

: DXY.VERTICAL.INIT  ( -- , setup vertical controller )
    new: cg-xy-vertical
    100 2000 put.wh: cg-xy-vertical
\
\ Set vertical range
    0 xy_vertical_part put.min: cg-xy-vertical
    200 xy_vertical_part put.max: cg-xy-vertical
\
\ Disable horizontal motion, sets vertical knob size
    cg-xy-vertical xy.only.vertical
\
    300 xy_vertical_part put.knob.size: cg-xy-vertical
\
    'c dxy.tell.v put.down.function: cg-xy-vertical
    'c dxy.tell.v put.move.function: cg-xy-vertical
    'c dxy.tell.v put.up.function: cg-xy-vertical
;

: DXY.INIT ( -- )
\ initialize each control
    dxy.2d.init
    dxy.horizontal.init
    dxy.vertical.init
\
\ put controls in screen
    4 3 new: scr-xy
    cg-xy-2d           40  300 add: scr-xy
    cg-xy-horizontal 1040 3000 add: scr-xy
    cg-xy-vertical   3200  300 add: scr-xy
\
    " Demo XY" put.title: scr-xy
\
\ make this screen come up first
    scr-xy default-screen !
;

: DXY.TERM  ( -- )
    freeall: scr-xy
    free: scr-xy
;

: DEMO.XY  ( -- )
    dxy.init
    hmsl
    dxy.term
;

if.forgotten dxy.term

cr ." Enter: DEMO.XY" cr

