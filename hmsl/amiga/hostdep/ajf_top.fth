\ Host dependant initialization and control.
\
\ Author: Phil Burk
\ Copyright 1986 -  Phil Burk, Larry Polansky, David Rosenboom.
\ All Rights Reserved

ANEW TASK-AJF_TOP


\ For repeatedly opening and closing HMSL window.
: HMSL.OPEN  ( -- , Open HMSL window, attach main menu. )
    hmsl-window @  ( do we need a window? )
    IF   detach.menus
         hmsl-window @ >abs callvoid intuition_lib windowtofront
    ELSE gr.openhmsl
    THEN
    cm.setup  ( name custom screens )
    attach.menus
;

: HMSL.CLOSE ( -- , CLose HMSL window. )
    hmsl-window @ ?dup
    IF  cg-current-screen @ ?dup
        IF undraw: []
        THEN
        detach.menus
        gr.set.curwindow
        gr.closecurw
        hmsl-window off
    THEN
;

: HMSL.REFRESH ( -- , Refresh display )
    cg-current-screen @ ?dup
    IF  hmsl-window @
        IF  \ optimize redraw using intuition and layers
          hmsl.set.window
          hmsl-window @ callvoid>abs intuition_lib BeginRefresh
          draw: []
\ Intuition manual wrong, EndRefresh needs COMPLETE flag as 2nd param.
          hmsl-window @ 1 callvoid>abs intuition_lib EndRefresh
        THEN
    THEN
;

: HMSL.1ST.DRAW  ( -- , draw initial screen )
    default-screen @ ?dup
    IF draw: []
    THEN
;

\ Host dependant  ( %Q kludge, use ARP or something to get real filenames )
: HOST.GETFILE  ( -- $filename fileptr | $filename 0 )
    " ram:hmsl.data" dup $fopen
;

: HOST.PUTFILE  ( -- $filename fileptr | $filename 0 )
    " ram:hmsl.data" dup new $fopen
;


