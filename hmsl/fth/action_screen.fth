\ ACTION-TABLE control screen
\ place for 64 actions in four different columns, 16 of each
\ priority

\ Author: Polansky
\ Copyright 1986 -  Phil Burk, Larry Polansky, David Rosenboom.
\
\ MOD: PLB 3/2/87 Check for ACT-NULL in DO.ACTION.
\ MOD: PLB 4/15/87 Need rel->use in table=>grid
\ MOD: PLB 5/20/87 Use 0 for text in table->grid.
\      Remove TIME@ call before AO.POST
\ MOD: PLB 5/24/87 Add TURN.SELF.OFF
\ MOD: PLB 5/28/87 Add prob grids.
\ MOD: PLB 10/28 Remove ACTION-# references.
\ MOD: PLB 11/4/87 Changed DELETE.ACTION: calls to DELETE:
\ MOD: PLB 10/17/88 Convert to new control grid design.
\ MOD: PLB 9/28/89 Change PUT.XYWH: to WH and screen-x,y.
\ MOD: PLB 12/13/89 Got rid of PUT.NUMXY: , add part# to MIN/MAX
\ MOD: PLB Changed 0STUFF.TEXT: to }STUFF.text:

anew task-action_screen

\ =========================================================

ob.check.grid action-grid

\ move action-table to grid

v: do.action-mode

\ utility for clearing a cell on action-grid
: CLEAR.ACTION-GRID.CELL  \ action-# action --- action-# action
    0  2 pick
    put.text: action-grid
;

\ case statement for executing a hit on action-grid
\ CASE value is passed from DO.ACTION
: DO.ACTION.OF \ #, action-add ---
do.action-mode @
CASE
   0 OF act.toggle: [] drop
     ENDOF
   1 OF clear.action-grid.cell
	delete: action-table drop
     ENDOF
   2 OF clear.action-grid.cell dup
	delete: action-table
        dup inc.priority: []
        put.action:  action-table
        drop
     ENDOF
   3 OF clear.action-grid.cell dup delete: action-table
        dup dec.priority: []
        put.action:  action-table
        drop
     ENDOF
   4 OF drop  -4 ashift  \ need priority-#
        clear.priority: action-table
     ENDOF
   5 OF drop drop clear: action-table
     ENDOF
   " DO.ACTION.OF"   " Unsupported choice!" er_return er.report
ENDCASE
;

: ACTION-TABLE=>ACTION-GRID ( -- , fill control grid )
    64 0
    DO  \ first put text in cell
        i get: action-table
        dup act-null =
        IF drop 0
        ELSE get.name|nfa: []   ( use nfa if appropriate )
        THEN
        i put.text: action-grid
\ highlight if action on...
        i get: action-table
        action.on?: []
        i put.value: action-grid
    LOOP
\ cfa in action-grid is always do.action.of!!!
;

\ highest level word which executes in current selected mode...

