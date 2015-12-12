\ @(#) elmnts.fth 96/06/11 1.1
\ ELEMENTS CLASS
\ OB.ELMNTS provides an ordered set of N dimensional elements.
\
\ Author: Phil Burk
\ Copyright 1986 Delta Research
\
\ MOD: PLB 7/30/86 Added FILL.DIM:
\ NOD: PLB 11/8/86 Put TAB in PRINT.ELEMENT: OB.OBJLIST
\ MOD: PLB 11/21/86 Optimized MOVE:
\ MOD: PLB 12/26/86 Added DUMP.SOURCE: and DUMP.ELEMENT:
\ MOD: PLB 1/14/87 Removed dead code, don't zero data in CLEAR:
\ MOD: PLB 2/10/87 FIRST: leaves pointer at second element.
\ MOD: PLB 2/13/87 LAST: leaves pointer past last, added
\      FOREWARD: , BACKWARD: .
\ MOD: PLB 2/19/87 Added EMPTY: method.
\ MOD: PLB 5/13/87 Optimized GET: and PUT:
\ MOD: PLB 9/3/87 Added DO: for iteration.
\ MOD: PLB 9/19/87 Added COPY: , SPLIT: , and SMEAR: .
\ MOD: PLB 11/3/87 Add DELETE:
\ MOD: PLB 9/13/88 Remove MRESET
\ MOD: PLB 1/6/88  Moved increment of IV-MANY in INSERT:
\      to fix overwriting bug.
\ MOD: PLB 3/8/89 Made DO: work on other Forths, fix FILL.DIM: msg,
\ MOD: PLB 5/17/89 Added GOTO: and WHERE:
\ MOD: PLB 12/15/89 Added STUFF{ and }NEWSTUFF:
\ MOD: PLB 10/30/90 Better protection in CHOP: and SPLIT:
\ MOD: PLB 12/1/90 Make NEXTWRAP: loop without error.
\ 00001 PLB 1/14/92 Use ?NEW: in ?INSTANTIATE:

ANEW TASK-ELMNTS.FTH

\ Declare OB.ELMNTS methods.
METHOD RESET:   ( First method )
METHOD MANY:
METHOD ED2I:                METHOD I2ED:
METHOD ED.AT:               METHOD ED.TO:
METHOD DIMENSION:           METHOD ADD:
METHOD FIRST:               METHOD LAST:
METHOD NEXT:                METHOD CURRENT:
METHOD CHECK.UNDER:         METHOD CHECK.OVER:
METHOD STRETCH:             METHOD CHOP:
METHOD REMOVE:              METHOD INSERT:
METHOD PRINT.ELEMENT:       METHOD PRINT.DIMENSION:
METHOD SET.MANY:            METHOD EXECUTE:
METHOD MAX.ELEMENTS:        METHOD MOVE:
METHOD MANYLEFT:            METHOD I2ADDR:
METHOD DUMP.SOURCE:         METHOD DUMP.ELEMENT:
METHOD BACKWARD:            METHOD FOREWARD:
METHOD FILL.DIM:            METHOD DO:
METHOD SPLIT:               METHOD SMEAR:
METHOD COPY:
METHOD GOTO:                METHOD WHERE:
METHOD NEXTWRAP:

\ Variables to avoid stack dancing in elmnts methods
U: ZZEL1
U: ZZEL2
U: ZZEL3
U: ZZEL4
U: ZZEL5

( OB.ELMNTS CLASS )
( This object has an array of "elements" where an element is )
( a set of values.  It is equivalent to a 2 dimensional list. )
( Each row can be considered an element. )
( This can also be considered as a set of multidimensional points)
:CLASS OB.ELMNTS   <SUPER OB.ARRAY
	IV.LONG IV-DIMENSION   ( number of columns )
	IV.LONG IV-#ELEMENTS ( maximum number of data elements )
	IV.LONG IV-MANY     ( Count of elements with data in them )
	IV.LONG IV-CURRENT  ( Current element pointer )

:M RESET:     ( -- , Reset pointers )
	0 iv=> iv-current
;M

:M EMPTY:  ( -- , set to no valid data condition )
	reset: self
	0 iv=> iv-many
;M

:M CLEAR:  (  -- , clear data and reset pointers  )
	clear: super
	empty: self
;M

:M INIT:  (  --  )
	init: super
	reset: self
	0 iv=> iv-dimension
	0 iv=> iv-#elements
	0 iv=> iv-many
;M

:M FREE: ( -- , clear some ivars )
	free: super
	0 iv=> iv-#elements
	0 iv=> iv-dimension
;M

:M ?NEW:  ( maxindex #dimensions -- addr | 0, allocate data space )
	2dup *  ?new: super >r
	iv=> iv-dimension
	iv=> iv-#elements   ( for keeping track of max data elements )
	r>
;M

:M NEW: ( #cells -- , abort if error )
	?new: self <new:error>
;M

:M ED2I: ( element# dimension# -- index , calculate  index)
	swap iv-dimension  *  +
;M

:M I2ED: ( index -- element# dimension# )
	iv-dimension  /mod swap
;M

\ This is not really fast but is still useful.
:M I2ADDR: ( index -- address , calculate address of item )
	iv-width * iv-pntr +
;M

:M ED.AT:  ( e# d# -- value , fetch value from shape )
	ed2i: self  at.self
;M

:M ED.TO:  ( value e# d# -- , store value in shape )
	ed2i: self  to.self
;M

:M DIMENSION:    ( -- #dimensions , return # of dimensions )
	iv-dimension
;M

:M MAX.ELEMENTS:   ( -- max , max number of elements allowed )
	iv-#elements
;M

\ PUT: and GET: have been optimized at the expense of elegance.
\ This stores into an entire element (or row).
\ The number of data items must match the number of dimensions.
:M PUT:   ( V1 V2 V3 ... VN E# -- , Put values in e#)
	1+ iv-dimension ?dup
	IF  dup>r *  ( Calculate index of last value + 1 )
		r> 0
		?DO   ( For all values )
			1- tuck to.self
		LOOP drop
	ELSE
		" PUT: OB.ELMNTS"  " No memory allocated!"
		er_fatal ob.report.error
	THEN
;M

:M GET:   ( E# -- V1 V2 V3 ... VN   , Get values from e#)
	iv-dimension dup>r *  ( Calculate index of first value )
	dup r> + swap
	?DO   ( For all values )
		i at.self
	LOOP
;M

:M ADD:  (  v1 v2 ... vn -- , add element to end )
	iv-many   put: self
	1 iv+> iv-many
;M

:M FIRST:  (  -- v1 v2 ... vn , return 1st element & setpntr=1)
	0 get: self
	1 iv=> iv-current
;M

:M LAST:  ( -- v1 ... vn , return last element & set pointer )
	iv-many  dup iv=> iv-current
	1- get: self
;M

:M MANY: ( -- N , Number of elements with valid data )
	iv-many
;M

:M SIZE:  (  -- size , return number of single values  )
	iv-many   dimension: self *
;M

:M MANYLEFT:  ( -- N , # elements remaining after current )
	iv-many iv-current  -
;M

:M CURRENT:  ( -- VAL , Fetch current value )
	iv-current
	dup 1+ iv-many  >
	IF
		" CURRENT: OB.ELMNTS"  " Past end of list!"
		er_fatal ob.report.error
	THEN    get: self
;M

:M NEXT:  ( -- v1 v2 ... vn , return next element and inc pntr)
	iv-current get: self
	1 iv+> iv-current
;M

:M NEXTWRAP:  ( -- v1 v2 ... vn , wrap if at end )
	iv-current get: self
	iv-current 1+ dup iv-many >=
	IF drop 0
	THEN iv=> iv-current
;M

:M CHECK.UNDER: ( #sub -- underflow? , true if trying to remove too many)
	iv-many >
;M

:M CHECK.OVER: ( #add -- overflow? , true if danger of overflow )
	iv-many +  max.elements: self >
;M

:M MOVE: ( from to count -- , move elements up or down )
	?dup
	IF  iv-width *  iv-dimension * >r ( number of bytes )
		0 ed2i: self i2addr: self swap
		0 ed2i: self i2addr: self swap
		r> move
	ELSE 2drop
	THEN
;M


:M SPLIT: ( start count -- , push data up )
	zzel5 ! zzel4 !       ( avoid stack dancing )
	zzel5 @ check.over: self
	IF  " SPLIT: OB.ELMNTS" " Too many elements"
		er_return ob.report.error
	ELSE
		zzel4 @ iv-many <
		IF	zzel4 @ iv-current  <
			IF    zzel5 @ iv+> iv-current
			THEN
			zzel5 @ iv+> iv-many
\
\ Push others up.
			zzel4 @ ( -- from )
			dup zzel5 @ + ( -- from to )
			iv-many 1 pick - ( -- from to count )
			move: self
		ELSE
			" SPLIT: OB.ELMNTS" " Past last element."
			er_return ob.report.error
		THEN
	THEN
;M

:M SMEAR: ( start count -- , copy one element up over others )
	over + 1+ over 1+
	?DO dup get: self
		i put: self
	LOOP drop
;M

:M STRETCH: ( start count -- , copy element at start up, pushing others)
	over 1+ iv-many <
	IF
		over 1+ over split: self
	ELSE dup iv+> iv-many
	THEN
	smear: self
;M

:M INSERT:  ( v1 v2 ...vn index  -- ,insert and expand )
	1 check.over: self
	IF  " INSERT: OB.ELMNTS" " Too many elements"
		er_return ob.report.error
		put: self bell
	ELSE
		dup iv-current  <  ( -- v1-n index flag )
		IF 1 iv+> iv-current THEN  ( Adjust pointer )
		dup iv-many <  ( move if any higher data )
		IF ( -- v1-n index )
			dup dup 1+ over iv-many swap - ( v1-n index from to count)
			move: self
		THEN ( v1-n index )
		1 iv+> iv-many
		put: self   ( put in new element )
	THEN
;M

:M CHOP: ( start count -- , remove a chunk )
	2dup zzel5 ! zzel4 !       ( avoid stack dancing )
	+ check.under: self
	IF
		cr ZZEL4 @ .  ZZEL5 @ .
		" CHOP: OB.ELMNTS" " Not enough elements"
		er_return ob.report.error
	ELSE
		zzel4 @ iv-current  <
		IF    iv-current  zzel5 @ -
			zzel4 @ max iv=> iv-current
		THEN
		zzel5 @ negate iv+> iv-many

\ Pull others down.
		zzel4 @ zzel5 @ + ( from )
		zzel4 @   ( from to )
		iv-many zzel4 @ - move: self
	THEN
;M

:M REMOVE:  ( index  -- , remove and compress  )
	1 chop: self
;M

:M FILL.DIM:    ( value d# -- , fill a dimension with a value )
	iv-many ?dup
	IF  0 DO
			2dup i swap ed.to: self
		LOOP 2drop
	ELSE 2drop " FILL.DIM:" " Empty object!"
		er_return ob.report.error
	THEN
;M

:M PRINT.ELEMENT:  ( E# -- , Print an element )
	dimension: self 0 ?DO
		dup i ed.at: self 7 .r space
	LOOP  drop
;M

:M PRINT.DIMENSION:  ( D# -- , PRINT A COLUMN )
	cr iv-many 0 ?DO
		i .   i over ed.at: self 8 .r  cr
	LOOP drop
;M

:M PRINT:   ( -- , Print the elements of a shape )
	cr name: self cr
	." ELMT\DIM " dimension: self 0 ?DO i  8 .r LOOP cr
	iv-many dup
	IF  0
		DO   ( Use late binding for each element to allow mods)
			i 6 .r  4 spaces
			i self print.element: [] cr
			?pause
		LOOP
	ELSE drop ."   No Data!!" cr
	THEN
;M

:M SET.MANY: ( many -- , force add of elements )
	dup 0 iv-#elements within?
	IF iv=> iv-many
	ELSE . " SET.MANY:" " MANY outside range!"
		er_fatal ob.report.error
	THEN
;M

:M DUMP.ELEMENT: ( e# -- , print source for one element )
	self print.element: []
	."  add: " name: self cr
;M

:M DUMP.SOURCE: ( -- , Print source code to recreate object. )
	iv-pntr  ( check for data )
\ Write NEW: for object.
	IF  cr tab iv-#elements .  iv-dimension .
		."  new: " name: self cr
\ Rcreate individual elements.
		iv-many 0
		?DO  i self dump.element: []
		LOOP cr
	THEN
;M

:M FOREWARD: ( -- , advance read pointer by one )
	1 iv+> iv-current
;M
:M BACKWARD: ( -- , move read pointer back by one )
	-1 iv+> iv-current
;M

:M GOTO: ( index -- , set data cursor)
	iv=> iv-current
;M

:M WHERE: ( -- index , where is data cursor? )
	iv-current
;M

:M EXTEND:  ( #elements -- , extend array area )
	dup iv+> iv-#elements  ( new # elements )
	iv-dimension *  ( #cells to add )
	extend: super
;M

:M DO: ( function_cfa -- , pass each element to function )
	iv-many 0
	?DO ( don't DUP>R before I for some Forths )
		i over >r get: self r> execute
	LOOP drop
;M

:M COPY: ( start target count target-object -- , copy data to it )
	zzel4 ! ( target-object )
	zzel3 ! ( count )
	zzel2 ! ( target elmnt# )
	zzel1 ! ( start elmnt# )
	zzel1 @ 0 ed2i: self i2addr: self   ( source address )
	zzel2 @ 0 zzel4 @ ed2i: [] dup>r    ( target unit # )
	zzel4 @ i2addr: []                  ( target address )
	zzel3 @ dimension: self * width: self *  ( #bytes to move )
	zzel4 @ limit: [] ( max target unit # )
	r> - zzel4 @ width: [] *
	over <
	IF . . .
		" COPY: OB.ELMNTS" " Not enough room in target!"
		er_fatal ob.report.error
	ELSE
		move
	THEN
;M

:M }STUFF:  ( stuff... -- , stuff data and set many )
	iv-pntr
	IF  stuff.depth dimension: self / >r
		<}stuff:>
		r> set.many: self
	ELSE cr ." Must be NEW:ed before }STUFF:" cr abort
	THEN
;M

;CLASS

METHOD DELETE:
METHOD 0STUFF:

: 0DEPTH ( 0 ? ? ? -- N | -1, 'pick' position of first 0)
	-1 ( default count )
	depth 1
	?DO  i pick 0=
		IF drop i 1- leave
		THEN
	LOOP
;

\ OB.LIST  ------------------------------------------------
\ This class is currently implemented as a one dimensional
\ OB.ELMNTS array.  Eventually it should be a linked list.

:CLASS OB.LIST  <SUPER OB.ELMNTS

:M ?NEW:  ( Max_elements -- addr | 0 )
	1 ?NEW: SUPER   ( declare as one dimensional )
;M

:M NEW: ( max_elements -- , abort if error )
	?new: self <new:error>
;M

:M DUMP.SOURCE: ( -- , Print source code to recreate object. )
	iv-pntr  ( check for data )
\ Write NEW: for object.
	IF  cr tab iv-#elements . ."  new: " name: self cr
\ Rcreate individual elements.
		many: self 0
		?DO  i self dump.element: []
		LOOP cr
	THEN
;M

:M DELETE: ( value -- , delete that value from list )
	indexof: self
	IF  remove: self
	THEN
;M

\ Define as colon definition so it can be inherited
\ by other classes not derived from LIST.
: <0STUFF:> ( 0 m0 m1 ... mN -- , easy build of object list)
\ Scan For 0 to count objects.
	0DEPTH
	dup 0>
	IF  dup self new: []  ( 0 m0 m1 ... mN N -- )
		dup self set.many: []
		dup 0
		?DO 1- tuck self put: []
		LOOP
		2drop
	ELSE
		0< IF " 0STUFF:" " 0 required before object list!"
			er_fatal ob.report.error
		ELSE drop
		THEN
	THEN
;

:M 0STUFF: ( 0 m0 m1 ... mN -- , easy build of list )
	<0stuff:>
;M

:M }STUFF:  ( stuff...  --- , load it into object )
	stuff.depth >r
		<}stuff:>
	r> set.many: self
;M

;CLASS


METHOD FREEALL:
METHOD ?INSTANTIATE:
METHOD DEINSTANTIATE:

:CLASS OB.OBJLIST <SUPER OB.LIST

:M PRINT.ELEMENT: ( E# -- , PRINT OBJECT INFO )
	get: self dup name: []  tab  .class: []
;M

:M DUMP.ELEMENT: ( E# -- , PRINT OBJECT INFO )
	tab get: self name: []  ."  add: " name: self CR
;M

:M FREEALL: ( -- , Send free: message to all members. )
	many: self dup 0>
	IF  0 DO
		i get: self free: []
	LOOP
	ELSE drop
	THEN
;M

:M DEINSTANTIATE:
	many: self 0
	?DO
		i get: self deinstantiate
	LOOP
	free: self
;M

:M ?INSTANTIATE: ( class_cfa many -- class_pfa | 0 )
	>r >body r>  \ need pfa for instantiate
	dup ?new: self \ 00001
	IF
		0
		?DO
			dup <?instantiate> ?dup
			IF
				add: self
			ELSE
				self deinstantiate: []
				drop 0 LEAVE
			THEN
		LOOP
	ELSE
		2drop 0
	THEN
;M

;CLASS

\ For testing.
if-testing @ [IF]
ob.elmnts ELM1
: BUILD.ELM1
	10 2 new: elm1
	0  0 add: elm1
	1 11 add: elm1
	2 22 add: elm1
	3 33 add: elm1
	4 44 add: elm1
	5 55 add: elm1
;
: P1 print: elm1 ;
OB.ELMNTS ELM2
: P2 print: elm2 ;

[THEN]

