\ Piece based on random walk.
\
\ Draw vectors and change two audio channels pitches
\ based on x,y position of pen.
\
\ Author: Phil Burk
\ Copyright 1986 -  Phil Burk, Larry Polansky, David Rosenboom.

INCLUDE? OB.RANDOM.WALK H:RANDOM_WALK

ANEW TASK-WALKER
OB.RANDOM.WALK RWX
OB.RANDOM.WALK RWY

: WALKER.INIT   ( -- , Initialize walkers. )
    gr_xmax put.max: rwx   ( set maximum values for x,y )
    4 put.min: rwx
    9 put.step: rwx
    gr_ymax put.max: rwy
    12 put.min: rwy
    3 put.step: rwy
\
\ Start sound.
    da.init    ( reset in case messed up. )
    0 da.channel! da.start   ( start sound )
    1 da.channel! da.start
;

: WALKER.PLAY
    hmsl.open    ( open graphics window )
    gr.clear     ( clear it )
    1 gr.color!  ( start with normal color )
    walk: rwx  walk: rwy  gr.move ( move to 1st x,y)
\
    BEGIN
        100 0 DO
            walk: rwx  walk: rwy  ( generate new x,y)
            2dup gr.draw   ( draw line to it. )
            0 da.channel!   4* 600 + da.period!  ( play y )
            1 da.channel!   4* 600 + da.period!  ( play x )
        LOOP
        4 choose gr.color!  ( new color )
        ?terminal ?closebox OR    ( quit? )
    UNTIL
    hmsl.close    ( close graphics window )
;

: WALKER.TERM  ( -- , Clean up. )
    da.kill
;

: WALKER  ( -- , do it )
    walker.init   walker.play   walker.term
;
." Enter:   WALKER    to hear and see demo." cr
