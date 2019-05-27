\ Control Class
\
\ This is a host independant facility for interacting with
\ a user.
\ Controls reside in a screen and are sent messages
\ to draw and to respond to mouse up and down events.
\ Control grids display text in a grid, when selected
\ with the mouse, they execute an associated CFA.  Different
\ grids have different behaviors.
\
\ Author: Phil Burk
\ Copyright 1986 -  Phil Burk, Larry Polansky, David Rosenboom.
\ All Rights Reserved
\
\ MOD: PLB 6/30/86 Added ABS to deltaxy!
\ MOD: PLB 7/18/86 Added UNDRAW: and MENUPICK: methods.
\ MOD: PLB 7/25/86 Added GR.CHECK call to DRAW:
\ MOD: PLB 10/13/86 Converted to use IV.LONG, START.XY: to TOPLEFT:
\ MOD: PLB 11/21/86 Add service.tasks to DRAW: , no highlight
\      if disabled.
\ MOD: PLB 12/3/86 Use GR_SMALL_TEXT GR.HEIGHT!
\ MOD: PLB 12/15/86 Base text position on text height.
\ MOD: PLB 4/27/87 Clear entire control area in DRAW:
\ MOD: PLB 5/28/87 Add PRINT:
\ MOD: PLB 8/13/87 Move HIGHLIGHT: start 1,1 in x,y
\ MOD: PLB 1/28/87 Add more service.tasks to DRAW:
\
\ MOD: PLB 2/8/88 REWRITTEN based on new design!!!
\ MOD: PLB 3/22/89 Reorganize, not OB.ELMNTS.
\ MOD: PLB 9/22/89 Split XYWH into XY & WH
\ MOD: PLB 12/12/89 Change to Single/Multi Valued System.
\      MIN and MAX have part#s, -1 for all.
\ MOD: PLB 2/24/90 Use EXECUTE: method for executing CFAs.
\ MOD: PLB 3/90 Fix HIGHLIGHT:
\ MOD: PLB 4/15/90 Add PUT.TEXT.FONT: etc.
\ MOD: PLB 10/30/90 c/i/r@/ in DRAW.PART:
\ MOD: PLB 2/10/91 No reference to GR_BIG_TEXT
\ MOD: PLB 5/20/91 Added FREE: SUPER to FREE: OB.CHECK.GRID
\ MOD: PLB 7/26/91 Remove ELSE DROP from }STUFF.TEXT:
\ 00001 PLB 9/27/91 Add KEY:
\ 00002 PLB 9/28/91 Added PUT.ACTIVE: GET.ACTIVE:
\ 00003 PLB 11/12/91 Make PUT.ENABLE: use -1
\ 00004 PLB 2/6/92 Add EXEC.STACK?
\ 00005 PLB 2/12/92 Added PUT.WH.DC:
\ 00006 PLB 2/21/92 Add 3D bevels, CG-3D, CG-BEVEL-THICKNESS
\ 00007 PLB 2/22/92 Fix GET.INNER.RECT:
\ 00008 PLB 2/27/92 Use MOUSE.UP: SUPER in MENU.GRID for cg-last-mx,y
\ 00009 PLB 3/10/92 Added PUT.XY.DC:
\ 00010 PLB 3/13/92 Removed 1 GR.COLOR! from CG.DRAW.TITLE
\ 00011 PLB 5/23/92 Set default height in control.

decimal

ANEW TASK-CONTROL

\ If you want to put the NFA of a word in a grid cell.
\ This word will fix the name, done automatically.
: CG.FIXTEXT ( string1 -- string2 , Make new string if NFA )
    dup count swap drop 31 >
    IF nfa->$
    THEN
;

create &ZERO 0 ,

METHOD GET.RECT:      METHOD GET.INNER.RECT:
METHOD ?DRAWN:
METHOD PUT.LASTHIT:   METHOD GET.LASTHIT:

