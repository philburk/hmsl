\ Some generic interpreters for processing shapes.
\
\ All interpreters must have the following stack diagram:
\     ( elment_number shape instrument -- )
\
\ Author: Phil Burk
\ Copyright 1986 -  Phil Burk, Larry Polansky, David Rosenboom.
\
\ MOD: PLB 3/26/90 Moved in INTERP.EL.ON
\ MOD: PLB 10/24/91 Take advantage of new binding to locals.

ANEW TASK-INTERPRETERS

: STANDARD.DIM.NAMES ( shape -- , name dimensions )
    >r ( save on return stack )
    " Duration" 0 r@ put.dim.name: []
    " Note" 1 r@ put.dim.name: []
    " Loudness" 2 r@ put.dim.name: []
    rdrop
;

: INTERP.EXTRACT.PV { elmnt# shape -- pitch velocity }
    elmnt# 1 ed.at: shape ( get pitch )
    dimension: shape  2 >  ( is there a dimension 2 )
    IF ( -- pitch )
        elmnt# 2 ed.at: shape  ( get velocity )
    ELSE 64  ( default MIDI velocity )
    THEN
;

\ Simple interpreter --------------------------------
: INTERP.EL.ON ( elmnt# shape instr -- , play as note )
    >r interp.extract.pv
    over 0=   ( is this a rest? )
    IF rdrop 2drop
    ELSE r> note.on: []
    THEN
;

\ This OFF interpreter can leave notes hanging if the
\ shape changes between NOTE.ON: and NOTE.OFF:
: INTERP.EL.OFF ( elmnt# shape instr -- )
    >r interp.extract.pv
    over 0=   ( is this a rest? )
    IF rdrop 2drop
    ELSE r> note.off: []
    THEN
;

\ This OFF interpreter works best for random notes on
\ or when a shape is changing frequently.
: INTERP.LAST.OFF ( elmnt# shape instr -- , off last note played)
    >r interp.extract.pv
    drop 0=   ( Was it a rest? )
    IF rdrop
    ELSE r> LAST.NOTE.OFF: []
    THEN
;

: INTERP.FIRST.OFF ( elmnt# shape instr -- )
    >r interp.extract.pv
    drop 0=   ( Was it a rest? )
    IF rdrop
    ELSE r> FIRST.NOTE.OFF: []
    THEN
;

: USE.STANDARD.INTERP ( instrument -- )
    'c interp.el.on over put.on.function: []
    'c interp.first.off swap put.off.function: []
;

\ This interpreter uses NOTE.ON.FOR: which
\ allows the playing of polyphonic shapes.
\ It uses ON.TIME which is set by player.
\ Dim 0 = ?
\ Dim 1 = note-index
\ Dim 2 = velocity

: INTERP.EL.ON.FOR { elmnt# shape instr -- , on for time }
    elmnt# shape interp.extract.pv
    over 0=   ( is this a rest? )
    IF 2drop
    ELSE ( -- note vel )
        on.time  ( from player )
        note.on.for: instr
    THEN
;

'c interp.el.on.for is default.on.interp
'c 3drop is default.off.interp

: USE.POLY.INTERP  ( instrument -- )
    'c interp.el.on.for over put.on.function: []
    'c 3drop swap put.off.function: []
;

\ Support word for next interpreter.
: 2P.STOP.MORPH  ( morph data -- )
    drop stop: []
;

\ Turn on and off Morphs listed in a shape.
\ Dim 0 = time
\ Dim 1 = morph
\ Dim 2 = #repeats if positive  , ignored if <= 0
\ also #ticks if on.time positive    , ignored if <= 0

: INTERP.PLAY.MORPH  { elmnt# shape instr | morph -- , play morph }
\ Get morph from dimension 1
    elmnt# 1 ed.at: shape -> morph
\
\ Set repeat count if > 0
    elmnt# 2 ed.at: shape dup 0>  ( is #repeats pos. )
    IF put.repeat: morph
    ELSE drop
    THEN
    start: morph
\
\ Check to see if time is limited.
    on.time dup 0>
    IF  vtime@ +  ( calc time to stop )
\ schedule STOP: event
        morph 0   'c 2p.stop.morph   post.event
    ELSE drop
    THEN
;

: PRINT.MORPH.SHAPE  { shape -- }
    >newline
    ."   Time  Morph   Repeats  On.Time" cr
    shape many: [] 0
    ?DO i 0 shape ed.at: [] 6 .r 2 spaces
       i 1 shape ed.at: [] name: [] 2 spaces
       i 2 shape ed.at: [] 6 .r 2 spaces
       shape dimension: [] 3 >
       IF i 3 shape ed.at: [] 6 .r
       THEN cr
    LOOP
;
       
\ Execute functions and data in shape.
\ The shape must have as many data dimensions
\ as the functions will eat.
\ Dim 0 = time
\ Dim 1 = data_1
\ Dim 2 = data_2
\ Dim n = data_n
\ Dim n+1 = CFA
\
\ The function must have the following stack diagram.
\      ( data_1 ... data_n -- )
\
: INTERP.EXECUTE  ( elmnt# shape instr -- , exec func )
    drop get: [] execute drop
;

: PRINT.EXEC.SHAPE  { shape -- , print one of these shapes }
    >newline
    shape many: [] 0
    ?DO shape dimension: [] 1- 0
       ?DO j i shape ed.at: [] 6 .r 2 spaces
       LOOP
       i shape dimension: [] 1- shape ed.at: [] cfa. cr
    LOOP
;

