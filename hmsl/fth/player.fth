\ This Morph plays the Shapes it contains.
\ It keeps track of time and calls an Instrument to make the
\ sound occur.
\
\ The Duration of an event is defined as the time until
\ the next event occurs.
\ The duration of an event is determined as follows:
\   1) If the DUR.FUNCTION is nonzero, the function will
\      calculate a duration.
\   2) If the dur-dim is >= 0 , the duration will be read from
\      the dimension.
\   3) Otherwise the duration will come from the duration set by
\      PUT.DURATION:
\
\ The ON time of an event is defined as the time between
\ the start (ON) and end (OFF) of an event.
\ If the ON time is longer than the DUR then events will overlap.
\ The ON time is determined as follows:
\   1) If the on-dim is >= 0 , the ON time will be read from
\      that dimension.
\   2) Otherwise the DUTY cycle will determine the ON time
\      as a fraction of the duration.  If the numerator and
\      denominator of the duty cycle are both zero then
\      there will be no OFF event and no notion of ON time.
\ Once the ON-TIME is determined, the value ON.TIME is set
\ for reading by interpreters.
\
\ The calling of the OFF Interpreter was important in the
\ the original HMSL but is now mostly obsolete.
\
\ Allow setting start of player to a specific time.
\
\ Author: Phil Burk
\ Copyright 1986 -  Phil Burk, Larry Polansky, David Rosenboom.
\ All Rights Reserved
\
\ MOD: PLB 3/2/87 Add ABORT: processing.
\ MOD: PLB 3/7/87 Add duration scheduling.
\ MOD: PLB 3/7/87 Add legato for on>total.
\ MOD: PLB 5/23/87 Add STOP: , no done? for TASK:
\ MOD: PLB 5/28/87 Add ?HIERARCHICAL:
\ MOD: PLB 6/15/87 Add DEFAULT:
\ MOD: PLB 10/7/87 Add PUT.DUR.FUNCTION:
\ MOD: PLB 9/26/89 Add PREFAB: and BUILD: , add internal pending list,
\      Allow absolute time.
\ MOD: PLB 10/23/89 Only do PREFAB: if MIDI defined.
\ MOD: PLB 10/27/89 Don't fail if empty shape.
\ MOD: PLB 3/26/90 Add ON.TIME
\ 00001 PLB 10/1/91 print IV-PL-OFFSET
\ 00002 PLB 2/6/92 Use EXEC.STACK?
\ 00003 PLB 11/20/91 Use EXIT instead of RETURN
\ 00004 PLB 3/31/92 INHERIT.METHODS from LIST classes.

ANEW TASK-PLAYER.FTH


METHOD PUT.DUTY.CYCLE:      METHOD GET.DUTY.CYCLE:
METHOD PUT.DUR.DIM:         METHOD GET.DUR.DIM:
METHOD PUT.ON.DIM:          METHOD GET.ON.DIM:
METHOD PUT.DUR.FUNCTION:    METHOD GET.DUR.FUNCTION:
METHOD ?DONE:
METHOD USE.RELATIVE.TIME:   METHOD USE.ABSOLUTE.TIME:
METHOD PLAY.ONLY.ON:        METHOD PLAY.ON&OFF:
METHOD SET.TIMER:

:CLASS OB.PLAYER <SUPER OB.JOB
    IV.LONG  IV-PL-DUR-DIM    ( dimensions holding DURATIONS )
    IV.LONG  IV-PL-DUR-FUNCTION
    IV.LONG  IV-PL-CUR-DUR    ( this elements duration )