METHOD PUT.VALUE:     METHOD GET.VALUE:
METHOD PUT.ENABLE:    METHOD GET.ENABLE:
METHOD PUT.MIN:       METHOD GET.MIN:
METHOD PUT.MAX:       METHOD GET.MAX:
METHOD PUT.INCREMENT: METHOD GET.INCREMENT:

( These functions will all be passed the current value and part# )
METHOD PUT.DOWN.FUNCTION:
METHOD GET.DOWN.FUNCTION:
METHOD PUT.UP.FUNCTION:
METHOD GET.UP.FUNCTION:
METHOD PUT.MOVE.FUNCTION:
METHOD GET.MOVE.FUNCTION:

METHOD MOUSE.DOWN:    METHOD EXEC.DOWN:
METHOD MOUSE.UP:
METHOD MOUSE.MOVE:
METHOD EXECUTE:

METHOD PUT.DRAW.FUNCTION:
METHOD GET.DRAW.FUNCTION:
METHOD PUT.UNDRAW.FUNCTION:
METHOD GET.UNDRAW.FUNCTION:

METHOD PUT.XY:        METHOD GET.XY:
METHOD PUT.XY.DC:     METHOD GET.XY.DC:
METHOD PUT.WH:        METHOD GET.WH:
METHOD PUT.WH.DC:     METHOD GET.WH.DC:
METHOD DRAW:          METHOD UNDRAW:
METHOD XY.DRAW:       METHOD XY.UNDRAW:

METHOD PUT.DATA:      METHOD GET.DATA:
METHOD PUT.TITLE:     METHOD GET.TITLE:
METHOD HIGHLIGHT:     METHOD DRAW.PART:
METHOD ?HIT:

METHOD PUT.TEXT.FUNCTION:  METHOD GET.TEXT.FUNCTION:
METHOD PUT.TEXT.SIZE:      METHOD GET.TEXT.SIZE:
METHOD PUT.TEXT.FONT:      METHOD GET.TEXT.FONT:
METHOD KEY: \ 00001
METHOD PUT.ACTIVE:         METHOD GET.ACTIVE: \ 00002

( Define FLAG bits )
1 CONSTANT CG_ENABLE_MASK

\ Define variables used to track mouse.

variable CG-FIRST-MX
variable CG-FIRST-MY
variable CG-LAST-MX
variable CG-LAST-MY

variable CG-3D  \ if true, draw using 3D bevel technique
cg-3d off
variable CG-BEVEL-THICKNESS
2 cg-bevel-thickness !

: CG.DEBUG.DRAW  ( -- , help debug drawing )
    if-debug @
    IF
        >newline ." Drawing " self name: [] cr
    THEN
;

( Define OB.CONTROL Class )
:CLASS OB.CONTROL <SUPER OBJECT
\ Positions and sizes are stored in Device Coordinates,
\ or DC, for speed.  They are specified in World Coordinates,
\ or WC, for portability.
    IV.SHORT IV-CG-LEFTX
    IV.SHORT IV-CG-TOPY
    IV.SHORT IV-CG-WIDTH
    IV.SHORT IV-CG-HEIGHT
    IV.SHORT IV-CG-DRAWN  ( true if currently drawn )
    IV.SHORT IV-CG-ACTIVE  ( true if currently the active control )
\
    IV.LONG  IV-CG-DATA   ( User data )
    IV.LONG  IV-CG-TITLE
\
    IV.LONG  IV-CG-VALUE    ( for single valued controls )
    IV.SHORT IV-CG-FLAG
    IV.SHORT IV-CG-LASTHIT  ( last part hit )
\
    IV.LONG  IV-CG-DRAW-CFA
    IV.LONG  IV-CG-UNDRAW-CFA
    IV.LONG  IV-CG-DOWN-CFA   ( function to execute when down )
    IV.LONG  IV-CG-MOVE-CFA   ( function to execute when moved )
    IV.LONG  IV-CG-UP-CFA   ( function to execute when up )
    IV.LONG IV-CG-TEXT-CFA
    IV.LONG IV-CG-TEXT-SIZE
    IV.LONG IV-CG-TEXT-FONT
\
    IV.LONG IV-CG-MIN
    IV.LONG IV-CG-MAX
    IV.LONG IV-CG-INCR


:M INIT:  ( -- , INITIALIZE grid )
    init: super
    10 iv=> iv-cg-leftx
    20 iv=> iv-cg-topy
    40 iv=> iv-cg-width
    16 iv=> iv-cg-height \ 00011
    0 iv=> iv-cg-title ( nothing drawn )
    0 iv=> iv-cg-draw-cfa
    0 iv=> iv-cg-undraw-cfa
    -1 iv=> iv-cg-min ( for true )
    1 iv=> iv-cg-max
    1 iv=> iv-cg-incr
    0 iv=> iv-cg-value
    cg_enable_mask iv=> iv-cg-flag
    0 iv=> iv-cg-drawn
    0 iv=> iv-cg-active \ 00002
    gr_small_text iv=> iv-cg-text-size
    0 iv=> iv-cg-text-font
;M

:M MANY:  ( -- n , number of values )
    1
;M
:M FREE:  ( -- , dummy to allow easier frees from object list )
;M

\ Methods for setting up a control, specify appearance, etc.
:M PUT.XY: ( leftx topy -- )
    scg.wc->dc
    iv=> iv-cg-topy    iv=> iv-cg-leftx
;M
    
:M GET.XY: ( -- leftx topy )
    iv-cg-leftx iv-cg-topy
    scg.dc->wc
;M

:M PUT.XY.DC: ( leftx topy -- , device coordinates, pixels 00009 ) 
    iv=> iv-cg-topy    iv=> iv-cg-leftx
;M

:M GET.XY.DC: ( -- leftx topy )
    iv-cg-leftx iv-cg-topy
;M

\ Set width, height -------------------
:M PUT.WH: ( width height -- )
    scg.delta.wc->dc
    iv=> iv-cg-height    iv=> iv-cg-width
;M

:M PUT.WH.DC: ( width height -- )
    iv=> iv-cg-height    iv=> iv-cg-width
;M
    
:M GET.WH: ( -- width height )
    iv-cg-width iv-cg-height
    scg.delta.dc->wc
;M
    
:M GET.WH.DC: ( -- width height )
    iv-cg-width iv-cg-height
;M

\ --------------------------------------
:M PUT.ACTIVE:  ( active? -- , set active or not 00002 )
      iv=> iv-cg-active
;M
:M GET.ACTIVE: ( -- active? )
      iv-cg-active 
;M

:M PUT.DATA:  ( data -- , user settable data value )
      iv=> iv-cg-data
;M
:M GET.DATA: ( -- data )
      iv-cg-data 
;M

:M PUT.TEXT.FUNCTION: ( cfa -- )
    iv=> iv-cg-text-cfa
;M
:M GET.TEXT.FUNCTION: ( -- cfa )
    iv-cg-text-cfa
;M

:M PUT.TEXT.SIZE: ( size -- )
    iv=> iv-cg-text-size
;M
:M GET.TEXT.SIZE: ( -- size )
    iv-cg-text-size
;M

:M PUT.TEXT.FONT: ( font -- )
    iv=> iv-cg-text-font
;M
:M GET.TEXT.FONT: ( -- font )
    iv-cg-text-font
;M
:M PUT.LASTHIT:  ( part# -- )
    iv=> iv-cg-lasthit
;M
:M GET.LASTHIT: ( -- part# )
    iv-cg-lasthit
;M

:M PUT.DOWN.FUNCTION: ( cfa --  , cfa to execute when mouse down )
     iv=> iv-cg-down-cfa
;M
:M GET.DOWN.FUNCTION:  ( -- cfa )
    iv-cg-down-cfa
;M
:M PUT.MOVE.FUNCTION: ( cfa --  , cfa to execute when mouse moves )
     iv=> iv-cg-move-cfa
;M
:M GET.MOVE.FUNCTION:  ( -- cfa )
    iv-cg-move-cfa
;M
:M PUT.UP.FUNCTION: ( cfa --  , cfa to execute when mouse up )
     iv=> iv-cg-up-cfa
;M
:M GET.UP.FUNCTION:  ( -- cfa )
    iv-cg-up-cfa
;M

:M PUT.DRAW.FUNCTION: ( cfa --  , cfa to execute when drawn )
     iv=> iv-cg-draw-cfa
;M
:M GET.DRAW.FUNCTION:  ( -- cfa )
     iv-cg-draw-cfa
;M

:M PUT.UNDRAW.FUNCTION: ( cfa --  , cfa to execute when undrawn )
     iv=> iv-cg-undraw-cfa
;M
:M GET.UNDRAW.FUNCTION:  ( -- cfa )
     iv-cg-undraw-cfa
;M

: CG.CLIP.VALUE ( value -- value' )
    iv-cg-min iv-cg-max clipto
;

:M PUT.VALUE: ( value part -- )
    drop cg.clip.value iv=> iv-cg-value
;M
:M GET.VALUE: ( part -- value )
    drop iv-cg-value
;M

: CG.CLIP.PART ( part -- , clip value of part to limits )
    dup self get.value: []
    swap self put.value: []
;

: CG.CLIP.ALL  ( -- , clip all values )
    self many: [] 0
    ?DO i cg.clip.part
    LOOP
;

:M PUT.ENABLE: ( flag part -- , enable or disable cell )
      drop iv-cg-flag swap
      IF cg_enable_mask OR
      ELSE cg_enable_mask invert and
      THEN iv=> iv-cg-flag
;M
:M GET.ENABLE:  ( part -- flag , Check for enable bit )
      drop iv-cg-flag cg_enable_mask and
;M

:M PUT.MIN: ( min part -- , set minimum value for control )
    drop iv=> iv-cg-min cg.clip.all
;M
:M GET.MIN: ( part -- min , get minimum value for control )
    drop iv-cg-min
;M

:M PUT.MAX: ( max part -- , set maximum value for control )
    drop iv=> iv-cg-max cg.clip.all
;M
:M GET.MAX: ( part -- max , get maximum value for control )
    drop iv-cg-max 
;M

:M PUT.INCREMENT: ( incr -- , set increment for control )
    iv=> iv-cg-incr
;M
:M GET.INCREMENT: ( -- incr , get increment value for control )
    iv-cg-incr
;M

:M PUT.TITLE:  ( $title -- , SET control title )
      iv=> iv-cg-title
;M
:M GET.TITLE:  ( -- $title , GET control title )
      iv-cg-title 
;M

: CG.DRAW.TITLE ( -- , Draw title by control )
    get.title: self   ?dup
    IF
        iv-cg-text-size gr.height! \ 1 gr.color!
        iv-cg-text-font gr.font!
        iv-cg-leftx iv-cg-topy  3 -
        rot gr.xytext
     THEN
;

:M GET.RECT:  ( part -- x1 y1 x2 y2 , in DC )
    drop iv-cg-leftx iv-cg-topy
    over iv-cg-width +
    over iv-cg-height +
;M

:M GET.INNER.RECT: { part | thick -- x1 y1 x2 y2 , in DC }
    cg-3d @
    IF
        cg-bevel-thickness @ -> thick
    ELSE
        1 -> thick
    THEN
    part self get.rect: []
    thick - >r
    thick - >r
    thick + >r
    thick + r> r> r>
;M

:M ?DRAWN:  ( -- flag , true if currently drawn )
    iv-cg-drawn
;M

:M DRAW:   ( -- , Draw control)
    cg.debug.draw
    gr.check  ( make sure there is a window open )
    iv-cg-draw-cfa ?dup
    IF
        0 exec.stack? \ 00004
    THEN
\
    service.tasks
    1 gr.color! \ 00010
    cg.draw.title
    true iv=> iv-cg-drawn
;M

:M UNDRAW:  ( -- )
    iv-cg-undraw-cfa ?dup
    IF
        0 exec.stack? \ 00004
    THEN
    false iv=> iv-cg-drawn
;M

:M ?HIT: ( x y -- true_if_hit )
    iv-cg-topy dup iv-cg-height + 1- within?
    IF iv-cg-leftx dup iv-cg-width + 1- within?
    ELSE drop false
    THEN
;M

:M EXECUTE: ( cfa | 0 -- , execute DOWN/MOVE/UP function )
    ?dup
    IF  >r
        iv-cg-lasthit dup self get.value: []
        swap
        r> -2 exec.stack? \ 00004
    THEN
;M

\ Stubs to be defined in later classes
:M EXEC.DOWN:  ( -- , do down functions )
;M

:M MOUSE.DOWN: (  x y -- trapped? , process mouse DOWN event )
    2dup self ?hit: []
    IF  cg-first-my !   cg-first-mx !
        iv-cg-lasthit self get.enable: []
        IF  self exec.down: [] true
            iv-cg-down-cfa self execute: []
        ELSE bell false  ( beep if disabled )
        THEN
    ELSE 2drop false
    THEN
;M

:M MOUSE.UP:  ( x y -- , do up functions )
    cg-last-my !   cg-last-mx !
    iv-cg-up-cfa self execute: []
;M

:M MOUSE.MOVE:  ( x y -- , do move functions )
    cg-last-my !   cg-last-mx !
    iv-cg-move-cfa self execute: []
;M

:M KEY: ( character -- , process keyboard input 00001 )
    drop
;M

: PRINT.XYWH ( x y w h -- )
    ."   Top Left X,Y = " 2swap swap . . cr
    ."   Width, Height    = " swap . . cr
;

:M PRINT: ( -- )
    cr
    ." Device Coordinates!" cr
    get.xy.dc: self
    get.wh.dc: self print.xywh
    ." World Coordinates!" cr
    get.xy: self
    get.wh: self print.xywh
    ." User Data = " iv-cg-data . cr
    ." Title   = " iv-cg-title dup
    IF $.
    ELSE .
    THEN cr
    ." Part#  Value     Min     Max" cr
    self many: [] 0
    ?DO  i 4 .r i self get.value: []  8 .r
        i self get.min: [] 8 .r
        i self get.max: [] 8 .r cr
    LOOP
    ." Draw.Function   = " iv-cg-draw-cfa cfa. cr
    ." Undraw.Function = " iv-cg-undraw-cfa cfa. cr
    ." Text.Function   = " iv-cg-text-cfa cfa. cr
    ." Down.Function   = " iv-cg-down-cfa cfa. cr
    ." Move.Function   = " iv-cg-move-cfa cfa. cr
    ." Up.Function     = " iv-cg-up-cfa cfa. cr
;M

;CLASS

METHOD PUT.TEXT:      METHOD GET.TEXT:
METHOD }STUFF.TEXT:
METHOD COLOR.PART:
METHOD CLEAR.PART:

:CLASS OB.CONTROL.GRID <SUPER OB.CONTROL
    OB.ARRAY IV-CG-VALUES
    OB.BARRAY IV-CG-FLAGS
\ Layout of parts
    IV.SHORT IV-CG-NUMX
    IV.SHORT IV-CG-NUMY

: CG.PUT.ENABLE ( flag part# -- )
    dup>r at: iv-cg-flags swap
    IF cg_enable_mask OR
    ELSE cg_enable_mask invert and
    THEN r> to: iv-cg-flags
;

:M PUT.ENABLE: ( flag part# -- , enable or disable cell )
    dup 0<
    IF
\ do them all if part# is less then zero, 00003
        drop
        many: iv-cg-flags 0
        ?DO
            dup i cg.put.enable
        LOOP
        drop
    ELSE
        cg.put.enable
    THEN
;M
:M GET.ENABLE:  ( part# -- flag , Check for enable bit )
      at: iv-cg-flags cg_enable_mask and
;M

:M FREE: ( -- , free allocated memory )
    free: iv-cg-values
    free: iv-cg-flags
;M

:M NEW:  ( nx ny -- , Specify number of cells )
    self free: []
    2dup iv=> iv-cg-numy iv=> iv-cg-numx
    * dup new: iv-cg-values
    0 cg.clip.value fill: iv-cg-values
    new: iv-cg-flags
    cg_enable_mask fill: iv-cg-flags  ( set all enabled as default )
;M

:M MANY:  ( -- n , number of values )
    size: iv-cg-values
;M

: CG.PART.TOPLEFT  ( index -- x y )
     iv-cg-numx  /mod iv-cg-height  * iv-cg-topy  +
     swap iv-cg-width  * iv-cg-leftx  + swap
;

:M GET.RECT:  ( index -- x1 y1 x2 y2 , in DC )
    dup 0<
    IF  drop iv-cg-leftx iv-cg-topy
        over iv-cg-width iv-cg-numx * +
        over iv-cg-height iv-cg-numy * +
    ELSE
        cg.part.topleft
        2dup iv-cg-height  +
        swap iv-cg-width  + swap
        cg-3d @   \ inset bottom left corner to avoid overlap
        IF
            1- >r 1- r>
\           cg-bevel-thickness @ - >r 
\           cg-bevel-thickness @ - r>
        THEN
    THEN
;M

: INSET.RECTANGLE  ( x1 y1 x2 y2 -- x1+1 y1+1 x2-1 y2-1 )
    1- >r 1- >r 1+ >r 1+ r> r> r>   ( move in one pixel)
;

:M COLOR.PART:   ( part color -- , color that parts rectangle )
    gr.color@ >r
    gr.color!
    get.inner.rect: self
    gr.rect ( paint background )
    r> gr.color!
;M

:M CLEAR.PART:   ( part -- , clear that parts rectangle )
    0 color.part: self
;M

:M ?HIT:   ( x y -- true_if_hit , report if hit , DC)
      iv-cg-topy  iv-cg-height  iv-cg-numy  ug.?hit
      IF  swap  ( -- ypart x )
          iv-cg-leftx  iv-cg-width  iv-cg-numx  ug.?hit
          IF  swap iv-cg-numx  * +
              iv=> iv-cg-lasthit true
          ELSE drop false
          THEN
      ELSE drop 0
      THEN
;M

:M HIGHLIGHT:   ( part -- , Highlight cell )
    iv-cg-drawn
    IF  gr.color@ swap get.inner.rect: self
        gr.highlight
        gr.color!
    ELSE drop
    THEN
;M

:M PUT.VALUE: ( value part -- )
     >r cg.clip.value r> to: iv-cg-values
;M
:M GET.VALUE:  ( part -- value )
     at: iv-cg-values
;M

: CG.DRAW.PART.BEVEL { part down? -- }
     part self get.rect: []
     down?
     2 draw.thick.bevel
;

:M DRAW:   ( -- , Draw control grid )
    draw: super
    0 gr.color!
    -1 get.rect: self gr.rect
    service.tasks
    1 gr.color!
    service.tasks
    cg-3d @ 0=
    IF
        get.xy.dc: self
        get.wh.dc: self
        iv-cg-numx iv-cg-numy ug.grid  ( draw grid )
    THEN
    service.tasks
\
\ Draw each part
    size: iv-cg-values ?dup
    IF  0
        DO
\
\ draw 3d bevel if desired
            cg-3d @
            IF
                i 0 cg.draw.part.bevel
            THEN
\
            i self draw.part: []
            service.tasks
        LOOP
    ELSE
        cg-3d @
        IF
            0 0 cg.draw.part.bevel
        THEN
    THEN
;M

:M PRINT:
    print: super
    space space iv-cg-numy . ."  rows and "
        iv-cg-numx . ."  columns." cr
;M

;CLASS

\ CHECK GRIDCONTROL ----------------------------------------------

:CLASS OB.CHECK.GRID <SUPER OB.CONTROL.GRID
    ob.array  iv-cg-texts

:M FREE:  ( -- )
    free: super
    free: iv-cg-texts
;M

:M NEW: ( nx ny -- )
    2dup new: super
    * new: iv-cg-texts
    &zero fill: iv-cg-texts
;M

:M PRINT: ( -- )
    print: super
    size: iv-cg-texts 0
    ?DO i at: iv-cg-texts $type cr
    LOOP
;M

: GR.START.DIM ( part# -- )
    drop 2 gr.color!
;
: GR.END.DIM ( part# -- )
    drop 1 gr.color!
;

:M DRAW.PART: ( part -- , draw a single part of a control )
    >r

\ draw background based on the value
    r@ get.value: self
    IF r@ gr_yellow color.part: self
    ELSE r@ clear.part: self
    THEN

\ get text for this part
    iv-cg-text-cfa dup
    IF r@ swap 1 exec.stack?  ( addr count , 00004 )
    ELSE drop r@ at: iv-cg-texts ?dup
        IF cg.fixtext count
        ELSE 0 0
        THEN
    THEN service.tasks
\
    dup  ( -- addr count count )
    IF
\ dim the text if disabled
        r@ get.enable: self 0=
        IF r@ gr.start.dim
        THEN

        service.tasks
        r@ cg.part.topleft
        iv-cg-text-size dup gr.height!
        + 1+ swap 6 + swap  ( calc bottom left )
        iv-cg-text-font gr.font!
        gr.move   gr.type
\
        r@ get.enable: self 0=
        IF r@ gr.end.dim
        THEN
    ELSE 2drop
    THEN

    rdrop
;M

:M PUT.TEXT: ( string part# --  , text to appear in grid cell )
    tuck to: iv-cg-texts
    iv-cg-drawn
    IF dup self clear.part: []
       dup self draw.part: []
    THEN drop
;M

:M GET.TEXT:  ( part# -- string , string may need cg.fixtext )
     at: iv-cg-texts
;M

:M }STUFF.TEXT: ( stuff{ t0 t1 t2 ... -- , put many texts )
\ Scan For 0 to count objects.
    stuff.depth
    dup 0>
    IF  dup 0
        DO 1- tuck ( t t tn-1 n tn n ) self put.text: []
        LOOP
        drop
    ELSE
        0< IF " }STUFF.TEXT" " STUFF{ required before text!"
              er_fatal ob.report.error
        THEN
    THEN
;M

GR_XOR_SUPPORTED [IF]
:M PUT.VALUE:  ( value part# -- ,  toggle if changed )
    dup get.value: self ( -- newv part oldv )
    rot tuck ( -- part newv oldv newv )
    - ( toggle if different )
    IF   over highlight: self
    THEN
    swap put.value: super
;M
[ELSE]
:M PUT.VALUE:  ( value part# -- ,  toggle if changed )
    tuck put.value: super
    iv-cg-drawn
    IF draw.part: self
    ELSE drop
    THEN
;M
[THEN]

:M EXEC.DOWN: ( -- , perform modal action then cfa )
    iv-cg-lasthit    get.value: self   ( -- v )
    0= iv-cg-lasthit put.value: self
;M

;CLASS

\ CHECK BOX CONTROL ----------------------------------------------
:CLASS OB.MENU.GRID <SUPER OB.CHECK.GRID

:M MOUSE.UP: ( x y -- , turn off now )
    iv-cg-lasthit    get.value: self   ( -- v )
    0= iv-cg-lasthit put.value: self
    mouse.up: super \ 00008
;M

;CLASS

\ RADIO GRID CONTROL ------------------------------------------------
:CLASS OB.RADIO.GRID <SUPER OB.CHECK.GRID

:M NEW:  ( nx ny -- , set default on )
    new: super
    true iv-cg-lasthit
    size: iv-cg-values 1- min   to: iv-cg-values
;M

:M PUT.VALUE:  ( value part# -- , turn others off )
    over
    IF  size: iv-cg-values 0
        ?DO 0 i put.value: super
        LOOP
    THEN
    put.value: super
;M

:M EXEC.DOWN:    ( -- , turn off all others )
    true iv-cg-lasthit put.value: self
;M

;CLASS
