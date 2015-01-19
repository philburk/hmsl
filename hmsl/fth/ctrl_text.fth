\ Text Input Control
\ Define a grid of text input items.
\
\ Author: Phil Burk
\ Copyright 1991 Phil Burk
\
\ 00001 PLB 2/6/92 Use EXEC.STACK?

ANEW TASK-CTRL_TEXT.FTH
decimal

\ -----------------------------------------------
: $INSERT.CHAR { char cursor $string -- }
\
\ check for string overflow
	$string c@ 255 = abort" $INSERT.CHAR - string is full!"
\
\ check for past end
	$string c@ cursor
	< abort" $INSERT.CHAR - cursor past end of string!"
\
\ move characters up
	$string c@ cursor >
	IF
		$string 1+ cursor + \ source
		dup 1+ \ dest
		$string c@ cursor - \ many
		move
	THEN
\
\ put in character
	char $string 1+ cursor + c!
\
\ increment count
	$string c@ 1+ $string c!
;

: $REMOVE.CHAR { cursor $string -- }
\ check for past end
	$string c@ cursor
	< abort" $REMOVE.CHAR - cursor past end of string!"
\
\ move characters down
	cursor 0>
	IF
		$string 1+ cursor + \ source
		dup 1- \ dest
		$string c@ cursor - \ many
		move
\
\ decrement count
		$string c@ 1- $string c!
	THEN
;

: $CHOP.RANGE { start end $string -- }
\ check for past end
	$string c@ start end max
	< abort" $CHOP.RANGE - cursor past end of string!"
\
\ move characters down
	end 0>
	IF
		$string 1+ end + \ source
		$string 1+ start + \ dest
		$string c@ end - \ many
		move
\
\ decrement count
		$string c@ end start - - $string c!
	THEN
;

\ -----------------------------------------------
\ One Line Text Editing Control

METHOD PUT.CR.FUNCTION:
METHOD GET.CR.FUNCTION:
METHOD PUT.FILTER.FUNCTION:
METHOD GET.FILTER.FUNCTION:
METHOD PUT.LEAVE.FUNCTION:
METHOD GET.LEAVE.FUNCTION:
METHOD PUT.JUSTIFY:
METHOD GET.JUSTIFY:

0 value CG_TXED_START
0 value CG_TXED_END
0 value CG_TXED_ANCHOR
0 value CG_TXED_LAST
0 value CG_TXED_PART  \ currently highlighted part

:CLASS OB.TEXT.GRID <SUPER OB.CONTROL.GRID
	iv.long  IV-CG-TEXT-CR-CFA
	iv.long  IV-CG-TEXT-FILTER-CFA
	iv.long  IV-CG-TEXT-LEAVE-CFA
	iv.short IV-CG-TEXT-MAX  \ maximum number of characters in string
	iv.short IV-CG-TEXT-JUST  \ 0,1,2 for left,center,right justify
	ob.barray IV-CG-TEXT-BUF  \ contains N Forth strings

:M PUT.CR.FUNCTION: ( cfa -- )
	iv=> iv-cg-text-cr-cfa
;M

:M GET.CR.FUNCTION: ( -- cfa )
	iv-cg-text-cr-cfa
;M

:M PUT.FILTER.FUNCTION: ( cfa -- )
	iv=> iv-cg-text-filter-cfa
;M

:M GET.FILTER.FUNCTION: ( -- cfa )
	iv-cg-text-filter-cfa
;M

:M PUT.LEAVE.FUNCTION: ( cfa -- )
	iv=> iv-cg-text-leave-cfa
;M

:M GET.LEAVE.FUNCTION: ( -- cfa )
	iv-cg-text-leave-cfa
;M


:M PUT.JUSTIFY: ( justification -- )
	iv=> iv-cg-text-just
;M

:M GET.JUSTIFY: ( -- justification )
	iv-cg-text-just
;M

