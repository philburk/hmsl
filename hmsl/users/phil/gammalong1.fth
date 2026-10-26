\ Piece for UBU concert 8/1/86
\ Sliding window behavior with different style collections.
\
\ Author: Phil Burk
\ Performed with Larry Polansky and Phil Stone
\ Copyright 1986

ANEW TASK-GAMMALONG1

: GAMMA.BUILD.1   ( -- , Build up objects for first collection )
     28 2 new: shape-1-a
     2 new: coll-1
     6  0 add: shape-1-a
     6 10 add: shape-1-a
     12 11 add: shape-1-a
     12  1 add: shape-1-a
     12  4 add: shape-1-a
     6  5 add: shape-1-a
     6  3 add: shape-1-a
     12 16 add: shape-1-a
     12  6 add: shape-1-a
     12  4 add: shape-1-a
     12  5 add: shape-1-a
     6  3 add: shape-1-a
     6  5 add: shape-1-a

     6  2 add: shape-1-a
     12  4 add: shape-1-a
     12  0 add: shape-1-a
     12  0 add: shape-1-a
     12  2 add: shape-1-a
     6  1 add: shape-1-a
     6  2 add: shape-1-a
     12  8 add: shape-1-a
     18 3 add: shape-1-a

     shape-1-a put.object: player-1-a
     player-1-a 'c oper.post.exec add: coll-1
     4 put.repeat: player-1-a
     player-1-a ins.use.c1
;
: GAMMA.FREE.1
     free: shape-1-a
     free: coll-1
;

\ ----------------------------------------------------------
\ This next collection uses a shape as a constraint for randomly
\ generating a melody.
\ One dimension controls the magnitude of an interval.
\ Another dimension control the sign.

\ It is implemented by putting a special set of CFAs in the shape player.
V: G2-OLD-NOTE    12 g2-old-note !
: G2.NOTE.ON  ( mag sign -- , calculate a new note )
    swap choose swap *   ( new interval )
    g2-old-note @ +      ( new note )
    0 max 24 min         ( clip to 4 octave range )
    dup 20 > IF 2- THEN  ( coerce to middle of range )
    dup  4 < IF 2+ THEN
    dup g2-old-note !    ( save note )
    set.note: ins-can-1
    start: ins-can-1
;
: G2.NOTE.OFF  ( mag sign -- , turn off previous note )
    2drop finish: ins-can-1
;

: GAMMA.BUILD.2
     16 3 new: shape-2-a
     2 new: coll-2
     12 4  1 add: shape-2-a
     12 4  1 add: shape-2-a
     12 2 -1 add: shape-2-a
     16 6 -1 add: shape-2-a
     12 2  1 add: shape-2-a
     6 3  1 add: shape-2-a
     6 4 -1 add: shape-2-a
     6 3 -1 add: shape-2-a
     12 2  1 add: shape-2-a
     6 3  1 add: shape-2-a
     12 2  1 add: shape-2-a
     12 5 -1 add: shape-2-a
     6 3 -1 add: shape-2-a
     6 1 -1 add: shape-2-a
     16 6 1 add: shape-2-a
     16 2 -1 add: shape-2-a

     shape-2-a put.object: player-2-a
     player-2-a 'c oper.post.exec add: coll-2

     8 put.repeat: player-2-a
     'c g2.note.on put.on.cfa: player-2-a
     'c g2.note.off put.off.cfa: player-2-a
     2 put.vel.dim: player-2-a   ( use second dimension as "velocity" )
     ( the velocity is actually interpreted here as sign of interval )
     0 put.offset: player-2-a
;

: GAMMA.FREE.2
     free: shape-2-a
     free: coll-2
;

\ Collection 3 -----------------------------------------------
\ Play polyrythms of 3 & 5
: a5s3a  ( note -- )
    15 swap add: shape-3-a
;
: a3s3b  ( note -- )
    9 swap add: shape-3-b
;
: GAMMA.BUILD.3
    3 4 * 2 new: shape-3-a
    5 4 * 2 new: shape-3-b

\ Shape with 3 notes per 15
 0 a5s3a  5 a5s3a  2 a5s3a 
 1 a5s3a  2 a5s3a  3 a5s3a 
 9 a5s3a  8 a5s3a  6 a5s3a 
 7 a5s3a  4 a5s3a  5 a5s3a 

\ Shape with 5 notes per 15
 0 a3s3b  5 a3s3b  10 a3s3b  6 a3s3b  6 a3s3b 
 7 a3s3b  8 a3s3b  12 a3s3b  13 a3s3b  15 a3s3b 
 4 a3s3b  3 a3s3b  2 a3s3b  7 a3s3b  8 a3s3b 
 12 a3s3b  11 a3s3b  13 a3s3b  10 a3s3b  10 a3s3b 

     shape-3-a put.object: player-3-a
     shape-3-b put.object: player-3-b
     2 new: coll-3
     player-3-a 'c oper.post.exec add: coll-3
     player-3-b 'c oper.post.exec add: coll-3

     6 put.repeat: player-3-A
     6 put.repeat: player-3-B
     player-3-a ins.use.c1
     player-3-b ins.use.c2
