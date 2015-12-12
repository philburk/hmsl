\ @(#) load_ode.fth 96/06/11 1.1
\ LOAD ODE - Object Development Environment
\
\ Author: Phil Burk
\ Copyright 1986 -  Phil Burk, Larry Polansky, David Rosenboom.
\
\ Start of cascaded initialization and termination.
exists? SYS.INIT not [if] 
    : SYS.INIT ;
    : SYS.TERM ;
    : SYS.RESET ;
[THEN]

exists?  SYS.CLEANUP not [if]
    : SYS.CLEANUP ; \ less severe then SYS.RESET
    : SYS.START ;
    : SYS.STOP ;
    : SYS.TASK ;
[THEN]

exists? SYS.STATUS not [if]
    : SYS.STATUS >newline ;
[THEN]

include? within?            p4thbase.fth
include? toupper            charmacr.fth
include? task-utils.fth         utils.fth

include? task-errormsg.fth      errormsg.fth
include? task-memalloc.fth      memalloc.fth


include? task-global_data.fth   h:global_data.fth

\ MIDI and Time support-------------------------------
if-load-midi @ .IF
    include? task-midi_globals  h:midi_globals
.THEN

\
\ Object Oriented Code -------------------------
include? task-ob_stack.fth    ob_stack.fth
include? task-ob_main.fth     ob_main.fth
include? task-ob_bind.fth     ob_bind.fth
include? task-obmethod.fth    obmethod.fth
mreset-warn off
include? task-ob_ivars.fth    ob_ivars.fth
include? task-dbl_list.fth    dbl_list.fth
include? task-obobject.fth    obobject.fth
include? task-ob_array.fth    ob_array.fth
include? task-elmnts.fth      elmnts.fth
include? task-ob_dlist.fth    ob_dlist.fth

