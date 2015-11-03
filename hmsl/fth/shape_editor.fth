\ Shape Editor
\
\ Shapes, which includes waveforms, can be edited with this
\ screen.  A special class of control grid, an OB.CTRL.EDIT
\ is defined that can do operations on a contained shape.
\
\ Author: Phil Burk
\ Copyright 1986 - David Rosenboom, Larry Polansky, Phil Burk.
\
\ MOD: 11/5/86 PLB Add range selection, transpose, cut, copy, paste.
\ MOD: 11/6/86 PLB Improve ranging and updating, add random mode.
\ MOD: 11/21/86 PLB Don't calc.stats for bytewide, draw once after
\      randomize.
\ MOD: PLB 12/6/86 Change ' to 'c
\ MOD: PLB 12/9/86 Fix text overdraw, and INIT: SE-PLAYER in SE.INIT
\ MOD: PLB 12/15/86 Remove special code for overdraw, not needed now.
\ MOD: PLB 3/5/87 Stay on dimension when switching shapes.
\ MOD: PLB 3/6/87 Select values, start and end, are now before point.
\ MOD: PLB 3/10/87 Don't PASTE if no CUTS done.
\          Add SE.STARTUP
\ MOD: PLB 7/8/87 Extend SE-MODECG
\ MOD: PLB 9/20/87 Use low level COPY: to speed up SE.CUT and SE.PASTE
\ MOD: PLB 10/7/87 Show new position if UP or DOWN of single point.
\ MOD: PLB 10/22/87 Show new position of first point in UP or DOWN.
\ MOD: PLB 10/26/87 Set SE-IF-ZOOMED to FALSE in SE.INIT, min to 8.
\ MOD: PLB 12/15/87 Implemented SCRAMBLE button.
\ MOD: PLB 4/27/88 Changed SE.SET.SHAPE and SE.SETUP so HMSL.EDIT.PLAY
\          edits the specified shape.
\ MOD: PLB 9/28/88 Converted to new control grids.
\ MOD: PLB 3/28/89 Newer control grid design.
\ MOD: PLB 10/3/89 Add player tracking & SE.UPDATE.SHAPE
\ MOD: PLB 10/29/89 Make SE.STARTUP the DRAW function.
\ MOD: PLB 12/13/89 Converted to v/p system.
\ MOD: PLB 4/9/91 Rearranged screen, fixed hit range.
\ MOD: PLB 4/18/91 Made shape select immediate, just redraw box.
\ MOD: PLB 5/20/91 FREE: SHAPE-1 and SE-PLAYER
\ MOD: PLB 6/24/91 Fix dimension selection in PUT.OBJECT:  c/MAX/MIN/
\ 00001 PLB 10/1/91 Make additions to SHAPE-HOLDER immediately accesible
\ 00002 PLB 4/27/92 Move Shape Holder validation to H:MORPH_LISTS

ANEW TASK-SHAPE_EDITOR

V: SE-MODE
V: SE-QUIT

\ Objects used in support of shape editor.
OB.PLAYER SE-PLAYER   \ Used for Playing Shape

OB.SCREEN SE-SCREEN

0 constant SE_CTRL_TNR
5 constant SE_EDIT_TNR

\ Mode control --------------------------------------------
0 constant SE_INSERT
1 constant SE_DELETE
2 constant SE_REPLACE
3 constant SE_SELECT
4 constant SE_RUBBER
5 constant SE_TRACE
6 constant SE_SET_Y
7 constant SE_RANDOMIZE

OB.RADIO.GRID SE-MODECG

: SE.SETMODE ( value mode -- , Set mode to based on last hit )
    se-mode ! drop
;

: BUILD.SE-MODE ( -- )
    2 4 new: se-modecg
    se_insert se-mode !
    530 280 put.wh: se-modecg
    " Set Mode" put.title: se-modecg
    'c se.setmode put.down.function: se-modecg
    stuff{ " Insert"  " Delete"  " Replace"
      " Select"  " Rubber"  " Draw"
      " Set Y "  " Random"
    }stuff.text: se-modecg
;

\ Editor Control Grid ---------------------------------
\
\ This Ctrl provides methods for editing morphs.
METHOD PUT.DIM:         METHOD GET.DIM:
METHOD PUT.SELECT:      METHOD GET.SELECT:
METHOD PUT.RANGE:       METHOD GET.RANGE:
METHOD GET.YMARK:
METHOD UPDATE.DRAW:     METHOD TELL.XY:
METHOD PUT.OBJECT:      METHOD GET.OBJECT:
METHOD DRAW.DATA:
\ Methods for showing played element.
METHOD NOW.PLAYING:     METHOD STOP.PLAYING:

