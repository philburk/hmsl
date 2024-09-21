\ MIDI Input to BreySheet

ANEW TASK-MIDI_Input

variable BRS-PITCH
variable BRS-BEND

: BRS.NOTE.RESPONSE  ( note velocity -- )
    drop brs-pitch !
;

: BRS.BEND.RESPONSE  ( 7lo 7hi -- )
    ( 2dup swap .hex .hex )
    7lo7hi->14 $ 2000 - ( dup . cr ) brs-bend !
;

: PAR.INPUT.MODE  ( -- , old ADC word )
;

: PAR@  ( -- pitch , get value that reflects pitch )
    midi.parse.many
    brs-bend @ ( 14 bit value , ranges +/- $2000 )
    -10 ashift  ( leave 16 levels )
    brs-pitch @ $ 20 - 4 ashift
    +
;

: B.SETUP.PARSE  ( -- )
    'c brs.note.response mp-on-vector !
    'c brs.bend.response mp-bend-vector !
;

b.setup.parse

if.forgotten mp.reset

VARIABLE PAR-DELAY
10 par-delay !

: PAR.WATCH  ( -- , monitor changes on parallel port )
    par.input.mode
    0
    BEGIN
        par@ dup 2 pick - abs 1 > ( change beyond jitter? )
        IF dup . swap drop cr
        ELSE drop
        THEN
        par-delay @ 0 DO LOOP
        ?terminal
    UNTIL drop
;
