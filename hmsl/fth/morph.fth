\ MORPH Class
\ MORPHS are a class of music objects based on abstract morphology
\ and hierarchy.
\
\ A hierarchy of morphs communicate with each other by
\ sending messages up and down the tree.  Some parameters
\ contain a time and a return address.
\ The time is used to maintain synchronization.
\ The METHODS that support this messaging system are:
\    EXECUTE:    ( time raddr -- , perform specific operation)
\    ?EXECUTE:   ( time raddr -- time true | false , true if already done )
\    TERMINATE:  ( time -- , stop execution using time )
\    DONE:       ( time raddr -- , inform parent of completion )
\    ABORT:      ( -- , cleanup self, abort parents. )
\    START:      ( -- , starts a morph executing NOW )
\    STOP:       ( -- , stop a morph and its children )
\    PREFAB:     ( set up a morph to something useable )
\    
\ Aborts are issued to objects in the multi-tasker.  They
\ send abort messages up the hierarchy so all morphs get aborted.
\
\ Author: Phil Burk
\ Copyright 1986 -  Phil Burk, Larry Polansky, David Rosenboom.
\ All Rights Reserved
\
\ MOD: PLB 10/13/86 Changed from OB.IVAR to IV.LONG
\ MOD: PLB 1/??/86 Rewrote EXECUTE: technique.
\ MOD: PLB 3/2/87 Add ABORT: processing.
\ MOD: PLB 3/6/87 Add PRINT.HIERARCHY:
\ MOD: PLB 5/23/87 Add STOP: , changed TASK: to not return done?
\      Changed SET.INVOKER to GET and PUT.INVOKER:
\ MOD: PLB 5/24/87 Added flag=true if executing.
\ MOD: PLB 6/4/87 Add PUT.DATA: DEFAULT:
\ MOD: PLB 7/8/87 Add GET.NAME|NFA:
\ MOD: PLB 10/28/87 Add START:
\ MOD: PLB 5/17/89 Add ?EXECUTE:  to return if_done_flag
\ MOD: PLB 9/26/89 Add PREFAB: and BUILD:
\ MOD: PLB 2/23/90 Put STOP: in ABORT:
\ MOD: PLB 4/5/90 Rewrote STOP code
\ MOD: PLB 7/12/90 Put DEFAULT before FREE in CLEANUP:
\ 00001 11/12/91 Change START: to use RTC.TIME@, Added START.AT:
\ 00002 7/21/92 Added PUT.REPETITION:

ANEW TASK-MORPH

( Methods for morph)
METHOD TASK:
METHOD DONE:
METHOD START:
METHOD START.AT:
METHOD ABORT:
METHOD STOP:
METHOD PUT.INVOKER:
METHOD GET.INVOKER:
METHOD DEFAULT:
METHOD PRINT.HIERARCHY:
METHOD FREE.HIERARCHY:
METHOD DEFAULT.HIERARCHY:
METHOD ?HIERARCHICAL:
METHOD PUT.DATA:
METHOD GET.DATA:
METHOD GET.NAME|NFA:
METHOD ?EXECUTING:
METHOD ?EXECUTE:
METHOD PREFAB:
METHOD BUILD:
METHOD CLEANUP:
METHOD TERMINATE:

\ The following methods moved from OB.Collection 3/30/92

METHOD GET.WEIGHT:       METHOD PUT.WEIGHT:
METHOD GET.REPEAT:       METHOD PUT.REPEAT:
METHOD GET.REPETITION:   METHOD PUT.REPETITION: \ 00002
METHOD CUSTOM.EXEC:
METHOD GET.NEXT.TIME:    METHOD SET.DONE:
METHOD FINISH:

\ Allow delays for each part of play.
METHOD GET.START.DELAY:  METHOD PUT.START.DELAY:
METHOD GET.REPEAT.DELAY: METHOD PUT.REPEAT.DELAY:
METHOD GET.STOP.DELAY:   METHOD PUT.STOP.DELAY:

\ These functions will be passed the address of the object.
METHOD GET.START.FUNCTION:  METHOD PUT.START.FUNCTION:
METHOD GET.REPEAT.FUNCTION: METHOD PUT.REPEAT.FUNCTION:
METHOD GET.STOP.FUNCTION:   METHOD PUT.STOP.FUNCTION:

