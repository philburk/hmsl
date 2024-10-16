\ World's Longest Melody
\ lp april 13, 1992
\ rev: may 23
\ 5/23: added midi control


\ Basic wlm objects, have probs for loud., dur, and pitch, 1 controller
\ value, and many
\ other instance variables

ANEW TASK-WLM_OBJ

\ the following word is used for setting values into
\ various wlm
defer wlm.user.init
'c noop is wlm.user.init

\ probability of a wlm doing what it just did (directionally)
method put.duration-prob:
method get.duration-prob:
method put.pitch-prob:
method get.pitch-prob:
method put.loudness-prob:
method get.loudness-prob:
method put.control-prob:
method get.control-prob:


method get.on?: ( tells whether wlm is currently being excecuted or not )
method put.on?: ( put a true or false in this... )

\ increment in each paramter
method put.duration-inc:
method get.duration-inc:
method put.pitch-inc:
method get.pitch-inc:
method put.loudness-inc:
method get.loudness-inc:
method put.control-inc:
method get.control-inc:

\ keeps track of previous values
method put.duration-last-dir:
method get.duration-last-dir:
method put.pitch-last-dir:
method get.pitch-last-dir:
method put.loudness-last-dir:
method get.loudness-last-dir:
method put.control-last-dir:
method get.control-last-dir:

\ can force all parameters, get.duration: and put.duration: inherited from jobs
method get.pitch:
method put.pitch:
method get.loudness:
method put.loudness:
method get.control:
method put.control:
method get.staccato:
method put.staccato:

\ set range in a given parameter for a given wlm
method put.loudness-range:
method put.duration-range:
method put.pitch-range:
method get.loudness-range:
method get.duration-range:
method get.pitch-range:
method put.control-range:
method get.control-range:

\ turn off and on motion in a given parameter
method loudness.on:
method loudness.off:
method pitch.on:
method pitch.off:
method duration.on:
method duration.off:
method control.on:
method control.off:

\ decide which midi controller a wlm will use
method put.control-#:
method get.control-#:

\ change a midi preset on a given channel
method put.preset-#:
method get.preset-#:

\ force a job function into the wlm
method setup:

:CLASS  ob.wlm  <super ob.job
    iv.short on?
    iv.short duration-prob
    iv.short pitch-prob
    iv.short loudness-prob
    iv.short control-prob
    iv.short duration-inc
    iv.short pitch-inc
    iv.short loudness-inc
    iv.short control-inc
    iv.short pitch
    iv.short loudness
    iv.short iv-control
    iv.short staccato
    iv.short duration-last-dir
    iv.short pitch-last-dir
    iv.short loudness-last-dir
    iv.short control-last-dir
    iv.short hi-pitch
    iv.short lo-pitch
    iv.short hi-dur
    iv.short lo-dur
    iv.short hi-loud
    iv.short lo-loud
    iv.short hi-control
    iv.short lo-control
    iv.short channel
    iv.short duration-on
    iv.short pitch-on
    iv.short loudness-on
    iv.short control-on
    iv.short prev-pitch
    iv.short control-#
    iv.short preset-#

:M INIT:
\ default values are done here, user can change these ....
    init: super
    5 new: super
    false iv=> on?
    50 iv=> duration-prob
    50 iv=> pitch-prob
    50 iv=> loudness-prob
    50 iv=> control-prob
    5 iv=> duration-inc
    1 iv=> pitch-inc
    1 iv=> control-inc
    2 iv=> loudness-inc
    60 iv=> pitch
    50 iv=> staccato
    30 put.duration: super
    60 iv=> loudness
    60 iv=> iv-control
    1 iv=> duration-last-dir
    1 iv=> pitch-last-dir
    1 iv=> loudness-last-dir
    1 iv=> control-last-dir
    1 iv=> lo-dur
    5000 iv=> hi-dur
    108 iv=> hi-pitch
    20 iv=> lo-pitch
    0 iv=> lo-loud
    127 iv=> hi-loud
    0 iv=> lo-control
    127 iv=> hi-control
    1 IV=> channel
    10 iv=> control-#
    true iv=> pitch-on
    true iv=> duration-on
    true iv=> loudness-on
    false iv=> control-on \ controller wlm has to be turned on by user
    1 iv=> preset-#
;m

\ just determines whether a wlm is running or not, a variable is set by start: and stop:
:M GET.ON?:
    on?
;m

:M PUT.ON?: ( flag -- )
    iv=> on?
;m


\ Probabilities for 4 parameters
:M PUT.DURATION-PROB:
    0 100 clipto
    iv=> duration-prob
;m

:M GET.DURATION-PROB:
     duration-prob
;m

:M PUT.PITCH-PROB:
    0 100 clipto
    iv=> pitch-prob
;m

:M GET.PITCH-PROB:
     pitch-prob
;m

:M PUT.LOUDNESS-PROB:
    0 100 clipto
    iv=> loudness-prob
;m

:M GET.LOUDNESS-PROB:
     loudness-prob
;m

