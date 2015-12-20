\ Action  definition
\
\ ACTIONS are the basic units of the HMSL PERFORM environment, and
\ are arbitarily definable stimulus-response events with a great
\ deal of on-board intelligence
\
\ ACTIONS are defined as PARALLEL COLLECTIONS  with one executable
\ cell -- consisting of a STIMULUS and a RESPONSE.
\ Instance variables are used for the INIT, TERM, STIMULUS
\ and the  RESPONSE. The stimulus must leave a
\ Boolean on the stack, and the response must "eat" that boolean
\ in deciding whether to perform or not.
\ INIT and TERM are executed whenever an ACTION is turned on or off
\
\ ACTIONS have instance variables for:  ACTION-ON?,
\ ACTION-PRIORITY, STIMULUS, RESPONSE, RESPONSE-ARG, STIMULUS-ARG
\ LOCAL-COUNTER
\
\ The ACTION-TABLE contains 64 possible actions, 16 for each of the
\ priorities 0-3.
\
\ PRIORITIES set at 0 for a default. Note that PRIORITIES
\ are simply renamed collection weights.
\
\ Author: Larry Polansky
\ Copyright 1986 -  Phil Burk, Larry Polansky, David Rosenboom.
\
\ MOD: PLB 2/28/87 Changed superclass to OB.PRODUCTION
\ MOD: PLB 3/5/87  Put repeat in action EXECUTE: method.
\ MOD: PLB 5/24/87 Make turn.self.off turn off grid.
\      Remove SET.CURRENT-ACTION: method , set CURRENT-ACTION
\      for ACT.ON: and ACT.OFF:
\ MOD: PLB 6/10/87 Add DEFAULT: , set repeat to 1
\ MOD: PLB 10/29/87 Remove ACTION-# references.
\ MOD: PLB 4/11/90 Remove definition of CFA.
\ MOD: PLB 2/4/91 Add TERMINATE: to call TERM word.
\		Change EXECUTE to call CUSTOM.EXEC:
\ MOD: PLB 6/15/91 Increment ACTION-GLOBAL-COUNTER in TASK:
\
\ ===========================================================

ANEW TASK-OB_ACTIONS

( Used for distributing actions and in unweighted behavior)
V: ACTION-NEXT-PRIORITY
: ACTION.NEXT.PRIORITY  ( -- priority )
    action-next-priority @
    1+ 3 and
    dup action-next-priority !
;

\ "system" variables used for ACTIONs include:
\  how many actions, global counter (agc)

\ action methods
method put.priority:         method get.priority:
method get.stimulus:         method get.response:
method act.on:               method act.off:
method put.local-counter:    method get.local-counter:
method reset.local-counter:  method act.toggle:
method inc.priority:         method dec.priority:
method get.response-arg:     method put.response-arg:
method put.stimulus-arg:     method get.stimulus-arg:
method put.stimulus:         method put.response:
method get.init:             method get.term:
method put.init:             method put.term:
method action.on?:
method set.current-action:

:CLASS OB.ACTION   <SUPER OB.PRODUCTION
   iv.long  ACTION-ON?
   iv.long  STIMULUS
   iv.long  RESPONSE
   iv.short LOCAL-COUNTER
   iv.long  RESPONSE-ARG
   iv.long  STIMULUS-ARG
   iv.long  ACTION-INIT
   iv.long  ACTION-TERM

\ actions use inherited collection weights as priorities
:m PUT.PRIORITY: ( n {0-3} -- puts priority to action )
    dup 3 >
   IF cr ." !!! BAD PRIORITY -- should be from 0-3 " drop
   ELSE put.weight: super
   THEN
;m

:m INIT:
   init: super ( does default )
   action.next.priority put.priority: self \ distribute evenly
;M

:M DEFAULT: ( -- )
   default: super
   0 iv=> local-counter
   0 iv=> action-on?   \ off
   'c never  iv=> stimulus
   'c do.nothing  iv=> response
   'c noop iv=> action-init
   'c noop iv=> action-term
   1 iv=> iv-repeat ( This was sometimes zero!?)
;M

:m GET.PRIORITY: ( --- ,returns priority {0-3} )
   get.weight: super
;m


:m GET.RESPONSE-ARG: ( --- n )
   response-arg
