\ Host Dependant Pull Down Menu Support
\
\ This was originally based on a control grid which was suppposed
\ to be generic but the hosts were too different.
\ Now this simply contains the host dependant code required
\ to implement pull down menus for each machine.
\
\ Author: Phil Burk
\ Copyright 1986 -  Phil Burk, Larry Polansky, David Rosenboom.
\ All Rights Reserved
\
\ MOD: PLB 12/22/86 Fix CG-MENU-COUNT phantom increment.
\ MOD: PLB 10/18/88 Merge with BUILD_MENUS, eliminate OB.HOST.MENU
\ MOD: PLB 3/26/90 Removed Shape Editor and Perform from Main menu

ANEW TASK-AJF_MENU

defer HMSL.RESET
: MAIN.QUIT  ( -- )
    quit-hmsl on
;

V: IF-MENUS-INIT
EZMENU MAIN-MENU   ( main menu structure )
EZMENU CUSTOM-MENU

: FREE.MENUS ( -- )
    main-menu ezmenu.free
    custom-menu ezmenu.free
;

: BUILD.MAIN.MENU ( -- ok? , Create main Menu )
\ Allocate and link components of menu.
    2  main-menu ezmenu.alloc?
    IF
    	0" HMSL" 0 main-menu  ezmenu.setup
\
\ Give text for items.
    	0" Reset" 0 main-menu ezmenu.text!
    	0" Stop" 1 main-menu ezmenu.text!
\
\ Set CFAs for Items.
    	'c hmsl.reset   0 main-menu ezmenu.cfa[] !
    	'c main.quit    1 main-menu ezmenu.cfa[] !
    	ascii Q 1 main-menu ezmenu.commseq!
    	true
	ELSE
		false ." Could not allocate Menu!" cr
	THEN
;

\ Custom Screen Menu

\ Hold NUL terminated string required for menu.
CREATE CUSTOM-STRINGS 18 max_custom_screens * allot

: CUSTOM.STRING  ( i -- addr )
    18 * custom-strings +
;

: CM.PUT.STRING ( $addr i -- , convert string to 0 terminated )
    >r
    count 16 min tuck r@ custom.string swap cmove  ( place string )
    r> custom.string + 0 swap c!
;

: CM.SETUP  ( -- , set text based on custom screen titles )
    many: custom-screens 0
    DO  i get: custom-screens get.title: []
        i cm.put.string
        i custom.string
        i custom-menu ezmenu.text!
        i get: custom-screens get.key: []
        i custom-menu  ezmenu.commseq!
    LOOP
    max_custom_screens many: custom-screens
    DO 0" ---" i custom-menu ezmenu.text!
       0 i custom-menu  ezmenu.commseq!
    LOOP
;

: CM.EXEC  ( -- , draw custom screen )
    ev-last-code @ itemnum()
    dup many: custom-screens <
    IF  cg-current-screen @ ?dup
        IF undraw: []
        THEN
        get: custom-screens draw: []
    ELSE drop
    THEN
;

: BUILD.CUSTOM.MENU ( -- ok? , Create menu for custom screens )
\ Allocate and link components of menu.
    max_custom_screens  custom-menu ezmenu.alloc?
    IF
    	0" Screens" 1 custom-menu  ezmenu.setup
    	cm.setup
\
\ Set CFAs for Items.
    	max_custom_screens 0
    	DO 'c cm.exec i custom-menu ezmenu.cfa[] !
    	LOOP
    	true
	ELSE
		false ." Could not allocate Menu!" cr
	THEN
;


\ Attach menus to HMSL window using INTUITION call.
: ATTACH.MENUS  ( -- , Attach menus to window )
    if-menus-init @
    IF
    	hmsl-window @  ?dup
    	IF main-menu  setmenustrip()
    	THEN
    THEN
;

: DETACH.MENUS ( -- , Take down menus. )
    hmsl-window @ ?dup
    IF clearmenustrip()
    THEN
;

: MENUS.INIT ( -- , Build all menus )
    if-menus-init @ 0=
    IF  " MENUS.INIT" debug.type
        2 menu-defleft !
        2 menuitem-defleft !
        200 menuitem-defwidth !
        build.main.menu
        IF
        	200 menuitem-defwidth !
        	build.custom.menu
        	IF
        		main-menu custom-menu menu.linkto
        		if-menus-init on
        	ELSE
        		free.menus
        	THEN
        THEN
    THEN
;

: MENUS.TERM
    if-menus-init @
    IF  free.menus
        if-menus-init off
    THEN
;

\ This word must be supported on different hosts.
: PROCESS.MENUS ( -- , execute menu item )
    ev-last-code @ $ FFFF and main-menu ezmenu.exec
;

: SYS.INIT sys.init menus.init ;
: SYS.TERM menus.term sys.term ;

