\ This is the top level file for HMSL the
\ Hierarchical Music Specification Language
\
\ The required initialization and termination can be performed
\ from this file.
\
\ Author: Phil Burk
\ Copyright 1986 - Phil Burk, Larry Polansky, David Rosenboom
\
\ MOD: 8/16/86 Added main menu and menu picking.
\ MOD: 10/14/86 Changed 'COLDEXEC to COLDEXEC
\ MOD: 10/21/86 Removed MM.INIT and OPEN.LIBRARIES, add TRAPS
\ MOD: PLB 11/8/86 Added Copyright display.
\ MOD: PLB 12/4/86 Mods for MAC
\ MOD: PLB 12/9/86 Set more Mac variables.
\ MOD: PLB 12/15/86 Add screen refresh code.
\ MOD: PLB 1/14/87 Change HMSL.PLAY to use execute.
\ MOD: PLB 2/25/87 Removed init for streams and compose.
\ MOD: PLB 3/2/87 Add ABORT: processing.
\ MOD: PLB 3/6/87 Draw shape_editor after opening HMSL window.
\ MOD: PLB 3/10/87 Added CLEAR: ACTOBJ to HMSL.PLAY
\                  Added HMSL.PLAY.MANY which doesn't.
\ MOD: PLB 4/15/87 Switch screens by keystroke.
\ MOD: PLB 4/21/87 Print Message for Mach2
\ MOD: PLB 5/24/87 Removed double draw in HMSL.STARTUP
\      Use SYS.INIT and SYS.TERM
\ MOD: PLB 6/15/87 Force SE.STARTUP to avoid empty shape error.
\ MOD: PLB 7/6/87 Remove Definitions of HMSL.OPEN and CLOSE
\      Add LOAD.SEGMENTS and GR.INIT call.
\ MOD: PLB 7/8/87 MOved code out to MMAC_TOP
\ MOD: PLB 8/13/87 Add HMSL_VERSION#
\ MOD: PLB 10/28/87 Remove SYS.RESET from HMSL.CLEANUP
\          Moved code to ACTOBJ and called it AO.RESET
\ MOD: PLB 11/16/87 Version 3.14
\ MOD: PLB 1/29/88 version 3.15
\ MOD: PLB 4/26/88 version 3.16
\ MOD: PLB 11/15/88 version 3.18 - Fixed Instruments
\ MOD: PLB 1/13/89 version 3.19 - for JForth 2.0, double MIDI
\          variable RTC, HGO
\ MOD: PLB 5/27/89 V3.20 Beta
\ MOD: PLB 5/27/89 V3.21 Beta
\ MOD: PLB 10/29/89 Allowed for no SE-SCREEN, use DEFAULT-SCREEN,
\          FIND and execute SYS.INIT
\ MOD: PLB 11/27/89 Version 3.40
\ MOD: PLB 2/9/90 Version 3.42, disable SAVE_FORTH after HMSL.INIT
\ MOD: PLB 2/23/90 Version 3.43, don't sc.init, set version title
\ MOD: PLB 3/15/90 V3.44, reorganize open/close
\ MOD: PLB 4/13/90 Add Multiple Event Wait for Amiga
\ MOD: PLB 4/23/90 Add flashing cursor to <HMSL.KEY>
\ MOD: PLB 6/11/90 Sped up <HMSL.KEY> on Amiga, RESET.KEY in HMSL.TERM
\ MOD: PLB 8/8/91 Remove redef of BYE, use AUTO.TERM
\ 00001 PLB 9/27/91 Add EV_KEY events
\ 00002 PLB 10/7/91 Moved Version setting to seperate file.
\ 00003 PLB 10/22/91 Fixed handling of MIDI Parser for Amiga
\ 00004 PLB 2/18/92 Use SYS.START, SYS.STOP and SYS.TASK

ANEW TASK-HMSL_TOP

\ : EV.FLUSH ;

CREATE HMSL-IF-INIT 0 ,
CREATE HMSL-GRAPHICS if-load-graphics @ ,  ( allow graphics )

