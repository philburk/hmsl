\ Explore the behavior of the Action Table
\
\ This was written by Phil Burk to support his writing of
\ an article for Perspectives of New Music.

\ Author: Phil Burk
\ Copyright 2026

ANEW TASK-TEST_ACTION

METHOD IDENTIFY:

: TACT.INIT ( -- )
    ." --- INIT " current.object identify: [] cr
;
: TACT.TERM ( -- )
    ." --- TERM " current.object identify: [] cr
;

: TACT.STIMULUS ( -- flag )
    maybe
    ." STIM " current.object identify: [] cr
;
: TACT.RESPONSE ( flag -- )
    ." RESP " current.object identify: [] . cr
;

: TACT.FUNCTION ( -- , function for the OB.PRODUCTION )
    ." FUNCTION " current.object identify: [] cr
;

:CLASS ACTION.PRINT   <SUPER OB.ACTION

:M DEFAULT: ( -- )
   default: super
   'c tact.stimulus  iv=> stimulus
   'c tact.response  iv=> response
   'c tact.init iv=> action-init
   'c tact.term iv=> action-term
   1 iv=> iv-repeat ( This was sometimes zero!?)
;M

:M IDENTIFY: ( -- )
    name: self
    space rtc.time@ .
    ." #" get.local-counter: self .
    ."  / " ao-count @ .
;M

;CLASS

ACTION.PRINT TACT1
ACTION.PRINT TACT2
ACTION.PRINT TACT3
ACTION.PRINT TACT4
ACTION.PRINT TACT5
ACTION.PRINT TACT6
ACTION.PRINT TACT7
ACTION.PRINT TACT8

: TACT.SETUP { action -- }
    action put.action: action-table
    4 action new: []
    'c tact.function action add: []
;

: TACT.INIT  ( -- , Initialize Piece )
    tact1 tact.setup
    tact2 tact.setup
    tact3 tact.setup
    tact4 tact.setup
    tact5 tact.setup
    tact6 tact.setup
    tact7 tact.setup
    tact8 tact.setup
;

: TACT.PLAY ( -- )
    midi.clear midi.parser.on
    default-screen @
    action-screen default-screen !
    HMSL  ( no preposted morphs )
    default-screen !
    midi.parser.off
;

: TACT.TERM ( -- , Clean up for others. )
    clear: action-table
;

: TEST.ACTION  ( -- , Demonstrate use of Actions) cr
    tact.init  tact.play  tact.term
;

." Enter:   TEST.ACTION  to play this piece." cr
