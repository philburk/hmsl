\ Popup Text Entry for changing parameters in hierarchy editor, etc.
\
\ Based on Robert Marsanyi's Unit Editor
\
\ Author: Phil Burk
\ Copyright 1991 Phil Burk
\
\ 00001 PLB 10/1/92 Add screen title to avoid garbage 

anew task-Popup_Text.fth

\ Data structures

ob.screen popt-screen
ob.text.grid popt-text-grid

variable EU-PARENT-SCREEN		( store the parent in here when activated )
variable EU-CUR-UNIT

defer POPT.CALLBACK

\ Functions for controls

: CLOSE.POPUP.TEXT ( -- , exit screen )
	eu-parent-screen @ ?dup
	IF
		cg-current-screen off
		cg-drawing-screen off
		draw: []
		eu-parent-screen off
		eu-cur-unit off
\ This should not be needed!  Something is
\ turning on tracking but I can't figure out what!!!  %Q
EV.TRACK.OFF
	THEN
;

: POPT.CR.FUNC ( $text part -- )
	drop
	popt.callback  \ pass string back
	close.popup.text
;

1000 value POPT_XPOS
1000 value POPT_YPOS
700 value POPT_WIDTH
300 value POPT_HEIGHT

: POPT.SET.XY.DC ( xpos ypos -- )
	-> popt_ypos
	-> popt_xpos
;

: OPEN.POPUP.TEXT { $deftext maxchars callbackcfa -- }
	$deftext 1+ maxchars gr.textlen 8 + 0
	scg.delta.dc->wc drop -> popt_width
	popt_xpos popt_ypos put.xy.dc: popt-screen
	popt_width popt_height put.wh: popt-text-grid
	callbackcfa is popt.callback
	1 1 maxchars new: popt-text-grid
	$deftext 0 put.text: popt-text-grid
\
	cg-current-screen @ eu-parent-screen !
	cg-drawing-screen on			( so it doesn't clear )
	cg-current-screen off
	draw: popt-screen
	cg-drawing-screen off
	popt-screen cg-current-screen !
;

\ Build grids, screen

: BUILD.POPUP.TEXT
	1 1 20 new: popt-text-grid
	765 350 put.wh: popt-text-grid
	20 30 put.xy: popt-text-grid
	'c popt.cr.func put.cr.function: popt-text-grid
;

: BUILD.POPT.SCREEN
	10 3 new: popt-screen  \ make room for custom editing 00001
	popt-text-grid	10 10 add: popt-screen
	" Enter Text" put.title: popt-screen
;

\ Init and Term

: INIT.POPUP.TEXT
	build.popup.text
	build.popt.screen
;

: TERM.POPUP.TEXT
	freeall: popt-screen
	free: popt-screen
;

: SYS.INIT	sys.init init.popup.text ;
: SYS.TERM	term.popup.text sys.term ;

false [IF]

ob.screen test
ob.menu.grid doit

: SHOW.TEXT ( $text -- )
	." Text = " $type cr
;

: DOIT.FUNC	( value part -- )
	2drop
	" Hello" 20 'c show.text open.popup.text
;

: BUILD.TEST
	1 1 new: doit
	300 300 put.wh: doit
	'c doit.func put.up.function: doit
	
	10 3 new: test
	doit 200 500 add: test
	test default-screen !
;

: init.test
	init.popup.text
	build.test
;

: term.test
	term.popup.text
	freeall: test
	free: test
	gr.closecurw
;
if.forgotten term.test

: TPT
	init.test
	gr.closecurw
	gr.openhmsl
	test sc.test
	gr.closecurw
;
[THEN]