: DO.ACTION  ( flag action-# -- , perform specific operation on action )
   nip dup         \ some routines need #
   get: action-table    ( -- action-# action )
   dup act-null = not
   IF do.action.of
      do.action-mode @ 0 >
      IF action-table=>action-grid draw: action-grid
      THEN
   ELSE 2drop
   THEN
;

\ builds empty grid
: BUILD.ACTION-GRID
   4 16 new: action-grid
   'c do.action put.down.function: action-grid
   64 0 DO
      0 ( text)  i put.text: action-grid
   LOOP
   500 215 put.wh: action-grid
;

\ ----------------------------------------------------------
OB.RADIO.GRID ACTION-CHOOSER
\ word for executing action-chooser
: ACTION.SET.MODE ( value mode -- )
    do.action-mode !  drop
;

: BUILD.ACTION-CHOOSER ( -- )
   1 6 new: action-chooser
   'c action.set.mode put.down.function: action-chooser
   stuff{ " Toggle"       " Delete"
     " Priority+"    " Priority-"
     " ClrPriority"  " ClrTable"
   }stuff.text: action-chooser
   680  450 put.wh: action-chooser
   " Mode" put.title: action-chooser
;

\ ----------------------------------------------------------
OB.CHECK.GRID PERFORM-CHOOSER
\ Control MIDI Parser from Action Screen

: SET.MIDI.PARSER ( flag -- , turn ON/OFF MIDI-PARSER )
    midi.clear
    midi-parser !
;

\ turn on or off PERFORM, or the posting of the ACTION-TABLE
: TOGGLE.PERFORM ( flag -- )
    IF   action-table ao.post    \  ." posted " cr
    ELSE action-table ao.unpost  \  ." unposted " cr
    THEN
;

: PERFORM.FUNC  ( flag part -- )
    IF set.midi.parser
    ELSE toggle.perform
    THEN
;

: BUILD.PERFORM-CHOOSER
   1 2 new: perform-chooser
   'c perform.func put.down.function: perform-chooser
   stuff{ " PERFORM " " MIDI Parser" }stuff.text: perform-chooser
   " On/Off" put.title: perform-chooser
   725 350 put.wh: perform-chooser
;

\ =======================================
: PUT.PRIORITY-BEHAVIOR ( VALUE INDEX -- )
   IF  'c unweighted.behavior put.behavior: action-table
   ELSE  'c priority.behavior put.behavior: action-table
   THEN drop
;

OB.RADIO.GRID BEHAVIOR-CHOOSER

: BUILD.BEHAVIOR-CHOOSER
   1 2 new: behavior-chooser
   'c put.priority-behavior put.down.function: behavior-chooser
   stuff{ " Weighted"  " Unweighted" }stuff.text: behavior-chooser
   " Behavior" put.title: behavior-chooser
   725 350 put.wh: behavior-chooser
;

\ -----------------------------------------------------------
\ Modify priorities from Count Controls
OB.COUNTER ACTION-PROB-GRID-0
OB.COUNTER ACTION-PROB-GRID-1
OB.COUNTER ACTION-PROB-GRID-2
OB.COUNTER ACTION-PROB-GRID-3

: ACTION.SET.PROB  ( value part -- , Set probabilities )
    2drop
    0 get.value: action-prob-grid-3
    0 get.value: action-prob-grid-2
    0 get.value: action-prob-grid-1
    0 get.value: action-prob-grid-0
    put.priority.probs
;

: BUILD.SINGLE.PROB ( object -- , Build one of four )
    >r
    350 600 r@ put.wh: []
    0 r@ put.title: []
    'c action.set.prob r@ put.down.function: []
    0 0 r@ put.min: []
    99 0 r@ put.max: []
    rdrop
;

: ACTION.SYNC.PROB  ( priority grid -- )
    >r action-probs @
    dup 0 r@ put.value: []
    2* 99 max 0 r> put.max: []
;

: ACTION.SYNC.PROBS ( -- , sync prob display with reality)
    0 action-prob-grid-0 action.sync.prob
    1 action-prob-grid-1 action.sync.prob
    2 action-prob-grid-2 action.sync.prob
    3 action-prob-grid-3 action.sync.prob
;

840 constant ACTION_PROB_SPACING

: BUILD.SET.PROB ( -- , Build four grids )
    action-prob-grid-0 build.single.prob
    " Probs" put.title: action-prob-grid-0
    action-prob-grid-1 build.single.prob
    action-prob-grid-2 build.single.prob
    action-prob-grid-3 build.single.prob
;

\ -----------------------------------------------------------
\ build entire ACTION-SCREEN
OB.SCREEN ACTION-SCREEN

: ACTION.SYNC.PERFORM  ( -- , execute this when screen drawn )
\ Make actions grid show all actions.
    action-table=>action-grid
\ Make sure PERFORM button reflects reality
    action-table indexof: actobj
    IF drop 1   ( %Q control grids use 0/1 )
    ELSE 0
    THEN
    0  put.value: perform-chooser
    midi-parser @ 0= 1+ 1 put.value: perform-chooser
\ Sync behavior chooser.
    get.behavior: action-table
    'c priority.behavior = IF 0 ELSE 1 THEN
    1 swap put.value: behavior-chooser
    action.sync.probs
;

: BUILD.ACTION-SCREEN ( -- , build screen , set X,Ys )
    8 3 new: action-screen
    action-grid 100 300 add: action-screen
    action-chooser 3275 200 add: action-screen
    perform-chooser 2500 200 add: action-screen
    behavior-chooser 2500 1700 add: action-screen
    250 >r
    action-prob-grid-0 2120 r@ add: action-screen
    action-prob-grid-1 2120 r> action_prob_spacing + dup>r
            add: action-screen
    action-prob-grid-2 2120 r> action_prob_spacing + dup>r
            add: action-screen
    action-prob-grid-3 2120 r> action_prob_spacing +
            add: action-screen
    " Action Table" put.title: action-screen
    'c action.sync.perform put.draw.function: action-screen
    ascii A put.key: action-screen
;

\ The following is  used inside
\ a response routine for turning an action-off. It can only be
\ executed from an ACTION which has already set itself to
\ CURRENT-ACTION
: TURN.SELF.OFF  ( -- )
    current-action @ act.off: []
    cg-current-screen @ action-screen =
    IF gr-curwindow @   ( Unhighlight grid cell if drawn. )
       IF  0  current-action @
           indexof: action-table
           IF put.value: action-grid
           ELSE drop
           THEN
       THEN
    THEN
;