\ IVARs for ON time
    IV.LONG  IV-PL-DUTY-ON    ( numerator for duty cycle )
    IV.LONG  IV-PL-DUTY-TOTAL ( denominator for duty cycle )
    IV.LONG  IV-PL-TIMEOFF    ( portion of time element is off )
    IV.LONG  IV-PL-ON-DIM     ( dimension holding ON-TIMEs
    IV.LONG  IV-PL-LEG-E#     ( element # of legato note )
\ This next IV is also used as a flag, 0 if last was not legato.
    IV.LONG  IV-PL-LEG-SHAPE  ( shape legato note came from )
\
    IV.LONG  IV-PL-SHAPE      ( Shape currently being processed )
    IV.LONG  IV-PL-ELMNT#     ( Points to current element in shape )
    IV.LONG  IV-PL-OFFSET     ( time offset for starting )
    IV.LONG  IV-PL-OFFSET-ADD ( time to add when starting )
    iv.long  IV-PL-START-REP  ( start on this repitition )
    
    IV.LONG  IV-PL-ON#        ( index of element while on, waiting for off )
    IV.LONG  IV-PL-ALLOW?     ( Allow element off? )
\
    IV.BYTE  IV-PL-IF-ABSOLUTE  ( true if use absolute time )
    IV.BYTE  IV-PL-IF-ON&OFF    ( true if use OFF interpreter )
    IV.BYTE  IV-PL-IF-PREFAB    ( true if prefabricated )
    IV.LONG  IV-PL-START-TIME   ( time player started )

:M DEFAULT: ( -- )
\ Don't get rid of instrument if prefab.
    iv-pl-if-prefab
    IF iv-jb-instrument
       default: super
       iv=> iv-jb-instrument
    ELSE default: super
    THEN
    4 iv=> iv-pl-duty-on    ( default duty cycle = 4/5 )
    5 iv=> iv-pl-duty-total
\
    0 iv=> iv-pl-dur-dim
    -1 iv=> iv-pl-on-dim
    0 iv=> iv-pl-dur-function
    8 iv=> iv-jb-duration
\
    false iv=> iv-pl-if-absolute
    false iv=> iv-pl-if-on&off
;M

:M INIT: ( -- )
    init: super
    -1 iv=> iv-pl-elmnt#
    0 iv=> iv-pl-shape      ( current shape )
    -1 iv=> iv-pl-on#
    0 iv=> iv-pl-leg-shape
    false iv=> iv-pl-if-prefab
;M

:M FREE: ( -- , free prefab stuff too )
    iv-pl-if-prefab
    IF 0 get: self dup free: [] deinstantiate  ( shape )
       get.instrument: self ?dup
       IF dup free: [] deinstantiate
       THEN
       0 put.instrument: self
       0 iv=> iv-pl-if-prefab
    THEN
    free: super
;M

exists? OB.MIDI.INSTRUMENT [IF]
:M PREFAB:  ( -- , dynamically instantiate shape and instrument )
    free: self
    instantiate ob.shape dup prefab: []
    instantiate ob.midi.instrument
    build: self
    true iv=> iv-pl-if-prefab
;M
[THEN]

:M USE.RELATIVE.TIME: ( -- , use time till next event )
    false iv=> iv-pl-if-absolute
;M
:M USE.ABSOLUTE.TIME: ( -- , use time since start: )
    true iv=> iv-pl-if-absolute
;M

:M PLAY.ON&OFF: ( -- , call if you want player to use both )
    true iv=> iv-pl-if-on&off
;M

:M PLAY.ONLY.ON: ( -- , call if you want player to only use ON )
    false iv=> iv-pl-if-on&off
;M

:M PUT.DUTY.CYCLE: ( on total -- )
    dup 0= 0= iv=> iv-pl-if-on&off
    iv=> iv-pl-duty-total
    iv=> iv-pl-duty-on
;M

:M GET.DUTY.CYCLE: ( -- on total )
    iv-pl-duty-on
    iv-pl-duty-total
;M

:M PUT.DUR.DIM: ( dim -- , set total duration dimension )
    iv=> iv-pl-dur-dim
;M
:M GET.DUR.DIM: ( -- dim , which dimension has total duration? )
    iv-pl-dur-dim
;M

:M PUT.DUR.FUNCTION: ( cfa -- , set duration function )
    iv=> iv-pl-dur-function
;M
:M GET.DUR.FUNCTION: ( -- cfa , fetch duration function )
    iv-pl-dur-function
;M

:M PUT.ON.DIM: ( dim | -1 -- , set on time dimension )
    iv=> iv-pl-on-dim
;M
:M GET.ON.DIM: ( -- dim | -1 , which dimension has on time? )
    iv-pl-on-dim
;M

:M WHERE:  ( -- elmnt# shape# , last one played )
    iv-pl-elmnt# 1+ iv-current 1-
;M

:M GOTO:  ( elmnt# shape# -- , jump to different shape )
    dup at: self iv=> iv-pl-shape
    1+ iv=> iv-current  ( set current to after that shape )
    1- iv=> iv-pl-elmnt#
;M

: PL.NEXT.ABSOLUTE ( -- , Set start timer )
    iv-pl-if-absolute
    IF  iv-time-next iv=> iv-pl-start-time
        0 iv-pl-dur-dim iv-pl-shape ed.at: []
        iv+> iv-time-next  ( set time for first event )
    THEN
;

: PL.START.ABSOLUTE ( -- , Set start timer )
    iv-pl-if-absolute
    IF  iv-time-next
    	iv-pl-elmnt# 1+ iv-pl-dur-dim iv-pl-shape ed.at: []
    	iv-pl-offset-add - -
    		iv=> iv-pl-start-time
        iv-pl-offset-add iv+> iv-time-next  ( set time for first event )
    THEN
;

: PL.NEXT.SHAPE ( -- , move to next shape )
\ Keep going until you find a shape with data.
\ Set IV-PL-SHAPE to 0 if none found.
    0 iv=> iv-pl-shape
    BEGIN manyleft: self 0>
        IF next: self dup iv=> iv-pl-shape
           many: [] 0>
           IF  pl.next.absolute true
           ELSE 0 iv=> iv-pl-shape false  ( keep looking )
           THEN
        ELSE true
        THEN
    UNTIL
    -1 iv=> iv-pl-elmnt#
;

:M CUSTOM.EXEC: ( -- time true | false , set start time )
\ Check for instrument.
    iv-jb-instrument 0=
    IF  " CUSTOM.EXEC: OB.PLAYER" " No instrument!"
         er_fatal ob.report.error
    THEN
    -1 iv=> iv-pl-on#
\
\ Get first shape.
    many: self 0>
    IF	iv-pl-offset 0=  \ leave at current position if there
    	IF	reset: self
			pl.next.shape
    	ELSE
    		iv-pl-shape  \ avoid crash if set.timer past end
    		IF	pl.start.absolute
    		ELSE
    			0 iv=> iv-pl-offset
    			0 iv=> iv-pl-offset-add
    			0 iv=> iv-pl-start-rep
    		THEN
    		iv-repcount iv-pl-start-rep - iv=> iv-repcount
    	THEN
    	iv-pl-shape 0=
    	iv-repcount 0= OR
    	IF  iv-time-next true   ( let's not bother )
    	ELSE custom.exec: super
    	THEN
    	iv-pl-offset-add iv+> iv-time-next
    ELSE
       " CUSTOM.EXEC: OB.PLAYER" " No shapes!"
       er_return ob.report.error
    THEN
\
;M

: PL.LEGATO.OFF ( -- , turn off legato element )
    iv-pl-leg-e# iv-pl-leg-shape
    iv-jb-instrument element.off: []
    0 iv=> iv-pl-leg-shape
;

: PL.ELMNT.OFF ( -- , turn last element off )
\ Turn off last element if LEGATO.
    iv-pl-leg-shape
    IF pl.legato.off
    ELSE
        iv-pl-allow?
        IF  iv-pl-elmnt# iv-pl-shape
            iv-jb-instrument element.off: []
            false iv=> iv-pl-allow?
        THEN
        -1 iv=> iv-pl-on#
\ Schedule next event.
        iv-pl-timeoff iv+> iv-time-next
    THEN
;

: PL.SET.LEGATO ( -- )
    iv-pl-if-on&off  ( is this desired )
    IF  iv-pl-shape iv=> iv-pl-leg-shape  ( LEGATO this element )
        iv-pl-elmnt# iv=> iv-pl-leg-e#
    THEN
;

:M GET.DURATION: ( -- duration , calculate duration )
\ Is there a DUR.FUNCTION ?
    iv-pl-dur-function ?dup
    IF >r iv-pl-elmnt# iv-pl-shape r>
    	-1 exec.stack?  \ should ( e# sh -- dur )
\
\ If not, then if no DUR dimension, use DURATION
    ELSE iv-pl-dur-dim 0<
        IF iv-jb-duration
\
\ Read DUR dimension
        ELSE iv-pl-if-absolute  ( calc ticks to next event )
\ ABSOLUTE TIME
            IF  iv-pl-shape many: [] iv-pl-elmnt# 1+ >
                 IF iv-pl-elmnt# 1+ iv-pl-dur-dim iv-pl-shape
                    ed.at: []  ( time of next event )
                    iv-pl-start-time + iv-time-next -
                 ELSE 0
                 THEN
\ RELATIVE TIME
             ELSE iv-pl-elmnt# iv-pl-dur-dim iv-pl-shape ed.at: []
             THEN
        THEN
    THEN
;M

: PL.SCAN.TIME ( time -- total false | time true )
\ scan for element and shape
{ time | shape num atime ifhit -- endat ifhit , calculate duration }
	0 -> ifhit
\ Is there a DUR.FUNCTION ?
    iv-pl-dur-function
    IF 0 0
    ELSE iv-pl-dur-dim 0<
        IF \ use constant duration
        	time iv-jb-duration /mod -> num
        	iv=> iv-pl-offset-add
        	many: self 0
        	?DO	i at: self ( shape )
        		many: [] dup num >
        		IF	drop num i goto: self
        			true -> ifhit LEAVE
        		ELSE num swap - -> num
        		THEN
        	LOOP
        	num iv-jb-duration * ifhit
        ELSE iv-pl-if-absolute  ( calc ticks to next event )
\ ABSOLUTE TIME
            IF	0 -> num
        		many: self 0
        		?DO	i at: self ( shape ) dup -> shape
        			many: [] 0
        			?DO i iv-pl-dur-dim shape ed.at: [] -> atime
        				num atime + time >=
        				IF	i j goto: self
        					num atime + time - iv=> iv-pl-offset-add
        					true -> ifhit
        					LEAVE
        				THEN
        			LOOP
        			ifhit
        			IF LEAVE  ( got it )
        			THEN
        			atime num + -> num
        		LOOP
        		num ifhit
\ RELATIVE TIME
			ELSE 0 -> num
        		many: self 0
        		?DO	i at: self ( shape ) dup -> shape
        			many: [] 0
        			?DO	i iv-pl-dur-dim shape ed.at: [] ( Rtime )
        				num + -> num
        				num time >=
        				IF	i j goto: self
        					num time - iv=> iv-pl-offset-add
        					true -> ifhit LEAVE
        				THEN
        			LOOP
        			ifhit
        			IF LEAVE  ( got it )
        			THEN
        		LOOP
        		num ifhit
			THEN
		THEN
	THEN
;

:M SET.TIMER:  ( time -- )
	dup iv=> iv-pl-offset
	0 iv=> iv-pl-start-rep
	iv-start-delay - \ account for start delay
	dup pl.scan.time 0=  \ Is it NOT in first repitition?
	IF ( time' total )
		dup 0>
		IF	( time' total )
			iv-repeat-delay +
			/mod dup iv-repeat < \ Is it before end of last?
			IF	( rem n )
				iv=> iv-pl-start-rep
				pl.scan.time
			ELSE dup iv-repeat min  iv=> iv-pl-start-rep
			THEN
		THEN
	THEN
	iv-repeat iv-pl-start-rep - iv=> iv-repcount
	2drop
;M
		
: PL.SET.DELAY ( delay -- , set timenext to delay )
    iv-jb-epochal?
    IF iv+> iv-time-next
    ELSE time@ + iv=> iv-time-next
    THEN
;

: PL.SET.DUR&ON     ( -- , Precalculate timing for element. )
    get.duration: self  ( -- dur ) dup iv=> iv-pl-cur-dur
\
    iv-pl-on-dim dup 0<
\ Calculate ON from duty cycle.  ( -- dur on-dim flag )
    IF  drop iv-pl-duty-on iv-pl-duty-total
        >r * r> /
\
\ OR Look up in "on" dimension.
    ELSE ( -- total on_dim , calc delay from shape )
        nip iv-pl-elmnt# swap iv-pl-shape ed.at: []  ( -- on_time )
    THEN
    -> on.time  ( set global value for interpreters )
;

: PL.TIMING  ( -- , determine time till next event )
    iv-pl-cur-dur on.time
    iv-pl-if-on&off
    IF  ( -- dur time_on )
        2dup <
        IF pl.set.legato drop 0
        ELSE tuck -
        THEN
        iv=> iv-pl-timeoff  ( -- time_on )
    ELSE drop   ( -- dur )
    THEN
    pl.set.delay
;


: PL.NEXT.ELMNT ( -- play next element in shape )
    1 iv+> iv-pl-elmnt#   ( advance pointer )
\ Set on time for next events.
    pl.set.dur&on
\
    jb.in.time?   ( or are we too late )
    IF
       iv-pl-elmnt# iv-pl-shape 2dup
       iv-jb-instrument element.on: []   ( ON )
       pl.now.playing
       true iv=> iv-pl-allow?
    ELSE false iv=> iv-pl-allow?
    THEN
\
\ Set number of ON element for later OFF if desired
    iv-pl-if-on&off
    IF  iv-pl-elmnt# iv=> iv-pl-on#
    THEN
\
\ Now turn off any overlapped LEGATO elements.
    iv-pl-leg-shape iv-pl-if-on&off AND
    IF pl.legato.off
    THEN
\
    pl.timing
\
;

:M TERMINATE: ( time -- , turn off pending off events )
    iv-pl-on# 0< NOT
    IF pl.elmnt.off  ( turn off if on )
    THEN
    iv-pl-leg-shape
    IF pl.legato.off
    THEN
    0 iv=> iv-pl-shape
    0 iv=> iv-pl-elmnt#
    0 iv=> iv-pl-offset
    0 iv=> iv-pl-offset-add
    0 iv=> iv-pl-start-rep
    terminate: super  ( use OB.JOB termination )
;M

:M ?DONE: ( -- , cleanup if the morph is done )
    col.do.repeat iv-repcount 0=
    IF iv-time-next terminate: self
    ELSE
       reset: self
       pl.next.shape
    THEN
;M

:M TASK: ( -- , play pending elements. )
    BEGIN
        iv-time-next doitnow?
    WHILE
    	iv-pl-on# 0<   iv-pl-leg-shape OR
        IF  iv-pl-elmnt# iv-pl-shape many: [] 1- <
            IF pl.next.elmnt
            ELSE
                iv-pl-shape pl.stop.playing
                pl.next.shape iv-pl-shape 0=
                IF ?done: self exit  \ 00003
                THEN
            THEN
        ELSE pl.elmnt.off  ( turn off if on )
        THEN
    REPEAT
;M

:M PRINT.ELEMENT:  ( e# -- , print the element )
    get: self  ( get morph)
    name: []
;M

:M PRINT: ( -- )
    print: super ?pause
    ." DURation func.= " iv-pl-dur-function cfa. cr
    ." DURation dim. = " iv-pl-dur-dim . cr
    ." ON dimension  = " iv-pl-on-dim . cr ?pause
    ." Duty Cycle    = " iv-pl-duty-on . iv-pl-duty-total . cr
    ." Offset Time   = " iv-pl-offset . cr \ 00001
    iv-pl-if-absolute
    IF ." Absolute Time" cr
    ELSE ." Relative Time" cr
    THEN ?pause
;M

:M ?HIERARCHICAL:  ( -- flag , true if can contain other morphs)
    true
;M

\ Since this is a one-dimensional list, let's inherit a bunch
\ of object list methods. \ 00004
inherit.method freeall: ob.objlist
inherit.method deinstantiate: ob.objlist
inherit.method ?instantiate: ob.objlist

;CLASS

\ Test player
false [IF]

OB.PLAYER PL1
OB.MIDI.INSTRUMENT INS1
OB.SHAPE SH1

: TP.FILL
    32 4 new: sh1
    20 0
    DO	10 i *
    	10 i +
    	100 8 add: sh1
    LOOP
\
	default: ins1
    4 new: pl1
    sh1 add: pl1
    ins1 put.instrument: pl1
    use.absolute.time: pl1
    10 put.repeat.delay: pl1
    2 put.repeat: pl1
    3 put.on.dim: pl1
;

: TP.FREE
    free: pl1
    free: sh1
;
if.forgotten tp.free
[THEN]


