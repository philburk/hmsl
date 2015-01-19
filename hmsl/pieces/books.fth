\ Music for Bookstores
\
\ This piece can use 7 channels of MIDI.
\ Adjust MIDI-SITE-RANGE if you don't have 7 channels available.
\
\ Entrance music for poetry reading at
\ Modern Times Bookstore 7/21/87
\
\ A shape containing values for "INTENSITY" and "COMPLEXITY"
\ is played.  A simple interpreter is used that sets
\ global variables to values currently being played
\ in the shape.
\
\ A "master noodler" generates a melody using 1/f noise.
\ Several "slave noodlers" track this master melody in
\ a manner controlled by the "intensity" and "complexity".
\ For lower complexity values, the slaves track the master
\ closer.  For very low complexity, the slave note values
\ are the same as the master notes.
\ Higher intensity results in faster and louder slave notes.
\ The slaves are started all at once and allowed to die
\ out randomly.  When the last one has died, they are all restarted
\ and so on.
\
\ Composer: Phil Burk
\ Copyright 1987 Phil Burk
\ All Rights Reserved
\
\ MOD: PLB 11/17/87 Added MIDI site range.
\ MOD: PLB 10/4/89 Removed printing of elmnt#.
\ MOD: PLB 7/12/90 CLEANUP: COLL-P-1

ANEW TASK-BOOKS

rtc.rate@ 8 / value dur_basic

\ Change this to the range of allowable MIDI channels
\ to match your music system!!!!!
: MIDI-SITE-RANGE ( -- lo hi )
	1 8
;

\ There will be this many noodlers plus one master channel.
\ Change to suit your MIDI configuration.
6 constant BS_MAX_NOODLERS

\ Global variables that control "mood" of piece.
\ These values will range from 0-100 and are changed
\ as the shape is played.
V: BS-INTENSITY
V: BS-COMPLEXITY

OB.INSTRUMENT INS-PARAMS
OB.SHAPE SH-PARAMS

: SNIPTO  { num lo hi -- num' , clip to mean if outside range }
	num hi >
	IF lo hi + 2/
	ELSE num lo <
		IF lo hi + 2/
		ELSE num
		THEN
	THEN
;

\ INTERPRETER for sh-params
: BS.MOOD.INTERP  ( element# shape instr -- , set variables )
	drop      ( don't need instrument address )
	get: []   ( element# shape -- intensity complexity )
	bs-complexity !    ( set global variables )
	bs-intensity !
;

: BS.MOOD.INIT ( -- )
	50 bs-intensity !
	50 bs-complexity !
\
\ Set up PLAYER for "mood" changes.
		32 2  new: sh-params
\ Intensity  Complexity
	48       0 add: sh-params
	19      15 add: sh-params
	87       6 add: sh-params
	71       0 add: sh-params
	29      35 add: sh-params
	65      23 add: sh-params
	50      28 add: sh-params
	43      28 add: sh-params
	39       0 add: sh-params
	35      72 add: sh-params
	32      99 add: sh-params
	22      87 add: sh-params
	16      90 add: sh-params
	13      97 add: sh-params
	14      87 add: sh-params
	26      43 add: sh-params
\
\ Give names to dimensions.
	" Intensity" 0 put.dim.name: sh-params
	" Complexity" 1 put.dim.name: sh-params
\
\ Set limits for dimensions.
	0 100 0 put.dim.limits: sh-params
	0 100 1 put.dim.limits: sh-params
\
	0 sh-params 0stuff: player-1
	ins-params put.instrument: player-1
	midi-site-range put.channel.range: ins-params
\
\ Use constant duration, new feature in 3.14!!
	-1 put.dur.dim: player-1
	rtc.rate@ 2* put.duration: player-1
\
\ Use custom INTERPRETERS
	'c bs.mood.interp put.on.function: ins-params
	'c 3drop put.off.function: ins-params
	100000 put.repeat: player-1
\
\ Make available for editing.
	clear: shape-holder
	sh-params add: shape-holder
	" SH-Params" put.name: sh-params
;

\ ---------------------------------------------------
\ Master Noodler - provides material for other noodlers to follow.
V: BS-MASTER-NOTE

: BS.MASTER.NEXT ( job -- , generate 1/f melody )
	4 choose 1+ dur_basic * over put.duration: []  ( randomize length )
\ Choose new note based on 1/f
	bs-master-note @ 1/f 8 20 snipto dup bs-master-note !
( -- job note )
	swap get.instrument: [] ( -- note instr )
	100 swap note.on: []
;

: BS.MASTER.INIT ( -- )
	20 bs-master-note !
	0 'c bs.master.next 0stuff: job-2
	ins-midi-2 put.instrument: job-2
;

\ ---------------------------------------------------
\ Slave noodlers.
: BS.NEW.PRESET ( instr -- , randomly change MIDI preset more often when intensity high )
	100 bs-intensity @ -
	choose -3 ashift 0=
	IF 100 choose swap put.preset: []
	ELSE drop
	THEN
;

: BS.SLAVE.NEXT ( job -- , track master noodler )
	bs-intensity @ 4/ 1+ choose 0=
	IF  dup get.instrument: []
		last.note.off: []
		set.done: []
	ELSE
\ Set duration.
		100 bs-intensity @ -
		choose -3 ashift
		1 max dur_basic *  over put.duration: []
\
\ Choose new note.
		bs-complexity @ choose
		-4 ashift  ( scale )
		2 choose IF negate THEN
		bs-master-note @ +  ( -- job new_note )
		swap get.instrument: [] ( -- new_note instr )
\
		dup bs.new.preset
		dup last.note.off: []   ( turn off any previous note)
		bs-intensity @ choose 2/ 50 + ( -- n i vel )
		swap note.on: []
	THEN
;

: BS.SLAVE.SETUP  ( job -- , initialize one job )
	instantiate ob.midi.instrument
	tr-current-key over put.gamut: []
	midi-site-range 2 pick put.channel.range: []
	over put.instrument: []
	0 'c bs.slave.next rot 0stuff: []
;

OB.COLLECTION BS-NOODLERS

: BS.SLAVE.INIT  ( -- , set up series of dynamic slave noodlers )
	bs_max_noodlers new: bs-noodlers
	bs_max_noodlers 0
	DO  instantiate ob.job
		dup add: bs-noodlers
		bs.slave.setup
	LOOP
	1000 put.repeat: bs-noodlers
;

: BS.SLAVE.TERM ( -- , cleanup )
\ Way to save shape
\    " ram:moods" $logto
\    dump.source: sh-params
\    logend
\
	many: bs-noodlers 0
	DO  i get: bs-noodlers
		dup free.hierarchy: []
		dup get.instrument: [] deinstantiate
		deinstantiate
	LOOP
	free: bs-noodlers
;

\ ---------------------------------------------------
: BS.INIT ( -- , Initialize piece )
    rtc.rate@ 8 / -> dur_basic
	bs.mood.init
	bs.master.init
	bs.slave.init
	stuff{ player-1 job-2 bs-noodlers }stuff: coll-p-1
    print.hierarchy: coll-p-1
;

: BS.PLAY ( -- )
	coll-p-1 hmsl.play
;

: BS.TERM ( -- )
	bs.slave.term
	cleanup: coll-p-1
;

: BOOKS
	bs.init
	bs.play
	bs.term
;

cr ." Enter   BOOKS    to hear piece." cr