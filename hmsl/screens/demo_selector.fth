\ This is an example of using two controls to make a
\ scrolling selector box.

include? ob.fader h:ctrl_fader

ANEW TASK-DEMO_SELECTOR

ob.menu.grid    SS-ITEMS
ob.fader        SS-FADER
ob.screen       SS-SCREEN
ob.list         SS-TEXT

: SETUP.SELECTOR { x y w h itemscg fadercg screen -- }
\ set widths and height
    w h itemscg put.wh: []
    100 h itemscg many: [] *
    fadercg put.wh: []
    
\ set screen positions
    itemscg x y screen add: []
    fadercg x w + y screen add: []
\
    0 -1 fadercg put.min: []
    false fadercg if.show.value: []
;

: SS.FADER.FUNC  ( value part -- )
\ invert and set offset for items
    get.max: ss-fader swap -
    put.data: ss-items
    draw: ss-items
;

: SS.GET.TEXT  ( item -- addr count )
    get.data: ss-items + ( add item offset )
    get: ss-text count
;

: SS.ITEMS.FUNC  ( value part -- )
    get.data: ss-items + ( add item offset )
    get: ss-text $type cr
    drop
;

: SS.TEST.INIT
    2 3 new: ss-screen
    1 5 new: ss-items
    
    'c ss.get.text put.text.function: ss-items
    'c ss.items.func put.down.function: ss-items
    'c ss.fader.func put.move.function: ss-fader
    'c ss.fader.func put.up.function: ss-fader
\
    400 200 500 300 ss-items ss-fader ss-screen setup.selector
    
    stuff{
        " Apple"
        " Bat"
        " Casaba"
        " Dongle"
        " Ebony"
        " Fern"
        " Grunt"
        " Harp"
        " Iris"
        " Jewel"
        " Kite"
    }stuff: ss-text
\
\ don't go past end of text array
    many: ss-text many: ss-items -
    dup -1 put.max: ss-fader
    -1 put.value: ss-fader
;

: SS.TEST.TERM
    freeall: ss-screen
    free: ss-screen
    free: ss-text
;

: TEST ss.test.init hmsl.start ;

if.forgotten ss.test.term
.THEN

