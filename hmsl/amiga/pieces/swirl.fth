\ Rotate dimensions of a source shape.
\
\ Composer: Phil Burk
\ Copyright 1987 Phil Burk
\
\ Performed 11/13/87 at Mills College
\ MOD: 12/4/87 Changed OB.TEST.SAMPLE to OB.SAMPLE

include? bsort ju:bsort
include? ob.2d.transform ht:2d_transform

ANEW TASK-SWIRL

\ Controlling constants
240 value SW_TEMPO  ( tempo )
500 value SW_RANGE  ( original parameter range )
\ sw_range 141 100 */ value SW_ROTATED_RANGE  ( sqrt[2] after )
sw_range 160 100 */ value SW_ROTATED_RANGE  ( scaled )

$ 00800 value SW_ANGLE_INC  ( angle increment )

OB.SHAPE SOURCE-SHAPE
OB.SHAPE PLAYED-SHAPE
OB.PLAYER SW-PLAYER
OB.2D.TRANSFORM SW-MATRIX

\ Control grids
OB.MENU.GRID SW-GRID
OB.SCREEN SW-SCREEN

\ Declare several samples for switching.
\ This will help to uniquely identify a point.
OB.SAMPLE SW-SAMPLE-1
OB.SAMPLE SW-SAMPLE-2
OB.SAMPLE SW-SAMPLE-3
OB.SAMPLE SW-SAMPLE-4
OB.SAMPLE SW-SAMPLE-5
OB.SAMPLE SW-SAMPLE-6
OB.OBJLIST SW-SAMPLES

: SW.SAMPLES.INIT
    " hs:mcsingle" dup $. load: sw-sample-1
    " hs:bowl"     dup $. load: sw-sample-2
    " hs:analog1"  dup $. load: sw-sample-3
    " hs:uhh"      dup $. load: sw-sample-4
    " hs:mando5th" dup $. load: sw-sample-5
    " hs:peking"   dup $. load: sw-sample-6
\
    stuff{
      sw-sample-1
      sw-sample-2
      sw-sample-3
      sw-sample-4
      sw-sample-5
      sw-sample-6
    }stuff: sw-samples
;

: SW.SAMPLES.TERM
    freeall: sw-samples
    free: sw-samples
;

\ Pitch range is 160  - 1000 => 840
\ Scaled absolute 0 - 840
: SW.SOURCE.INIT ( -- )

        32 4  new: SOURCE-SHAPE
       0     274      62       1 add: SOURCE-SHAPE
      31     438      41       1 add: SOURCE-SHAPE
      62     371      32       1 add: SOURCE-SHAPE
      93     727      54       4 add: SOURCE-SHAPE
     124     327      40       5 add: SOURCE-SHAPE
     155     274      45       5 add: SOURCE-SHAPE
     186     337      39       2 add: SOURCE-SHAPE
     217     742      60       2 add: SOURCE-SHAPE
     248     472      64       3 add: SOURCE-SHAPE
     279     573      56       0 add: SOURCE-SHAPE
     310     461      50       0 add: SOURCE-SHAPE
     341     427      62       0 add: SOURCE-SHAPE
     372     450      36       0 add: SOURCE-SHAPE
     403     562      59       5 add: SOURCE-SHAPE
     434     274      64       4 add: SOURCE-SHAPE
     465     427      64       2 add: SOURCE-SHAPE
\
    " Absolute" 0 put.dim.name: source-shape
    " Period" 1 put.dim.name: source-shape
    " Loudness" 2 put.dim.name: source-shape
    " Sample#" 3 put.dim.name: source-shape
\
    sw_rotated_range 2/ sw_range 2/ -
    dup sw_range + 124 + swap 124 + swap
    ." Pitch limits = " 2dup . . cr 
    1 put.dim.limits: source-shape
    0 64 2 put.dim.limits: source-shape
    0 5 3 put.dim.limits: source-shape
\
\ Set absolute pitches to steady rhythm at first.
    sw_range many: source-shape /  ( -- increment )
    many: source-shape 0
    DO  i over *
        i 0 ed.to: source-shape
    LOOP drop
\
    32 4 new: played-shape
\
    clear: shape-holder
    source-shape add: shape-holder
    played-shape add: shape-holder
;

: SW.COPY2PLAYED  ( -- , copy source to played )
    clear: played-shape
    many: source-shape 0
    DO  i get: source-shape
        add: played-shape
    LOOP
;

: SW.EXCH? ( i1 i2 -- , exchange if s[i1,0] > s[i2,0] )
    2dup 0 ed.at: played-shape
    swap 0 ed.at: played-shape  <
    IF  2dup >r >r >r >r
        r> get: played-shape
        r> get: played-shape
        r> put: played-shape
        r> put: played-shape
    ELSE 2drop
    THEN
;

: SW.SORT.PLAYED  ( -- , sort played-shape by absolute dim0 )
    'c sw.exch? is bsort-exch?
    many: played-shape bsort
;

: SW.ABS->DUR  ( -- convert absolute to durational )
    0 0 ed.at: played-shape   ( abs0 )
    many: played-shape  1
    DO  i 0 ed.at: played-shape tuck  ( -- abs1 abs0 abs1 )
        swap - 60 * sw_tempo /  ( scale down )
        i 1- 0 ed.to: played-shape ( -- abs1 )
    LOOP drop
