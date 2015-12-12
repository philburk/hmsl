\ Generate notes using hailstone sequence. Play in Gamut.
\ For every note played on MIDI keyboard, a JOB will be created to play
\  a sequence.
\ Use Multitimbral Synth mode on synth.
\
\ Author: Phil Burk
\ Copyright 1989 Phil Burk
\ May be freely distributed among HMSL users.
\
\ 00001 PLB 10/9/91 Fixed stack problem in STOP.JOB.CHECK

ANEW TASK-BUBBLE

VARIABLE LAST-VELOCITY
VARIABLE CURRENT-DUR
VARIABLE NUM-VOICES
VARIABLE IF-SINGLE-CHANNEL
if-single-channel off

: NEW.NUMBER  ( n -- n' , generate new note based on old )
    dup 1 and
    IF  3 * 5 -   ( odd )
    ELSE  2/ 1+ ( even )
    THEN
;

: JOB.FUNC  ( job -- , play a note , old automatically turned off by instrument)
\ save sequence in data slot
    dup>r get.data: [] dup new.number r@ put.data: []
    31 and  ( -- note )  ( restrict between 0-31 )
\ make odd notes last twice as long
    current-dur @ over 1 and  ( -- n d flag )
    IF 2*
    THEN r@ put.duration: []  ( set duration in job )
    last-velocity @ r> get.instrument: [] note.on: [] ( turn on note )
;

\ Array to hold all instantiated jobs.
OB.ARRAY ALL-JOBS  ( keep job address indexed by note number )

: START.JOB  ( note -- , instantiate a job for immediate use )
    instantiate ob.job >r
    dup r@ put.data: []      ( save last note in job )
    r@ swap to: all-jobs     ( save job in array )
    0 'c job.func r@ 0stuff: []  ( use function )
    10 r@ put.duration: []   ( default duration )
\ Instantiate an instrument for the job.
    instantiate ob.midi.instrument >r    ( setup instrument )
        27 r@ put.offset: []
        tr-current-key r@ put.gamut: []   ( play "in key" )
        if-single-channel @
        IF 1 r@ put.channel: []  ( force all to same channel )
        THEN
        num-voices @ r@ put.#voices: []  ( set #voices for auto noteoff )
    r> r@ put.instrument: []
    current-dur @ r@ put.duration: [] ( get from variable for changing tempo )
    rtc.time@ 0 r> execute: []
;

: START.JOB.CHECK ( note -- )
    dup at: all-jobs 0=
    IF start.job
    ELSE . ."  still playing!" cr
    THEN
;

: STOP.JOB ( note -- )
    dup at: all-jobs    ( get job from array ) ?dup
    IF  dup stop: []    ( stop execution )
        dup get.instrument: [] deinstantiate  ( get rid of objects )
        deinstantiate
        0 swap to: all-jobs   ( clear holder )
    ELSE drop
    THEN
;

: STOP.JOB.CHECK ( note -- )
    dup at: all-jobs    ( get job from array )
    IF  stop.job
    ELSE drop \ 00001
        ." BUBBLE - No JOB for that note!" cr
    THEN
;

\ Define responses to note input.
: BUBBLE.ON.RESPONSE  ( note velocity -- , )
    IF   start.job
    ELSE stop.job
    THEN
;

: CONTROL.RESPONSE  ( note velocity -- , control system based on note hit)
    last-velocity !
    dup 39 >
    IF  40 = dup if-single-channel !
        IF ." Single Channel Mode!" cr
        ELSE ." MultiChannel Mode!" cr
        THEN
    ELSE     ( -- note ) 35 - 1 max dup num-voices !
        ." Maximum #voices per channel = " . cr
    THEN
;

: NOTE.ON.RESPONSE  ( note velocity -- , for MIDI parser )
    over 41 >  ( split keyboard into control and play )
    IF drop start.job
    ELSE control.response
    THEN
;
: NOTE.OFF.RESPONSE  ( note velocity -- , for MIDI parser )
    over 41 >  ( split keyboard into control and play )
    IF drop stop.job.check
    ELSE 2drop
    THEN
;

HEX
: BEND.RESPONSE  ( lo hi -- )
    7lo7hi->14
    2000 - 8 * 2000 /  ( convert into range from 2 to 18 )
    A swap - current-dur !
;
DECIMAL

: BUBBLE.INIT ( -- )
    128 new: all-jobs
    100 last-velocity !    1 num-voices !    10 current-dur !
    mp.reset
    'c note.on.response  mp-on-vector !
    'c note.off.response  mp-off-vector !
    'c bend.response  mp-bend-vector !
    if-single-channel off
    midi.clear
    8 time-advance !
    hmsl-graphics off
;
: BUBBLE.TERM ( -- )
    size: all-jobs 0
    DO
        i stop.job
    LOOP
    free: all-jobs
    60 time-advance !
    hmsl-graphics on
;
if.forgotten bubble.term

: BUBBLE ( -- , set up the instrument for play )
    bubble.init
    midi.parser.on
    hmsl
    bubble.term
;
: TEST.ALGO  ( N -- , test note generator , loop until key hit )
    BEGIN new.number dup . cr?
        ?terminal
    UNTIL drop
;

cr ." Enter:  BUBBLE    then play MIDI keyboard." cr