:M GET.TEXT: ( part -- $text )
	iv-cg-text-max 1+ * data.addr: iv-cg-text-buf +
;M

: CT.CUR.TEXT ( -- $text )
	cg_txed_part get.text: self
;

:M PUT.TEXT: ( $text part -- )
	over c@ iv-cg-text-max >
	IF
		. $type ." too long in PUT.TEXT: " name: self cr
	ELSE
		0 -> cg_txed_start \ highlight entire text
		over c@ -> cg_txed_end
		get.text: self $move
	THEN
;M

:M GET.VALUE: ( part -- n )
	get.text: self number?
	IF
		drop
	ELSE
		." Invalid number in " name: self cr
		0 \ have to return something !
	THEN
;M

:M PUT.VALUE: ( n part -- )
	get.text: self >r
	n>text ( addr count )
	dup r@ c!
	r> 1+ swap cmove
;M

:M INIT:
	init: super
	0 iv=> iv-cg-text-max
	0 iv=> iv-cg-text-cr-cfa
	0 iv=> iv-cg-text-filter-cfa
;M

:M NEW: ( numx numy numchars -- )
	>r 2dup .s new: super
	* r> dup iv=> iv-cg-text-max  \ remember new: calls SELF FREE: []
	1+ * new: iv-cg-text-buf
	clear: iv-cg-text-buf
;M

:M FREE:
	free: super
	free: iv-cg-text-buf
	0 iv=> iv-cg-text-max
;M

3 value CT_TEXT_DESCENT

: CT.PART>XY { part | x1 y1 x2 y2 -- x y }
	part get.rect: self -> y2 -> x2 -> y1 -> x1
	iv-cg-text-just
	CASE
		0 OF x1 2+ y2 ct_text_descent - ENDOF
		1 OF x2 x1 + 2/  \ center
			part get.text: self count gr.textlen 2/ -
			y2 ct_text_descent -
		ENDOF
		2 OF x2 4 -
			part get.text: self count gr.textlen -
			y2 ct_text_descent -
		ENDOF
	ENDCASE
;

: CT.BASE.XY ( -- x y )
	cg_txed_part ct.part>xy
;

: CT.INDEX>XY  ( index -- x y )
	ct.cur.text 1+ swap gr.textlen
	ct.base.xy >r + r>
;

: IN.RECT? { mx my x1 y1 x2 y2 -- in_rectangle? }
	mx x1 x2 within? dup
	IF
		drop
		my y1 y2 within?
	THEN
;

: CT.XY>INDEX { mx my | indx x1 y1 x2 y2 -- indx true | false }
	cg_txed_part get.rect: self -> y2 -> x2 -> y1 -> x1
	my y1 y2 within?
	IF
		mx ct.base.xy drop - -> mx  \ offset from first char
\ scan all characters in case we have a proportional font
		ct.cur.text c@   dup -> indx   0
		?DO
			ct.cur.text 1+ i 1+ gr.textlen
			mx >
			IF
			i -> indx
				LEAVE
			THEN
		LOOP
		indx true
	ELSE
		FALSE
	THEN
;

: CT.HIGHLIGHT ( -- , highlight selected region )
	gr.mode@
	gr.color@
	cg_txed_start ct.index>xy gr.height@ -
	cg_txed_end ct.index>xy ( -- x1 y1 x2 y2 )
\
\ force minimum width of 3 pixels
	>r 2 pick 3 + max r>
\
\ draw in XOR mode
	gr_xor_mode gr.mode!
	gr_white gr.color!
	gr.rect
	
	gr.color!
	gr.mode!
;

:M DRAW.PART: ( part -- )
	dup clear.part: self
	dup ct.part>xy gr.move
	dup get.text: self  gr.text
	iv-cg-active
	IF
		dup cg_txed_part =
		IF ct.highlight
		THEN
	THEN
	drop
;M

