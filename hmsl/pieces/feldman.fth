\ This series of simple studies are based on descriptions
\ of pieces by David Feldman.
\
\ Translated to HMSL by Phil Burk

ANEW TASK-FELDMAN

\ Some useful variables for controlling these studies.
V: DF-DELAY  ( note delay )
100 DF-DELAY !

: DF.NOTE ( note -- , play that note )
    100 midi.noteon
    df-delay @ msec
    midi.lastoff
    df-delay @ msec
;

\ David says these sequences remind him of Wagner. :-)
V: DF-LOOP1
V: DF-LOOP2
V: DF-LOOP3
V: DF-LOOP4
6 df-loop1 !   7 df-loop2 !  4 df-loop3 !  5 df-loop4 !
V: DF-RANGE
36 df-range !  ( 3 octaves )
: DF.WAGNER ( -- )
    df-loop1 @ 1 DO i
        df-loop2 @ 1 DO dup i *
            df-loop3 @ 1 DO dup i *
                df-loop4 @ 1 DO dup i *
                    df-range @ mod 40 + df.note  ( two octave range )
                    ?terminal IF abort THEN
                LOOP drop
            LOOP drop
        LOOP drop
    LOOP
;

\ ----------------------------------------------------------
\ An offset is calculated by weighting succesive binary digits
\ with 1 and -1 alternately.
: DF.N>OFFSET ( n -- offset )
    0  ( initial offset )
    BEGIN
        over
    WHILE
        over 1 and +
        >r 2/ r>
        over 1 and -
        >r 2/ r>
    REPEAT
    nip
;

: DF.1-1  ( start end -- , play pattern )
    -2sort DO
        i df.n>offset  48 mod
        dup . cr
        50 + df.note
        ?terminal IF leave THEN
    LOOP
;

." Enter:    DF.WAGNER" cr
." ENter:    0 30 DF.1-1" cr