:M PUT.CONTROL-PROB:
    0 100 clipto
    iv=> control-prob
;m

:M GET.CONTROL-PROB:
     control-prob
;m

\ Increments for 4 parameters
:M PUT.DURATION-INC:
    0 100 clipto
    iv=> duration-inc
;m

:M GET.DURATION-INC:
     duration-inc
;m

:M PUT.PITCH-INC:
    0 100 clipto
    iv=> pitch-inc
;m

:M GET.PITCH-INC:
     pitch-inc
;m

:M PUT.LOUDNESS-INC:
    0 100 clipto
    iv=> loudness-inc
;m

:M GET.LOUDNESS-INC:
     loudness-inc
;m

:M PUT.CONTROL-INC:
    0 100 clipto
    iv=> control-inc
;m

:M GET.CONTROL-INC:
     control-inc
;m

\ Last direction values for 4 parameters
:M PUT.DURATION-LAST-DIR:
    iv=> duration-last-dir
;m

:M GET.DURATION-LAST-DIR:
     duration-last-dir
;m

:M PUT.PITCH-LAST-DIR:
    iv=> pitch-last-dir
;m

:M GET.PITCH-LAST-DIR:
     pitch-last-dir
;m

:M PUT.LOUDNESS-LAST-DIR:
    iv=> loudness-last-dir
;m

:M GET.LOUDNESS-LAST-DIR:
     loudness-last-dir
;m

:M PUT.CONTROL-LAST-DIR:
    iv=> control-last-dir
;m

:M GET.CONTROL-LAST-DIR:
     control-last-dir
;m

\ Put and get pitch loudness and control and staccato, don't need duration cause inherited from job
:M PUT.PITCH:
    1 127 clipto
    iv=> pitch
;m

:M GET.PITCH:
    pitch
;m


:M PUT.STACCATO:
    1 127 clipto
    iv=> staccato
;m

:M GET.STACCATO:
    staccato
;m

:M PUT.LOUDNESS:
    0 127 clipto
    iv=> loudness
;m

:M GET.LOUDNESS:
    loudness
;m

:M PUT.CONTROL:
    0 127 clipto
    iv=> iv-control
;m

:M GET.CONTROL:
    iv-control
;m

:M PUT.CONTROL-#:
    0 127 clipto
    iv=> control-#
;m

:M GET.CONTROL-#:
    control-#
;m
\ Put and get midi channel for each wlm...
:M PUT.CHANNEL:
    iv=> channel
;M

:M GET.CHANNEL:
    channel
;m

\ preset changing
:M GET.PRESET-#:
    preset-#
;m

:M PUT.PRESET-#:
    0 256 clipto
    iv=> preset-#
;m

\ Set a range in each parameter
\ Syntax for input of ranges: lo hi
:M PUT.DURATION-RANGE:
    iv=> hi-dur iv=> lo-dur
;m

:M PUT.PITCH-RANGE:
     iv=> hi-pitch iv=> lo-pitch
;m

:M PUT.LOUDNESS-RANGE:
     iv=> hi-loud iv=> lo-loud
;m

:M PUT.CONTROL-RANGE:
     iv=> hi-control iv=> lo-control
;m

:M GET.DURATION-RANGE: (  -- lo hi )
    lo-dur  hi-dur
;m

:M GET.PITCH-RANGE: (  -- lo hi)
    lo-pitch hi-pitch
;m

:M GET.LOUDNESS-RANGE: (  -- lo hi )
    lo-loud hi-loud
;m

:M GET.CONTROL-RANGE: (  -- lo hi )
    lo-control hi-control
;m

\ Turn on or off parametric functions
\ WLM could be changing pitch, or duration, but maintaining loudness

:M LOUDNESS.ON:
    true iv=> loudness-on
;m

:M LOUDNESS.OFF:
    false iv=> loudness-on
;M

:M DURATION.ON:
    true iv=> duration-on
;m

:M DURATION.OFF:
    false iv=> duration-on
;M

:M PITCH.ON:
    true iv=> pitch-on
;m

:M PITCH.OFF:
    false iv=> pitch-on
;M

:M CONTROL.ON:
    true iv=> control-on
;m

:M CONTROL.OFF:
    false iv=> control-on
;M

\ These are standard duration, pitch, control, and loudness
\  functions that are jammed into each WLM with the
\ method SETUP:
\ You must exectute that method  for a WLM to be a WLM

\ Duration inc is a ratio to the current duration.
: WLM.DURATION.FUNC { wlm -- }
    duration-on
    IF
        wlm get.duration: [] ( -- dur )
        dup ( -- dur dur )
        wlm get.duration-inc: [] ( --  dur dur inc )
        / 1+ \ -- dur (dur/inc)+1 : don't allow it to be zero ever.....
        wlm get.duration-last-dir: [] ( -- dur adj-dur-inc last-dir )
        \ basic WLM algorithm:
        101 choose wlm get.duration-prob: []
        <
            IF
                -1
            ELSE
                1
            THEN
        * ( -- dur adj-dur-incr new-dir )
        dup wlm put.duration-last-dir: []
        * +
        wlm get.duration-range: []
        clipto wlm put.duration: []