:CLASS OB.CTRL.EDIT <SUPER OB.CONTROL
    IV.LONG IV-EDIT-DIM   ( currently edited dimension )
    IV.LONG IV-EDIT-TNR   ( edit transformation )
    IV.LONG IV-EDIT-START ( start of select )
    IV.LONG IV-EDIT-END   ( end of select )
    IV.LONG IV-EDIT-LEFT  ( left index of display range )
    IV.LONG IV-EDIT-RIGHT ( right index of display range )
    IV.LONG IV-EDIT-YMARK ( mark vertical value )
    IV.LONG IV-EDIT-X     ( Position of mouse hit. )
    IV.LONG IV-EDIT-Y
    IV.LONG IV-EDIT-TOP   ( Value at top of box. )
    IV.LONG IV-EDIT-BOT
    IV.LONG IV-EDIT-WIDTH/2 ( in DC, half width of element )
    IV.LONG IV-EDIT-HEIGHT/2
    IV.LONG IV-EDIT-SHAPE
    IV.LONG IV-EDIT-FIRST-ELM
    IV.LONG IV-EDIT-FIRST-VAL
    IV.LONG IV-EDIT-LAST-ELM
    IV.LONG IV-EDIT-LAST-VAL
    IV.LONG IV-EDIT-PLAYING  ( -1 if none displayed, or cur elmnt )

:M INIT:   ( -- , Initialize )
    init: super
    se_edit_tnr iv=> iv-edit-tnr
    -1 iv=> iv-edit-playing
;M

:M PUT.OBJECT: ( rel_morph_addr -- , set shape to edit )
    dup iv=> iv-edit-shape
    dup max.elements: [] 1- iv=> iv-edit-right   ( set bounds )
    dimension: [] 1- iv-edit-dim MIN iv=> iv-edit-dim
    0 iv=> iv-edit-left
    0 iv=> iv-edit-start
    0 iv=> iv-edit-end
;M

:M GET.OBJECT: ( -- shape )
    iv-edit-shape
;M

:M PUT.DIM: ( dim -- , set dim of morph to edit )
    iv=> iv-edit-dim
;M
:M GET.DIM: ( -- dim , Get dim of morph to edit )
    iv-edit-dim 
;M

:M PUT.RANGE: ( left right -- , set display range )
    2sort
    iv-edit-shape max.elements: [] 1- MIN iv=> iv-edit-right
    0 MAX iv=> iv-edit-left
;M

:M GET.RANGE: ( -- left right , fetch display range )
     iv-edit-left iv-edit-right
;M

:M PUT.SELECT: ( start end -- , set selection range )
    2sort
\  Clip to points in shape.
    iv-edit-shape ?dup
    IF many: [] >r
    ELSE 0 >r
    THEN
    0 max r@ min iv=> iv-edit-end
    0 max r> min iv=> iv-edit-start
;M

:M GET.SELECT: ( -- start end , fetch selection range )
     iv-edit-start iv-edit-end
;M

:M GET.YMARK: ( -- ymark , Fetch Y mark for inversion, etc. )
    iv-edit-ymark
;M

:M UPDATE:  ( -- , update all draw parameters based on current state)
    iv-edit-left  iv-edit-right   ( xmin xmax )
    iv-edit-shape width: [] 1 > ( byte OR bigger )
    IF
        iv-edit-shape   dup many: []  ( any data? )
        IF
            get.dim: self swap calc.dim.stats: []
\ invert Y axis for more normal editing
            get.dim: self  iv-edit-shape get.dim.max: [] 
            dup 2/ + ( *3/2 )  8 max  ( maximum Y )
            get.dim: self  iv-edit-shape get.dim.min: []
            dup 0<
            IF   dup 2/ -4 min +
            ELSE 2/  8 max  8 -
            THEN   ( minimum Y )
        ELSE
            drop 64 0   ( default range when no data yet in shape )
        THEN
\ Use complete range for byte wide shape for fast waveform editing.
    ELSE 128 -128
    THEN  ( -- topy boty )
    2dup iv=> iv-edit-bot iv=> iv-edit-top
    2dup 2sort iv-edit-ymark ( keep mark in range )
    -rot clipto iv=> iv-edit-ymark
    se_edit_tnr scg.swn    ( set window for data )

\ set viewport for data
\ add one to avoid select range wiping out left edge
    iv-cg-leftx dup iv-cg-width +
    iv-cg-topy dup iv-cg-height +
    se_edit_tnr scg.svp
    se_edit_tnr scg.selnt  ( update calculation )
    0 scg.selnt  ( reset transform )
;M


: SE.CALC.SXY  ( wx wy -- dx dy , calculate device x,y for select)
    >r iv-edit-left iv-edit-right clipto
    r> scg.wc->dc   ( -- xd1 yd1 )
;

: SE.DRAW.SELECT ( -- , Highlight Range )
    iv-edit-start iv-edit-left iv-edit-right within?
    iv-edit-end   iv-edit-left iv-edit-right within? OR
    IF  iv-edit-start iv-edit-top se.calc.sxy
        iv-edit-start iv-edit-left >
        IF swap iv-edit-width/2 - swap
        THEN
        iv-edit-end iv-edit-bot se.calc.sxy
        iv-edit-end iv-edit-left 1+ iv-edit-right within?
        IF swap iv-edit-width/2 - swap
        THEN
\ Sort X and Ys  ( x1 y1 x2 y2 )
        rot 2sort >r >r   ( Ys )
        2sort r> swap
        1+ \ make it wider so it is visible
        r>  ( Xs )
        gr.highlight
    THEN
;