\ These are to support the Hierarchy Editor
METHOD HIT:
METHOD GET.EXPANDED:
METHOD PUT.EXPANDED:
METHOD DEINSTANTIATE.HIERARCHY:
METHOD EDIT:
METHOD CLASS.NAME:
METHOD GET.HEIGHT:
METHOD GET.WIDTH:
METHOD DUMP.SOURCE:
METHOD DUMP.SOURCE.BODY:
METHOD DUMP.SOURCE.NAME:
\
\ for Units
METHOD EXEC.STACK:  

( DEFINE MORPH CLASS )
:CLASS OB.MORPH <SUPER OB.ELMNTS
\ Internal Active Parameters
    IV.SHORT IV-IF-ACTIVE
    IV.SHORT IV-IF-RECURSE
    IV.LONG  IV-INVOKER    ( execution invoker )
    IV.LONG  IV-MORPH-DATA ( User data )
    IV.LONG IV-TIME-NEXT    ( execution time for next group )
    IV.LONG IV-REPCOUNT   \ Countdown times played.
	iv.long	IV-HED-EXPANDED?
\
\ User Settable Parameters
    IV.LONG IV-WEIGHT     \ Statistical Weight.
    IV.LONG IV-REPEAT     \ How many times to play.
    IV.LONG IV-START-DELAY  ( initial delay for phasing )
    IV.LONG IV-REPEAT-DELAY ( delay between reps )
    IV.LONG IV-STOP-DELAY   ( delay after stop )
    IV.LONG IV-COL-START-CFA
    IV.LONG IV-COL-REPEAT-CFA
    IV.LONG IV-COL-STOP-CFA
    IV.SHORT IV-COL-DONE?   ( true if this rep is done )
    
:M DEFAULT: ( -- , Set to default condition. )
	0 iv=> iv-invoker
	false iv=> iv-if-active
    1 iv=> iv-weight
    1 iv=> iv-repeat
    0 iv=> iv-col-start-cfa
    0 iv=> iv-col-repeat-cfa
    0 iv=> iv-col-stop-cfa
    0 iv=> iv-start-delay
    0 iv=> iv-repeat-delay
    0 iv=> iv-stop-delay
	true iv=> iv-hed-expanded?
;M
    
:M INIT:   ( -- )
     init: super
     self default: [] ( Pick up later default definitions.)
( DEFAULT: should thus never call INIT: )
;M

:M GET.NEXT.TIME:  ( -- time-next-execution )
    iv-time-next
;M

:M PUT.WEIGHT: ( weight -- , store probability weight )
    iv=> iv-weight
;M

:M GET.WEIGHT:  ( weight, fetch probability weight )
    iv-weight 
;M

:M SET.DONE: ( -- , set done flag to terminate job. )
    true iv=> iv-col-done?
;M

:M PUT.START.FUNCTION: ( cfa -- , function to exec at start )
    iv=> iv-col-start-cfa
;M
:M GET.START.FUNCTION: ( -- cfa , function to exec at start )
    iv-col-start-cfa
;M
:M PUT.REPEAT.FUNCTION: ( cfa -- , function to exec at repeat )
    iv=> iv-col-repeat-cfa
;M
:M GET.REPEAT.FUNCTION: ( -- cfa , function to exec at repeat )
    iv-col-repeat-cfa
;M
:M PUT.STOP.FUNCTION: ( cfa -- , function to exec at stop )
    iv=> iv-col-stop-cfa
;M
:M GET.STOP.FUNCTION: ( -- cfa , function to exec at stop )
    iv-col-stop-cfa
;M

:M PUT.START.DELAY: ( delay -- , store delay )
    iv=> iv-start-delay
;M

:M GET.START.DELAY:  ( -- delay , fetch delay )
    iv-start-delay 
;M

:M PUT.REPEAT.DELAY: ( delay -- , store delay )
    iv=> iv-repeat-delay
;M

:M GET.REPEAT.DELAY:  ( -- delay , fetch delay )
    iv-repeat-delay 
;M

:M PUT.STOP.DELAY: ( delay -- , store delay )
    iv=> iv-stop-delay
;M

:M GET.STOP.DELAY:  ( -- delay , fetch delay )
    iv-stop-delay 
;M

:M PUT.REPEAT:  ( count -- , set repeat count)
    dup iv=> iv-repeat
    iv-repcount min iv=> iv-repcount
