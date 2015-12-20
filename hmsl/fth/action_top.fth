\ Top control file for PERFORM (ACTION-TABLE, etc.)
\
\ Author: Larry Polansky
\ Copyright 1986 -  Phil Burk, Larry Polansky, David Rosenboom.
\
\ MOD: PLB 3/6/87 Remove PUT.VALUE: from ACTION.RESET
\          Added ACTION.DRAW.SCREEN
\ MOD: PLB 4/15/87 Use ACTION.UTILS.INIT
\ MOD: PLB 5/20/87 Init DO.ACTION-MODE
\      Combine ACTION_INIT and ACTION_TERM files.
\      Move NEW:s to BUILD.xx words.
\ MOD: PLB 10/28/87 ACTION.RESET now clears ACTION-TABLE.
\ MOD: PLB 3/26/90 Made optional module w/ USER.INIT

ANEW TASK-ACTION_TOP

\ after actions, action-table, and action-screen are set up
\ grids : Action-grid; Action-chooser; Perform-chooser; Behavior-chooser

: ACTION.RESET ( -- )
    'c priority.behavior put.behavior: action-table
    clear: action-table
;

: ACTION.INIT ( -- )
    0 scg.selnt     ( force proper transformation )
    build.action-table
    build.action-chooser
    build.perform-chooser
    build.action-grid
    build.behavior-chooser
    build.set.prob
    build.action-screen
    action.reset
    action.utils.init
    init.stock.actions
    0 do.action-mode !
;

: ACTION.TERM ( -- )
    freeall: action-screen
    free: action-screen
;

: USER.INIT user.init action.init ;
: USER.RESET user.reset action.reset ;
: USER.TERM action.term user.term ;
