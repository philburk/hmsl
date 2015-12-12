\ Example Of Making Control Grids
\ Part of Design Document dated 12/9/87
\
\ Author: Phil Burk
\ Copyright 1987 Phil Burk, Larry Polansky, David Rosenboom
\ All Rights Reserved
\
\ MOD: PLB 8/8/88 Made to work with actual grids.
\ MOD: PLB 3/21/89 Test OB.CONTROL class.
\ MOD: PLB 2/26/90 Remove refs to CUSTOM-SCREENS
\ 00001 PLB 2/20/92 test PUT.xxx.FUNCTION for Screens
\ 00002 PLB 2/21/92 Make larger for bevel, and lower message.

include? ob.control h:control
include? ob.counter h:ctrl_count
include? ob.numeric.grid h:ctrl_numeric
include? ob.fader  h:ctrl_fader
include? ob.screen h:screen
decimal

ANEW TASK-EXAMPLE_GRIDS

variable MF-CHANNEL
1 MF-CHANNEL !

350 value DCG_HEIGHT \ 00002

\ Simple control class.
OB.CONTROL MY-CONTROL

\ Example of CHECK Grid --------------------- check
\ Function to be called from check grid.
: CHECK.FUNCTION ( value part -- , do something )
    mf-channel @ midi.channel!
    0=
    IF $ 40 ( sustain pedal )
    ELSE $ 41 ( portamento pedal )
    THEN swap
    IF 127 
    ELSE 0
    THEN midi.control
;

OB.check.GRID MY-check    ( declare check grid )

: BUILD.MY-check ( -- )
    1 2 new: my-check     ( allocate room for two cells )
    700 dcg_height put.wh: my-check  ( position it )
\
\ Load check with functions and text.
    'c check.function put.down.function: my-check
    stuff{ " Sustain" " Portamento" }stuff.text: MY-check
;

\ Example of MENU Grid --------------------- MENU
\ Build A MENU Grid to turn on or off a MIDI note.
\ Choose a sustained organ like preset.
OB.MENU.GRID MY-MENU

CREATE SIMPLE-GAMUT 0 c, 2 c, 4 c, 5 c, 7 c, 9 c, 11 c, 12 c,
: NOTES.ON/OFF ( value part -- turn note on or off )
    mf-channel @ midi.channel!
    simple-gamut + c@ 60 +  ( note )
    swap IF 100 ELSE 0 THEN  ( velocity )
    midi.noteon
;

: BUILD.MY-MENU ( -- )
    4 2 new: my-menu
    160 dcg_height put.wh: my-menu
    'c notes.on/off put.down.function: my-menu
    'c notes.on/off put.up.function: my-menu
    " Notes" put.title: my-menu
    stuff{ " C"  " D"  " E"
    " F"  " G"  " A"
    " B"  " C"  }stuff.text: my-menu
;

\ Example of RADIO Grid ----------------------- RADIO
OB.RADIO.GRID MY-RADIO
: SHOW.MODE ( value part -- , set mode for future actions )
    nip
    ." Now in "
    get.text: my-radio count type
    ."  mode!" cr
;

\ When this word is called it will behave as chosen.
: USE.MODE  ( a b -- , Use current mode )
    GET.LASTHIT: MY-RADIO
    CASE
        0 OF -ROT + SWAP ENDOF
        1 OF -ROT - SWAP ENDOF
        2 OF -ROT * SWAP ENDOF
        3 OF -ROT / SWAP ENDOF
    ENDCASE
    ." Answer is " . CR
;

: BUILD.MY-RADIO ( -- )
    2 2 new: my-radio
    500 dcg_height put.wh: my-radio
\
    'c show.mode put.down.function: my-radio
    stuff{ " Add"    " Subtract"
    " Multiply" " Divide" }stuff.text: my-radio
\ this choice disabled.
    false 3 put.enable: my-radio
;

\ Example of COUNT grid ---------------------- COUNT
exists? ob.counter .IF
OB.COUNTER MIDI-COUNT

: SYNC.MIDI-COUNT ( -- )
    mf-channel @ 0 put.value: midi-count
;

: MC.CHANGE.CHANNEL  ( value part -- )
    drop dup midi.channel!
    mf-channel !
;

: BUILD.MIDI-COUNT ( -- )
    200 900 put.wh: midi-count
    1  0 put.min: midi-count
    16 0 put.max: midi-count
\
    " channel" put.title: midi-count
    'c mc.change.channel put.down.function: midi-count
    'c sync.midi-count put.draw.function: midi-count
;

\ Example of SELECTOR grid ----------------------

OB.COUNTER MY-SELECT

: GET.MY.TEXT ( index -- addr count )
    CASE
        0 OF " FB-01" ENDOF
        1 OF " CZ-1000" ENDOF
        2 OF " EPS-10" ENDOF
        ." Out of range in GET.MY.TEXT" cr
        " ----" swap
    ENDCASE count
;

: USE.NAME ( value part -- )
    dup 1 = swap 2 = OR
    IF cr get.my.text type ."  chosen!" cr
    ELSE drop
    THEN
;

: BUILD.MY-SELECT ( -- )
    400 900 put.wh: my-select
\
    " names" put.title: my-select
    'c use.name put.down.function: my-select  ( no index!)
    'c get.my.text put.text.function: my-select
    2 0 put.max: my-select
;
.THEN

exists? ob.numeric.grid .IF
\ Example of NUMERIC grid -------------------- NUMERIC
OB.NUMERIC.GRID NUMERIC-PRESET