: SE.DRAW.PLAYING ( -- , play currently playing element )
\ Use XOR mode so we can draw or undraw with same word.
    iv-edit-playing iv-edit-left iv-edit-right within?
    IF gr.mode@
       gr_xor_mode gr.mode!
       gr.color@
       gr_white gr.color!
       iv-edit-playing iv-edit-top scg.move
       iv-edit-playing iv-edit-bot scg.draw
       gr.color!
       gr.mode!
    THEN
;

:M NOW.PLAYING:  ( elmnt# shape -- )
    iv-edit-shape =
    IF se_edit_tnr scg.selnt
       1 gr.color! se.draw.playing
       iv=> iv-edit-playing se.draw.playing
       0 scg.selnt
    ELSE drop
    THEN
;M

:M STOP.PLAYING: ( shape -- , turn off display if right shape )
    iv-edit-shape =   iv-edit-playing -1 > and
    IF se_edit_tnr scg.selnt
       1 gr.color! se.draw.playing
       -1 iv=> iv-edit-playing
       0 scg.selnt
    THEN
;M

: SE.DRAW.SHAPE ( -- )
    iv-edit-shape
    IF  iv-edit-left 
        iv-edit-right    iv-edit-shape  many: [] 1-  min 
        iv-edit-dim 
        iv-edit-shape draw.dim: [] ( draw shape )
    THEN
;

: SE.DRAW.LINES ( -- , clear and redraw data )
    service.tasks
    0 gr.color!
    -1 get.rect: self gr.rect    ( blank out rect )
    1 gr.color!
    se_edit_tnr scg.selnt
    se.draw.shape
    se.draw.playing
    0 scg.selnt
;

: SE.DRAW.YMARK ( -- , Draw horizontal Y level )
    gr.color@ 2 gr.color!
    iv-edit-right iv-edit-ymark scg.move
    iv-edit-left  iv-edit-ymark scg.draw
    gr.color!
;

: SE.DRAW.TRIM ( -- , draw select ed, ymark, axes, etc.)
\ Get half cell sizes for x,y adjustments
    se_edit_tnr scg.showvp
    se_edit_tnr scg.selnt
    1 1 scg.delta.wc->dc
    2/ iv=> iv-edit-height/2 2/ iv=> iv-edit-width/2
    se.draw.ymark
    se.draw.select   ( highlight selected range )
    0 scg.selnt
;

:M DRAW.DATA:   ( -- , Draw control and morph )
    service.tasks
    se.draw.lines
    se.draw.trim
;M

: SE.TELL.SHAPE ( -- )
    iv-cg-leftx iv-cg-topy iv-cg-height +
    gr.height@ + 2+ gr.move
    "         " gr.text   ( move over)
    iv-edit-shape dup get.name: [] gr.text  ( Shape name)
    "    " gr.text
    iv-edit-dim swap get.dim.name: [] dup 0=
    IF drop " ----"
    THEN gr.text  ( Dimension name)
    "             " gr.text
;

:M DRAW:   ( -- , Draw axes, etc. )
    update: self
    draw: super
    se_edit_tnr  scg.selnt
    se.tell.shape
    scg.draw.axes
    draw.data: self
    0 scg.selnt
;M

:M UPDATE.DRAW:  ( -- , Update only if really needed. )
    iv-edit-shape width: [] 1 > ( byte OR bigger )
    IF   ( only check if wider than byte )
        get.dim: self iv-edit-shape
        2dup calc.dim.stats: []
        2dup get.dim.max: [] >r
        get.dim.min: [] r>       ( -- dim.min dim.max )
\ Check for data in range.
        iv-edit-bot iv-edit-top within?
        >r  iv-edit-bot iv-edit-top within?  r> AND NOT
        IF draw: self
        ELSE draw.data: self
        THEN
    ELSE draw.data: self
    THEN
;M

:M TELL.XY:   ( value elmnt# -- , display x,y at top )
    iv-cg-leftx 4+ iv-cg-topy 4-
    " X = "   gr.xytext gr.number
    " , Y = " gr.text   gr.number
    "      "  gr.text ( blank out rest )
;M

: SE.CLIP.SELECT ( -- , clip select to shape limits)
    get.select: self    put.select: self
;

: SE.INSERT ( value elmnt# -- , Insert a value into shape )
    1 iv-edit-shape check.over: []
    IF 2drop bell
    ELSE  
        iv-edit-shape many: []
        IF ( make room for one more )
            dup 1- 0 max 1 iv-edit-shape  stretch: []
        ELSE ( make one 0 element )
            1 iv-edit-shape set.many: []
            0 iv-edit-shape fill: []
        THEN 
        get.dim: self iv-edit-shape clip.ed.to: []
    THEN
    iv-edit-shape update: []
;

: SE.RANDOMIZE ( value -- ,generate random values, ymark->value)
    iv-edit-ymark 2sort   ( data range )
    iv-edit-start iv-edit-end ( index range )
    2dup <
    IF  1- iv-edit-dim  iv-edit-shape   randomize: []
    ELSE 2drop 2drop
    THEN
;

: SE.EXEC.DOWN  ( value elmnt# -- , Perform action based on mode )
    service.tasks
    2dup tell.xy: self
    se-mode @
    CASE  ( -- value elmnt# )
        SE_INSERT OF se.insert se.clip.select
            draw.data: self
        ENDOF
        SE_DELETE OF
            iv-edit-shape remove: []   drop se.clip.select
            draw.data: self
            iv-edit-shape update: []
        ENDOF
        SE_REPLACE OF 
            2drop ev.track.on
        ENDOF
        SE_TRACE OF 
            get.dim: self iv-edit-shape clip.ed.to: []
            se.draw.lines
            ev.track.on
        ENDOF
        SE_SELECT OF  ( pick first point )
            se_edit_tnr scg.selnt
            se.draw.select
            dup put.select: self drop
            se.draw.select
            ev.track.on
            0 scg.selnt
        ENDOF
        SE_SET_Y OF
            2drop ev.track.on
        ENDOF
        SE_RANDOMIZE OF
            drop se.randomize
            draw.data: self
        ENDOF
        SE_RUBBER OF
            ev.track.on 2drop
        ENDOF
    ENDCASE
;

: SE.EXEC.MOVE ( value elmnt -- )
    2dup tell.xy: self
    se-mode @
    CASE
        SE_TRACE OF
\ Add to end if traced past.
            dup iv-edit-shape many: [] =
            IF ( make room for one more if past end )
              dup 1- 0 max 1 iv-edit-shape  stretch: []
              iv-edit-shape update: []
              get.dim: self iv-edit-shape clip.ed.to: []
            ELSE ( -- v e )
\ Interpolate values if elements skipped.
              dup iv-edit-last-elm - abs 1 >
              IF  ( -- v e , more than one element traced )
                tuck swap
                iv-edit-last-elm iv-edit-last-val  set.interp
                ( -- e ) iv-edit-last-elm -2sort >r 1+ r>
                DO i interp  i
                   get.dim: self iv-edit-shape clip.ed.to: []
                LOOP
              ELSE ( -- v e )
                get.dim: self iv-edit-shape clip.ed.to: []
              THEN
            THEN
            se.draw.lines
        ENDOF
        SE_RUBBER OF
            gr.mode@ >r
            gr.color@ >r
            gr_xor_mode gr.mode!
            gr_white gr.color!
            se_edit_tnr scg.selnt
            iv-edit-first-elm iv-edit-first-val scg.wc->dc
              2dup gr.move
            iv-edit-last-elm iv-edit-last-val scg.draw
            gr.move swap scg.draw
            r> gr.color!
            r> gr.mode!
        ENDOF
        2drop  
    ENDCASE
;

: SE.EXEC.UP ( value elmnt -- )
    se-mode @
    CASE
        SE_REPLACE OF 
            get.dim: self iv-edit-shape clip.ed.to: []
            update.draw: self
        ENDOF
        SE_RUBBER OF
            gr.mode@ >r
            gr.color@ >r
            gr_xor_mode gr.mode!
            gr_white gr.color!
            se_edit_tnr scg.selnt
            iv-edit-first-elm iv-edit-first-val scg.move
            iv-edit-last-elm iv-edit-last-val scg.draw
            2drop
            r> gr.color!
            r> gr.mode!
\
            iv-edit-first-elm iv-edit-last-elm -
            IF  iv-edit-first-elm iv-edit-first-val
                iv-edit-last-elm iv-edit-last-val  set.interp
                iv-edit-first-elm iv-edit-last-elm -2sort >r 1+ r>
                DO i interp i
                   get.dim: self iv-edit-shape clip.ed.to: []
                LOOP
                draw.data: self
            THEN
        ENDOF
        SE_SET_Y OF
            drop iv=> iv-edit-ymark
            draw.data: self
        ENDOF
        SE_TRACE OF
            2drop se.draw.trim  \ draw remaining stuff
        ENDOF
        2drop
    ENDCASE
    ev.track.off
;

: SE.XY>VAL.ELM  ( x y -- value elmnt , unclipped)
    service.tasks
    iv-edit-shape 0= IF
       " EXECUTE: OB.CTRL.EDIT" " NO shape." er_fatal er.report
    THEN

    se_edit_tnr scg.selnt
    scg.dc->wc  SWAP ( val elmnt# )
    0 scg.selnt
;

: SE.CLIP.ELM ( elemnt -- elemnt' , clipped to current range )
    0 iv-edit-shape  many: []  clipto   ( clip to max+1 )
    iv-edit-shape max.elements: [] 1- min  ( clip to limit )
;

: SE.GET.VAL.ELM  ( x y -- value elmnt , clipped )
	se.xy>val.elm
	se.clip.elm
;

:M EXEC.DOWN: ( -- , perform current edit mode on morph)
    iv-edit-x iv-edit-y
    se.get.val.elm
    2dup iv=> iv-edit-last-elm iv=> iv-edit-last-val
    2dup iv=> iv-edit-first-elm iv=> iv-edit-first-val
    se.exec.down
    0 scg.selnt
;M

:M MOUSE.MOVE: ( x y -- , perform current edit mode on morph)
	se-mode @ SE_SELECT =
    IF
    	se.xy>val.elm 2dup
\ same as before?
        dup iv-edit-last-elm =
        2 pick iv-edit-last-val = AND not
        IF  
    		se_edit_tnr scg.selnt
    		se.draw.select
    		iv-edit-first-elm 2sort
    		put.select: self
    		se.draw.select
    		drop \ don't need value
        ELSE 2drop
        THEN
        iv=> iv-edit-last-elm iv=> iv-edit-last-val
        0 scg.selnt
    ELSE
    	2dup ?hit: self
    	IF  se.get.val.elm 2dup
\ same as before?
        	dup iv-edit-last-elm =
        	2 pick iv-edit-last-val = AND not
        	IF  se.exec.move
        	ELSE 2drop
        	THEN
        	iv=> iv-edit-last-elm iv=> iv-edit-last-val
        	0 scg.selnt
    	ELSE 2drop
    	THEN
	THEN
;M

:M MOUSE.UP: ( x y -- , perform current edit mode on morph)
    se.get.val.elm
    se.exec.up
    0 scg.selnt
;M
    
:M MOUSE.DOWN: (  x y -- trapped? , process mouse DOWN event )
    2dup  iv=> iv-edit-y  iv=> iv-edit-x
    mouse.down: super
;M


;CLASS


\ Declare edit objects -------------------------------------
OB.CTRL.EDIT SE-EDITBOX

\ Support words for Shape Edit Operations
: SE.GET.SHAPE ( -- shape , currently being edited )
    get.object: se-editbox
;
: SE.GET.SELECT ( -- lo hi , elment range selected )
    get.select: se-editbox
;
: SE.GET.DIM ( -- dimension , currently shown )
    get.dim: se-editbox
;
: SE.GET.YMARK ( -- ymark_value , as used by invert and randomize )
    get.ymark: se-editbox
;
: SE.UPDATE.DRAW ( -- , redraw shape after change )
    update.draw: se-editbox
;

\ Functions for deferred showing of what a player is playing.

: SE.NOW.PLAYING  ( elmnt# shape -- )
    cg-current-screen @ se-screen =
    servicing-tasks @ 0= and
    IF gr.check
       now.playing: se-editbox
    ELSE 2drop
    THEN
;

: SE.STOP.PLAYING  ( shape -- )
    cg-current-screen @ se-screen =
    servicing-tasks @ 0= and
    IF gr.check
       stop.playing: se-editbox
    ELSE drop
    THEN
;

: SE.TRACK.ON ( -- )
    'c se.now.playing is pl.now.playing
    'c se.stop.playing is pl.stop.playing
;


: SE.TRACK.OFF ( -- )
    'c 2drop is pl.now.playing
    'c drop is pl.stop.playing
;

: BUILD.SE-EDITBOX  ( -- , build shape editor )
    2700 2300 put.wh: se-editbox
;

if.forgotten se.track.off
\ Declare Dimension counter -----------------------------------
OB.COUNTER SE-DIMCOUNT

: SE.DODIM ( value part -- , process change in dimension )
    drop
    put.dim: se-editbox
    draw: se-editbox
;

: BUILD.SE-DIMCOUNT
    " Dim" put.title: se-dimcount
    1 0 put.value: se-dimcount
    1 put.dim: se-editbox

\ Set Geometry
    200 700 put.wh: se-dimcount

\ Set word to execute when hit
    'c se.dodim put.down.function: se-dimcount
;

\ Numeric Grid for A,B,C operations. ------------------
OB.NUMERIC.GRID SE-ABC-CG

: BUILD.ABC  ( -- )
    3 1 new: se-abc-cg
    270 300 put.wh: se-abc-cg
    -100 -1 put.min: se-abc-cg
    100 -1 put.max: se-abc-cg
    "  A    B    C" put.title: se-abc-cg
    2 0 put.value: se-abc-cg
    1 1 put.value: se-abc-cg
    0 2 put.value: se-abc-cg
;

\ Options Grid ------------------------------------------------
OB.CHECK.GRID SE-OPTIONS-CG

variable SE-IF-ALL

: SE.OPTIONS.FUNC   ( value part -- )
    CASE
       0 OF se-if-all ! ENDOF
       1 OF IF se.track.on
            ELSE se.track.off
                 se.get.shape   stop.playing: se-editbox
            THEN
         ENDOF
    ENDCASE
;

: BUILD.OPTIONS ( -- )
    2 1 new: se-options-cg
    350 300 put.wh: se-options-cg
    stuff{ " All/1" " Track" }stuff.text: se-options-cg
    'c se.options.func put.down.function: se-options-cg
\
\ set tracking ON by default
    true 1 put.value: se-options-cg
    se.track.on
\    " Options" put.title: se-options-cg
;

\ Declare Operations Grid -------------------------------------
OB.MENU.GRID SE-OPERCG
-1  ( The order of these constants must match that in BUILD.SE-OPERCG)
1+ dup constant SE_CUT
1+ dup constant SE_COPY
1+ dup constant SE_PASTE
1+ dup constant SE_*A/B+C
1+ dup constant SE_-C*B/A
1+ dup constant SE_UP_1
1+ dup constant SE_DOWN_1
1+ dup constant SE_REVERSE
1+ dup constant SE_INVERT
1+ dup constant SE_SCRAMBLE
1+ dup constant SE_ZOOM
1+ dup constant SE_UNZOOM
1+ dup constant SE_PAN_LEFT
1+ dup constant SE_PAN_RIGHT
1+ dup constant SE_CUSTOM
drop

: SE.REVERSE  ( -- , Reverse values in range. )
    se.get.select 2dup <
    IF 1-    se-if-all @ IF -1 ELSE se.get.dim THEN
       se.get.shape
       reverse: []
       draw.data: se-editbox  ( update display )
    ELSE 2drop
    THEN
;

: SE.SCRAMBLE  ( -- , SCRAMBLE values in range. )
    se.get.select 2dup <
    IF 1-    se-if-all @ IF -1 ELSE se.get.dim THEN
       se.get.shape
       scramble: []
       draw.data: se-editbox  ( update display )
    ELSE 2drop
    THEN
;

: SE.SHOW.XY ( -- , show position of first point in range )
    se.get.select drop
    dup se.get.dim  ( -- elmnt# elmnt# dim )
    se.get.shape ed.at: []  ( -- elmnt# value )
    swap tell.xy: se-editbox
;

: SE.TRANSPOSE  ( value -- , transpose select )
    se.get.select 2dup <
    IF 1- se.get.dim
       se.get.shape
       transpose: []
       se.update.draw
       se.show.xy
    ELSE 2drop drop
    THEN
;

: SE.TRANSPOSE.DOWN  ( -- , Transpose values down in select. )
    -1 se.transpose
;

: SE.TRANSPOSE.UP ( -- , Transpose values up in select. )
    1 se.transpose
;


: SE.*A/B+C  ( -- , scale and transpose data )
    1 get.value: se-abc-cg 0= 0=
    se.get.select < and
    IF 0 get.value: se-abc-cg
       1 get.value: se-abc-cg
       se.get.select
       1- se.get.dim
       se.get.shape
       scale: []
\
       2 get.value: se-abc-cg
       se.get.select
       1- se.get.dim
       get.object: se-editbox
       transpose: []
       se.update.draw
       se.show.xy
    THEN
;


: SE.-C*B/A  ( -- , inverse of scale and transpose data )
    0 get.value: se-abc-cg 0= 0=
    se.get.select < and
    IF 2 get.value: se-abc-cg negate
       se.get.select
       1- se.get.dim
       se.get.shape
       transpose: []
\
       1 get.value: se-abc-cg
       0 get.value: se-abc-cg
       se.get.select
       1- se.get.dim
       se.get.shape
       scale: []
       se.update.draw
       se.show.xy
    THEN
;

OB.ELMNTS SE-PASTE   ( Paste buffer)

: SE.COPY  ( -- , copy select region to paste buffer )
    se.get.select  ( -- s e )
    over -    ( -- s count )
    ?dup
    IF    ( -- s count )
        free: se-paste se.get.shape width: []
        set.width: se-paste
        dup se.get.shape dimension: [] new: se-paste
        dup set.many: se-paste
        0 swap se-paste  ( -- start 0 count se-paste )
        se.get.shape copy: []
\
\ Enable PASTE
        se_paste get.enable: se-opercg 0=
        IF true se_paste put.enable: se-opercg
           draw: se-opercg
        THEN
    ELSE drop
    THEN
;

: SE.CHOP ( -- , Remove selected range. )
    se.get.select 2dup <
    IF  ( -- s e )
        over -   ( -- s count )
        se.get.shape chop: []
        se.get.select drop  ( reset select range )
        dup put.select: se-editbox
        se.get.shape update: []
    ELSE 2drop
    THEN
;

: SE.CUT   ( -- , cut and copy select to paste buffer )
    se.copy
    se.chop
    draw.data: se-editbox  ( update display )
;

: <SE.PASTE>   ( -- , perform actual paste)
\ Destroy selected range.
    se.chop
\
    se.get.select drop
    many: se-paste  ( -- start count )
\ Make room for new data. Check for being at end.
    over se.get.shape many: [] <
    IF 2dup   se.get.shape split: []
    ELSE dup se.get.shape dup >r many: [] +
         r> set.many: []
    THEN
\ Move from paste buffer.  ( -- start count )
    0 -rot se.get.shape copy: se-paste
    draw.data: se-editbox  ( update display )
;

: SE.PASTE   ( -- , paste from current position paste buffer )
\ Check PASTE buffer.
    many: se-paste
    IF
\ Check to make sure paste has same width and dimension
\ as target.
        se.get.shape width: []
        width: se-paste =
        se.get.shape dimension: []
        dimension: se-paste = AND
        IF
\ Check for overflow.
            se.get.select swap -  ( -- #selected )
            many: se-paste swap -          ( -- #to_add )
            se.get.shape check.over: []
            IF
                " SE.PASTE" " Paste would overflow shape!"
                er_return er.report
            ELSE  <se.paste>        ( actually do it! )
            THEN
            se.get.select put.select: se-editbox
        ELSE
            " SE.PASTE" " Different dimension and width!"
            er_return er.report
        THEN
\ No DATA
    ELSE
        " SE.PASTE" " Must do CUT or COPY first!"
         er_return er.report
    THEN
;

: SE.INVERT  ( -- , Invert portion of shape. )
    se.get.select 2dup <
    IF se.get.ymark -rot 1-
       se.get.dim
       se.get.shape invert: []
       se.update.draw
    ELSE 2drop
    THEN
;

V: SE-IF-ZOOMED
: SE.ZOOM ( -- , Zoom on selected range. )
    se.get.select
    2dup  2- >
    IF 2drop " SE.ZOOM" " Must select range first."
       er_return er.report 
    ELSE
       1- put.range: se-editbox
       draw: se-editbox
       se-if-zoomed @ NOT
       IF  1 se_unzoom put.enable: se-opercg
           1 se_pan_left put.enable: se-opercg
           1 se_pan_right put.enable: se-opercg
           draw: se-opercg
       THEN true se-if-zoomed !
    THEN
;

: SE_MAX_INDEX   ( -- maximum_index )
    se.get.shape
    max.elements: [] 1-
;

: SE.UNZOOM ( -- , UnZoom )
    0 se_max_index put.range: se-editbox
    draw: se-editbox
    false se-if-zoomed !
    0 se_pan_left put.enable: se-opercg
    0 se_pan_right put.enable: se-opercg
    draw: se-opercg
;

: SE.FIT.WITHIN ( x1 x2 -- x1' x2' )
    over - >r    ( width )
    0 se_max_index r@ - clipto   ( position left edge )
    dup r> +    ( calc right )
;

: SE.PAN ( shift_count -- , Shift viewing range. )
    get.range: se-editbox 2 pick83 +
    >r + r> se.fit.within put.range: se-editbox
    draw: se-editbox
;

: SE.PAN.LEFT ( -- , Pan to the left )
    get.range: se-editbox swap - 2/ negate se.pan
;

: SE.PAN.RIGHT ( -- , Pan to the left )
    get.range: se-editbox swap - 2/ se.pan
;

OB.OBJLIST SE-OPER-CFAS
VARIABLE SE-OPER-PAGE   ( contains page of operators )

: SE.EXEC.OPER  ( value part -- )
    nip exec: se-oper-cfas
;

: BUILD.SE-OPERCG ( -- )
\ Build first page.
    stuff{ 'c se.cut  'c se.copy 'c se.paste
      'c se.*a/b+c 'c se.-c*b/a
      'c se.transpose.up 'c se.transpose.down 'c se.reverse
      'c se.invert  'c se.scramble 
      'c se.zoom  'c se.unzoom 'c se.pan.left 'c se.pan.right
      'c noop
    }stuff: se-oper-cfas

    5 3 new: se-opercg
\    " Operations" put.title: se-opercg
\
\ Set Geometry
    570 280 put.wh: se-opercg
    'c se.exec.oper put.down.function: se-opercg
    false se_paste   put.enable: se-opercg
    false se_Pan_left  put.enable: se-opercg
    false se_Pan_right put.enable: se-opercg
    false se_custom  put.enable: se-opercg
    stuff{ " Cut"      " Copy"    " Paste"
      " *A/B+C"   " -C*B/A"  " Up 1"
      " Down 1"   " Reverse" " Invert"
      " Scramble" " Zoom"    " UnZoom"
      " <= Pan"   " Pan =>"   " Custom"
    }stuff.text: se-opercg
;

: SE.SET.CUSTOM  ( text cfa -- , allow custom function in SE )
    se_custom put: se-oper-cfas
    se_custom put.text: se-opercg
    true se_custom put.enable: se-opercg
;

: SE.RESET.CUSTOM ( -- )
    " Custom" 'c noop se.set.custom
    false se_custom put.enable: se-opercg
;

: SE.DRAW.SCREEN   ( -- , Make shape editor current screen )
    draw: se-screen
;

: SE.SET.SHAPE  ( shape -- , Set shape in editor )
\ Check for allocated space.
    dup limit: [] 0=
    IF cr ." Space automatically allocated.  32 3 NEW: " 
       dup name: [] beep cr 
       32 3   2 pick83 new: []
       10 20 100  3 pick83 add: []
    THEN
\
\ Set up dimension counter
    dup dimension: []  1- 
    dup 0 put.max: se-dimcount  ( set max dimension )
\ Attempt to stay on same dimension as before.
    se.get.dim MIN dup put.dim: se-editbox
    0 put.value: se-dimcount
\
\ Set up edit display box  ( -- shape )
    dup put.object: se-editbox
    update: se-editbox
\
\ Make sure it is in SHAPE-HOLDER
    dup indexof: shape-holder
    IF 2drop
    ELSE add: shape-holder
    THEN    
;

: SE.EDIT.SHAPE ( shape -- )
	se.set.shape
	draw: se-screen
;

\ Setup -------------------------------------------------------
: SE.SETUP  ( shape -- , set up shape editor for a shape )
    se.set.shape
    draw: se-editbox
    draw: se-dimcount
;

: SE.STARTUP ( -- , Set shape editor to known state. )
    ml.validate  ( make sure all shapes valid, 00002 )
    many: shape-holder 0=
    IF  shape-1 add: shape-holder
        shape-1
    ELSE se.get.shape
        dup indexof: shape-holder
        IF ( -- shape index )
            drop ( shape found in shape-holder, use it. )
        ELSE ( -- bad_shape )
            drop 0 get: shape-holder
        THEN
    THEN  ( -- shape )
    se.set.shape
    0 scg.selnt
;

\ Selector -----------------------------------------
OB.COUNTER SE-SHSELCG
: SE.CHOOSESH    ( index part -- , Make selected shape current.)
	swap  ( get index )
	dup many: shape-holder <
	IF  get: shape-holder   se.setup
	ELSE drop
	THEN
\
\ redraw entire screen if hit in middle
    dup 1 = swap 2 = or
    IF 	se.draw.screen
    THEN
;

: SE.TEXT.FUNC ( index -- addr count , get name of shape )
    ml.validate ( 00002 )
    many: shape-holder 1- 0 put.max: se-shselcg \ 00001
    get: shape-holder get.name: [] count
;

: BUILD.SE-SHSELCG
    " Select Shape" put.title: se-shselcg
    800 700 put.wh: se-shselcg
    'c se.choosesh put.down.function: se-shselcg
    'c se.text.func put.text.function: se-shselcg
;
    
\ Define edit screen ------------------------------------------

: BUILD.ESCR
    build.se-mode
    build.se-editbox
    build.se-dimcount
    build.se-opercg
    build.se-shselcg
    build.abc
    build.options
    10  3 new: SE-SCREEN
    SE-EDITBOX            1330     303  add: SE-SCREEN
    SE-OPERCG              100    3000  add: SE-SCREEN
    SE-OPTIONS-CG         3158    3537  add: SE-SCREEN
    SE-ABC-CG             3150    3000  add: SE-SCREEN
    SE-SHSELCG             100    2141  add: SE-SCREEN
    SE-DIMCOUNT            958    2141  add: SE-SCREEN
    SE-MODECG              100     652  add: SE-SCREEN

    " Shape Editor" put.title: se-screen
    ascii S put.key: se-screen
\
\ Set DRAW function.
    'c se.startup put.draw.function: se-screen
;

: SE.INIT   ( -- , Initialize shape editor )
    " SE.INIT" debug.type
    false se-if-zoomed !
\ Fix up the default player for shape editor
	free: se-player
    init: se-player   ( to ensure proper CFAs on Mac )
    4 new: se-player
\
[ exists? INS-MIDI-1 [IF] ]
    ins-midi-1 put.instrument: se-player
[ [THEN] ]
\
    1000000 put.repeat: se-player
\
    build.escr
\
    32 3 new: shape-1
    rtc.rate@ 3 /    \ duration
    dup 10 choose 10 + 100 add: shape-1
    dup 10 choose 10 +  90 add: shape-1
    dup 10 choose 10 +  90 add: shape-1
    dup 10 choose 10 +  90 add: shape-1
    drop
    shape-1 se.set.shape
\
    se-screen default-screen !
    'c se.edit.shape is edit.shape
;

: SE.TERM
    " SE.TERM" debug.type
    free: se-player
    free: shape-1
    freeall: se-screen
    free: se-oper-cfas
    free: se-screen
    'c drop is edit.shape
;

\ These are loaded above HMSL.INIT as optional modules
\ so use USER.INIT
: USER.INIT user.init se.init ;
: USER.TERM se.term user.term ;

\ A few user accessible SE words
: SE.UPDATE.SHAPE  ( shape -- , update drawing if being shown )
    se.get.shape =  ( same shape? )
    IF  cg-current-screen @ se-screen =  ( in SE ? )
        IF  servicing-tasks @ 0=  ( not called from SERVICE.TASKS )
            IF servicing-tasks on  \ disable it
               gr.check se.update.draw
               servicing-tasks off
            THEN
        THEN
    THEN
;

: HMSL.EDIT.PLAY ( shape -- , edit and simultaneously play a shape )
    hmsl.init
    limit: se-player 1 <
    IF 4 new: se-player
    THEN
    clear: se-player dup add: se-player
    hmsl.open  ( make window available for drawing )
    se.set.shape   ( set up shape editor )
    se-screen default-screen !
    se-player hmsl.play
;

: SHEP  ( -- , quickly play and edit a shape )
    shape-1 hmsl.edit.play
;


\ ---------------------------------------------------------
if.forgotten se.term

false [IF]
: HMSL.CHECK.EVENT ( -- done? , Process one event from event queue. )
    false         ( default done flag )
    ev.get.event  ( get one event )
    CASE 
         EV_NULL OF ENDOF

         EV_MOUSE_DOWN OF cg-current-screen @ ?dup
                 IF gr.getxy rot mouse.down: [] drop THEN
             ENDOF

         EV_MOUSE_UP OF cg-current-screen @ ?dup 
                 IF gr.getxy rot mouse.up: [] THEN
             ENDOF

         EV_MOUSE_MOVE OF  cg-current-screen @ ?dup 
                 IF gr.getxy rot mouse.move: [] THEN
             ENDOF

\         EV_REFRESH OF
 \               hmsl.refresh
  \       ENDOF

\         EV_MENU_PICK OF
 \               process.menus
  \       ENDOF

         EV_CLOSE_WINDOW OF drop true \ STOP HMSL !
             ENDOF
    ENDCASE
;

: LOOP.SCREEN
    stack.mark
    BEGIN
        stack.check
        hmsl.check.event
    UNTIL
;

: TEST.SE
    SE.INIT
    gr.check
    draw: se-screen
    loop.screen
    SE.TERM
;

[THEN]
