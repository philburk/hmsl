\ Base notes on the recent past notes.
\ Use an Interpreter that checks for an index.
\ When that index is hit it calculates some more notes
\ based on the previous notes, and resets the index.
\
\ Author: Phil Burk
\ Copyright 1989 Phil Burk

ANEW TASK-RECENT

.NEED CHOOSE+/-
: CHOOSE+/-  ( N -- r , calc number from +/- N inclusive )
    dup 2* 1+ choose swap -
;
.THEN

variable RE-CALC-AT  ( index that triggers a calculation )
variable RE-LAST     ( wrap around index for adding )
variable RE-ELAPSED  ( accumulate time put into shape )
variable TICKS/MEASURE  ( make this a global variable ! )
128 ticks/measure !
ticks/measure @ 16 / constant SMALLEST_DUR

variable RE-MAX-BACK
8 re-max-back !
variable RE-MAX-OFFSET
4 re-max-offset !
variable RE-MAX-TIMES
3 re-max-times !

OB.SHAPE RE-SHAPE
OB.PLAYER RE-PLAYER
OB.MIDI.INSTRUMENT RE-INST

: RE.ADD ( vn ... v0 -- , add or put )
    many: re-shape max.elements: re-shape <
    IF add: re-shape
        many: re-shape 1- re-last !
    ELSE
        re-last @ 1+ max.elements: re-shape mod
        dup re-last !
        put: re-shape
    THEN
    re-last @ 0 ed.at: re-shape re-elapsed +!  ( track time )
;

: RE.WRAP.INDEX  ( index -- vn ... v0 , wrap negative indices )
    many: re-shape dup>r 8 ashift + r> mod
;

1 constant RE_LOW
28 constant RE_HIGH
7 constant RE_N/OCTAVE   ( 7 notes per octave )

: RE.CLIP ( pitch -- pitch' )
    dup re_low <
    IF re_n/octave + recurse
    ELSE dup re_high >
        IF re_n/octave - recurse
        THEN
    THEN
;

: RE.PULL.NEW ( index offset -- )
    >r
    re.wrap.index get: re-shape re.add
    re-last @ 1 ed.at: re-shape  ( pitch )
    r> + re.clip re-last @ 1 ed.to: re-shape
;

: RE.DEVELOP { num_notes offset num_times -- }
    num_notes num_times * 0
    DO re-last @ num_notes 1- - offset re.pull.new
    LOOP
;

: CHOOSE**2.IN  ( upper-bound -- dur , choose in powers of 2 )
    1 swap logbase2 choose ashift
;

: RE.NICE.DUR  ( -- dur , get duration in bound )
    re-elapsed @ ticks/measure @ tuck mod - ( -- left )
    smallest_dur / choose**2.in
    smallest_dur *
;

: RE.RANDOM  ( -- )
    re.nice.dur
    10 choose 10 +
    30 choose 80 +
    re.add
;

: RE.RANDOM.MEASURE ( -- , generate a random measure )
    BEGIN re.random
        re-elapsed @ ticks/measure @ mod 0=
    UNTIL
;

: RE.SCAN.BACK  { | tdur indx etime -- num_notes , scan back for break }
    1 5 choose ashift smallest_dur * -> tdur
    0 -> indx
    0 -> etime
    BEGIN re-last @ indx - re.wrap.index
        0 ed.at: re-shape etime + -> etime
        indx 1+ -> indx
        indx 16 >
        etime tdur mod 0= OR
    UNTIL
    indx
;

: RE.RIFF ( -- )
    4 choose 0=
    IF re.random.measure
    ELSE
        re.scan.back ( num notes )
        re-max-offset @ choose+/- ( offset )
        1 re-max-times @  choose ashift
        re.develop
    THEN
;

: RE.INTERP  ( eln shp inst -- )
    2 pick re-last @ =
    IF re.riff
    THEN
    interp.el.on.for
;

: RE.INIT ( -- )
    -1 re-last !
    2 set.width: re-shape
    128 3 new: re-shape
    4 0
    DO re.random.measure   LOOP
    re.riff re.riff
    re-shape add: shape-holder
    re-shape re-inst  build: re-player
    1000000 put.repeat: re-player
    'c re.interp put.on.function: re-inst
;


: RE.TERM ( -- )
    free: re-shape
    free: re-player
    re-shape delete: shape-holder
;

: RE.TEST
    re.init
    re-player hmsl.play
    re.term
;

if.forgotten re.term