: HMSL_COPYRIGHT
" Copyright 1986,87,88,89,90 - Phil Burk, Larry Polansky, David Rosenboom"
;

: VERSION. ( N -- , print int as d.dd )
    s->d <# # # ascii . hold #S #>  type
;

: HMSL_TITLE
    " HMSL - Hierarchical Music Specification Language"
;

: HMSL.COPYRIGHT  ( -- , Show copyright and message.)
 cr
 hmsl_title $. ."  V" hmsl_version# version. cr
 cr
 ." HMSL is intended for a community of experimental composers who" cr
 ." are contributing to the development of this language. We would" cr
 ." appreciate any suggestions or comments that you have. If you make" cr
 ." modifications to HMSL that you would like to see incorporated into" cr
 ." the language, please send them to us.  You are allowed to make" cr
 ." copies of HMSL for personal backups, but not for any other reason." cr
 ." We would like to be the sole distributor of this, and future" cr
 ." versions of HMSL.    Thank you." cr
 cr
 hmsl_copyright $. cr
 ." All Rights Reserved." cr
;

\ Host INDependant Initialization ------------------------
\
\ In a turnkeyed system FIND won't work.
\ You must call USER.INIT and USER.TERM yourself.
: USER.INIT ." End USER.INIT" cr ;  ( stubs to end chains )
: USER.TERM ." End USER.TERM" cr ;
: USER.RESET ." End USER.RESET" cr ;

: EXEC.USER.INIT ( -- )
\ Use FIND to find USER.INIT chain.
    " USER.INIT" find
    IF >newline ." Begin USER.INIT" cr execute
    ELSE drop
    THEN   \ global system initialization.
;

: EXEC.USER.TERM ( -- )
\ Use FIND to find USER.TERM chain.
    " USER.TERM" find
    IF ." Begin USER.TERM" cr execute
    ELSE drop
    THEN
;

: EXEC.USER.RESET ( -- )
\ Use FIND to find USER.RESET chain.
    " USER.RESET" find
    IF ." Begin USER.RESET" cr execute
    ELSE drop
    THEN
;

: (HMSL.RESET)  ( -- , deferred for menu )
    sys.reset
    exec.user.reset
    hmsl-window @
    IF default-screen @ ?dup
       IF draw: []
       THEN
    THEN
;
'c (hmsl.reset) is hmsl.reset

variable NO-SAVE-FORTH

: SAVE-FORTH  ( <name> -- , disable after HMSL.INIT )
    ( -- , on Macintosh )
    no-save-forth @
    IF  ." SAVE-FORTH not allowed after HMSL.INIT" cr
    ELSE save-forth
    THEN
;

: HMSL.INIT  ( -- , Initialize the system. )
    hmsl-if-init @ NOT
    IF 	cr
        no-save-forth on
\
        ob.init    \ set object stack, critical before any object use!!!
        'c (hmsl.title) is hmsl.title
        sys.init   \ global system initialization
\
\ Initialize user loaded code above HMSL.INIT, screens, etc.
        exec.user.init
        true hmsl-if-init !
        if-debug off
        cr ." HMSL Initialized and Ready!" cr
    THEN
;

: HMSL.TERM ( -- , Terminate the system. )
    hmsl-if-init @
    IF
\       reset.emit
\       reset.key
       exec.user.term
       hmsl.close \ close window
       sys.term   \ global system termination.
       cr ." HMSL Terminated" cr
       false hmsl-if-init !
    THEN
;

\ -------------------
: QUIT.HMSL ( -- )
	quit-hmsl on
;

defer CLOSEBOX.HIT
'c quit.hmsl is closebox.hit

