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
include? task-utils utils.fth

include? task-errormsg errormsg.fth
include? task-memalloc memalloc.fth


include? task-global_data h:global_data.fth

\ MIDI and Time support-------------------------------
if-load-midi @ .IF
    include? task-midi_globals h:midi_globals
.THEN

\
\ Object Oriented Code -------------------------
include? task-ob_stack ob_stack.fth
include? task-ob_main ob_main.fth
include? task-ob_bind ob_bind.fth
include? task-obmethod obmethod.fth
mreset-warn off
include? task-ob_ivars ob_ivars.fth
include? task-dbl_list dbl_list.fth
include? task-obobject obobject.fth
include? task-ob_array ob_array.fth
include? task-elmnts elmnts.fth
include? task-ob_dlist ob_dlist.fth

