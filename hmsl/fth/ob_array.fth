\ @(#) ob_array.fth 96/06/11 1.1
\ Basic Classes of Array.
\
\ Author: Phil Burk
\ Copyright 1986 Delta Research
\
\ MOD: PLB 5/17/91 Split OBJ_ARRAY into OBJ_OBJECT & OBJ_ARRAY
\ 00001 PLB 8/27/91 Fixed }stuff when filling completely.

ANEW TASK-OB_ARRAY.FTH


\ Support ARRAY classes ----------------------------------
METHOD AT:              METHOD TO:
METHOD NEW:             METHOD LIMIT:
METHOD FREE:            METHOD WIDTH:
METHOD RANGE:           METHOD FILL:
METHOD SIZE:            METHOD USE.DICT:
METHOD DATA.ADDR:       METHOD STUFF:
METHOD INDEXOF:         METHOD +TO:
METHOD SET.WIDTH:       METHOD DO.RANGE:
METHOD EXTEND:          METHOD EMPTY:
METHOD }STUFF:			METHOD MANY:
METHOD ?NEW:

U: IF-RANGE-CHECK  ( Use range checking on declared arrays )
TRUE IF-RANGE-CHECK !

: RUN.FASTER  ( -- , set flags to NOT error check. )
	false if-range-check !
	false ob-if-check-bind !
;
: RUN.SAFER  ( -- , set flags to error check. )
	true if-range-check !
	true ob-if-check-bind !
;

\ Byte array definition.
:CLASS OB.BARRAY  <SUPER OBJECT
	IV.SHORT IV-WIDTH    ( width of cell in bytes )
	IV.LONG  IV-#CELLS   ( elements in array )
	IV.LONG  IV-PNTR     ( pointer to area in extended memory )
\ flag for whether to allocate space from dictionary or heap
	IV.SHORT IV-USE-DICT
\ CFAS for use in basic array access, determine width.
	IV.LONG  IV-AR-CFA-AT
	IV.LONG  IV-AR-CFA-TO
	IV.SHORT IV-RANGE-CHECK?   ( Flag for range checking. )

\ Define @ and ! for different array widths.
: AR.@ ( index -- value )
	cell* iv-pntr + @
;
: AR.W@ ( index -- value )
	2* iv-pntr + w@
;
: AR.C@ ( index -- value )
	iv-pntr + c@
;

: AR.! ( value index -- )
	cell* iv-pntr + !
;
: AR.W! ( value index -- )
	2* iv-pntr + w!
;
: AR.C! ( value index -- )
	iv-pntr + c!
;

: <RANGE:>  ( index -- , check for valid range, make subroutine for speed )
	dup 0 iv-#cells 1- within?
	IF drop ( OK )
	ELSE >newline dup . 0 <
		IF   " Index < 0"
		ELSE " Index out of range"
		THEN " RANGE: ARRAY" swap
		er_fatal ob.report.error  ( does not return )
	THEN
;

:M RANGE: ( index -- , check for index out of range )
	<range:>
;M

\ Define with range checking for debugging and testing.
: AR.RANGE.@ ( index -- value )
	dup <range:>   ar.@
;
: AR.RANGE.W@ ( index -- value )
	dup <range:>   ar.w@
;
: AR.RANGE.C@ ( index -- value )
	dup <range:>   ar.c@
;

: AR.RANGE.! ( value index -- )
	dup <range:>   ar.!
;
: AR.RANGE.W! ( value index -- )
	dup <range:>   ar.w!
;
: AR.RANGE.C! ( value index -- )
	dup <range:>   ar.c!
;


:M USE.DICT:   ( flag -- , use dictionary for data? )
	iv=> iv-use-dict
;M

:M FREE: ( -- , free memory used for array )
	iv-pntr    iv-use-dict  not
	and IF
		self empty: []   ( late bound empty )
		iv-pntr  mm.free
		0 iv=> iv-pntr  ( mark as unallocated )
		0 iv=> iv-#cells  ( for range checking )
	THEN
;M


:M DATA.ADDR: ( -- address_of_allocated_data )
	iv-pntr
;M