: CT.CHOP ( -- , chop selected range )
	cg_txed_start cg_txed_end
	2dup -
	IF
		ct.cur.text $chop.range
		cg_txed_start -> cg_txed_end
	ELSE
		2drop
	THEN
;

: CT.DELETE ( -- , delete char in front of cursor )
	cg_txed_start cg_txed_end
	2dup -
	IF
		ct.cur.text $chop.range
	ELSE
		\ no text range selected
		drop 1+ dup ct.cur.text c@ <=  \ before end?
		IF
			ct.cur.text  $remove.char
		ELSE drop
		THEN
	THEN
	cg_txed_start -> cg_txed_end
;

: CT.BACKSPACE ( -- )
	cg_txed_start cg_txed_end
	2dup -
	IF
		ct.cur.text $chop.range
		cg_txed_start -> cg_txed_end
	ELSE
		\ no text range selected
		drop
		ct.cur.text  $remove.char
		cg_txed_start 1- 0 max
		dup -> cg_txed_start -> cg_txed_end
	THEN
;

: CT.INSERT { char | xl xr x1 x2 -- }
	ct.chop
	ct.cur.text c@ iv-cg-text-max <
	IF 
		char cg_txed_start ct.cur.text  $insert.char
		cg_txed_start 1+
		dup -> cg_txed_start -> cg_txed_end
\
\ check for past end of box
		ct.base.xy drop -> xl \ start of text
		xl ct.cur.text count gr.textlen + -> xr \ end of text
		cg_txed_part get.rect: self drop -> x2 drop -> x1
		xL x1 x2 within? not  \ left edge outside box ?
		xR x1 x2 within? not OR \ right edge outside box ?
		IF
			ct.backspace beep
		THEN
	THEN
;

: CT.LEFT ( -- , move cursor one to left )
	cg_txed_start 1- 0 max -> cg_txed_start
	cg_txed_start -> cg_txed_end
;
: CT.RIGHT ( -- , move cursor one to right )
	cg_txed_start 1+ ct.cur.text c@ min -> cg_txed_start
	cg_txed_start -> cg_txed_end
;

: CT.SHIFT.LEFT ( -- , move cursor fully to left )
	0 dup -> cg_txed_start
	-> cg_txed_end
;
: CT.SHIFT.RIGHT ( -- , move cursor fully to right )
	ct.cur.text c@ dup -> cg_txed_start
	-> cg_txed_end
;

$ 7F constant DELETE_CHAR

: CT.DO.KEY { character | redraw? -- , do editing based on char }
	true -> redraw?
	ct.highlight
	character
	CASE
\
		character isprint
		?OF character ct.insert
		ENDOF
\
		8
		OF ct.backspace
		ENDOF
\
		delete_char
		OF ct.delete
		ENDOF
\
		left_arrow OF ct.left ENDOF
		right_arrow OF ct.right ENDOF
		shift_left_arrow OF ct.shift.left ENDOF
		shift_right_arrow OF ct.shift.right ENDOF
\
		$ 0D \ carriage return
		OF 
			iv-cg-text-cr-cfa ?dup
			IF	>r ct.cur.text cg_txed_part r>
				-2 exec.stack?
			THEN
			false -> redraw?
		ENDOF
	ENDCASE
	redraw?
	IF
		cg_txed_part draw.part: self
	THEN
;

:M KEY: ( character -- )
\ decide whether this is an OK character
	iv-cg-text-filter-cfa ?dup
	IF >r dup r> 0 exec.stack?
	ELSE true
	THEN  ( char ok? )
\
	IF
		ct.do.key
	ELSE
		drop beep
	THEN
;M

: CT.DO.LEAVE ( n -- , execute LEAVE function )
	iv-cg-text-leave-cfa ?dup
	IF	>r dup get.text: self  swap r>
		-2 exec.stack?
	ELSE drop
	THEN
;

