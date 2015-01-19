\ Host Dependant code for HMSL on Macintosh running H4th
\
\ Copyright 1987 - Phil Burk, Larry Polansky, David Rosenboom
\ All Rights Reserved

ANEW TASK-TOP.FTH

\ Open the HMSL window for graphics I/O

: HMSL.REFRESH ( -- , Refresh display )
    cg-current-screen @ ?dup
    IF draw: []
    THEN
;

: HMSL.OPEN ( -- , open graphics window )
	hmsl-window @ 0=
    IF  gr.openhmsl
\	ELSE ." HMSL Window already open!" cr
	THEN
\	hmsl-window @ SelectWindow()
;

: HMSL.CLOSE ( -- , close graphics window )
	hmsl-window @
    IF	cg-current-screen @ ?dup
		IF undraw: []
		THEN
		gr.closehmsl
	THEN
	menus.undraw
;

: HMSL.1ST.DRAW ( -- , draw initial screen )
\ On Mac, screen will get drawn when update event occurs!!!
\ Before this it used to double draw.
    default-screen @ cg-current-screen !
    hmsl.refresh
;

if.forgotten hmsl.close
