\ wlm user init file
\ 1/18/93
\ this file can be customized by the user to set wlm variables and so
\ on at start up of twlm

\ to use it, create your own word, in here, or anywhere else
\ and stuff it in the deferred word WLM.USER.INIT
\ for example, create a word called MY.WLM.INIT
\ which sets all the presets for wlm's (as is done currently in
\ this file) and then do
\ 'C MY.WLM.INIT IS WLM.USER.INIT
\ WLM.USER.INIT is executed in the DO.WLM word when the piece is
\ fired up

\ note that the init word is called BEFORE the screen is setup...

anew task-wlm_user_init



\ these words are used for mobius gig, using proteus, with
\ 65 as a harmonic series piano preset on the proteus
: SET.PRESETS.MOBIUS
    #-channels 0
    DO
        20
        i at: wlm-list
         put.preset-#: []
    LOOP
;

: SET.PITCHES/DURATIONS.MOBIUS
    #-channels 0
    DO
        60
        i at: wlm-list
         put.pitch: []
        60
        i at: wlm-list
        put.duration: []
    LOOP
;

: SET.LOUDNESS-PROBS.MOBIUS
    #-channels 0
    DO
        100 choose
        i at: wlm-list
         put.loudness-prob: []
    LOOP
;

: MOBIUS.INIT
    60 rtc.rate!
    set.presets.mobius
    set.pitches/durations.mobius
    set.loudness-probs.mobius
;

'c mobius.init is wlm.user.init
: INIT.JITTERS
    0 dur-jitter !
    0 pitch-jitter !
    0 loudness-jitter !
    0 control-jitter !
    0 dur-inc-jitter !
    0 pitch-inc-jitter !
    0 control-inc-jitter !
    0 loudness-inc-jitter !
;

: DO.WLM
\ these two lines require a higher version of hmsl than 4.19
\ they'll set the initial window size...
    600 -> gr_window_height
    700 -> gr_window_width
    init.jitters
    init.wlm-list
    wlm.user.init
    build.wlm-screen
    hmsl
    #-channels 0
    DO
            0 i put.value: wlm-on
    LOOP
    midi.killall
    \ the next line is only printed in the source code version, not the turnkey
    wlm-turnkey @ not
    IF
        ." To start the piece again, just type HMSL, not DO.WLM " cr
    THEN
;

\ this is for the turnkeyed version: don't use in the compiled version
wlm-turnkey @
.if
: WLM.INIT
    hmsl.init
;

: WLM.TERM
    hmsl.term
;
.then


\ the conditional compilation is just for the turnkey version
wlm-turnkey @ not
.if
    cr cr cr
    tab tab ." Type DO.WLM to start piece "
    cr cr cr
.then

