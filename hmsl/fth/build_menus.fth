\ Build menus for HMSL
\
\ Author: Phil Burk
\ Copyright 1986 -  Phil Burk, Larry Polansky, David Rosenboom.
\ All Rights Reserved
\
\ MOD: PLB 2/26/90 Moved CUSTOM-SCREENS object to H:SCREEN.

ANEW TASK-BUILD_MENUS

variable IF-HMSL-MENUS

defer HMSL.RESET

: MAIN.QUIT  ( - )
    quit-hmsl on
;

133 constant HMSL_MENU_ID
134 constant CUSTOM_MENU_ID

variable hmsl-menu-ptr
variable custom-menu-ptr

: MENUS.MAKE.SCR  ( -- , set text based on custom screen titles )
    ." MENUS.MAKE.SCR - unimplemented!" cr
;

: MENUS.MAKE.HMSL  ( -- , create menus on the fly )
    ." MENUS.MAKE.HMSL - unimplemented!" cr
;

: MENUS.DISPOSE ( -- , get rid of them )
    ." MENUS.DISPOSE - unimplemented!" cr
;

: MENUS.DRAW ( -- )
    ." MENUS.DRAW - unimplemented!" cr
;

: MENUS.UNDRAW  ( -- )
    ." MENUS.UNDRAW - unimplemented!" cr
;

: MENUS.INIT ( -- , Build Master Menu)
    " MENUS.INIT" debug.type
\   'c menus.draw is draw.hmsl.menus
\   'c menus.undraw is undraw.hmsl.menus
;

: MENUS.TERM  ( -- )
\   'c noop is draw.hmsl.menus
\   'c noop is undraw.hmsl.menus
;

\ This word must be supported on different hosts.
: PROCESS.MAIN.MENU  ( item -- )
    CASE
       1 OF hmsl.reset   ENDOF
       2 OF main.quit    ENDOF
       notyet
    ENDCASE
;

: PROCESS.CUSTOM.MENU  ( item -- )
    1- 
    dup many: custom-screens <
    IF  cg-current-screen @ ?dup
        IF undraw: []
        THEN
        get: custom-screens draw: []
    ELSE drop
    THEN
;

: PROCESS.MENUS ( -- )
    ." PROCESS.MENUS - unimplemented!" cr
\    ev.get.menuitem  swap hmsl_menu_id =
\   IF process.main.menu
\   ELSE process.custom.menu
\   THEN
;

: SYS.INIT sys.init menus.init ;
: SYS.TERM menus.term sys.term ;