: HMSL.HANDLE.EVENT ( event -- , Process one event from event queue. )
    CASE
         EV_NULL OF ENDOF

         EV_MOUSE_DOWN OF cg-current-screen @ ?dup
                 IF gr.getxy rot mouse.down: [] drop THEN
             ENDOF

         EV_MOUSE_UP OF cg-current-screen @ ?dup 
                 IF gr.getxy rot mouse.up: [] THEN
             ENDOF

         EV_MOUSE_MOVE OF  cg-current-screen @ ?dup 
                 IF gr.getxy rot mouse.move: [] THEN
             ENDOF

         EV_REFRESH OF
                hmsl.refresh
         ENDOF

         EV_KEY OF ev.get.key ?dup \ 00001
                 IF cg-current-screen @ ?dup
                 	IF key: []
                 	ELSE drop
                 	THEN
                 THEN
             ENDOF
             
         EV_MENU_PICK OF
                process.menus
         ENDOF

         EV_CLOSE_WINDOW OF closebox.hit
             ENDOF
    ENDCASE
;

: HMSL.CHECK.EVENTS  ( -- )
    BEGIN ev.get.event ( get one event ) dup
    WHILE hmsl.handle.event
    REPEAT drop
;

: HMSL.ABORT ( -- , word to call if ABORT called )
\    reset.abort  ( reset vector to prevent recursion )
\    reset.emit
\    reset.key
    hmsl.close
    sys.cleanup
    abort    ( perform appropriate system ABORT )
;

: HMSL.STOP  ( -- , put back KEY and EMIT vector )
\    reset.emit
\    reset.key
    sys.stop
    hmsl.close
;

: HMSL.STARTUP ( -- )
    sys.start
    hmsl-graphics @
    IF  hmsl.open
    	hmsl.1st.draw
        ev.flush     ( flush old events )
        ev.track.off
    THEN
    servicing-tasks off
;

CREATE KEY-PARSER 0 ,

: HMSL.KEYS  ( -- , Handle keystrokes )
    ?terminal/8
    IF  key TOUPPER
        CASE
        ascii Q OF true quit-hmsl ! ENDOF
            key-parser @ ?dup
            IF over swap execute
            ELSE ." Hit Q to quit." cr
            THEN
        ENDCASE
    THEN
;

\ ----------------- MAIN LOOP --------------------

create HMSL-IN-SCAN 0 ,

: (HMSL.SCAN)  ( -- , low level scan )
    sys.task
    midi-parser @ IF midi.parse.many THEN
    sys.task
    hmsl-graphics @
    IF  hmsl.check.events  ( -- flag , process user input )
    THEN
;

: HMSL.SCAN  ( -- done? , perform one scan of the HMSL cycle )
\    'c hmsl.abort set.abort
    stack.mark
    (hmsl.scan)
    stack.check  ( make sure just flag is returned )
\    reset.abort
    quit-hmsl @
;

: HMSL.SAFE.SCAN  ( -- done? , scan that will not allow recursion )
    hmsl-in-scan @ 0=
    IF hmsl-in-scan on
       hmsl.scan
       hmsl-in-scan off
    ELSE false
    THEN
;

\ ----------------------------------------------
: HMSL    ( -- , DO HMSL )
    false quit-hmsl !    ( set flag for QUIT on main menu )
    hmsl.startup
    BEGIN
      hmsl.keys
      hmsl.scan
    UNTIL
    hmsl.stop
;

exists? ob.morph [IF]
: HMSL.DELAY.EXEC  ( morph -- )
    time@ rtc.rate@ +  ( postdate 1 second for clean startup )
    0 rot execute: []
;

: HMSL.PLAY.MANY   ( morph -- , execute/play a morph )
    depth 0= abort" HMSL.PLAY requires a morph!"
    hmsl.delay.exec
    hmsl
;

: HMSL.PLAY ( morph -- , execute/play one morph )
    clear: actobj    ( prevent crashes from full list. )
    hmsl.play.many
;

: HMSL.EXEC ( morph -- , quit when morph is done )
    hmsl.delay.exec
    false quit-hmsl !    ( set flag for QUIT on main menu )
    hmsl.startup
    BEGIN
      hmsl.keys
      hmsl.scan
      many: actobj 0= or
    UNTIL
    hmsl.stop
;

[THEN]

if.forgotten hmsl.term

: AUTO.TERM  hmsl.term auto.term
;
