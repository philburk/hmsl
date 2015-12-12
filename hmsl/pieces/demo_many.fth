\ Multinote Interpreter
\ This interpreter considers each element to have several notes
\ and a velocity.  This makes it easy to play chords.
\
\ Author: Phil Burk
\ Based on an idea by Saul Lande
\ Copyright 1989 Phil Burk

ANEW TASK-MANY_NOTES

: INTERP.MANY.ON  { elmnt shape instr | velo -- , play several notes }
\
\ Get velocity from dimension 1, save in local variable.
    elmnt 1 shape ed.at: [] -> velo
\
\ Loop through dimensions 2 on, play any non-zero value as a note.
    shape dimension: []  2  ( start with dim 2, use remaining )
    DO  elmnt i shape ed.at: []  ( -- note ) ?dup
        IF  velo instr note.on: []   ( play it )
        THEN
    LOOP
;

\ Now basically the same thing but this turns them off.
\ This technique has a problem if you edit the shape while playing.
\ You may turn off a different note then the one you turned on,
\ thus leaving notes hanging.
: INTERP.MANY.OFF  { elmnt shape instr | velo -- , play several notes }
    shape dimension: []  2  ( start with dim 2, use remaining )
    DO  elmnt i shape ed.at: []  ( -- note ) ?dup
        IF  0 instr note.OFF: []   ( turn it OFF )
        THEN
    LOOP
;

\ This alternative OFF interpreter will turn off any notes that were
\ turned on, even if the shape has been edited.  It turns off all notes.
: INTERP.MANY.OFF  ( elmnt shape instr -- , play several notes )
    all.off: []
    2drop  ( don't need ELMNT or SHAPE )
;

: BUILD.MANY.SHAPE ( -- , build a shape with many notes/element )
\ You can have as many N notes per element by allocating
\ N+2 dimensions.  Here we allocate 4+2=6 dimensions.
    32 6 new: shape-1
\  dur vel  n1  n2  n3  n4
    10 100  21   0   0   0  add: shape-1
    10 100  23   0   0   0  add: shape-1
    20 100  21  24  28   0  add: shape-1
    10 100  23   0   0   0  add: shape-1
    30 100  17  21  24   0  add: shape-1
;

: DEMO.MANY ( -- )
    build.many.shape
    'c interp.many.on put.on.function: ins-midi-1
    'c interp.many.off put.off.function: ins-midi-1
    shape-1 hmsl.edit.play
    free: shape-1
    default: ins-midi-1
;

cr ." Enter:     DEMO.MANY   to hear chords." cr