\ Set last duration.
    8 many: played-shape 1- 0 ed.to: played-shape
;

V: SW-XCENTER
V: SW-YCENTER
V: SW-ANGLE
V: SW-DELTA-ANGLE

: SW.ROTATE  ( -- )
    sw-xcenter @ sw-ycenter @ sw-angle @
    calc.rotate.point: sw-matrix
    0 1 played-shape array.multiply: sw-matrix
;

: SW.DRAW.01 ( -- )
    0 0 ed.at: played-shape
    0 1 ed.at: played-shape
    scg.move
    many: played-shape 1
    DO  i 0 ed.at: played-shape
        i 1 ed.at: played-shape
        scg.draw
    LOOP
;

V: SW-COLOR
: SW.DRAW.ABSOLUTE ( -- )
    cg-current-screen @ sw-screen =
    IF  2 scg.selnt
        sw-color @ 1+ 1 and dup sw-color !
        2* 1+ gr.color!  ( use 1 or 3 )
        sw.draw.01
    THEN
;

: SCG.CLEAR.VIEW ( tnr -- , danger! needs sorted vertices )
    gr.color@ 0 gr.color!  ( to black )
    swap get: scg-viewports -rot gr.rect  ( clear view )
    gr.color!
;

: SW.DRAW.SORTED ( -- )
    cg-current-screen @ sw-screen =
    IF  3 scg.selnt
        3 scg.clear.view
        sw.draw.01
    THEN
;

: SW.TRANSFORM ( player -- , repeat function, transform shape)
    DROP
    sw-delta-angle @ sw-angle +!
    sw.copy2played
    sw.rotate
    sw.draw.absolute
    sw.sort.played
    sw.draw.sorted
    sw.abs->dur
    490 20 gr.move sw-angle @  hex gr.number decimal
    "   " gr.text
;   

: SW.SET.CENTER ( -- )
    calc.stats: source-shape
    0 get.dim.max: source-shape
    0 get.dim.min: source-shape + 2/
    sw-xcenter !
    1 get.dim.max: source-shape
    1 get.dim.min: source-shape + 2/
    sw-ycenter !
;

: SW.SET.CENTER
    sw_range 2/ sw-xcenter !
    sw_rotated_range 2/ 124 2/ + sw-ycenter !
;

V: SW-CHANNEL

: SW.ON.INTERP ( elmnt# shape instr -- )
    >r
    sw-channel @ 1+ 3 and dup sw-channel !
    dup r@ put.channel: [] da.channel!
\
    2dup 3 swap ed.at: []  ( get sample# )
    get: sw-samples r@ put.waveform: []
\
    interp.extract.pv
    r@ put.loudness: []
    124 max ( clip to DA_MAX ) r@ put.period: []
    r> start: []
;

: SW.GRID.FUNC ( value part# -- )
    nip
    CASE
        0 OF 2 scg.clear.view ENDOF
        1 OF sw_angle_inc sw-delta-angle ! \ forward
		 ENDOF
        2 OF sw_angle_inc negate sw-delta-angle ! \ reverse 
		ENDOF
        3 OF 0 sw-delta-angle ! \  stop rotating 
		ENDOF
    ENDCASE
;

: SW.CONTROL.INIT ( -- )
    0 scg.selnt
    4 1 new: sw-grid
    440 300 put.wh: sw-grid
\
    stuff{
      " Clear"
      " Forward"
      " Stop"
      " Reverse"
    }stuff.text: sw-grid
    'c sw.grid.func put.down.function: sw-grid
\
    2 3 new: sw-screen
    sw-grid 1000 80 add: sw-screen
    " Swirl" put.title: sw-screen
;

: SW.CONTROL.TERM ( -- )
    free: sw-grid
    free: sw-screen
;

\ -------------------------------
: SW.WINDOW.INIT  ( -- , allow for SQRT[2] ranging )
    40 300 180 30 2 scg.svp
    sw_range 2/ sw_rotated_range 2/ -
    dup sw_rotated_range +
    ." WINDOW = " 2dup swap . .
    sw_rotated_range 124 + 124
    2 scg.swn
    340 600 180 30 3 scg.svp
    2 scg.qwn
    3 scg.swn
;

: SWIRL.INIT ( -- )
    sw.control.init
    sw.source.init
    sw.samples.init
    sw.copy2played
    sw.abs->dur
    new: sw-matrix
    sw.set.center
    0 dup sw-delta-angle !   sw-angle !
    sw.window.init
\
    played-shape ins-amiga-1 build: sw-player
    400 put.repeat: sw-player
    40 put.repeat.delay: sw-player
    'c sw.transform put.repeat.function: sw-player
\
    sw-sample-1 put.waveform: ins-amiga-1
    0 put.envelope: ins-amiga-1
    'c sw.on.interp put.on.function: ins-amiga-1
    'c 3drop put.off.function: ins-amiga-1
;

: SWIRL.TERM
\    " ram:swd" $logto
\    dump.source: source-shape
\    logend
\
    free: source-shape
    free: played-shape
    free: sw-player
    free: sw-matrix
    sw.samples.term
    sw.control.term
;

: SWIRL.PLAY ( -- )
    sw-player hmsl.play
;

: SWIRL ( -- )
    swirl.init
    swirl.play
    swirl.term
;

if.forgotten swirl.term

cr ." Enter:   SWIRL" cr