;M

:M GET.REPEAT:  ( -- count , fetch repeat count)
    iv-repeat
;M

:M GET.REPETITION:  ( -- count , fetch which repetition )
    iv-repeat iv-repcount -
;M

:M PUT.REPETITION:  ( count -- , set which repetition  00004 )
    iv-repeat swap - iv=> iv-repcount
;M

:M FINISH: ( -- , finish this repetition then stop )
    iv-repcount 1 min iv=> iv-repcount
;M
:M ?EXECUTING:  ( -- flag , true if currently executing )
    iv-if-active
;M

: MO.TRACK.DONE ( time raddr -- time raddr , report completion of child )
      if-debug @
      IF 2dup >newline  name: self ."  <-DONE- "  name: []
         ."    , T = " . cr
      THEN
;
: MO.TRACK.EXEC ( time raddr -- time raddr , report execution of child )
    if-debug @
    IF 2dup >newline  ?dup
       IF name: []
       ELSE ." 0 "
       THEN ."  -EXEC-> "  name: self
       ."    , T = " . cr
    THEN
;

:M DONE: ( time raddr -- , handle completion of child )
      mo.track.done 2drop
;M

: SEND.DONE ( time -- , send DONE: message to invoker )
    iv-invoker ?dup  ( check for parent's existence )
    IF 0 iv=> iv-invoker
       self swap done: []   ( notify invoker )
    ELSE drop
    THEN
;

: IF.EXEC|DROP ( n cfa -- , execute or drop )
    ?dup
    IF
    	-1 exec.stack?
    ELSE drop
    THEN
;

: COL.EXEC.START ( -- , execute start function )
	self iv-col-start-cfa if.exec|drop   \ 00001
;

: COL.EXEC.REPEAT ( -- , execute repeat function )
   	self iv-col-repeat-cfa if.exec|drop   \ 00001
;

: COL.EXEC.STOP  ( -- , perform stop function )
    self iv-col-stop-cfa if.exec|drop   \ 00001
;

: MORPH.STOP  ( time -- )
    false iv=> iv-if-active
	0 iv=> iv-repcount
    col.exec.stop
    iv-stop-delay + dup vtime! ( adjust time )
    send.done  ( notify parent, if any )
;

:M TERMINATE: ( time -- )
    iv-if-active
    IF  morph.stop
    THEN
;M

:M STOP:  ( -- )
    time@ self terminate: []
;M

:M ABORT: ( -- , abort self and parent. )
    iv-invoker ?dup  ( check for parent's existence )
    IF 0 iv=> iv-invoker   ( clear for later execution. )
       abort: []   ( abort invoker )
    THEN
    self stop: []
;M

:M PUT.INVOKER: ( invoker -- , set return address for DONE: )
    iv=> iv-invoker
    true iv=> iv-if-active
;M

:M GET.INVOKER: ( invoker -- , get morph who executed )
    iv-invoker
;M

: MORPH.CHECK.STOP  ( time -- , send done if parent and stop )
    iv-if-recurse
    IF  0 iv=> iv-if-recurse
        " MORPH.CHECK.STOP" " Recursion prevented!"
        er_fatal ob.report.error
    THEN
\
    iv-if-active
    IF TRUE iv=> iv-if-recurse
\ This next call could trigger recursion!!!!
       self terminate: []
       if-debug @
       IF " MORPH.CHECK.STOP" " Morph already executing!"
          er_return ob.report.error
       THEN
       FALSE iv=> iv-if-recurse
    ELSE drop
    THEN
;

: COL.DO.REPEAT  ( -- , perform repeat function and decr counter )
    iv-repcount 1- dup iv=> iv-repcount 0>
    IF
    	col.exec.repeat
        iv-repeat-delay iv+> iv-time-next
        false iv=> iv-col-done?
    THEN
;

\ This method is used within hierarchy for controlling execution.
:M ?EXECUTE: ( time invoker -- time true | false )
    mo.track.exec
    over morph.check.stop
    put.invoker: self ( -- time )
    false iv=> iv-col-done?
    iv-repeat 0>
    IF
    	dup vtime!
		col.exec.start
    	iv-start-delay + dup iv=> iv-time-next vtime! ( apply delay )
        iv-repeat iv=> iv-repcount  ( set down-counter )
        self custom.exec: []   ( late bind to specific method )
        dup
        IF
        	col.exec.stop
        	over iv-stop-delay + vtime! ( adjust time )
        	0 iv=> iv-invoker  false iv=> iv-if-active
        THEN
    ELSE true  ( all done )
    THEN
;M

:M EXECUTE: ( time invoker --, exec all morphs in collection )
    self ?execute: []  IF drop THEN
;M

:M START.AT: ( time -- , execute starting then )
    0 ( no parent )
    self execute: []  ( use latest execution method )
;M

:M START: ( -- , execute now )
    rtc.time@ ( 00001 )
    start.at: self
;M

( Task is called repeatedly by multitasker )
:M TASK: ( -- , do single time slice )
;M

:M ?HIERARCHICAL:  ( -- flag , true if can contain other morphs)
    false
;M

CREATE MORPH-INDENT 0 ,

:M PRINT.HIERARCHY: ( -- , print just name , doesn't nest )
    >newline morph-indent @ spaces name: self >newline
;M

:M FREE.HIERARCHY: ( -- , Just free self )
    self ?hierarchical: []
    IF  reset: self
        BEGIN manyleft: self
        WHILE next: self free.hierarchy: []
        REPEAT
    THEN
    self free: []
;M

:M DEFAULT.HIERARCHY: ( -- , Just default self )
    self ?hierarchical: []
    IF  reset: self
        BEGIN manyleft: self
        WHILE next: self default.hierarchy: []
        REPEAT
    THEN
    self default: []
;M

:M CLEANUP:  ( -- , easy cleanup of entire hierarchy )
    self default.hierarchy: []
    self free.hierarchy: []
    self free: []
;M

:M PUT.DATA: ( data -- , Place User data in Morph )
    iv=> iv-morph-data
;M
:M GET.DATA: ( -- data , Get User data from Morph )
    iv-morph-data
;M

\ This is used when the names of several morphs must be stored
\ indirectly.
\ Similar to GET.NAME: but never uses the PAD, ie. NFA->$ .
:M GET.NAME|NFA: ( -- $name | nfa )
    iv-name ?dup 0=
    IF address: self pfa->nfa
    THEN
;M

:M BUILD: ( ? -- )
;M
:M PREFAB: ( -- )
;M


:M PRINT: ( -- , print it )
     print: super
     ." Weight  = " iv-weight . cr
     ." Repeat  = " iv-repeat . cr ?pause
\
     ." Delays:" cr
     ."  Start  = " iv-start-delay . cr
     ."  Repeat = " iv-repeat-delay . cr
     ."  Stop   = " iv-stop-delay . cr ?pause
\
     ." Functions:" cr
     ."  Start  = " iv-col-start-cfa cfa. cr
     ."  Repeat = " iv-col-repeat-cfa cfa. cr
     ."  Stop   = " iv-col-stop-cfa cfa. cr ?pause
;M

\ Support for Morph Hierarchy Editor(s)
14 constant HED_LINE_HEIGHT
10 constant HED_INDENT_BY
variable HED-INDENT  \ current level of indentation
variable HED-YPOS    \ used when drawing or scanning
variable HED-XLEFT   \ left margin

:M PUT.EXPANDED: ( flag -- )
	iv=> iv-hed-expanded?
;M
:M GET.EXPANDED: ( -- flag )
	iv-hed-expanded?
;M

:M DEINSTANTIATE.HIERARCHY:  ( -- , stub for non-hierarchical morphs )
;M

:M CLASS.NAME: ( -- $name )
	" OB.MORPH"
;M

:M GET.HEIGHT: ( -- height , when drawn )
	HED_LINE_HEIGHT
;M

:M GET.WIDTH: ( -- width , when drawn )
	300
;M

0 constant MHED_EXP_X
30 constant MHED_EDIT_X
60 constant MHED_REPEAT_X
100 constant MHED_NAME_X

:M XY.DRAW: { xpos ypos -- }
\ Draw Line
	xpos ypos gr.move
	xpos 200 + ypos gr.draw
	ypos hed_line_height + 2- -> ypos
\
\ Draw Expand gadget depending on state.
	xpos mhed_exp_x + ypos gr.move
	many: self 0>
	self ?hierarchical: [] AND
	IF
		get.expanded: self
		IF
			" [-]"
		ELSE
			" [X]"
		THEN
	ELSE
		" [ ]"
	THEN
	gr.text
\
\ Draw Edit Gadget
	xpos mhed_edit_x + ypos gr.move
	" [E]" gr.text
\
\ Draw Repeat Count
	xpos mhed_repeat_x + ypos gr.move
	" [" gr.text
	get.repeat: self n>text gr.type
	" ]" gr.text
\
\ Draw Name
	xpos mhed_name_x + ypos gr.move
	get.name: self gr.text
\
\ Draw Class
	"   - " gr.text self class.name: [] gr.text
;M

:M EDIT: ( -- )
	." Edit " name: self cr
;M

variable MHED-CUR-MORPH

\ Callback functions for Popup Text Requesters
: MHED.SET.REPEAT ( $text -- )
	number?
	IF
		drop mhed-cur-morph @ put.repeat: []
	ELSE
		." Bad number!" cr \ %Q
	THEN
;

: MHED.SET.NAME ( $text -- )
	mhed-cur-morph @ put.name: []
;

:M HIT: { xoff yoff -- }
\ offsets from top left corner
	xoff mhed_edit_x <
	IF
		get.expanded: self 0= put.expanded: self
	ELSE
		xoff mhed_repeat_x <
		IF
			self edit: []
		ELSE
			xoff mhed_name_x <   \ edit REPEAT
			IF
				ev.getxy
				yoff -
				swap xoff - mhed_repeat_x + swap
				popt.set.xy.dc
\
				get.repeat: self n>text   \ set default text
				pad off pad $append
				pad
				8  'c mhed.set.repeat
				self mhed-cur-morph !
				open.popup.text
			ELSE
				ev.2click?
				IF
					ev.getxy yoff -
					swap xoff - mhed_name_x + swap
					popt.set.xy.dc
\
					self mhed-cur-morph !
					get.name: self
					16  'c mhed.set.name
					open.popup.text
				THEN
			THEN
		THEN
	THEN
;M

\ generate source code to regenerate this object
:M DUMP.SOURCE.NAME: ( -- )
	>newline
	self class.name: [] $type space name: self cr
;M

: DUMP.MORPH.BODY ( -- , dump things common to all morphs )
	>newline
	iv-weight 1 = not
	IF
		tab iv-weight . ."  put.weight: " name: self cr
	THEN
	iv-repeat 1 = not
	IF
		tab iv-repeat . ."  put.repeat: " name: self cr
	THEN
	iv-start-delay 0>
	IF
		tab iv-start-delay . ."  put.start.delay: " name: self cr
	THEN
	iv-repeat-delay 0>
	IF
		tab iv-repeat-delay . ."  put.repeat.delay: " name: self cr
	THEN
	iv-stop-delay 0>
	IF
		tab iv-stop-delay . ."  put.stop.delay: " name: self cr
	THEN
\
\ Functions
	iv-col-start-cfa 0>
	IF
		tab ." 'c " iv-col-start-cfa cfa.
		."  put.start.function: " name: self cr
	THEN
	iv-col-repeat-cfa 0>
	IF
		tab ." 'c " iv-col-repeat-cfa cfa.
		."  put.repeat.function: " name: self cr
	THEN
	iv-col-stop-cfa 0>
	IF
		tab ." 'c " iv-col-stop-cfa cfa.
		."  put.stop.function: " name: self cr
	THEN
;
:M DUMP.SOURCE.BODY: ( -- )
;M

:M DUMP.SOURCE:
	self dump.source.name: []
	self dump.source.body: []
;M

;CLASS

\ Handy for printing names that might be zero.
: OB.NAME ( object -- , print name if non-zero )
    ?dup IF name: []
    ELSE ." 0"
    THEN
;

V: HMSL-ABORT   ( Flag set true for top loop to abort. )

: EXEC.OBJ|CFA  ( cfa|obj -- , execute as object or cfa )
	dup ob.valid?
	IF
	    ." WARNING: EXEC.OBJ|CFA calling EXEC.STACK: []" cr
		EXEC.STACK: []
	ELSE
		EXECUTE
	THEN
;

: SYS.INIT
	sys.init
	'c exec.obj|cfa is deferred.execute
;

: SYS.TERM
	'c execute is deferred.execute
	sys.term
;