\   wlm get.duration: [] .
    THEN
;

: WLM.PITCH.FUNC { wlm -- }
    pitch-on
    IF
        wlm get.pitch: [] ( -- p )
        wlm get.pitch-inc: [] ( -- p inc )
        wlm get.pitch-last-dir: [] ( -- p inc dir )
        101 choose wlm get.pitch-prob: []
        <
            IF
                -1
            ELSE
                1
            THEN
        * ( -- p inc dir )
        dup wlm put.pitch-last-dir: [] ( -- p inc dir )
        * +
        wlm get.pitch-range: [] clipto
        dup iv=> prev-pitch
        wlm put.pitch: []
\       wlm get.pitch: [] .
    THEN
;

: WLM.LOUDNESS.FUNC { wlm -- }
    loudness-on
    IF
        wlm get.loudness: [] ( -- l )
        wlm get.loudness-inc: [] ( -- l inc )
        wlm get.loudness-last-dir: [] ( -- l inc dir )
        101 choose wlm get.loudness-prob: []
        <
        IF
            -1
        ELSE
            1
        THEN
        * ( -- l inc dir )
        dup wlm put.loudness-last-dir: []
        * +
        wlm get.loudness-range: [] clipto
        wlm put.loudness: []
\   wlm get.loudness: [] . cr
    THEN
;

: WLM.CONTROL.FUNC { wlm -- }
    control-on
    IF
        wlm get.control: [] ( -- l )
        wlm get.control-inc: [] ( -- l inc )
        wlm get.control-last-dir: [] ( -- l inc dir )
        100 choose wlm get.control-prob: []
        <
        IF
            -1
        ELSE
            1
        THEN
        * ( -- l inc dir )
        dup wlm put.control-last-dir: []
        * +
        wlm get.control-range: [] clipto
        wlm put.control: []
\   wlm get.control: [] . cr
    THEN
;

\ This is the function, jammed in with SETUP:, that plays the WLM
\ Note that it turns off its own last note, not necessarily the last note
\ on the particular midi channel
: WLM.PLAY { wlm -- }
    wlm get.channel: []
    midi.channel!
\   prev-pitch 0 midi.noteoff ( don't need this now, using midi.noteon.for )
    wlm get.pitch: []
    wlm get.loudness: []
    wlm get.duration: []  ( the ontime of a note is 1 less than the duration of the job )
    wlm get.staccato: []
    100 */ \ take staccato value
    midi.noteon.for
    wlm get.control-#: []
    wlm get.control: []
    midi.control
;


\ This word is crucial, and must be executed after a WLM is instantiated.
\ It puts the special functions into the WLM "job"
:M SETUP: {  -- }
    'c wlm.duration.func  add: self
    'c wlm.pitch.func  add: self
    'c wlm.loudness.func  add: self
    'c wlm.control.func add: self
    'c wlm.play add: self
;m

\ start is redefined slightly so that it sets a preset on the WLM's channel...
:M START:
    true put.on?: self
    get.preset-#: self
    get.channel: self midi.channel!
    midi.preset
    start: super
;M

\ stop: is redefined slightly so that it doesn't leave a hung midi note...
:M STOP:
    false put.on?: self
    get.channel: self
    midi.channel!
    prev-pitch 0 midi.noteoff
    stop: super
;M

:M PRINT:
    print: super
    ." Duration prob.,inc.,start is "
    get.duration-prob: self . ." ," get.duration-inc: self . ." ,"
    get.duration: self .  cr
    ." Pitch prob.,inc.,start is "
    get.pitch-prob: self . ." ," get.pitch-inc: self . ." ,"
    get.pitch: self .  cr
    ." Loudness prob.,inc.,start is "
    get.loudness-prob: self . ." ," get.loudness-inc: self . ." ,"
    get.loudness: self .  cr
    ." Control prob.,inc.,start is "
    get.control-prob: self . ." ," get.control-inc: self . ." ,"
    get.control: self .  cr
    ." Channel: " get.channel: self . cr
    ." Preset: " get.preset-#: self . cr
    ." Controller # is " get.control-#: self . cr
    ." Duration range: " get.duration-range: self . . cr
    ." Pitch range: " get.pitch-range: self . . cr
    ." Loudness range: " get.loudness-range: self . . cr
    ." Control range: " get.control-range: self . . cr
    duration-on IF ." Duration on " cr ELSE ." Duration off " cr THEN
    pitch-on IF ." Pitch on " cr ELSE ." Pitch off " cr THEN
    loudness-on IF ." Loudness on " cr ELSE ." Loudness off " cr THEN
    control-on IF ." Control on " cr ELSE ." Control off " cr THEN
;M


;CLASS



\ EXAMPLE:
\ ob.wlm my-wlm
\ setup: my-wlm
\ hmsl.start
\ (on forth window): start: my-wlm