:M LIMIT: ( -- #cells , RETURN # ELEMENTS ALLOCATED )
	iv-#cells
;M

:M SIZE:  ( -- #ENTRIES , will be used more for later classes )
	iv-#cells
;M

:M MANY:  ( -- , how many cells are "valid" )
	iv-#cells
;M

\ Fast versions for internal use by methods.
: TO.SELF  ( value index -- , store value in array )
	iv-ar-cfa-to execute
;
: AT.SELF ( index -- value , fetch value from array )
	iv-ar-cfa-at execute
;

:M TO: ( value index -- , store value in array )
	iv-ar-cfa-to execute
;M

:M AT: ( index -- value , fetch value from array )
	iv-ar-cfa-at execute
;M

: AR.SELECT.CFA  ( Select CFAs based on width and range_check. )
	iv-range-check?
	IF iv-width         ( WITH Range checking )
		CASE
		cell OF 'c ar.range.@ iv=> iv-ar-cfa-at
			'c ar.range.! iv=> iv-ar-cfa-to
		ENDOF
	2    OF 'c ar.range.w@ iv=> iv-ar-cfa-at
		'c ar.range.w! iv=> iv-ar-cfa-to
	ENDOF
	1    OF 'c ar.range.c@ iv=> iv-ar-cfa-at
		'c ar.range.c! iv=> iv-ar-cfa-to
	ENDOF
	" AR.SELECT.RANGE" " Illegal array width!"
	er_fatal ob.report.error
	ENDCASE
	ELSE iv-width         ( NO range checking. )
		CASE
		cell OF 'c ar.@ iv=> iv-ar-cfa-at
			'c ar.! iv=> iv-ar-cfa-to
		ENDOF
	2    OF 'c ar.w@ iv=> iv-ar-cfa-at
		'c ar.w! iv=> iv-ar-cfa-to
	ENDOF
	1    OF 'c ar.c@ iv=> iv-ar-cfa-at
		'c ar.c! iv=> iv-ar-cfa-to
	ENDOF
	" AR.SELECT.RANGE" " Illegal array width!"
	er_fatal ob.report.error
	ENDCASE
	THEN
;

:M DO.RANGE: ( flag -- , Determine whether this array checks range)
	iv=> iv-range-check?
	ar.select.cfa
;M

:M WIDTH: ( -- #bytes , fetch number of bytes per array unit )
	iv-width
;M

:M SET.WIDTH: ( #bytes -- , set number of bytes per array unit )
	iv-pntr  ( is data memory already allocated )
	IF  " SET.WIDTH: OB.ARRAY"
		" Memory already allocated, FREE: first!"
		er_return er.report drop
	ELSE iv=> iv-width   ( set width )
		ar.select.cfa   ( change CFAs )
	THEN
;M

:M ?NEW: ( #cells -- addr | 0 , allocate data space in extended memory )
	ar.select.cfa   ( update CFAs )
	self free: []  ( free any existing data , late bound )
	dup iv=> iv-#cells
	iv-width  *  ( calculate #bytes needed )
	iv-use-dict  IF
		." Allocating space in dictionary!!"
		here swap allot align
	ELSE
		mm.zalloc?
	THEN
	dup iv=> iv-pntr
;M

: <NEW:ERROR> ( 0 | addr -- ,  ABORT if error )
	0= IF " NEW:" " Not enough memory"
		er_fatal ob.report.error
	THEN
;

:M NEW: ( #cells -- , abort if error )
	?new: self <new:error>
;M

:M INIT: ( -- , clear data )
	init: super
	0 iv=> iv-#cells
	0 iv=> iv-pntr
	false use.dict: self
	if-range-check @ iv=> iv-range-check? ( do before SET.WIDTH: )
	1 set.width: self   ( 1 byte wide )
;M

:M +TO: ( value index -- , add value to index cell )
	dup at.self rot +
	swap to.self
;M

:M FILL: ( val -- , fill array with value )
	limit: self ?dup
	IF  0 DO
		dup i to.self
	LOOP drop
	ELSE drop " FILL:" " No data space allocated"
		er_return ob.report.error
	THEN
;M

:M CLEAR:  ( -- , zero array )
	0 fill: self
;M

:M EMPTY:  ( -- , just a stub for free: to call )
;M

\ This is klunky is considered obsolete
:M STUFF:  ( vn-1 vn-2 ... v0 N -- , stuff N values into array )
	0 ?DO
		i self to: []
	LOOP
;M

:M INDEXOF:  (  val  --  [index] flag , search array for )
	0 swap  ( Set false flag. )
	self size: [] ?dup    ( anything in array? )
	IF  ( -- 0 val size )
		0 DO  ( -- 0 val )
			I  at.self over =
			IF  ( -- 0 val , replace false flag )
				nip I true
				rot   leave  ( -- i true val )
			THEN
		LOOP
	THEN
	drop  ( val )
;M

:M PRINT: ( -- , print array )
	cr name: self cr
	self  size: [] ?dup
	IF  0 DO
		i dup . self at: [] . cr
		?pause
	LOOP
	THEN
;M

:M EXTEND: ( #items -- , extend data area )
	iv-pntr
	IF  >r iv-pntr dup ( -- old-memory old-memory )
		iv-#cells iv-width * ( -- om om  old-#bytes )
		r> iv+> iv-#cells    ( update #cells )
		iv-#cells iv-width * mm.alloc ( allocate new area )
		dup iv=> iv-pntr
		swap cmove  ( copy old data to new area )
		mm.free     ( free old ram )
	ELSE new: self
	THEN
;M

variable STUFF{-DEPTH

: STUFF{ ( -- , delimit stuff command , save depth )
	depth stuff{-depth !
;

: STUFF.DEPTH  ( -- #items , to stuff )
	depth stuff{-depth @ - 0 max
;

: <}STUFF:>  ( stuff...  --- , load it into object )
\    iv-#cells stuff.depth < ( !!! stuff.depth thrown off by IV-#CELLS )
	stuff.depth iv-#cells >  \ 00001
	IF   stuff.depth self new: []
	ELSE  self clear: []
	THEN
\
	stuff.depth dup stuff{-depth ! dup 0
	?DO 1- tuck ( --... t t tn-2 n-1 tn-1 n-1 ) self to: []
	LOOP stuff{-depth !
;

:M }STUFF:  ( stuff...  --- , load it into object )
	<}stuff:>
;M

;CLASS


\ Wider ARRAYS -----------------------------------------------

:CLASS OB.WARRAY <SUPER OB.BARRAY

:M INIT:  ( -- , set to word width  )
	init: super
	2 set.width: self
;M

;CLASS

METHOD EXEC:

:CLASS OB.ARRAY <SUPER OB.BARRAY

:M INIT:  ( -- , set to cell width )
	init: super
	cell set.width: self
;M

:M EXEC:  ( index -- , execute CFA there )
	at: self   execute
;M
;CLASS