: CT.UPDATE.STATUS ( -- update control variables )
	iv-cg-lasthit -> cg_txed_part
	cg-first-mx @ cg-first-my @ ct.xy>index not
	IF 0
	THEN
	dup -> cg_txed_end
	dup -> cg_txed_start
	dup -> cg_txed_anchor
	-> cg_txed_last
;

:M PUT.ACTIVE: ( flag -- , make selected, handle highlighting )
	depth 1- >r
\ turn off current highlighting if any
	iv-cg-drawn iv-cg-active and
	IF
		ct.highlight
		cg_txed_part ct.do.leave
	THEN
\
	dup put.active: super
\
\ change select and highlighting info
	IF
		ct.update.status
\
\ highlight if now active
		iv-cg-drawn
		IF
			ct.highlight
		THEN
\
\ no part currently active
	ELSE
		-1 -> cg_txed_part
	THEN
	depth r> - abort" MOUSE.DOWN: - stack change!"
;M

:M MOUSE.DOWN: ( x y -- trapped? )
	depth 1- >r
	mouse.down: super
\
\ If the same control is still active, but we have moved to
\ a new part, then call LEAVE.FUNCTION
	dup
	IF
		iv-cg-active
		IF
			cg_txed_part iv-cg-lasthit = not
			IF
				cg_txed_part ct.do.leave
			THEN
\
\ we know we are active so change highlighting
			iv-cg-drawn
			IF
				ct.highlight
				ct.update.status
				ct.highlight
			THEN
		THEN
	THEN
\
	ev.track.on
	depth r> - abort" MOUSE.DOWN: - stack change!"
;M

:M MOUSE.MOVE:  ( x y -- )
	2dup mouse.move: super
	ct.xy>index
	IF
		dup cg_txed_last - \ has the index changed, prevent flicker
		IF
			ct.highlight
			dup -> cg_txed_last 
			cg_txed_anchor 2sort
			-> cg_txed_end -> cg_txed_start
			ct.highlight
		ELSE drop
		THEN
	THEN
;M

:M MOUSE.UP:  ( x y -- )
	mouse.up: super
	ev.track.off
;M

:M PRINT: ( -- )
	print: super
	many: self 0
	?DO
		i . i get.text: self $type cr
	LOOP
;M

;CLASS


: CT.FILTER.NUMERIC  ( char -- ok? , filter characters for number )
	>r
	r@ isdigit
	r@ ascii . = OR
	r@ ascii , = OR
	r@ ascii - = cg_txed_start 0= AND OR
	r@ toupper ascii E = OR
	r@ isprint not OR
	rdrop
;

: CT.FILTER.NOTE ( key -- ok? )
	>r
	r@ isprint not
	r@ tolower ascii a ascii g within? OR
	r@ tolower ascii # = OR
	r@ isdigit OR
	rdrop
;


false [IF]

OB.TEXT.GRID CT1
OB.TEXT.GRID CT2
OB.MENU.GRID RG1
OB.SCREEN SCR1

: SHOW.TEXT ( $text part -- )
	. ." Text = " $type cr
;

: SHOW.VALUE ( $text part -- )
	. ." Value = " number?
	IF
		d.
	ELSE
		." Bad!"
	THEN
	cr
;
	
: CT.INIT
	2 2 new: rg1
	200 200 put.wh: rg1
\
	2 2 20 new: ct1
	600 300 put.wh: ct1
	'c show.text put.cr.function: ct1
\
	1 4 20 new: ct2
	600 300 put.wh: ct2
	'c ct.filter.numeric put.filter.function: ct2
	'c show.value put.cr.function: ct2
	'c show.value put.leave.function: ct2
	
	4 3 new: scr1
	ct1 200 400 add: scr1
	ct2 2000 400 add: scr1
	rg1 200 3000 add: scr1
	
	scr1 default-screen !
;

: CT.TERM
	freeall: scr1
	free: scr1
;

if.forgotten ct.term

: CT.TEST
	ct.init
	hmsl
	ct.term
;

[THEN]

