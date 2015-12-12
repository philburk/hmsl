\ Generic stack support.
\
\ Author: Phil Burk
\ Copyright 1989 Phil Burk

ANEW TASK-STACK.FTH
decimal

:STRUCT STACK.HEADER
    long   st_base    ( relative address of base of stack )
    long   st_depth
    long   st_limit
;STRUCT

: STACK.EMPTY? ( stack flag , true if empty )
    ..@ st_depth 1 <
;

: STACK.FULL?  ( stack flag , true if full )
    dup>r ..@ st_depth r> ..@ st_limit >=
;

: STACK.CLEAR ( stack -- )
    0 swap ..! st_depth
;

: STACK.SETUP ( data limit stack -- )
    dup>r ..! st_limit
    0 r@ ..! st_depth
    use->rel r> ..! st_base
;

: STACK.PUSH ( val stack -- )
    dup stack.full?
    IF .hex . ." - Custom stack full!" cr
    ELSE dup>r ..@ st_depth cell*
         r@ ..@ st_base rel->use + !
	 1 r> .. st_depth +!
    THEN
;

: STACK.POP ( stack -- val )
    dup stack.empty?
    IF .hex ." - Custom stack empty!" cr 0
    ELSE dup>r ..@ st_depth 1- dup r@ ..! st_depth
         cell*
         r> ..@ st_base rel->use + @
    THEN
;

: STACK.DROP ( stack -- )
    dup stack.empty?
    IF .hex ." - Custom stack empty!" cr
    ELSE dup>r ..@ st_depth 1- r> ..! st_depth
    THEN
;

: STACK.COPY ( stack -- val , copy from top of stack, like R@ )
    dup stack.empty?
    IF .hex ." - Custom stack empty!" cr 0
    ELSE dup>r ..@ st_depth 1-
         cell*
         r> ..@ st_base rel->use + @
    THEN
;

: STACK.DEPTH ( stack -- depth )
    ..@ st_depth
;

: STACK.DUMP ( stack -- , dump stack )
    dup stack.depth 0
    ?DO dup ..@ st_base rel->use i cell* + @ .
    LOOP drop cr
;

\ Testing
false [IF]
4 constant ST_MAX
CREATE ST-DATA st_max cell* allot
STACK.HEADER ST1
: ST.TEST1
    st-data st_max st1 stack.setup
;

: ST.TEST2
    st.test1
    123 st1 stack.push
    876 st1 stack.push
    st1 stack.dump
    st1 stack.pop dup . 876 - abort" ST.TEST2 failed!"
    st1 stack.pop dup . 123 - abort" ST.TEST2 failed!"
;
[THEN]