;
: GAMMA.FREE.3
     free: shape-3-A
     free: shape-3-B
     free: coll-3
;

: GAMMA.BUILD.4  ( -- ,  Build shape to be edited. )
     16 2 new: shape-4-a
     1 new: coll-4
     12 5 add: shape-4-a
     12 6 add: shape-4-a
     12 7 add: shape-4-a
     12 8 add: shape-4-a
     shape-4-a put.object: player-4-a
     8 put.repeat: player-4-a
     player-4-a 'c oper.post.exec add: coll-4
     player-4-a ins.use.c1
;
: GAMMA.FREE.4
    free: shape-4-a
    free: coll-4
;

\ COLLECTION 5 - Slow spacey sounds.  Accompanied by voice.
:CLASS OB.SPACEY <SUPER OB.STREAM
    CELL OB.IVAR OB-SPACE-PERIOD
    CELL OB.IVAR OB-SPACE-DELTA
    CELL OB.IVAR OB-SPACE-SAMPLE

:M INIT:
    init: super
;M

:M ?RTIME: ( -- rtime , stub to prevent reference to unallocated data )
    0
;M

:M REGISTER:  ( time -- , register object )
    register: super
    500 ob-space-period m!
    0 ob-space-delta m!
    0 da.ampmod!
    0 da.freqmod!
    64 da.loudness!
    use: wave-sawtooth
\    ob-environ-arg m@ 1000 * 
\    dup ob-space-sample m! 16 da.sample!   ( use random memory )
    da.start
;M

V: HIGH-WALL
V: LOW-WALL
124 LOW-WALL !
6000 HIGH-WALL !
: SPACE.BOUNCE.PERIOD  ( period delta -- period' delta', bounce off boundaries )
    2dup + dup LOW-WALL @ <   ( p d p' f )
    IF drop negate ." L"      ( p d- )
    ELSE HIGH-WALL @ <        ( p d f )
        IF negate  ." H"
        THEN
    THEN
;

: SPACE.CLIP.DELTA  ( delta -- delta' )
    dup abs 40 >
    IF drop 0 
    THEN
;
    
:M TASK:    ( -- done? , perform operation )
    set.environment: self

    ob-space-period m@
    ob-space-delta  m@

\ Calc new delta.
    space.bounce.period
    11 choose 5- ( random between -5 & +5 )
    + space.clip.delta
    dup ob-space-delta m!

\ Calc new period.
    + dup ob-space-period m!
    da.period!

\ Use new memory.
\    ob-space-sample m@ 8 +
\    512000 max dup ob-space-sample m!
\    16 da.sample!

    ?done: self
    dup IF da.stop THEN
;M
;CLASS

OB.SPACEY SPACE-0
OB.SPACEY SPACE-1
OB.SPACEY SPACE-2
OB.SPACEY SPACE-3

: GAMMA.BUILD.5
    0 put.environ.arg: space-0
    'c da.channel! put.environ.cfa: space-0
    1000 put.repeat: space-0

    1 put.environ.arg: space-1
    'c da.channel! put.environ.cfa: space-1
    1500 put.repeat: space-1

    2 put.environ.arg: space-2
    'c da.channel! put.environ.cfa: space-2
    1500 put.repeat: space-2

    3 put.environ.arg: space-3
    'c da.channel! put.environ.cfa: space-3
    1500 put.repeat: space-3

    4 new: coll-5
    space-0 'c oper.post.exec add: coll-5
    space-1 'c oper.post.exec add: coll-5
    space-2 'c oper.post.exec add: coll-5
    space-3 'c oper.post.exec add: coll-5
;
: GAMMA.FREE.5
;

\ Behavior for piece ------------------------------------------------
V: GAMMA-HIGH
V: GAMMA-OLD
V: GAMMA-MAX
: SLIDE.BEHAVE ( struct -- coll-index )
    drop
    gamma-old @ 1+
    dup gamma-high @ >
    over gamma-max @ > OR
    IF
        gamma-high @ 1+
        dup gamma-high !  ( i gh )
        gamma-max @ -  0 max ( i i' )
        dup gamma-max @ >  ( terminate? )
        IF drop -1 
        THEN
        swap drop
    THEN
    dup gamma-old !
    dup .
;

: SLIDE.INIT  ( -- )
     0 gamma-high !
    -1 gamma-old !
     many: frame-gamma 1-  gamma-max !
;

: test.slide slide.init 0 do 0 slide.behave drop loop ;

\ -----------------------------------------------------
: GAMMA.INIT ( -- )
    gamma.build.1
    gamma.build.2
    gamma.build.3
    gamma.build.4
    gamma.build.5

    5 new: frame-gamma
    coll-1 add: frame-gamma
    coll-2 add: frame-gamma
    coll-3 add: frame-gamma
    coll-4 add: frame-gamma
    coll-5 add: frame-gamma
    'c slide.behave set.behavior: frame-gamma
    slide.init
;

: gamma.term
    gamma.free.1
    gamma.free.2
    gamma.free.3
    gamma.free.4
    gamma.free.5
;

: do.gamma ( -- , perform gamma piece again )
    slide.init
    shape-4-a se.setup
    frame-gamma hmsl.play
;

\ TEST WORDS
: DROP-4 DROP ;