: SET.MIDI.PRESET ( preset index -- )
    1+ midi.channel!
    midi.preset
;

: MPR.LABEL.FUNC  ( i -- addr count , give label text )
    2* 1+ n>text
;

: BUILD.NP  ( -- )
    2 8 new: numeric-preset
    250 dcg_height put.wh: numeric-preset
    1 -1 put.min: numeric-preset
    127 -1 put.max: numeric-preset
    'c set.midi.preset put.move.function: numeric-preset
    'c set.midi.preset put.up.function: numeric-preset
    'c mpr.label.func put.text.function: numeric-preset
    "  preset" put.title: numeric-preset
;

OB.NUMERIC.GRID NUMERIC-CONTROLLER

: SET.MIDI.CONTROL ( preset index -- )
    1 =
    IF mf-channel @ midi.channel!
       0 get.value: numeric-controller swap midi.control
    ELSE drop
    THEN
;

: BUILD.NC ( -- )
    2 1 new: numeric-controller
    250 dcg_height put.wh: numeric-controller
    0 -1 put.min: numeric-controller
    127 -1 put.max: numeric-controller
    'c set.midi.control put.move.function: numeric-controller
    'c set.midi.control put.up.function: numeric-controller
    " ctrl value" put.title: numeric-controller
;

OB.NUMERIC.GRID NUMERIC-COMMON

: NCOM.FUNC ( value index -- )
   mf-channel @ midi.channel!
   1+ swap midi.control
;

: BUILD.NCOM ( -- )
    1 7 new: numeric-common
    250 dcg_height put.wh: numeric-common
    0 -1 put.min: numeric-common
    127 -1 put.max: numeric-common
    'c ncom.func put.down.function: numeric-common
    'c ncom.func put.move.function: numeric-common
    'c ncom.func put.up.function: numeric-common
    stuff{
        " Modulation"   " Breath"
        " Control 4"    " Foot"
        " Portam Time"  " Control 6"
        " Volume"
    }stuff.text: numeric-common
    " controls" put.title: numeric-common
;
.THEN

\ Example of SLIDER --------------------------- SLIDER
exists? ob.fader .IF
OB.FADER MY-FADER

: MF.BEND ( value part -- )
    mf-channel @ midi.channel!
    drop
    50 + $ 3FFF 100 */
    midi.bend
;

: BUILD.MY-FADER ( -- , build slider to BEND pitch )
    180 2000 put.wh: my-fader
    " bend" put.title: my-fader
\
    -50 0 put.min: my-fader
    50 0 put.max: my-fader
    0 0 put.value: my-fader
    1 put.increment: my-fader
\
\ slider specific methods
     200 put.knob.size: my-fader
\
    'c mf.bend put.move.function: my-fader
    'c mf.bend put.up.function: my-fader
;
.THEN

\ Build screen for placing objects. ----------- SCREEN
OB.SCREEN MY-SCREEN

: DRAW.MY-SCREEN ( -- )
\ Perform extra drawing operations.
    1000 3900 scg.move \ 00002
    " Experiment with these controls!" gr.text
\
\ Draw line under text.
    1000 3300 scg.move
    3 gr.color!
    3000 3300 scg.draw
;

\ Screen background functions 00001
: SCR.DOWN.FUNC { xpos ypos -- , play note }
    xpos 2/ 31 and 50 +
    ypos 2/ midi.noteon
    ev.track.on  \ so that MOVE events will be generated
;
: SCR.MOVE.FUNC ( xpos ypos -- , play new note )
    midi.lastoff scr.down.func
;
: SCR.UP.FUNC ( xpos ypos -- , turn off note )
    2drop midi.lastoff
    ev.track.off
;

: MY-SCREEN.INIT  ( -- )
\ Do all x,y placement here for easier layout.
    build.my-menu
    build.my-radio
    build.my-check
    build.midi-count
    build.my-select
    build.np
    build.nc
    build.ncom
    build.my-fader
\
\ Put controls in screen.
    10 3 new: my-screen
    my-menu            1200  500  add: my-screen
    my-check           1200 1500  add: my-screen
    my-radio           3000  200  add: my-screen
    midi-count          200  500  add: my-screen
    my-select          3400 1700  add: my-screen
    numeric-preset      650  500  add: my-screen
    numeric-controller 2000  500  add: my-screen
    numeric-common     2600 1000  add: my-screen
    my-fader           3000 1400  add: my-screen
\
\ Do extra things when drawn.
    'c draw.my-screen put.draw.function: my-screen
\
\ Test DOWN/MOVE/UP functions for screen 00001
    'c scr.down.func put.down.function: my-screen
    'c scr.move.func put.move.function: my-screen
    'c scr.up.func put.up.function: my-screen
\
\ Specify name for pull down menu.
    " MIDI Fun" put.title: my-screen
\
\ Make this screen come up first.
    my-screen default-screen !
    cg-3d on
;

: MY-SCREEN.TERM   ( -- , free allocated memory )
    freeall: my-screen
    free: my-screen
    0 default-screen !
    cg-3d off
;

exists? HMSL .IF
: MY-SCREEN.TEST
    my-screen.init
    HMSL
    my-screen.term
;
.ELSE
: MY-SCREEN.TEST
    my-screen.init
    gr.openhmsl
    draw: my-screen
    BEGIN sc.check.event
    UNTIL
    undraw: my-screen
    gr.closecurw
    my-screen.term
;
.THEN

if.forgotten my-screen.term
." Enter:  MY-SCREEN.TEST   then look in Screens menu! " CR
