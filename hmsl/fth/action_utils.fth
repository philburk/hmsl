\ Utilities to support the Action Table
\ Concerned mostly with prioritizing groups of actions.
\
\ Author: Larry Polansky
\ Copyright 1986 -  Phil Burk, Larry Polansky, David Rosenboom.
\
\ MOD: PLB 3/7/87 Add MAYBE
\ MOD: PLB 4/15/87 Added Variable initialization for Mac
\ MOD: PLB 5/20/87 Use ARRAYS for 4 priority levels.

ANEW TASK-ACTION_UTILS

\ used to see if you want to turn an action off after executing...
V: CURRENT-ACTION

\ global counter, used for all actions, updated everytime any action
\ is EXECUTE:d. useful for ACTION synchrony
v: ACTION-GLOBAL-COUNTER

\  variables for keeping track of column length in ACTION-TABLE
4 constant ACTION_#PRIORITIES
action_#priorities array ACTION-COL-LENGTHS

\ variables used by ACTION-TABLE Behaviors, programmer should keep track
\ of these for the 4 priorities when writing a Behavior
action_#priorities array ACTION-COUNTERS

v: PRIORITY-PROB-SUM \ used by stochastic, WEIGHTED Behavior

\ simple names for priorities
0 k: highest    1 k: high
2 k: low        3 k: lowest

\ simple names for priority execution probabilites
\ first cell is the probability for the highest probability
action_#priorities array ACTION-PROBS
\ sums of probabilities for quick weighted choose
action_#priorities array ACTION-PROB-SUMS

\ set probs for stochastic, WEIGHTED action-table behavior
: PUT.PRIORITY.PROBS \ lowest, low, high, highest --- \
    2dup 4 pick 6 pick \  --- lst,l,h,hst,h,hst,l,lst
    + + + \ sum them --- lst,l,h,hst,sum
    dup 65535 <
    IF  priority-prob-sum !
\ segment range of priorities for lookup!!!
        action_#priorities 0
        DO i action-probs !
        LOOP
        0 action_#priorities 0
        DO  i action-probs @ + ( calc sums )
            dup i action-prob-sums !
        LOOP drop
    ELSE drop drop drop drop drop
        " PUT.PRIORITIES"
        " Priorities sum must be less than 65535 !!! "
        er_return er.report
    THEN
;

\ default probabilities are  a simple fibbonacce sequence
: INIT.PRIORITY.PROBS
     5 8 13 21 put.priority.probs
;

: PRINT.PRIORITY.PROBS cr
    ." Priority probabilities are: " cr
    ."    highest " 0 action-probs  @ . cr
    ."    high    " 1 action-probs  @ . cr
    ."    low     " 2 action-probs  @ . cr
    ."    lowest  " 3 action-probs  @ . cr
;

\ default stimuli and response: never/do.nothing  put in
\ action at init time
: NEVER 0 ;
: ALWAYS 1 ;
: MAYBE ( -- flag , usually false )
    17 choose 0=
;
: DO.NOTHING drop ;

\ the following is used to get the current length of
\ columns in the ACTION-TABLE
: GET.COLUMN.LENGTH  \ priority --- address of variable
    action-col-lengths
;
\ get the current counter # in an action-table priority
: GET.PRIORITY.COUNTER  \ priority --- address of variable
    action-counters
;

: INC.PRIORITY.COUNTER  \ priority# - incs it mod column length
     dup dup action-counters @ ( --  # # counter )
     swap action-col-lengths @ ( --  # counter length )
     swap 1+ swap MOD          ( --  # counter+1modlength )
     swap action-counters !
;

: RESET.AGC   (  ---  )
   action-global-counter disable
;

: PUT.AGC     ( agc.value --- )
   action-global-counter !
;

: GET.AGC     ( --- agc.value )
   action-global-counter @
;

: ACTION.UTILS.INIT
    action-global-counter off
    action_#priorities 0
    DO  0 i action-col-lengths !
        0 i action-counters !
    LOOP
    init.priority.probs
;
