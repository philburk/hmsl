\ SHAPES are an abstract set of points in N dimensional space.
\ They can be manipulated using special methods like TRANSPOSE:
\ and can be edited using the shape editor.  They can also be
\ converted to musical events by a user defined interpretation
\ process.
\
\ Each dimension can have a name + average, min, max & sum.
\
\ Author: Phil Burk
\ Copyright 1986 -  Phil Burk, Larry Polansky, David Rosenboom.
\ All Rights Reserved
\
\ MOD: PLB 7/30/86 Added SERVICE.TASKS calls to DRAW.DIM:
\ MOD: PLB 10/8/86 Changed PICK to PICK83
\ MOD: PLB 10/13/86 Changed to IV.LONG system.
\ MOD: PLB 11/5/86 Added TRANSPOSE:, INVERT: etc.
\ MOD: PLB 11/8/86 Store names in separate array.
\ MOD: PLB 11/8/86 Fix bogus names in GET.DIM.NAME: after FREE:
\      Remove METRIC methods.
\ MOD: PLB 12/26/86 Add DUMP.SOURCE: method.
\ MOD: PLB 3/10/87 Fix bad PRINT: after FREE:
\ MOD: PLB 5/13/87 Add calculation of mean.
\ MOD: PLB 5/23/87 Changed AVE to MEAN
\ MOD: PLB 9/3/87 Change REVERSE: to not use so much stack.
\ MOD: PLB 9/10/87 Use internal instance objects for names,
\      mins, maxes, etc.
\      Add SCALE: and CLIP.ED.TO:
\ MOD: PLB 10/7/87 Fix PRINT.STATS: stack leftovers.
\ MOD: PLB 11/16/87 Add UPDATE: stub. Print stats before data.
\      Don't print dim names in DUMP.SOURCE:
\      Add SHAPE_CUSTOM_DATA
\ MOD: PLB 12/15/87 Add SWAP: and SCRAMBLE:, thanks to
\      Henry Lowengard for the scramble algorithm.
\ MOD: PLB 5/14/89 Added SEARCH.BACK: , INTEGRATE.DIM: ,
\      DIFFERENTIATE.DIM: and DIM.SUM:
\      Converted CALC.DIM.STATS: to locals,  13.68 => 11.58 secs
\      Converted REVERSE: to locals,  5.58 => 4.86
\ MOD: PLB 9/26/89 Added PREFAB: , clipped DIFFERENTIATE to 0.
\ MOD: PLB 10/3/89 Make NEXT: wrap around if at end.
\ MOD: PLB 11/15/89 Add CLONE: method and ENSURE.ROOM
\ MOD: PLB 3/12/90 Changed INTEGRATE.DIM: to INTEGRATE:
\ MOD: PLB 7/18/90 Use late bound SELF NEW: [] in PREFAB:
\ MOD: PLB 10/30/90 Fix crash in DIFFERENTIATE: if MANY=0
\ MOD: PLB 6/19/91 Fix off by one error in DIFFERENTIATE:, added 1-
\ MOD: PLB 5/7/92 Added methods for executing shapes directly.
\ 00001 PLB 5/21/92 Add EDIT: method.
\ 00002 PLB 7/26/93 Fixed DUMP.SOURCE.BODY:

ANEW TASK-SHAPE.FTH

0 value ON.TIME

\ These words can be used by other systems that want to
\ know what's playing, eg. the Shape Editor.