;m

:m PUT.RESPONSE-ARG: ( n --- )
   iv=> response-arg
;m

:m GET.STIMULUS-ARG: ( --- n)
   stimulus-arg
;m

:m PUT.STIMULUS-ARG: ( n --- )
  iv=>  stimulus-arg
;m

\ Syntax for following words, all of which use CFA's
\ in ACTION instance variables :
\ 'c FOO put.(init,term,stimulus,response): name-of-action
\ FOO must be an executable FORTH routine. If Stimulus, it must
\ leave a value (flag) on the stack. If a Response, it must
\ eat that value. INIT and TERM are routines that turn things
\ on or off, or set and reset, etc.
\ The "get:" methods, return executable routines (CFA's), and
\  are used in EXECUTE:

:m PUT.STIMULUS: ( CFA --- ,stick forth word into stimulus field )
   iv=> stimulus
;m

:m PUT.RESPONSE: ( CFA --- ,stick forth word into response field )
   iv=>  response
;m

:m GET.RESPONSE:  ( --- CFA )
   response  ( returns executable routine )
;m

:m GET.STIMULUS: ( --- CFA )
   stimulus  ( returns executable routine )
;m

:m GET.INIT: ( --- CFA )
    action-init
;m

:m GET.TERM: ( --- CFA )
   action-term
;m

:m PUT.INIT: ( CFA --- )
     iv=> action-init
;m

:m PUT.TERM: ( CFA --- )
    iv=> action-term
;m

:m ACT.ON: ( --- , turns action on and executes INIT  )
    1 iv=> action-on?
    self current-action !
    get.init: self execute
;m

:m ACT.OFF: ( --- , turns action off and executes TERM )
    0 iv=> action-on?
    self current-action !
    get.term: self execute
;m

:M TERMINATE: ( time -- )
	." Terminate: ACTION = " name: self cr
	terminate: super
	act.off: self
;M

:m ACTION.ON?:  ( --- 1 or 0, indicating whether action is on or off )
   action-on?
;m

:m ACT.TOGGLE:
( --- , toggles action on or off, used by ACTION-SCREEN )
   action-on?
   IF act.off: self
   ELSE act.on: self
   THEN
;m

\ n.b.: highest priority is 0 !!!
:m DEC.PRIORITY:  ( --- , decrements priority, clips at 3  )
   get.priority: self 1+ 3 min  put.priority: self
;m

:m INC.PRIORITY: (  --- ,increments priority, clips to 0 )
   get.priority: self 1- 0 max  put.priority: self
;m

:m PRINT:
    print: super-dooper
    ." Priority = " get.priority: self . cr
    ." Stimulus = " get.stimulus: self cfa. cr
    ." Response = " get.response: self cfa. cr
    ." init  = " get.init: self cfa. cr
    ." term  = " get.term: self cfa. cr
    action.on?: self
    IF  ." Action on ! " cr
    THEN
;m

:m RESET.LOCAL-COUNTER: ( --- , sets alc to 0 )
    0 iv=> local-counter
;m

:m GET.LOCAL-COUNTER: ( --- alc )
    local-counter
;m

:m PUT.LOCAL-COUNTER: ( alc-value --- )
    iv=> local-counter
;m

\ ==========================================

\ redefined execute: which increments local counter, stores ACTION in
\ current-action, and executes stimulus and then response.
\ note that EXECUTE: for actions does not follow the HMSL protocol
\ specifically, in that there is no time or sender address, since
\ none is needed. We have continued to call it EXECUTE: to identify
\ it functionally with other morphs. This works ONLY because actions
\ are executed only from action-table, and cannot be executed from
\ other morphs
\ CHANGED TO TASK: to avoid conflicts with HMSL

:m TASK: ( -- , only called from ACTION-TABLE )
\ stores address of action for turn.self.off routine...
     self current-action !
     action-on?   \ only execute: if ACTION is on
     IF  local-counter 1+ iv=> local-counter
		1 action-global-counter +!
         iv-repeat 0
         DO  stimulus execute
             response execute
         LOOP
\ execute fuctions like a Production would.
\ time@ 0 execute: super \ this is obsolete because
		time@ vtime!
		custom.exec: super 2drop
     THEN
;m


;CLASS