defer PL.NOW.PLAYING  ( elmnt# shape -- )
'c 2drop is pl.now.playing
defer PL.STOP.PLAYING  ( shape -- )
'c drop is pl.stop.playing


decimal
METHOD PUT.DIM.ATTR:     METHOD GET.DIM.ATTR:
METHOD GET.DIM.NAME:     METHOD PUT.DIM.NAME:
METHOD CALC.DIM.STATS:   METHOD GET.DIM.MEAN:
METHOD GET.DIM.MIN:      METHOD GET.DIM.MAX:
METHOD GET.DIM.SUM:
METHOD CALC.STATS:       METHOD PRINT.STATS:
METHOD DRAW.DIM:         METHOD SCRAMBLE:
METHOD RANDOMIZE:        METHOD REVERSE:
METHOD TRANSPOSE:        METHOD INVERT:
METHOD SCALE:            METHOD CLIP.ED.TO:
METHOD PUT.DIM.LIMITS:   METHOD GET.DIM.LIMITS:
METHOD UPDATE:           METHOD SWAP:
method SEARCH.BACK:
method INTEGRATE.DIM:
method DIFFERENTIATE.DIM:
method INTEGRATE:
method DIFFERENTIATE:
method CLONE:

METHOD PUT.CHANNEL:
METHOD GET.CHANNEL:
METHOD PUT.MUTE:
METHOD GET.MUTE:
METHOD PUT.PLAY.FUNCTION:
METHOD GET.PLAY.FUNCTION:
METHOD GET.OFFSET:
METHOD PUT.OFFSET:
METHOD PUT.DUR.FUNCTION:
METHOD GET.DUR.FUNCTION:
METHOD PUT.DURATION:
METHOD GET.DURATION:
METHOD USE.RELATIVE.TIME:
METHOD USE.ABSOLUTE.TIME:
METHOD ?DONE:

: (DEFAULT.PLAY.FUNCTION) { elmnt# seqobj -- }
	get.channel: seqobj midi.channel!  \ set channel
	elmnt# 1 ed.at: seqobj ?dup  \ note 
	IF
		get.offset: seqobj +     \ transpose
		dimension: seqobj 2 >
		IF
			elmnt# 2 ed.at: seqobj   \ velocity
		ELSE
			64
		THEN
		on.time                  \ on time
		midi.noteon.for
	THEN
;

defer DEFAULT.PLAY.FUNCTION

'c (default.play.function) is default.play.function

\ The attributes of a given dimension are stored in an
\ instance array.
\ Element number of attribute defined here.
0 constant SHAPE_MIN
1 constant SHAPE_MAX
2 constant SHAPE_SUM
3 constant SHAPE_NAME
4 constant SHAPE_LOLIM
5 constant SHAPE_HILIM
6 constant SHAPE_CUSTOM_DATA
7 constant SHAPE_#ATTRIBUTES

\ DEFINE OB.SHAPE CLASS 
:CLASS OB.SHAPE  <SUPER OB.MORPH
    OB.ELMNTS IV-SH-ATTRIBUTES
    IV.LONG  IV-SH-START-TIME   ( time player started )
	IV.LONG  IV-SH-DURATION   ( use this if >0 )
	IV.LONG  IV-SH-DUR-FUNCTION   ( use this if !0 )
	IV.LONG  IV-SH-OFFSET     ( transpose by this much )
    IV.LONG  IV-SH-CHANNEL    ( MIDI or other channel type )
    IV.LONG  IV-SH-PLAY-CFA
    IV.BYTE  IV-SH-IF-ABSOLUTE  ( true if use absolute time )
    IV.SHORT IV-SH-MUTE         ( if true, play function not executed )

:M DEFAULT:
	default: super
    1 iv=> iv-sh-channel
    -1 iv=> iv-sh-duration
    0 iv=> iv-sh-dur-function
;M

:M FREE: ( -- , Free dim attributes too.)
    free: super
    free: iv-sh-attributes
;M

:M PUT.DIM.ATTR:  ( value dim code -- , set attribute to value )
      swap ed.to: iv-sh-attributes
;M
:M GET.DIM.ATTR:  ( dim code -- value , get attr of dimension )
      swap ed.at: iv-sh-attributes
;M

:M PUT.DIM.LIMITS: ( low high dim -- , set limits for dimension )
      tuck shape_hilim put.dim.attr: self
      shape_lolim put.dim.attr: self
;M

:M GET.DIM.LIMITS: ( dim -- low high , fetch limits for dimension )
      dup shape_lolim get.dim.attr: self
      swap shape_hilim get.dim.attr: self
;M

:M CLIP.ED.TO: ( value e# dim -- , clip before setting )
    >r swap r@ get.dim.limits: self clipto
    swap r> ed.to: self
;M

:M ?NEW: ( maxindex #dimensions -- addr | 0, declare space )
    tuck ?new: super
    IF  shape_#attributes swap
        ?new: iv-sh-attributes
        IF  0 fill: iv-sh-attributes
\ Set default limits.
            dimension: self 0
            ?DO 0 ho_max_int i put.dim.limits: self
            LOOP
\ return address
            data.addr: self
        ELSE 0
        THEN
    ELSE 0
    THEN
;M

:M NEW: ( #cells -- , abort if error )
    ?new: self <new:error>
;M

:M GET.DIM.MIN: ( dim -- min , minimum value of dimension)
       shape_min get.dim.attr: self
;M
:M GET.DIM.MAX: ( dim -- max , maximum value of dimension)
       shape_max get.dim.attr: self
;M

:M GET.DIM.MEAN: ( dim -- mean , average value of dimension)
       shape_sum get.dim.attr: self many: self /
;M

:M GET.DIM.SUM: ( dim -- sum , sum of values of dimension)
       shape_sum get.dim.attr: self
;M


:M CALC.DIM.STATS:  { dim | smin smax ssum -- , calculate dimension stats }
    ho_max_int -> smin  ( set up)
    ho_min_int -> smax
    0 -> ssum
    many: self 0
    ?DO  i dim ed.at: self   ( get value )
        dup smin min -> smin
        dup smax max -> smax
        ssum + -> ssum
    LOOP
    smin dim shape_min  put.dim.attr: self
    smax dim shape_max  put.dim.attr: self
    ssum dim shape_sum  put.dim.attr: self
;M

:M PUT.DIM.NAME:  ( $NAME DIM -- , place pointer in name )
    shape_name put.dim.attr: self
;M

:M GET.DIM.NAME:  ( dim -- $name | 0, get name of dimension )
    shape_name get.dim.attr: self
;M

:M CALC.STATS:  ( -- , calc all stats )
    dimension: self 0
    ?DO
        i calc.dim.stats: self
    LOOP
;M

: SH.PRINT.STAT ( code $string -- , print statistic )
    $. dimension: self 0
    ?DO i over get.dim.attr: self 8 .r space
    LOOP drop cr
;

:M PRINT.STATS: ( -- , print statistics )
    dimension: self
    IF  calc.stats: self
        shape_min   " MIN:      " sh.print.stat
        shape_max   " MAX:      " sh.print.stat
        shape_sum   " SUM:      " sh.print.stat
        shape_lolim " LO LIMIT: " sh.print.stat
        shape_hilim " HI LIMIT: " sh.print.stat
    THEN
;M

:M PRINT: ( -- , print contents )
    cr name: self cr
    many: self
    IF  ." -- Stats -----------------" cr
        print.stats: self ?pause
        ." -- Dimension Names -------" cr
        dimension: self 0
        ?DO  ( print names of dimensions )
            i . space
            i get.dim.name: self ?dup
            IF   $.   ( print it)
            ELSE ." ---" ( mark space if not named)
            THEN cr ?pause
        LOOP cr
    THEN
    print: super
;M

:M DRAW.DIM: ( start end dim -- , draw dimension )
    many: self 1 >
    IF swap rot ( -- d e s)
       dup 3 pick83 ed.at: self ( -- d e s y0 , first Y )
       over swap scg.move          ( move to first point )
       1+ swap 1+ swap ( -- d e+1 s+1 )
       ?DO   i over ed.at: self  ( draw to following points )
            i swap scg.draw
            service.tasks/16
       LOOP drop
    ELSE
        2drop drop
    THEN
;M

\ Support for special music operations.
V: ZZZZDIM#  ( storage for dim to prevent stack dancing.)

: SH.RANDOMIZE ( min max elmnt# dim -- , set random value )
    >r >r swap wchoose r> r>
    clip.ed.to: self
;

:M RANDOMIZE: ( min max start end dim -- , Put random values in.)
    zzzzdim# ! 1+ swap
    ?DO  zzzzdim# @ 0<
        IF dimension: self 0
            ?DO 2dup j i sh.randomize
            LOOP
        ELSE 2dup i zzzzdim# @ sh.randomize
        THEN
    LOOP
    2drop
;M

:M TRANSPOSE: { val start endl dim -- , add value to shape }
    endl 1+ start
    ?DO val  i dim ed.at: self  +
       i dim clip.ed.to: self
    LOOP
;M

:M SCALE: { numer denom start endl dim -- , scale values }
    endl 1+ start
    ?DO i dim ed.at: self
       numer denom */
       i dim clip.ed.to: self
    LOOP
;M

:M INVERT: { val start endl dim -- , reflect values in shape }
    endl 1+ start
    ?DO val 2*  i dim ed.at: self
       -   i dim clip.ed.to: self
    LOOP
;M

:M REVERSE: { start endl dim -- , Reverse order of values. }
    start endl 2sort -> endl -> start
    BEGIN
        start endl <
    WHILE
        dim 0<
        IF  start get: self endl get: self
            start put: self endl put: self
        ELSE
            start dim ed.at: self
            endl dim ed.at: self
            start dim ed.to: self
            endl dim ed.to: self
        THEN
        1 +-> start
       -1 +-> endl
    REPEAT
;M

:M SWAP: { elm1 elm2 dim -- , swap elements }
    dim 0<
    IF  ( swap entire elements )
        elm1 get: self elm2 get: self ( -- v0s v1s )
        elm1 put: self elm2 put: self
    ELSE  ( swap single values )
        elm1 dim ed.at: self
        elm2 dim ed.at: self  ( -- v1 v2 )
        elm1 dim ed.to: self
        elm2 dim ed.to: self
    THEN
;M

\ Choose one element from range, swap with bottom,
\ then move bottom up.  Allow swap of one element.
:M SCRAMBLE: ( start end dim -- , reorder )
    -rot     tuck  
    swap ( -- dim end end start )
    ?DO  dup 1+ i wchoose   ( pick element to swap )
        i 3 pick swap: self
    LOOP 2drop
;M

:M UPDATE: ( -- , useful in later subclasses )
;M

:M SEARCH.BACK:  { val dim | index -- index , next highest if false }
    many: self dup -> index 0
    ?DO  index 1- dup -> index
        dim ed.at: self val <=
        IF index 1+ -> index leave
        THEN
    LOOP
    index
;M

:M INTEGRATE: { dim | sum -- sum , convert from delta to abs }
    0 -> sum
    many: self 0
    ?DO  i dim ed.at: self
        sum dup i dim ed.to: self
        + -> sum
    LOOP
    sum
;M

:M DIFFERENTIATE: { sum dim -- sum , convert from abs to delta }
    many: self ?dup
    IF  1- 0
    	?DO i 1+ dim ed.at: self
			i dim ed.at: self  - ( -- v[i+1] v[i]  )
			sum over - -> sum   ( track sum )
			i dim ed.to: self
    	LOOP
		sum  0 max many: self 1- dim ed.to: self
    THEN
;M

:M DIFFERENTIATE.DIM: ( sum dim -- )
    ." DIFFERENTIATE.DIM: is obsolete! Use DIFFERENTIATE:" cr
    self DIFFERENTIATE: []
;M

:M INTEGRATE.DIM: ( dim -- )
    ." INTEGRATE.DIM: is obsolete! Use INTEGRATE:" cr
    self INTEGRATE: []
;M

:M PREFAB: { | smalldur lastnote -- , setup a default shape }
\ Build a simple melody using a random walk.
\ This data will be appropriate duration in dim0, pitch
\ in dim1 and velocity in dim2.
    ticks/beat @ 4/ -> smalldur  ( use 1/4 beat per unit  )
    24 -> lastnote
\
\ Allocate space for 32 notes.
    32 3 self new: []
\ Add 16 notes.
    16 0
    DO smalldur 2 choose IF 2* THEN  ( dur = 1 or 2 units )
\ do a random walk for the dim 1
       lastnote 3 choose+/- + 1 20 clipto  ( note )
           dup -> lastnote
       60 choose 40 +    ( velocity )
       add: self
    LOOP
;M

:M NEXT:  ( -- v1 v2 ... vn , return next element and inc pntr)
     current: self
\
\ Wrap around if we reach end.
     iv-current 1+ dup
     iv-many >
     IF drop 0
     THEN
     iv=> iv-current
;M

:M CLONE: ( shape -- , make duplicate of self )
    >r  ( save on RS for ease )
    r@ max.elements: [] max.elements: self <  ( less room )
    r@ width: [] width: self = not OR
    r@ dimension: [] dimension: self = not OR
    IF ( shape )
        r@ free: []
        width: self r@ set.width: []
        many: self dimension: self r@ new: []
    THEN
    many: self r@ set.many: []
    0 0 many: self r@ copy: self
    r> dimension: self 0
    ?DO i get.dim.limits: self ( sh min max )
       i 3 pick put.dim.limits: []
       i get.dim.name: self  i 2 pick put.dim.name: []
    LOOP drop
;M


\ For shape execution ---------------------------------

:M PUT.DURATION: ( dur -- )
	iv=> iv-sh-duration
;M
:M GET.DURATION: ( -- dur )
	iv-sh-duration
;M

:M PUT.DUR.FUNCTION: ( cfa -- , set duration function )
    iv=> iv-sh-dur-function
;M
:M GET.DUR.FUNCTION: ( -- cfa , fetch duration function )
    iv-sh-dur-function
;M

:M PUT.MUTE: ( flag -- , set mute flag )
    iv=> iv-sh-mute
;M
:M GET.MUTE: ( -- flag , set mute flag )
    iv-sh-mute
;M

:M USE.RELATIVE.TIME: ( -- , use time till next event )
    false iv=> iv-sh-if-absolute
;M
:M USE.ABSOLUTE.TIME: ( -- , use time since start: )
    true iv=> iv-sh-if-absolute
;M

:M PUT.OFFSET: ( offset -- )
    iv=> iv-sh-offset
;M
:M GET.OFFSET: ( -- offset)
    iv-sh-offset
;M

:M PUT.CHANNEL: ( channel -- )
    iv=> iv-sh-channel
;M
:M GET.CHANNEL: ( -- channel )
    iv-sh-channel
;M


:M PUT.PLAY.FUNCTION: ( cfa -- )
    iv=> iv-sh-play-cfa
;M
:M GET.PLAY.FUNCTION: ( -- cfa )
    iv-sh-play-cfa
;M

:M CUSTOM.EXEC: ( -- time true | false , set start time )
	reset: self
	iv-repcount 0>
	many: self 0> AND
	IF
		false iv=> iv-col-done?
		iv-sh-if-absolute
		IF
			iv-time-next 0 at.self + iv=> iv-sh-start-time
		THEN
    	self ao.post false
	ELSE
		iv-time-next true   ( let's not bother )
	THEN
;M

:M TERMINATE: ( time -- )
    iv-if-active
    IF
		self ao.unpost
		morph.stop
    ELSE drop
    THEN
    self pl.stop.playing
;M

:M ?DONE: ( -- , cleanup if the morph is done )
    col.do.repeat
    iv-repcount 0=
    IF iv-time-next terminate: self
    ELSE
       reset: self
       iv-time-next
		iv=> iv-sh-start-time \ for absolute time
    THEN
;M

: SEQ.GET.DURATION ( -- dur )
\ Is there a DUR.FUNCTION ?
    iv-sh-dur-function ?dup
    IF >r iv-current self r>
    	-1 exec.stack?  \ should ( e# sh -- dur )
    ELSE
		iv-sh-duration dup 0<
		IF
			drop
			iv-current 0 ed.at: self
		THEN
    THEN
;

: SEQ.NEXT.ELMNT  ( -- , play next element )
\ set IV-NEXT-TIME and ON.TIME
	iv-sh-if-absolute
	IF
		iv-current 1+ many: self <
		IF
			iv-current 1+ 0 ed.at: self
			iv-sh-start-time +
			dup iv-time-next - -> on.time
			iv=> iv-time-next
		THEN
	ELSE
		seq.get.duration
		dup -> on.time
		iv+> iv-time-next
	THEN
\
	iv-current self
	iv-sh-mute not
	IF
		2dup
		iv-sh-play-cfa ?dup
		IF 
			-2 exec.stack?
		ELSE
			default.play.function
		THEN
	THEN
	pl.now.playing   \ track in shape editor %Q, remove from player
\
	1 iv+> iv-current
;

:M TASK: ( -- , play the next element )
    iv-time-next doitnow?
    IF
    	iv-current many: self <
    	IF seq.next.elmnt
    	ELSE
    		?done: self
        THEN
    THEN
;M

:M CLASS.NAME: ( -- $name )
	" OB.SHAPE"
;M

defer EDIT.SHAPE
' drop is edit.shape

:M EDIT: ( -- , edit using current editor ) \ 00001
	self edit.shape
;M

:M DUMP.SOURCE.BODY:
	dump.morph.body
\
	iv-pntr 
	IF
		tab max.elements: self . dimension: self .
		."  new: " name: self cr
\
		many: self 0
		?DO
			i self dump.element: []
		LOOP
	THEN
	
	cr
	tab iv-sh-channel . ." put.channel: " name: self cr
	iv-sh-duration 0>
	IF
		tab iv-sh-duration . ." put.duration: " name: self cr
	THEN
\
	iv-sh-dur-function
	IF
		tab ." 'c " iv-sh-dur-function cfa.
		." put.dur.function: " name: self cr
	THEN
\
	iv-sh-play-cfa
	IF
		tab ." 'c " iv-sh-play-cfa cfa.
		." put.play.function: " name: self cr
	THEN
\
	iv-sh-offset 0>
	IF
		tab iv-sh-offset . ." put.offset: " name: self cr
	THEN
\
	iv-sh-if-absolute
	IF
		tab ." use.absolute.time: " name: self cr
	THEN
;M

;CLASS

: ENSURE.ROOM ( shape -- , add room if needed )
    dup max.elements: []
    over many: [] =
    IF 64 swap extend: []
    ELSE drop
    THEN
;

if-testing @ [IF]

OB.SHAPE SH1
: FILL.SH1
    10 2 new: sh1
    8 0 DO
        i 10 * dup 1+ add: sh1
    LOOP
;

OB.SHAPE  SEQ1

: TSEQ.INIT
	32 3 new: seq1
	stuff{
		10 60 90
		10 67 60
		20 72 60
		10 64 60
		30  0 60
	}stuff: seq1
	1000 put.repeat: seq1
	clear: shape-holder
	seq1 add: shape-holder
;

: TSEQ.INIT.ABS
	4 3 new: seq1
	stuff{
		 0 60 90
		20 67 60
		40 72 60
		60 76 60
	}stuff: seq1
	use.absolute.time: seq1
	1000 put.repeat: seq1
	20 put.repeat.delay: seq1
	clear: shape-holder
	seq1 add: shape-holder
;

: TSEQ.PLAY { elmnt# seqobj -- }
	get.channel: seqobj midi.channel!  \ set channel
	elmnt# 1 ed.at: seqobj ?dup  \ note 
	IF
		get.offset: seqobj +     \ transpose
		elmnt# 2 ed.at: seqobj   \ velocity
		elmnt# 3 ed.at: seqobj   \ on time
		midi.noteon.for
	THEN
;

: TSEQ.INIT.ON
	32 4 new: seq1
	stuff{
		 0 60 90 10
		20 67 60 3
		40 72 60 15
		60 76 60 20
		80 62 90 10
		80 69 60 10
		80 74 60 10
		100 80 60 30
	}stuff: seq1
	use.absolute.time: seq1
	1000 put.repeat: seq1
	20 put.repeat.delay: seq1
	'c tseq.play put.play.function: seq1
	clear: shape-holder
	seq1 add: shape-holder
;

: TSEQ.TERM
	free: seq1
;

if.forgotten tseq.term

: TSEQ
	tseq.init
	seq1 ao.exec
	start: seq1
;
[THEN]


