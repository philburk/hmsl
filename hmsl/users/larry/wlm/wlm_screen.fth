\ WLM Screen
\ author LP
\ 5/13/92

\ 1/23/93 added harmonic and ratiometric rhythm functions
\ 1/23/93 moved init word to new file, and added deferred user init

\ GR_WINDOW_LEFT GR_WINDOW_TOP GR_WINDOW_WIDTH and
\   GR_WINDOW_HEIGHT to allow user to customize HMSL window.
\   Eg.    600 -> GR_WINDOW_WIDTH   HMSL.OPEN

ANEW TASK-WLM_SCREEN



\ some constants used to plot out the screen
180 k: grid_width ( width and height of the majority of the grids )
170 k: grid_height
215 k: x_inc ( x displacement of each grid across screen )
400 k: y_pos ( starting y top y corner of main grids )
130 k: x_group_offset ( x distance between groups of functions )
3400 k: globals_y_pos ( y position for global changers )
3800 k: jitters_y_pos ( y position for jitters )



\ *****************************************************
\ grids for turning wlm's on, and individual parameters
\ same block of code used for some of the control grids
: SETUP.WLM.CONTROL { control -- }
    9 control put.text.size: []
    1 #-channels control new: []
    grid_width grid_height control put.wh: []
;

\ **********************************
: WLM-ON.FUNCTION { val part | wlm -- }
    part at: wlm-list
    -> wlm
    val
        IF wlm start: []
        ELSE wlm stop: []
        \ when a WLM is turned off, update its parametric screen values
            wlm get.pitch: [] part put.value: wlm-pitch
            wlm get.duration: [] part put.value: wlm-dur
            wlm get.loudness: [] part put.value: wlm-loudness
            wlm get.control: [] part put.value: wlm-control
        THEN
;

\ If #-channels is not 16, change the text stuffing in this and the following words
\ turns wlm's off and on
: BUILD.WLM-ON
    wlm-on setup.wlm.control
    stuff{ " 1" " 2" " 3" " 4" " 5" " 6" " 7" " 8"
           " 9" " 10" " 11" " 12" " 13" " 14" " 15" " 16"
        }stuff.text: wlm-on
    " wlm" put.title: wlm-on
    'c wlm-on.function put.down.function: wlm-on
;

\ now global one
: WLM-ONS.FUNCTION { val part | wlm -- }
    16 0 DO
        i at: wlm-list
        -> wlm
        val
            IF wlm start: []
               true i put.value: wlm-on
            ELSE wlm stop: []
            \ when a WLM is turned off, update its parametric screen values
                wlm get.pitch: [] part put.value: wlm-pitch
                wlm get.duration: [] part put.value: wlm-dur
                wlm get.loudness: [] part put.value: wlm-loudness
                wlm get.control: [] part put.value: wlm-control
                false i put.value: wlm-on
            THEN
    LOOP
;

: BUILD.WLM-ONS
    1 1 new: WLM-ONS
    9  put.text.size: WLM-ONS
    grid_width grid_height put.wh: WLM-ONS
    " ons " put.title: WLM-ONS
    stuff{ " ? " }stuff.text: wlm-ons
    'c WLM-ONS.FUNCTION   put.down.function: WLM-ONS

;

\ turn pitch, loudness, and duration on and off...
: WLM-PITCH-ON.FUNCTION { val part | wlm -- }
    part at: wlm-list -> wlm
    val
        IF wlm pitch.on: []
        ELSE wlm pitch.off: [] wlm get.pitch: []
            \ show new pitch
            i put.value: wlm-pitch
        THEN
;

: BUILD.WLM-PITCH-ON
    wlm-pitch-on setup.wlm.control
    stuff{ " 1" " 2" " 3" " 4" " 5" " 6" " 7" " 8"
           " 9" " 10" " 11" " 12" " 13" " 14" " 15" " 16"
        }stuff.text: wlm-pitch-on
    " p-on" put.title: wlm-pitch-on
    #-channels 0 DO
        true  i put.value: wlm-pitch-on
    LOOP
    'c wlm-pitch-on.function put.down.function: wlm-pitch-on
;

\ now global one
: WLM-PITCH-ONS.FUNCTION { val part | wlm -- }
    16 0 DO
        i at: wlm-list
        -> wlm
        val
            IF  wlm pitch.on: []
               true i put.value: wlm-pitch-on
            ELSE
                wlm pitch.off: [] wlm get.pitch: []
                \ show new pitch
                i put.value: wlm-pitch
                false i put.value: wlm-pitch-on
            THEN
    LOOP
;

: BUILD.WLM-PITCH-ONS
    1 1 new: WLM-PITCH-ONS
    9  put.text.size: WLM-PITCH-ONS
    grid_width grid_height put.wh: WLM-PITCH-ONS
    true 0 put.value: wlm-pitch-ons
    " p's " put.title: WLM-PITCH-ONS
    stuff{ " ? " }stuff.text: WLM-PITCH-ONS
    'c WLM-PITCH-ONS.FUNCTION   put.down.function: WLM-PITCH-ONS

;


: WLM-DUR-ON.FUNCTION { val part | wlm -- }
    part at: wlm-list -> wlm
    val IF wlm duration.on: []
        ELSE wlm duration.off: []
             wlm get.duration: [] part put.value: wlm-dur
        THEN
;

: BUILD.WLM-DUR-ON
    wlm-dur-on setup.wlm.control
    stuff{ " 1" " 2" " 3" " 4" " 5" " 6" " 7" " 8"
           " 9" " 10" " 11" " 12" " 13" " 14" " 15" " 16"
        }stuff.text: wlm-dur-on
    " d-on" put.title: wlm-dur-on
    #-channels 0 DO
        true  i put.value: wlm-dur-on
    LOOP
    'c wlm-dur-on.function put.down.function: wlm-dur-on
;

\ now global one
: WLM-DUR-ONS.FUNCTION { val part | wlm -- }
    16 0 DO
        i at: wlm-list
        -> wlm
        val
            IF  wlm duration.on: []
                true i put.value: wlm-dur-on
            ELSE
                wlm duration.off: [] wlm get.duration: []
                \ show new duration
                i put.value: wlm-dur
                false i put.value: wlm-dur-on
            THEN
    LOOP
;

: BUILD.WLM-DUR-ONS
    1 1 new: WLM-DUR-ONS
    9  put.text.size: WLM-DUR-ONS
    grid_width grid_height put.wh: WLM-DUR-ONS
    " d's " put.title: WLM-DUR-ONS
    true 0 put.value: wlm-dur-ons
    stuff{ " ? " }stuff.text: WLM-DUR-ONS
    'c WLM-DUR-ONS.FUNCTION   put.down.function: WLM-DUR-ONS

;

\ shows new loudness value when turned off...
: WLM-LOUDNESS-ON.FUNCTION { val part | wlm -- }
    part at: wlm-list -> wlm
    val IF wlm loudness.on: []
        ELSE wlm loudness.off: []
             wlm get.loudness: [] part put.value: wlm-loudness
        THEN
;

: BUILD.WLM-LOUDNESS-ON
    wlm-loudness-on setup.wlm.control
    stuff{ " 1" " 2" " 3" " 4" " 5" " 6" " 7" " 8"
           " 9" " 10" " 11" " 12" " 13" " 14" " 15" " 16"
        }stuff.text: wlm-loudness-on
    " l-on" put.title: wlm-loudness-on
    #-channels 0 DO
        true  i put.value: wlm-loudness-on
    LOOP
    'c wlm-loudness-on.function put.down.function: wlm-loudness-on
;

\ now global one
: WLM-LOUDNESS-ONS.FUNCTION { val part | wlm -- }
    16 0 DO
        i at: wlm-list
        -> wlm
        val
            IF  wlm loudness.on: []
               true i put.value: wlm-loudness-on
            ELSE
                wlm loudness.off: [] wlm get.loudness: []
                \ show new loudness
                i put.value: wlm-loudness
                false i put.value: wlm-loudness-on
            THEN
    LOOP
;

: BUILD.WLM-LOUDNESS-ONS
    1 1 new: WLM-LOUDNESS-ONS
    9  put.text.size: WLM-LOUDNESS-ONS
    grid_width grid_height put.wh: WLM-LOUDNESS-ONS
    " l's " put.title: WLM-LOUDNESS-ONS
    true 0 put.value: wlm-loudness-ons
    stuff{ " ? " }stuff.text: WLM-LOUDNESS-ONS
    'c WLM-LOUDNESS-ONS.FUNCTION    put.down.function: WLM-LOUDNESS-ONS

;

: WLM-CONTROL-ON.FUNCTION { val part | wlm -- }
    part at: wlm-list -> wlm
    val IF wlm control.on: []
        ELSE wlm control.off: []
            wlm get.control: [] part put.value: wlm-control
        THEN
;

: BUILD.WLM-CONTROL-ON
    wlm-control-on setup.wlm.control
    stuff{ " 1" " 2" " 3" " 4" " 5" " 6" " 7" " 8"
           " 9" " 10" " 11" " 12" " 13" " 14" " 15" " 16"
        }stuff.text: wlm-control-on
    " c-on" put.title: wlm-control-on
    #-channels 0 DO
        false  i put.value: wlm-control-on
    LOOP
    'c wlm-control-on.function put.down.function: wlm-control-on
;

\ now global one
: WLM-CONTROL-ONS.FUNCTION { val part | wlm -- }
    16 0 DO
        i at: wlm-list
        -> wlm
        val
            IF  wlm control.on: []
               true i put.value: wlm-control-on
            ELSE
                wlm loudness.off: [] wlm get.loudness: []
                \ show new control
                i put.value: wlm-control
                false i put.value: wlm-control-on
            THEN
    LOOP
;

: BUILD.WLM-CONTROL-ONS
    1 1 new: WLM-CONTROL-ONS
    9  put.text.size: WLM-CONTROL-ONS
    grid_width grid_height put.wh: WLM-CONTROL-ONS
    " c's " put.title: WLM-CONTROL-ONS
    false 0 put.value: wlm-control-ons
    stuff{ " ? " }stuff.text: WLM-CONTROL-ONS
    'c WLM-CONTROL-ONS.FUNCTION    put.down.function: WLM-CONTROL-ONS

;

\ *****************************************************
\ set MIDI channel for each wlm
: WLM-CHANNEL.FUNCTION { val part -- }
    val part at: wlm-list put.channel: []
;

: BUILD.WLM-CHANNEL
    wlm-channel setup.wlm.control
    " chan." put.title: wlm-channel
    1 -1 put.min: wlm-channel
    #-channels  -1 put.max: wlm-channel
    #-channels 0 DO
        i 1+ i put.value: wlm-channel
    LOOP
    'c wlm-channel.function put.move.function: wlm-channel
    'c wlm-channel.function put.down.function: wlm-channel
    'c wlm-channel.function put.up.function: wlm-channel
;

\ now global one
: WLM-CHANNELS.FUNCTION { val part -- }
    16 0 DO
        val i at: wlm-list put.channel: []
        val i put.value: wlm-channel
    LOOP
;

: BUILD.WLM-CHANNELS
    1 1 new: WLM-CHANNELS
    9  put.text.size: WLM-CHANNELS
    grid_width grid_height put.wh: WLM-CHANNELS
    " chnls " put.title: WLM-CHANNELS
    1 0 put.min:        WLM-CHANNELS
    16 0 put.max:      WLM-CHANNELS
    1 0 put.value:      WLM-CHANNELS
    'c WLM-CHANNELS.FUNCTION  put.move.function: WLM-CHANNELS
    'c WLM-CHANNELS.FUNCTION   put.down.function: WLM-CHANNELS
    'c WLM-CHANNELS.FUNCTION   put.up.function:   WLM-CHANNELS
;

\ *****************************************************
\ set MIDI controller # for each wlm
: WLM-CONTROL-#.FUNCTION { val part -- }
    val part at: wlm-list put.control-#: []
;

: BUILD.WLM-CONTROL-#
    wlm-control-# setup.wlm.control
    " ctr#" put.title: wlm-control-#
    1 -1 put.min: wlm-control-#
    127 -1 put.max: wlm-control-#
    #-channels 0 DO
        i at: wlm-list
        get.control-#: []
        i put.value: wlm-control-#
    LOOP
    'c wlm-control-#.function put.move.function: wlm-control-#
    'c wlm-control-#.function put.down.function: wlm-control-#
    'c wlm-control-#.function put.up.function: wlm-control-#
;

\ now global one
: WLM-CONTROLS-#.FUNCTION { val part -- }
    16 0 DO
        val i at: wlm-list put.control-#: []
        val i put.value: wlm-control-#
    LOOP
;

: BUILD.WLM-CONTROLS-#
    1 1 new: WLM-CONTROLS-#
    9  put.text.size: WLM-CONTROLS-#
    grid_width grid_height put.wh: WLM-CONTROLS-#
    " ctrl " put.title: WLM-CONTROLS-#
    0 0 put.min:        WLM-CONTROLS-#
    127 0 put.max:      WLM-CONTROLS-#
    10 0 put.value:      WLM-CONTROLS-#
    'c WLM-CONTROLS-#.FUNCTION  put.move.function: WLM-CONTROLS-#
    'c WLM-CONTROLS-#.FUNCTION  put.down.function: WLM-CONTROLS-#
    'c WLM-CONTROLS-#.FUNCTION  put.up.function:   WLM-CONTROLS-#
;

\ *****************************************************
\ set MIDI preset # for each wlm
: WLM-PRESET-#.FUNCTION { val part -- }
    ( first set preset in wlm itself for next time... )
    val part at: wlm-list  put.preset-#: []
    ( now change preset on midi channel )
    part at: wlm-list get.channel: []
    midi.channel!
    val midi.preset
;

: BUILD.WLM-PRESET-#
    wlm-preset-# setup.wlm.control
    " pre " put.title: wlm-preset-#
    1 -1 put.min: wlm-preset-#
    255 -1 put.max: wlm-preset-#
    #-channels 0 DO
        i at: wlm-list
        get.preset-#: []
        i put.value: wlm-preset-#
    LOOP
    'c wlm-preset-#.function put.move.function: wlm-preset-#
    'c wlm-preset-#.function put.down.function: wlm-preset-#
    'c wlm-preset-#.function put.up.function: wlm-preset-#
;

\ now global one
: WLM-PRESETS-#.FUNCTION { val part -- }
    16 0 DO
        val i at: wlm-list put.preset-#: []
        i at: wlm-list get.channel: []
        midi.channel!
        val midi.preset
        val i put.value: wlm-preset-#
    LOOP
;

: BUILD.WLM-PRESETS-#
    1 1 new: WLM-PRESETS-#
    9  put.text.size: WLM-PRESETS-#
    grid_width grid_height put.wh: WLM-PRESETS-#
    " pre " put.title: wlm-presets-#
    1 0 put.min: wlm-presets-#
    256 0 put.max: wlm-presets-#
    20 0 put.value: wlm-presets-#
    'c wlm-presets-#.function put.move.function: wlm-presets-#
    'c wlm-presets-#.function put.down.function: wlm-presets-#
    'c wlm-presets-#.function put.up.function: wlm-presets-#
;


\ *****************DURs************************
\ set duration, pitch, and loudness
: WLM-DUR.FUNCTION { val part -- }
    val part at: wlm-list put.duration: []
;

: WLM-DUR.DRAW.FUNCTION
    #-channels 0
    DO
        i at: wlm-list
        get.duration: []
        i put.value: wlm-dur
    LOOP
;

: BUILD.WLM-DUR
    wlm-dur setup.wlm.control
    " dur" put.title: wlm-dur
    1 -1 put.min: wlm-dur
    600 -1 put.max: wlm-dur
    'c wlm-dur.function put.move.function: wlm-dur
    'c wlm-dur.function put.down.function: wlm-dur
    'c wlm-dur.function put.up.function: wlm-dur
    'c wlm-dur.draw.function put.draw.function: wlm-dur
    #-channels 0 DO
        i at: wlm-list
        get.duration: []
        i put.value: wlm-dur
    LOOP
;

\ now global one
: WLM-DURS.FUNCTION { val part  |  new-val  -- }
    16 0 DO
        val dur-jitter @ + 1+ val dur-jitter @ -
        wchoose
        -> new-val
        new-val i at: wlm-list put.duration: []
        new-val i put.value: wlm-dur
    LOOP
;

: BUILD.WLM-DURS
    1 1 new: WLM-DURS
    9  put.text.size: WLM-DURS
    grid_width grid_height put.wh: WLM-DURS
    " d's " put.title: WLM-DURS
    1 0 put.min:        WLM-DURS
    600 0 put.max:      WLM-DURS
    1 0 put.value:      WLM-DURS
    'c WLM-DURS.FUNCTION  put.move.function: WLM-DURS
    'c WLM-DURS.FUNCTION   put.down.function: WLM-DURS
    'c WLM-DURS.FUNCTION   put.up.function:   WLM-DURS
;

\ now global jitters one
: WLM-DUR-JITTER.FUNCTION { val part -- }
    val dur-jitter !
;

: BUILD.WLM-DUR-JITTER
    1 1 new: WLM-DUR-JITTER
    9  put.text.size: WLM-DUR-JITTER
    grid_width grid_height put.wh: WLM-DUR-JITTER
    " dj's " put.title: WLM-DUR-JITTER
    0 0 put.min:        WLM-DUR-JITTER
    600 0 put.max:      WLM-DUR-JITTER
    0 0 put.value:      WLM-DUR-JITTER
    'c WLM-DUR-JITTER.FUNCTION put.move.function: WLM-DUR-JITTER
    'c WLM-DUR-JITTER.FUNCTION  put.down.function: WLM-DUR-JITTER
    'c WLM-DUR-JITTER.FUNCTION  put.up.function:   WLM-DUR-JITTER
;


\ *********************PITCHES******************************
: WLM-PITCH.FUNCTION { val part -- }
    val part at: wlm-list put.pitch: []
;

: WLM-PITCH.DRAW.FUNCTION
        #-channels 0
    DO
        i at: wlm-list
        get.pitch: []
        i put.value: wlm-pitch
    LOOP
;

: BUILD.WLM-PITCH
    wlm-pitch setup.wlm.control
    " pit" put.title: wlm-pitch
    1 -1 put.min: wlm-pitch
    127 -1 put.max: wlm-pitch
    'c wlm-pitch.function put.move.function: wlm-pitch
    'c wlm-pitch.function put.down.function: wlm-pitch
    'c wlm-pitch.function put.up.function: wlm-pitch
    'c wlm-pitch.draw.function put.draw.function: wlm-pitch
    #-channels 0 DO
        i at: wlm-list
        get.pitch: []
        i put.value: wlm-pitch
    LOOP
;

\ now global one
: WLM-PITCHES.FUNCTION { val part | new-val -- }
    16 0 DO
        val pitch-jitter @ + 1+ val pitch-jitter @ -
        wchoose
        -> new-val
        new-val i at: wlm-list put.pitch: []
        new-val i put.value: wlm-pitch
    LOOP
;

: BUILD.WLM-PITCHES
    1 1 new: WLM-PITCHES
    9  put.text.size: WLM-PITCHES
    grid_width grid_height put.wh: WLM-PITCHES
    " p's " put.title: WLM-PITCHES
    1 0 put.min:        WLM-PITCHES
    127 0 put.max:      WLM-PITCHES
    1 0 put.value:      WLM-PITCHES
    'c WLM-PITCHES.FUNCTION   put.move.function: WLM-PITCHES
    'c WLM-PITCHES.FUNCTION    put.down.function: WLM-PITCHES
    'c WLM-PITCHES.FUNCTION    put.up.function:   WLM-PITCHES
;

\ now global jitters one
: WLM-PITCH-JITTER.FUNCTION { val part -- }
    val pitch-jitter !
;

: BUILD.WLM-PITCH-JITTER
    1 1 new: WLM-PITCH-JITTER
    9  put.text.size: WLM-PITCH-JITTER
    grid_width grid_height put.wh: WLM-PITCH-JITTER
    " pj's " put.title: WLM-PITCH-JITTER
    0 0 put.min:        WLM-PITCH-JITTER
    63 0 put.max:      WLM-PITCH-JITTER
    0 0 put.value:      WLM-PITCH-JITTER
    'c WLM-PITCH-JITTER.FUNCTION put.move.function: WLM-PITCH-JITTER
    'c WLM-PITCH-JITTER.FUNCTION  put.down.function: WLM-PITCH-JITTER
    'c WLM-PITCH-JITTER.FUNCTION  put.up.function:   WLM-PITCH-JITTER
;

\ ************** LOUDNESSES****************************
: WLM-LOUDNESS.FUNCTION { val part -- }
    val part at: wlm-list put.loudness: []
;

: BUILD.WLM-LOUDNESS
    wlm-loudness setup.wlm.control
    " loud" put.title: wlm-loudness
    0 -1 put.min: wlm-loudness
    127 -1 put.max: wlm-loudness
    'c wlm-loudness.function put.move.function: wlm-loudness
    'c wlm-loudness.function put.down.function: wlm-loudness
    'c wlm-loudness.function put.up.function: wlm-loudness
    #-channels 0 DO
        i at: wlm-list
        get.loudness: []
        i put.value: wlm-loudness
    LOOP
;

\ now global one
: WLM-LOUDNESSES.FUNCTION { val part | new-val -- }
    16 0 DO
        val loudness-jitter @ + 1+ val loudness-jitter @ -
        wchoose
        -> new-val
        new-val i at: wlm-list put.loudness: []
        new-val i put.value: wlm-loudness
    LOOP
;

: BUILD.WLM-LOUDNESSES
    1 1 new: WLM-LOUDNESSES
    9  put.text.size: WLM-LOUDNESSES
    grid_width grid_height put.wh: WLM-LOUDNESSES
    " l's " put.title: WLM-LOUDNESSES
    1 0 put.min:        WLM-LOUDNESSES
    127 0 put.max:      WLM-LOUDNESSES
    1 0 put.value:      WLM-LOUDNESSES
    'c WLM-LOUDNESSES.FUNCTION   put.move.function: WLM-LOUDNESSES
    'c WLM-LOUDNESSES.FUNCTION    put.down.function: WLM-LOUDNESSES
    'c WLM-LOUDNESSES.FUNCTION    put.up.function:   WLM-LOUDNESSES
;

\ now global jitters one

: WLM-LOUDNESS-JITTER.FUNCTION { val part -- }
    val loudness-jitter !
;

: BUILD.WLM-LOUDNESS-JITTER
    1 1 new: WLM-LOUDNESS-JITTER
    9  put.text.size: WLM-LOUDNESS-JITTER
    grid_width grid_height put.wh: WLM-LOUDNESS-JITTER
    " lj's " put.title: WLM-LOUDNESS-JITTER
    0 0 put.min:        WLM-LOUDNESS-JITTER
    63 0 put.max:      WLM-LOUDNESS-JITTER
    0 0 put.value:      WLM-LOUDNESS-JITTER
    'c WLM-LOUDNESS-JITTER.FUNCTION  put.move.function: WLM-LOUDNESS-JITTER
    'c WLM-LOUDNESS-JITTER.FUNCTION   put.down.function: WLM-LOUDNESS-JITTER
    'c WLM-LOUDNESS-JITTER.FUNCTION   put.up.function:   WLM-LOUDNESS-JITTER
;



\ ********** controls***************

: WLM-CONTROL.FUNCTION { val part -- }
    val part at: wlm-list put.control: []
;

: BUILD.WLM-CONTROL
    wlm-control setup.wlm.control
    " ctrl " put.title: wlm-control
    0 -1 put.min: wlm-control
    127 -1 put.max: wlm-control
    'c wlm-control.function put.move.function: wlm-control
    'c wlm-control.function put.down.function: wlm-control
    'c wlm-control.function put.up.function: wlm-control
    #-channels 0 DO
        i at: wlm-list
        get.control: []
        i put.value: wlm-control
    LOOP
;

\ now global one
: WLM-CONTROLS.FUNCTION { val part | new-val -- }
    16 0 DO
        val control-jitter @ + 1+ val control-jitter @ -
        wchoose
        -> new-val
        new-val i at: wlm-list put.control: []
        new-val i put.value: wlm-control
    LOOP
;

: BUILD.WLM-CONTROLS
    1 1 new: WLM-CONTROLS
    9  put.text.size: WLM-CONTROLS
    grid_width grid_height put.wh: WLM-CONTROLS
    " c's " put.title:  WLM-CONTROLS
    1 0 put.min:        WLM-CONTROLS
    127 0 put.max:      WLM-CONTROLS
    1 0 put.value:      WLM-CONTROLS
    'c WLM-CONTROLS.FUNCTION   put.move.function: WLM-CONTROLS
    'c WLM-CONTROLS.FUNCTION    put.down.function: WLM-CONTROLS
    'c WLM-controls.FUNCTION    put.up.function:   WLM-controls
;

\ now global jitters one

: WLM-CONTROL-JITTER.FUNCTION { val part -- }
    val control-jitter !
;

: BUILD.WLM-CONTROL-JITTER
    1 1 new: WLM-CONTROL-JITTER
    9  put.text.size: WLM-CONTROL-JITTER
    grid_width grid_height put.wh: WLM-CONTROL-JITTER
    " cj's " put.title: WLM-CONTROL-JITTER
    0 0 put.min:        WLM-CONTROL-JITTER
    63 0 put.max:      WLM-CONTROL-JITTER
    0 0 put.value:      WLM-CONTROL-JITTER
    'c WLM-CONTROL-JITTER.FUNCTION   put.move.function: WLM-CONTROL-JITTER
    'c WLM-CONTROL-JITTER.FUNCTION    put.down.function: WLM-CONTROL-JITTER
    'c WLM-CONTROL-JITTER.FUNCTION    put.up.function:   WLM-CONTROL-JITTER
;


\ ********** staccatos ***************

: WLM-STACCATO.FUNCTION { val part -- }
    val part at: wlm-list put.staccato: []
;

: BUILD.WLM-STACCATO
    WLM-STACCATO setup.WLM.control
    " stac" put.title: WLM-STACCATO
    0 -1 put.min: WLM-STACCATO
    100 -1 put.max: WLM-STACCATO
    'c WLM-STACCATO.FUNCTION  put.move.function: WLM-STACCATO
    'c WLM-STACCATO.FUNCTION  put.down.function: WLM-STACCATO
    'c WLM-STACCATO.FUNCTION  put.up.function: WLM-STACCATO
    #-channels 0 DO
        i at: wlm-list
        get.staccato: []
        i put.value: wlm-staccato
    LOOP
;

\ now global one
: WLM-STACCATOS.FUNCTION { val part | new-val -- }
    16 0 DO
        val staccato-jitter @ + 1+ val staccato-jitter @ -
        wchoose
        -> new-val
        new-val i at: wlm-list put.staccato: []
        new-val i put.value: wlm-staccato
    LOOP
;

: BUILD.WLM-STACCATOS
    1 1 new: WLM-STACCATOS
    9  put.text.size: WLM-STACCATOS
    grid_width grid_height put.wh: WLM-STACCATOS
    " s's " put.title: WLM-STACCATOS
    1 0 put.min:        WLM-STACCATOS
    100 0 put.max:      WLM-STACCATOS
    0 0 put.value:      WLM-STACCATOS
    'c WLM-STACCATOS.FUNCTION   put.move.function: WLM-STACCATOS
    'c WLM-STACCATOS.FUNCTION    put.down.function: WLM-STACCATOS
    'c WLM-STACCATOS.FUNCTION    put.up.function:   WLM-STACCATOS
;

\ now global jitters one

: WLM-STACCATO-JITTER.FUNCTION { val part -- }
    val staccato-jitter !
;

: BUILD.WLM-STACCATO-JITTER
    1 1 new: WLM-STACCATO-JITTER
    9  put.text.size: WLM-STACCATO-JITTER
    grid_width grid_height put.wh: WLM-STACCATO-JITTER
    " sj's " put.title: WLM-STACCATO-JITTER
    0 0 put.min:        WLM-STACCATO-JITTER
    50 0 put.max:      WLM-STACCATO-JITTER
    0 0 put.value:      WLM-STACCATO-JITTER
    'c WLM-STACCATO-JITTER.FUNCTION   put.move.function: WLM-STACCATO-JITTER
    'c WLM-STACCATO-JITTER.FUNCTION    put.down.function: WLM-STACCATO-JITTER
    'c WLM-STACCATO-JITTER.FUNCTION    put.up.function:   WLM-STACCATO-JITTER
;


\ *****************************************************
\ set wlm probabilities for pitch, loudness and duration
: WLM-DUR-PROB.FUNCTION { val part -- }
    100 val - part at: wlm-list put.duration-prob: []
;

: BUILD.WLM-DUR-PROB
    wlm-dur-prob setup.wlm.control
    " d-pr " put.title: wlm-dur-prob
    0 -1 put.min: wlm-dur-prob
    100 -1 put.max: wlm-dur-prob
    'c wlm-dur-prob.function put.move.function: wlm-dur-prob
    'c wlm-dur-prob.function put.down.function: wlm-dur-prob
    'c wlm-dur-prob.function put.up.function: wlm-dur-prob
    #-channels 0 DO
        i at: wlm-list
        get.duration-prob: []
        i put.value: wlm-dur-prob
    LOOP
;

\ now global one
: WLM-DUR-PROBS.FUNCTION { val part -- }
    16 0 DO
        100 val - i at: wlm-list put.duration-PROB: []
        val i put.value: wlm-dur-PROB
    LOOP
;

: BUILD.WLM-DUR-PROBS
    1 1 new: WLM-DUR-PROBS
    9  put.text.size: WLM-DUR-PROBS
    grid_width grid_height put.wh: WLM-DUR-PROBS
    " d-ps " put.title: WLM-DUR-PROBS
    0 0 put.min:        WLM-DUR-PROBS
    100 0 put.max:      WLM-DUR-PROBS
    1 0 put.value:      WLM-DUR-PROBS
    'c WLM-DUR-PROBS.FUNCTION  put.move.function: WLM-DUR-PROBS
    'c WLM-DUR-PROBS.FUNCTION   put.down.function: WLM-DUR-PROBS
    'c WLM-DUR-PROBS.FUNCTION   put.up.function:   WLM-DUR-PROBS
;

: WLM-PITCH-PROB.FUNCTION { val part -- }
    100 val - part at: wlm-list put.pitch-prob: []
;

: BUILD.WLM-PITCH-PROB
    wlm-pitch-prob setup.wlm.control
    " p-pr" put.title: wlm-pitch-prob
    0 -1 put.min: wlm-pitch-prob
    100 -1 put.max: wlm-pitch-prob
    'c wlm-pitch-prob.function put.move.function: wlm-pitch-prob
    'c wlm-pitch-prob.function put.down.function: wlm-pitch-prob
    'c wlm-pitch-prob.function put.up.function: wlm-pitch-prob
    #-channels 0 DO
        i at: wlm-list
        get.pitch-prob: []
        i put.value: wlm-pitch-prob
    LOOP
;

\ now global one
: WLM-PITCH-PROBS.FUNCTION { val part -- }
    16 0 DO
        100 val - i at: wlm-list put.pitch-PROB: []
        val i put.value: wlm-pitch-PROB
    LOOP
;

: BUILD.WLM-PITCH-PROBS
    1 1 new: WLM-PITCH-PROBS
    9  put.text.size: WLM-PITCH-PROBS
    grid_width grid_height put.wh: WLM-PITCH-PROBS
    " p-ps " put.title: WLM-PITCH-PROBS
    0 0 put.min:        WLM-PITCH-PROBS
    100 0 put.max:      WLM-PITCH-PROBS
    1 0 put.value:      WLM-PITCH-PROBS
    'c WLM-PITCH-PROBS.FUNCTION   put.move.function: WLM-PITCH-PROBS
    'c WLM-PITCH-PROBS.FUNCTION    put.down.function: WLM-PITCH-PROBS
    'c WLM-PITCH-PROBS.FUNCTION    put.up.function:   WLM-PITCH-PROBS
;

: WLM-LOUDNESS-PROB.FUNCTION { val part -- }
    100 val - part at: wlm-list put.loudness-prob: []
;

: BUILD.WLM-LOUDNESS-PROB
    wlm-loudness-prob setup.wlm.control
    " l-pr" put.title: wlm-loudness-prob
    0 -1 put.min: wlm-loudness-prob
    100 -1 put.max: wlm-loudness-prob
    'c wlm-loudness-prob.function put.move.function: wlm-loudness-prob
    'c wlm-loudness-prob.function put.down.function: wlm-loudness-prob
    'c wlm-loudness-prob.function put.up.function: wlm-loudness-prob
    #-channels 0 DO
        i at: wlm-list
        get.loudness-prob: []
        i put.value: wlm-loudness-prob
    LOOP
;
\ now global one
: WLM-LOUDNESS-PROBS.FUNCTION { val part -- }
    16 0 DO
        100 val -  i at: wlm-list put.LOUDNESS-PROB: []
         val i put.value: wlm-LOUDNESS-PROB
    LOOP
;

: BUILD.WLM-LOUDNESS-PROBS
    1 1 new: WLM-LOUDNESS-PROBS
    9  put.text.size: WLM-LOUDNESS-PROBS
    grid_width grid_height put.wh: WLM-LOUDNESS-PROBS
    " l-ps " put.title: WLM-LOUDNESS-PROBS
    0 0 put.min:        WLM-LOUDNESS-PROBS
    100 0 put.max:      WLM-LOUDNESS-PROBS
    1 0 put.value:      WLM-LOUDNESS-PROBS
    'c WLM-LOUDNESS-PROBS.FUNCTION  put.move.function: WLM-LOUDNESS-PROBS
    'c WLM-LOUDNESS-PROBS.FUNCTION   put.down.function: WLM-LOUDNESS-PROBS
    'c WLM-LOUDNESS-PROBS.FUNCTION   put.up.function:   WLM-LOUDNESS-PROBS
;

\
: WLM-CONTROL-PROB.FUNCTION { val part -- }
    100 val - part at: wlm-list put.control-prob: []
;

: BUILD.WLM-CONTROL-PROB
    wlm-control-prob setup.wlm.control
    " c-pr" put.title: wlm-control-prob
    0 -1 put.min: wlm-control-prob
    100 -1 put.max: wlm-control-prob
    'c wlm-control-prob.function put.move.function: wlm-control-prob
    'c wlm-control-prob.function put.down.function: wlm-control-prob
    'c wlm-control-prob.function put.up.function:   wlm-control-prob
    #-channels 0 DO
        i at: wlm-list
        get.control-prob: []
        i put.value: wlm-control-prob
    LOOP
;

\ now global one
: WLM-CONTROL-PROBS.FUNCTION { val part -- }
    16 0 DO
        100 val - i at: wlm-list put.control-prob: []
         val  i put.value: wlm-control-prob
    LOOP
;

: BUILD.WLM-CONTROL-PROBS
    1 1 new: WLM-CONTROL-PROBS
    9  put.text.size: WLM-CONTROL-PROBS
    grid_width grid_height put.wh: WLM-CONTROL-PROBS
    " c-ps " put.title: WLM-CONTROL-PROBS
    0 0 put.min:        WLM-CONTROL-PROBS
    100 0 put.max:      WLM-CONTROL-PROBS
    1 0 put.value:      WLM-CONTROL-PROBS
    'c WLM-CONTROL-PROBS.FUNCTION  put.move.function: WLM-CONTROL-PROBS
    'c WLM-CONTROL-PROBS.FUNCTION  put.down.function: WLM-CONTROL-PROBS
    'c WLM-CONTROL-PROBS.FUNCTION  put.up.function:   WLM-CONTROL-PROBS
;

\ **************dur incs*******************************
\ set increment for pitch, duration and loudness...
: WLM-DUR-INC.FUNCTION { val part -- }
    val part at: wlm-list put.duration-inc: []
;

: BUILD.WLM-DUR-INC
    wlm-dur-inc setup.wlm.control
    " d-inc" put.title: wlm-dur-inc
    1 -1 put.min: wlm-dur-inc
    300 -1 put.max: wlm-dur-inc
    'c wlm-dur-inc.function put.move.function: wlm-dur-inc
    'c wlm-dur-inc.function put.down.function: wlm-dur-inc
    'c wlm-dur-inc.function put.up.function: wlm-dur-inc
    #-channels 0 DO
        i at: wlm-list
        get.duration-inc: []
        i put.value: wlm-dur-inc
    LOOP
;

\ now global one
: WLM-DUR-INCS.FUNCTION { val part | new-val -- }
    16 0 DO
        val dur-inc-jitter @ + 1+ val dur-inc-jitter @ -
        wchoose
        -> new-val
        new-val i at: wlm-list put.duration-inc: []
        new-val i put.value: wlm-dur-inc
    LOOP
;

: BUILD.WLM-DUR-INCS
    1 1 new: WLM-DUR-INCS
    9  put.text.size: WLM-DUR-INCS
    grid_width grid_height put.wh: WLM-DUR-INCS
    " d's " put.title: WLM-DUR-INCS
    1 0 put.min:        WLM-DUR-INCS
    300 0 put.max:      WLM-DUR-INCS
    1 0 put.value:      WLM-DUR-INCS
    'c WLM-DUR-INCS.FUNCTION  put.move.function: WLM-DUR-INCS
    'c WLM-DUR-INCS.FUNCTION   put.down.function: WLM-DUR-INCS
    'c WLM-DUR-INCS.FUNCTION   put.up.function:   WLM-DUR-INCS
;

\ now global jitters one
: WLM-DUR-INC-JITTER.FUNCTION { val part -- }
    val dur-inc-jitter !
;

: BUILD.WLM-DUR-INC-JITTER
    1 1 new: WLM-DUR-INC-JITTER
    9  put.text.size: WLM-DUR-INC-JITTER
    grid_width grid_height put.wh: WLM-DUR-INC-JITTER
    " dij's " put.title: WLM-DUR-INC-JITTER
    0 0 put.min:        WLM-DUR-INC-JITTER
    600 0 put.max:      WLM-DUR-INC-JITTER
    0 0 put.value:      WLM-DUR-INC-JITTER
    'c WLM-DUR-INC-JITTER.FUNCTION  put.move.function: WLM-DUR-INC-JITTER
    'c WLM-DUR-INC-JITTER.FUNCTION   put.down.function: WLM-DUR-INC-JITTER
    'c WLM-DUR-INC-JITTER.FUNCTION   put.up.function:   WLM-DUR-INC-JITTER
;

\ ******* pitch incs*************
: WLM-PITCH-INC.FUNCTION { val part -- }
    val part at: wlm-list put.pitch-inc: []
;

: BUILD.WLM-PITCH-INC
    wlm-pitch-inc setup.wlm.control
    " p-inc" put.title: wlm-pitch-inc
    1 -1 put.min: wlm-pitch-inc
    24 -1 put.max: wlm-pitch-inc
    'c wlm-pitch-inc.function put.move.function: wlm-pitch-inc
    'c wlm-pitch-inc.function put.down.function: wlm-pitch-inc
    'c wlm-pitch-inc.function put.up.function: wlm-pitch-inc
    #-channels 0 DO
        i at: wlm-list
        get.pitch-inc: []
        i put.value: wlm-pitch-inc
    LOOP
;

\ now global one
: WLM-PITCH-INCS.FUNCTION { val part | new-val -- }
    16 0 DO
        val pitch-inc-jitter @ + 1+ val pitch-inc-jitter @ -
        wchoose
        -> new-val
        new-val i at: wlm-list put.pitch-inc: []
        new-val i put.value: wlm-pitch-inc
    LOOP
;

: BUILD.WLM-PITCH-INCS
    1 1 new: WLM-PITCH-INCS
    9  put.text.size: WLM-PITCH-INCS
    grid_width grid_height put.wh: WLM-PITCH-INCS
    " p's " put.title: WLM-PITCH-INCS
    1 0 put.min:        WLM-PITCH-INCS
    24  0 put.max:      WLM-PITCH-INCS
    1 0 put.value:      WLM-PITCH-INCS
    'c WLM-PITCH-INCS.FUNCTION  put.move.function: WLM-PITCH-INCS
    'c WLM-PITCH-INCS.FUNCTION   put.down.function: WLM-PITCH-INCS
    'c WLM-PITCH-INCS.FUNCTION   put.up.function:   WLM-PITCH-INCS
;

\ now global jitters one
: WLM-PITCH-INC-JITTER.FUNCTION { val part -- }
    val PITCH-inc-jitter !
;

: BUILD.WLM-PITCH-INC-JITTER
    1 1 new: WLM-PITCH-INC-JITTER
    9  put.text.size: WLM-PITCH-INC-JITTER
    grid_width grid_height put.wh: WLM-PITCH-INC-JITTER
    " pij's " put.title: WLM-PITCH-INC-JITTER
    0 0 put.min:        WLM-PITCH-INC-JITTER
    600 0 put.max:      WLM-PITCH-INC-JITTER
    0 0 put.value:      WLM-PITCH-INC-JITTER
    'c WLM-PITCH-INC-JITTER.FUNCTION  put.move.function: WLM-PITCH-INC-JITTER
    'c WLM-PITCH-INC-JITTER.FUNCTION   put.down.function: WLM-PITCH-INC-JITTER
    'c WLM-PITCH-INC-JITTER.FUNCTION   put.up.function:   WLM-PITCH-INC-JITTER
;
\ **************loudness incs*******************************
: WLM-LOUDNESS-INC.FUNCTION { val part -- }
    val part at: wlm-list put.loudness-inc: []
;

: BUILD.WLM-LOUDNESS-INC
    wlm-loudness-inc setup.wlm.control
    " l-inc" put.title: wlm-loudness-inc
    1 -1 put.min: wlm-loudness-inc
    60 -1 put.max: wlm-loudness-inc
    'c wlm-loudness-inc.function put.move.function: wlm-loudness-inc
    'c wlm-loudness-inc.function put.down.function: wlm-loudness-inc
    'c wlm-loudness-inc.function put.up.function: wlm-loudness-inc
    #-channels 0 DO
        i at: wlm-list
        get.loudness-inc: []
        i put.value: wlm-loudness-inc
    LOOP
;

\ now global one
: WLM-LOUDNESS-INCS.FUNCTION { val part | new-val -- }
    16 0 DO
        val loudness-inc-jitter @ + 1+ val loudness-inc-jitter @ -
        wchoose
        -> new-val
        new-val i at: wlm-list put.loudness-inc: []
        new-val i put.value: wlm-loudness-inc
    LOOP
;

: BUILD.WLM-LOUDNESS-INCS
    1 1 new: WLM-LOUDNESS-INCS
    9  put.text.size: WLM-LOUDNESS-INCS
    grid_width grid_height put.wh: WLM-LOUDNESS-INCS
    " l's " put.title: WLM-LOUDNESS-INCS
    1 0 put.min:        WLM-LOUDNESS-INCS
    60  0 put.max:      WLM-LOUDNESS-INCS
    1 0 put.value:      WLM-LOUDNESS-INCS
    'c WLM-LOUDNESS-INCS.FUNCTION  put.move.function: WLM-LOUDNESS-INCS
    'c WLM-LOUDNESS-INCS.FUNCTION   put.down.function: WLM-LOUDNESS-INCS
    'c WLM-LOUDNESS-INCS.FUNCTION   put.up.function:   WLM-LOUDNESS-INCS
;

\ now global jitters one
: WLM-LOUD-INC-JITTER.FUNCTION { val part -- }
    val loudness-inc-jitter !
;

: BUILD.WLM-LOUDNESS-INC-JITTER
    1 1 new: WLM-LOUDNESS-INC-JITTER
    9  put.text.size: WLM-LOUDNESS-INC-JITTER
    grid_width grid_height put.wh: WLM-LOUDNESS-INC-JITTER
    " lij's " put.title: WLM-LOUDNESS-INC-JITTER
    0 0 put.min:        WLM-LOUDNESS-INC-JITTER
    600 0 put.max:      WLM-LOUDNESS-INC-JITTER
    0 0 put.value:      WLM-LOUDNESS-INC-JITTER
    'c WLM-LOUD-INC-JITTER.FUNCTION   put.move.function:  WLM-LOUDNESS-INC-JITTER
    'c WLM-LOUD-INC-JITTER.FUNCTION    put.down.function: WLM-LOUDNESS-INC-JITTER
    'c WLM-LOUD-INC-JITTER.FUNCTION    put.up.function:   WLM-LOUDNESS-INC-JITTER
;
\ **************control incs*******************************
: WLM-CONTROL-INC.FUNCTION { val part -- }
    val part at: wlm-list put.control-inc: []
;

: BUILD.WLM-CONTROL-INC
    wlm-control-inc setup.wlm.control
    " c-inc" put.title: wlm-control-inc
    1 -1 put.min: wlm-control-inc
    60 -1 put.max: wlm-control-inc
    'c wlm-control-inc.function put.move.function: wlm-control-inc
    'c wlm-control-inc.function put.down.function: wlm-control-inc
    'c wlm-control-inc.function put.up.function: wlm-control-inc
    #-channels 0 DO
        i at: wlm-list
        get.control-inc: []
        i put.value: wlm-control-inc
    LOOP
;

\ now global one
: WLM-CONTROL-INCS.FUNCTION { val part | new-val -- }
    16 0 DO
        val control-inc-jitter @ + 1+ val control-inc-jitter @ -
        wchoose
        -> new-val
        new-val i at: wlm-list put.control-inc: []
        new-val i put.value: wlm-control-inc
    LOOP
;

: BUILD.WLM-CONTROL-INCS
    1 1 new: WLM-CONTROL-INCS
    9  put.text.size: WLM-CONTROL-INCS
    grid_width grid_height put.wh: WLM-CONTROL-INCS
    " c's " put.title: WLM-CONTROL-INCS
    1 0 put.min:        WLM-CONTROL-INCS
    60  0 put.max:      WLM-CONTROL-INCS
    1 0 put.value:      WLM-CONTROL-INCS
    'c WLM-CONTROL-INCS.FUNCTION  put.move.function: WLM-CONTROL-INCS
    'c WLM-CONTROL-INCS.FUNCTION   put.down.function: WLM-CONTROL-INCS
    'c WLM-CONTROL-INCS.FUNCTION   put.up.function:   WLM-CONTROL-INCS
;

\ now global jitters one
: WLM-CONTROL-INC-JITTER.FUNCTION { val part -- }
    val control-inc-jitter !
;

: BUILD.WLM-CONTROL-INC-JITTER
    1 1 new: WLM-CONTROL-INC-JITTER
    9  put.text.size: WLM-CONTROL-INC-JITTER
    grid_width grid_height put.wh: WLM-CONTROL-INC-JITTER
    " cij's " put.title: WLM-CONTROL-INC-JITTER
    0 0 put.min:        WLM-CONTROL-INC-JITTER
    600 0 put.max:      WLM-CONTROL-INC-JITTER
    0 0 put.value:      WLM-CONTROL-INC-JITTER
    'c WLM-CONTROL-INC-JITTER.FUNCTION    put.move.function:  WLM-CONTROL-INC-JITTER
    'c WLM-CONTROL-INC-JITTER.FUNCTION     put.down.function: WLM-CONTROL-INC-JITTER
    'c WLM-CONTROL-INC-JITTER.FUNCTION     put.up.function:   WLM-CONTROL-INC-JITTER
;
\ *****************************************

\ grids for setting ranges of parameters...
: WLM-PITCH-RANGE.FUNCTION { val part | temp-wlm  t-hi t-lo -- }
    part #-channels mod ( -- wlm-# )
    -> temp-wlm ( this is the actual wlm you're accessing )
    part #-channels <
    IF ( if getting high value in top row )
        temp-wlm get.value: wlm-pitch-range ( -- hi )
        -> t-hi
        part #-channels + get.value: wlm-pitch-range ( -- lo )
        -> t-lo
        t-hi t-lo  max  -> t-hi
        t-hi part put.value: wlm-pitch-range
    ELSE ( getting low value )
        temp-wlm #-channels + get.value: wlm-pitch-range ( -- lo )
        -> t-lo
        temp-wlm get.value: wlm-pitch-range ( -- hi )
        -> t-hi
        t-hi t-lo min  -> t-lo
        t-lo temp-wlm #-channels + put.value: wlm-pitch-range
    THEN
    t-lo t-hi
    \ now put the new range in the wlm
    part #-channels mod at: wlm-list
    put.pitch-range: [] ( syntax is lo, high put.pitch.range: )
;

: BUILD.WLM-PITCH-RANGE
    9 wlm-pitch-range put.text.size: []
    #-channels 2 wlm-pitch-range new: []
    grid_width grid_height wlm-pitch-range put.wh: []
    " P-Range" put.title: wlm-pitch-range
    #-channels  0 DO
        127 i put.max: wlm-pitch-range
        10 i put.min: wlm-pitch-range
        1 i #-channels + put.min: wlm-pitch-range
        116 i #-channels + put.max: wlm-pitch-range
    LOOP
    'c wlm-pitch-range.function put.move.function: wlm-pitch-range
    'c wlm-pitch-range.function put.down.function: wlm-pitch-range
    'c wlm-pitch-range.function put.up.function: wlm-pitch-range
    #-channels 0 DO
        i at: wlm-list
        get.pitch-range: [] ( -- lo hi )
        i put.value: wlm-pitch-range
        i #-channels  + put.value: wlm-pitch-range
    LOOP
;

: WLM-PITCH-RANGES.FUNCTION { val part | t-hi t-lo -- }
    part 0= ( hi values )
    IF
        #-channels 0 DO
            i at: wlm-list
            get.pitch-range: [] -> t-hi -> t-lo
            val t-lo max  ->  t-hi
            t-lo t-hi i at: wlm-list put.pitch-range: []
            t-hi i put.value: wlm-pitch-range
            \ now protect the global ranger grid
            val 1 get.value: wlm-pitch-ranges max
            0 put.value: wlm-pitch-ranges
        LOOP
    ELSE ( lo values )
        #-channels 0 DO
            i at: wlm-list
            get.pitch-range: []  -> t-hi -> t-lo
            val t-hi min  ->  t-lo
            t-lo t-hi i at: wlm-list put.pitch-range: []
            t-lo i #-channels + put.value: wlm-pitch-range
            \ now protect the global ranger grid
            val 0 get.value: wlm-pitch-ranges min
            1 put.value: wlm-pitch-ranges
        LOOP
    THEN
;

: BUILD.WLM-PITCH-RANGES
    9 wlm-pitch-ranges put.text.size: []
    1 2 wlm-pitch-ranges new: []
    grid_width grid_height wlm-pitch-ranges put.wh: []
    " P-Ranges" put.title: wlm-pitch-ranges
    127 0 put.max: wlm-pitch-ranges
    10 0 put.min: wlm-pitch-ranges
    1 1  put.min: wlm-pitch-ranges
    116 1  put.max: wlm-pitch-ranges
    127 0 put.value: wlm-pitch-ranges
    1 1 put.value: wlm-pitch-ranges
    'c wlm-pitch-ranges.function put.move.function: wlm-pitch-ranges
    'c wlm-pitch-ranges.function put.down.function: wlm-pitch-ranges
    'c wlm-pitch-ranges.function put.up.function:   wlm-pitch-ranges
;


: WLM-LOUDNESS-RANGE.FUNCTION { val part | temp-wlm  t-hi t-lo -- }
    part #-channels mod ( -- wlm-# )
    -> temp-wlm ( this is the actual wlm you're accessing )
    part #-channels <
    IF ( if getting high value in top row )
        temp-wlm get.value: wlm-loudness-range ( -- hi )
        -> t-hi
        part #-channels + get.value: wlm-LOUDNESS-range ( -- lo )
        -> t-lo
        t-hi t-lo  max  -> t-hi
        t-hi part put.value: wlm-LOUDNESS-range
    ELSE ( getting low value )
        temp-wlm #-channels + get.value: wlm-LOUDNESS-range ( -- lo )
        -> t-lo
        temp-wlm get.value: wlm-LOUDNESS-range ( -- hi )
        -> t-hi
        t-hi t-lo min  -> t-lo
        t-lo temp-wlm #-channels + put.value: wlm-LOUDNESS-range
    THEN
    t-lo t-hi
    \ now put the new range in the wlm
    part #-channels mod at: wlm-list
    put.LOUDNESS-range: []  ( syntax is lo, high put.LOUDNESS.range: )
;

: BUILD.WLM-LOUDNESS-RANGE
    9 wlm-loudness-range put.text.size: []
    #-channels 2 wlm-loudness-range new: []
    grid_width grid_height wlm-loudness-range put.wh: []
    " L-Range" put.title: wlm-loudness-range
    #-channels  0 DO
        127 i put.max: wlm-loudness-range
        10 i put.min: wlm-loudness-range
        1 i #-channels + put.min: wlm-loudness-range
        116 i #-channels + put.max: wlm-loudness-range
    LOOP
    'c wlm-loudness-range.function put.move.function: wlm-loudness-range
    'c wlm-loudness-range.function put.down.function: wlm-loudness-range
    'c wlm-loudness-range.function put.up.function: wlm-loudness-range
    #-channels 0 DO
        i at: wlm-list
        get.loudness-range: [] ( -- lo hi )
         i put.value: wlm-loudness-range
        i #-channels + put.value: wlm-loudness-range
    LOOP
;

: WLM-LOUDNESS-RANGES.FUNCTION { val part | t-hi t-lo -- }
    part 0= ( hi values )
    IF
        #-channels 0 DO
            i at: wlm-list
            get.loudness-range: [] -> t-hi -> t-lo
            val t-lo max  ->  t-hi
            t-lo t-hi i at: wlm-list put.loudness-range: []
            t-hi i put.value: wlm-loudness-range
            \ now protect the global ranger grid
            val 1 get.value: wlm-loudness-ranges max
            0 put.value: wlm-loudness-ranges
        LOOP
    ELSE ( lo values )
        #-channels 0 DO
            i at: wlm-list
            get.loudness-range: []  -> t-hi -> t-lo
            val t-hi min  ->  t-lo
            t-lo t-hi i at: wlm-list put.loudness-range: []
            t-lo i #-channels + put.value: wlm-loudness-range
                \ now protect the global ranger grid
            val 0 get.value: wlm-loudness-ranges min
            1 put.value: wlm-loudness-ranges
        LOOP
    THEN
;

: BUILD.WLM-LOUDNESS-RANGES
    9 wlm-loudness-ranges put.text.size: []
    1 2 wlm-loudness-ranges new: []
    grid_width grid_height wlm-loudness-ranges put.wh: []
    " L-Ranges" put.title: wlm-loudness-ranges
    127 0 put.max: wlm-loudness-ranges
    10 0 put.min: wlm-loudness-ranges
    1 1  put.min: wlm-loudness-ranges
    116 1  put.max: wlm-loudness-ranges
    127 0 put.value: wlm-loudness-ranges
    0 1 put.value: wlm-loudness-ranges
    'c wlm-loudness-ranges.function put.move.function: wlm-loudness-ranges
    'c wlm-loudness-ranges.function put.down.function: wlm-loudness-ranges
    'c wlm-loudness-ranges.function put.up.function:   wlm-loudness-ranges
;

: WLM-DURATION-RANGE.FUNCTION { val part | temp-wlm  t-hi t-lo -- }
    part #-channels mod ( -- wlm-# )
    -> temp-wlm ( this is the actual wlm you're accessing )
    part #-channels <
    IF ( if getting high value in top row )
        temp-wlm get.value: wlm-duration-range ( -- hi )
        -> t-hi
        part #-channels + get.value: wlm-duration-range ( -- lo )
        -> t-lo
        t-hi t-lo  max  -> t-hi
        t-hi part put.value: wlm-duration-range
    ELSE ( getting low value )
        temp-wlm #-channels + get.value: wlm-duration-range ( -- lo )
        -> t-lo
        temp-wlm get.value: wlm-duration-range ( -- hi )
        -> t-hi
        t-hi t-lo min  -> t-lo
        t-lo temp-wlm #-channels + put.value: wlm-duration-range
    THEN
    t-lo t-hi
    \ now put the new range in the wlm
    part #-channels mod at: wlm-list
    put.duration-range: []  ( syntax is lo, high wlm-duration-range: )
;

: BUILD.WLM-DURATION-RANGE
    9 wlm-duration-range put.text.size: []
    #-channels 2 wlm-duration-range new: []
    grid_width grid_height wlm-duration-range put.wh: []
    " D-Range" put.title: wlm-duration-range
    #-channels  0 DO
        999 i put.max: wlm-duration-range
        3 i put.min: wlm-duration-range
        1 i #-channels + put.min: wlm-duration-range
        990 i #-channels + put.max: wlm-duration-range
    LOOP
    'c wlm-duration-range.function put.move.function: wlm-duration-range
    'c wlm-duration-range.function put.down.function: wlm-duration-range
    'c wlm-duration-range.function put.up.function: wlm-duration-range
    #-channels 0 DO
        i at: wlm-list
        get.duration-range: [] ( -- lo hi )
         i put.value: wlm-duration-range
        i #-channels + put.value: wlm-duration-range
    LOOP
;

: WLM-DURATION-RANGES.FUNCTION { val part | t-hi t-lo -- }
    part 0= ( hi values )
    IF
        #-channels 0 DO
            i at: wlm-list
            get.duration-range: [] -> t-hi -> t-lo
            val t-lo max  ->  t-hi
            t-lo t-hi i at: wlm-list put.duration-range: []
            t-hi i put.value: wlm-duration-range
            \ now protect the global ranger grid
            val 1 get.value: wlm-duration-ranges max
            0 put.value: wlm-duration-ranges
        LOOP
    ELSE ( lo values )
        #-channels 0 DO
            i at: wlm-list
            get.duration-range: []  -> t-hi -> t-lo
            val t-hi min  ->  t-lo
            t-lo t-hi i at: wlm-list put.duration-range: []
            t-lo i #-channels + put.value: wlm-duration-range
                \ now protect the global ranger grid
            val 0 get.value: wlm-duration-ranges min
            1 put.value: wlm-duration-ranges
        LOOP
    THEN
;

: BUILD.WLM-DURATION-RANGES
    9 wlm-duration-ranges put.text.size: []
    1 2 wlm-duration-ranges new: []
    grid_width grid_height wlm-duration-ranges put.wh: []
    " D-Ranges" put.title: wlm-duration-ranges
    999 0 put.max: wlm-duration-ranges
    3 0 put.min: wlm-duration-ranges
    1 1  put.min: wlm-duration-ranges
    990 1  put.max: wlm-duration-ranges
    999 0 put.value: wlm-duration-ranges
    1 1 put.value: wlm-duration-ranges
    'c wlm-duration-ranges.function put.move.function: wlm-duration-ranges
    'c wlm-duration-ranges.function put.down.function: wlm-duration-ranges
    'c wlm-duration-ranges.function put.up.function:   wlm-duration-ranges
;

: WLM-CONTROL-RANGE.FUNCTION { val part | temp-wlm  t-hi t-lo -- }
    part #-channels mod ( -- wlm-# )
    -> temp-wlm ( this is the actual wlm you're accessing )
    part #-channels <
    IF ( if getting high value in top row )
        temp-wlm get.value: wlm-control-range ( -- hi )
        -> t-hi
        part #-channels + get.value: wlm-control-range ( -- lo )
        -> t-lo
        t-hi t-lo  max  -> t-hi
        t-hi part put.value: wlm-control-range
    ELSE ( getting low value )
        temp-wlm #-channels + get.value: wlm-control-range ( -- lo )
        -> t-lo
        temp-wlm get.value: wlm-control-range ( -- hi )
        -> t-hi
        t-hi t-lo min  -> t-lo
        t-lo temp-wlm #-channels + put.value: wlm-control-range
    THEN
    t-lo t-hi
    \ now put the new range in the wlm
    part #-channels mod at: wlm-list
    put.control-range: []   ( syntax is lo, high wlm-control-range: )
;

: BUILD.WLM-CONTROL-RANGE
    9 wlm-control-range put.text.size: []
    #-channels 2 wlm-control-range new: []
    grid_width grid_height wlm-control-range put.wh: []
    " C-Range" put.title: wlm-control-range
    #-channels  0 DO
        127 i put.max: wlm-control-range
        10 i put.min: wlm-control-range
        1 i #-channels + put.min: wlm-control-range
        116 i #-channels + put.max: wlm-control-range
    LOOP
    'c wlm-control-range.function put.move.function: wlm-control-range
    'c wlm-control-range.function put.down.function: wlm-control-range
    'c wlm-control-range.function put.up.function: wlm-control-range
    #-channels 0 DO
        i at: wlm-list
        get.control-range: [] ( -- lo hi )
         i put.value: wlm-control-range
        i #-channels + put.value: wlm-control-range
    LOOP
;

: WLM-CONTROL-RANGES.FUNCTION { val part | t-hi t-lo -- }
    part 0= ( hi values )
    IF
        #-channels 0 DO
            i at: wlm-list
            get.control-range: [] -> t-hi -> t-lo
            val t-lo max  ->  t-hi
            t-lo t-hi i at: wlm-list put.control-range: []
            t-hi i put.value: wlm-control-range
            \ now protect the global ranger grid
            val 1 get.value: wlm-control-ranges max
            0 put.value: wlm-control-ranges
        LOOP
    ELSE ( lo values )
        #-channels 0 DO
            i at: wlm-list
            get.control-range: []  -> t-hi -> t-lo
            val t-hi min  ->  t-lo
            t-lo t-hi i at: wlm-list put.control-range: []
            t-lo i #-channels + put.value: wlm-control-range
            \ now protect the global ranger grid
            val 0 get.value: wlm-control-ranges min
            1 put.value: wlm-control-ranges
        LOOP
    THEN
;

: BUILD.WLM-CONTROL-RANGES
    9 wlm-control-ranges put.text.size: []
    1 2 wlm-control-ranges new: []
    grid_width grid_height wlm-control-ranges put.wh: []
    " C-Ranges" put.title: wlm-control-ranges
    127 0 put.max: wlm-control-ranges
    10 0 put.min: wlm-control-ranges
    1 1  put.min: wlm-control-ranges
    116 1  put.max: wlm-control-ranges
    127 0 put.value: wlm-control-ranges
    0 1 put.value: wlm-control-ranges
    'c wlm-control-ranges.function  put.move.function: wlm-control-ranges
    'c wlm-control-ranges.function put.down.function: wlm-control-ranges
    'c wlm-control-ranges.function  put.up.function:   wlm-control-ranges
;

\ this is a bit complicated, and  assumes one wants a certain "harmonic
\ series" tuning for the 12 notes of the midi scale. The numbers here represent,
\ in backwards order, the 1st, 2nd, 3rd, .... 16th partial... by pitch names.
\ in other words, the 13th partial is assumed to be the minor sixth, the 11th
\ the tritone, and so on. If one tunes a scale in a particular MIDI synth
\ to correspond to this, it will act like the harmonic series... or... it could just
\ be used as a quick way to spread the pitches, or set them up a certain way.
\ The user could jam their own array in the wlm.user.init word to have some
\ user preset of pitches...
: BUILD.HARM-SERIES-ARRAY
    #-channels new: harm-series-array
    48 47 46 44 43 42 40 38 36 34 31 28 24 19 12 0 #-channels stuff: harm-series-array
;

: HARM-SERIES.FUNCTION
    #-channels 0
    DO
        i at: harm-series-array
        harm-series-fund +
        i at: wlm-list
        put.pitch: []
    LOOP
    draw: wlm-pitch
;

: DURATION-RATIOS.FUNCTION
    #-channels 0
    DO
        duration-fund
        i 1+ /
        i at: wlm-list
        put.duration: []
    LOOP
    draw: wlm-dur
;

\ check grid at bottom of screen, utilities..
: WLM-FUNCTIONS.FUNCTION { val part -- }
    part
    CASE
        0 OF val
            IF start: wlm-list-job
            ELSE stop: wlm-list-job
                #-channels 0
                DO
                    i at: wlm-list
                    get.on?: []
                    i put.value: wlm-on
                LOOP
                draw: wlm-on
            THEN
        ENDOF
        1 OF sync.wlms ENDOF
        2 OF harm-series.function ENDOF
        3 OF duration-ratios.function cr ENDOF
        4 OF ." Not yet implemented " cr ENDOF
    ENDCASE
;

: BUILD.WLM-FUNCTIONS
    5 1 new: wlm-functions
    build.harm-series-array
    " Functions " put.title: wlm-functions
    400 265 put.wh: wlm-functions
    stuff{ " play" " sync" " harm" " ratio" " null"
    }stuff.text: wlm-functions
    'c wlm-functions.function put.down.function: wlm-functions
;

: WLM-MIDIKILL.FUNCTION ( val part -- )
     2drop midi.killall
;

\ overall tempo of piece.... each wlm is linked to this...
: WLM-TEMPO.FUNCTION { val part -- }
    val rtc.rate!
;

: BUILD.WLM-TEMPO
    1 1 new: wlm-tempo
    " Tempo " put.title: wlm-tempo
    350 265 put.wh: wlm-tempo
    1018 0 put.max: wlm-tempo
    1 0 put.min: wlm-tempo
    rtc.rate@ 0 put.value: wlm-tempo
    'c wlm-tempo.function put.down.function: wlm-tempo
    'c wlm-tempo.function put.move.function: wlm-tempo
    'c wlm-tempo.function put.up.function: wlm-tempo
;

\ overall tempo of piece.... each wlm is linked to this...
: WLM-HARM-SERIES-FUND.FUNCTION { val part -- }
    val -> harm-series-fund
    fundamental-tracking? @ IF
        harm-series.function
        draw: wlm-pitch
    THEN
;

: BUILD.WLM-HARM-SERIES-FUND
    1 1 new: wlm-harm-series-fund
    9 wlm-harm-series-fund put.text.size: []
    " P-Fund. " put.title: wlm-harm-series-fund
    350 265 put.wh: wlm-harm-series-fund
    96 0 put.max: wlm-harm-series-fund
    1 0 put.min: wlm-harm-series-fund
    30 0 put.value: wlm-harm-series-fund
    'c wlm-harm-series-fund.function put.down.function: wlm-harm-series-fund
    'c wlm-harm-series-fund.function put.move.function: wlm-harm-series-fund
    'c wlm-harm-series-fund.function put.up.function: wlm-harm-series-fund
;

\ overall tempo of piece.... each wlm is linked to this...
: WLM-DURATION-FUND.FUNCTION { val part -- }
    val -> duration-fund
    fundamental-tracking? @ IF
            duration-ratios.function
            draw: wlm-dur
    THEN
;

: BUILD.WLM-DURATION-FUND
     1 1 new: wlm-duration-fund
    9 wlm-duration-fund put.text.size: []
    " D-Fund. " put.title: wlm-duration-fund
    350 265 put.wh: wlm-duration-fund
    5000 0 put.max: wlm-duration-fund
    16 0 put.min: wlm-duration-fund
    duration-fund 0 put.value: wlm-duration-fund
    'c wlm-duration-fund.function put.down.function: wlm-duration-fund
    'c wlm-duration-fund.function put.move.function: wlm-duration-fund
    'c wlm-duration-fund.function put.up.function: wlm-duration-fund
;

\ whether or not to track fundamental
: WLM-FUND-TRACK.FUNCTION { val part -- }
    val -> fundamental-tracking?
;

: BUILD.FUND-TRACK
    1 1 new: wlm-fund-track
    9 wlm-fund-track put.text.size: []
    stuff{ " ?" }stuff.text: wlm-fund-track
    " Track " put.title: wlm-fund-track
    350 265 put.wh: wlm-fund-track
    duration-fund 0 put.value: wlm-fund-track
    'c wlm-fund-track.function put.down.function: wlm-fund-track
;

: CG-TIME-ADVANCE.FUNCTION { val part -- }
    val time-advance !
;

: BUILD.CG-TIME-ADVANCE
    1 1 new: CG-TIME-ADVANCE
    300 250 put.wh: CG-TIME-ADVANCE
    9 put.text.size: CG-TIME-ADVANCE
    " e-buffer " put.title: CG-TIME-ADVANCE
    0 0 put.min: CG-TIME-ADVANCE
    120 0 put.max: CG-TIME-ADVANCE
    15 0 put.value: CG-TIME-ADVANCE
    'c CG-TIME-ADVANCE.FUNCTION put.down.function: CG-TIME-ADVANCE
    'c CG-TIME-ADVANCE.FUNCTION put.up.function: CG-TIME-ADVANCE
    'c CG-TIME-ADVANCE.FUNCTION put.move.function: CG-TIME-ADVANCE
;

: WLM-SCREEN.DRAW.FUNCTION
\   gr_small_text set.text.size
    150 7300 scg.move " (revision 12/26/95) " gr.text

;

\ ***************
\ Build whole screen...
\ ***************
: BUILD.WLM-SCREEN
    72 3 new: wlm-screen
    " The World's Longest Melody (2.0, polansky)" put.title: wlm-screen
    119 put.key: wlm-screen \ W chooses this screen
    build.wlm-on
\ individuals
    build.wlm-pitch-on
    build.wlm-loudness-on
    build.wlm-dur-on
    build.wlm-control-on
\
    build.wlm-ons
    build.wlm-pitch-ons
    build.wlm-loudness-ons
    build.wlm-dur-ons
    build.wlm-control-ons
\
    build.wlm-channel
\
    build.wlm-channels
\ individuals
    build.wlm-dur
    build.wlm-pitch
    build.wlm-control
    build.wlm-loudness
    build.wlm-staccato
\ globals
    build.wlm-durs
    build.wlm-pitches
    build.wlm-controls
    build.wlm-loudnesses
    build.wlm-staccatos
\ jitters
    build.wlm-dur-jitter
    build.wlm-pitch-jitter
    build.wlm-control-jitter
    build.wlm-loudness-jitter
    build.wlm-staccato-jitter
\
    build.wlm-dur-prob
    build.wlm-pitch-prob
    build.wlm-loudness-prob
    build.wlm-control-prob
\ globals
    build.wlm-dur-probs
    build.wlm-pitch-probs
    build.wlm-loudness-probs
    build.wlm-control-probs
\
    build.wlm-pitch-inc
    build.wlm-dur-inc
    build.wlm-loudness-inc
    build.wlm-control-inc
\
    build.wlm-pitch-incs
    build.wlm-dur-incs
    build.wlm-loudness-incs
    build.wlm-control-incs
\
    build.wlm-pitch-inc-jitter
    build.wlm-dur-inc-jitter
    build.wlm-loudness-inc-jitter
    build.wlm-control-inc-jitter
\
    build.wlm-control-#
    build.wlm-preset-#

\ globals
    build.wlm-presets-#
    build.wlm-controls-#

\
    build.wlm-pitch-range
    build.wlm-loudness-range
    build.wlm-duration-range
    build.wlm-control-range
\
    build.wlm-pitch-ranges
    build.wlm-loudness-ranges
    build.wlm-duration-ranges
    build.wlm-control-ranges
\
    build.wlm-functions
    build.wlm-tempo
    build.wlm-harm-series-fund
    build.wlm-duration-fund
    build.fund-track
\
    build.cg-time-advance

\
    wlm-on       x_inc 140 -                      y_pos add: wlm-screen
    wlm-channel  x_inc 100 - 2 * x_group_offset + y_pos add: wlm-screen
\
    wlm-ons          x_inc 140 -                      globals_y_pos add: wlm-screen
    wlm-channels     x_inc 100 - 2 * x_group_offset + globals_y_pos add: wlm-screen

\
    wlm-dur-on x_inc         3 * x_group_offset  +  y_pos add: wlm-screen
    wlm-pitch-on x_inc       4 * x_group_offset  +  y_pos add: wlm-screen
    wlm-loudness-on x_inc    5 * x_group_offset  +  y_pos add: wlm-screen
    wlm-control-on x_inc     6 * x_group_offset  +  y_pos add: wlm-screen
\
    wlm-pitch-ons x_inc         4 * x_group_offset  +  globals_y_pos add: wlm-screen
    wlm-loudness-ons x_inc      5 * x_group_offset  +  globals_y_pos add: wlm-screen
    wlm-dur-ons x_inc           3 * x_group_offset  +  globals_y_pos add: wlm-screen
    wlm-control-ons x_inc       6 * x_group_offset  +  globals_y_pos add: wlm-screen
\
    wlm-dur-prob x_inc          7 * x_group_offset 2 * + y_pos add: wlm-screen
    wlm-pitch-prob  x_inc       8 * x_group_offset 2 * + y_pos add: wlm-screen
    wlm-loudness-prob x_inc     9 * x_group_offset 2 * + y_pos add: wlm-screen
    wlm-control-prob x_inc      10 * x_group_offset 2 * + y_pos add: wlm-screen
\
    wlm-dur-probs x_inc         7 *  x_group_offset 2 * + globals_y_pos add: wlm-screen
    wlm-pitch-probs  x_inc      8 *  x_group_offset 2 * + globals_y_pos add: wlm-screen
    wlm-loudness-probs x_inc    9 *  x_group_offset 2 * + globals_y_pos add: wlm-screen
    wlm-control-probs x_inc     10 * x_group_offset 2 * + globals_y_pos add: wlm-screen

\
    wlm-dur-inc  x_inc          11 * x_group_offset 3 * + y_pos add: wlm-screen
    wlm-pitch-inc x_inc         12 * x_group_offset 3 * + y_pos add: wlm-screen
    wlm-loudness-inc  x_inc     13 * x_group_offset 3 * + y_pos add: wlm-screen
    wlm-control-inc  x_inc      14 * x_group_offset 3 * + y_pos add: wlm-screen
\
    wlm-dur-inc-jitter          x_inc   11 * x_group_offset 3 * + jitters_y_pos add: wlm-screen
    wlm-pitch-inc-jitter        x_inc   12 * x_group_offset 3 * + jitters_y_pos add: wlm-screen
    wlm-loudness-inc-jitter     x_inc   13 * x_group_offset 3 * + jitters_y_pos add: wlm-screen
    wlm-control-inc-jitter      x_inc   14 * x_group_offset 3 * + jitters_y_pos add: wlm-screen
\
    wlm-dur  x_inc              15 * x_group_offset 45 10 */ + 100 - y_pos add: wlm-screen
    wlm-pitch  x_inc            16 * x_group_offset 45 10 */ + 100 -  y_pos add: wlm-screen
    wlm-loudness  x_inc         17 * x_group_offset 45 10 */ + 100 -  y_pos add: wlm-screen
    wlm-control  x_inc          18 * x_group_offset 45 10 */ + 100 -  y_pos add: wlm-screen
    wlm-staccato  x_inc         19 * x_group_offset 45 10 */ + 100 -  y_pos add: wlm-screen
\
    wlm-durs  x_inc             15 * x_group_offset 45 10 */ + 100 -  globals_y_pos add: wlm-screen
    wlm-pitches  x_inc          16 * x_group_offset 45 10 */ + 100 -  globals_y_pos add: wlm-screen
    wlm-loudnesses  x_inc       17 * x_group_offset 45 10 */ + 100 -  globals_y_pos add: wlm-screen
    wlm-controls  x_inc         18 * x_group_offset 45 10 */ + 100 -  globals_y_pos add: wlm-screen
    wlm-staccatos  x_inc        19 * x_group_offset 45 10 */ + 100 -  globals_y_pos add: wlm-screen
\
    wlm-dur-jitter  x_inc       15 * x_group_offset 45 10 */ + 100 - jitters_y_pos add: wlm-screen
    wlm-pitch-jitter  x_inc     16 * x_group_offset 45 10 */ + 100 - jitters_y_pos add: wlm-screen
    wlm-loudness-jitter  x_inc  17 * x_group_offset 45 10 */ + 100 - jitters_y_pos add: wlm-screen
    wlm-control-jitter x_inc    18 * x_group_offset 45 10 */ + 100 - jitters_y_pos add: wlm-screen
    wlm-staccato-jitter x_inc   19 * x_group_offset 45 10 */ + 100 - jitters_y_pos add: wlm-screen
\
    wlm-control-#  x_inc        19 * x_group_offset 56 10 */ + y_pos add: wlm-screen
    wlm-preset-#  x_inc         20 * x_group_offset 56 10 */ + y_pos add: wlm-screen
\
    wlm-controls-# x_inc        19 * x_group_offset 56 10 */ + globals_y_pos add: wlm-screen
    wlm-presets-# x_inc         20 * x_group_offset 56 10 */ + globals_y_pos add: wlm-screen


\
    wlm-pitch-incs  x_inc       12 * x_group_offset  3 * + globals_y_pos add: wlm-screen
    wlm-dur-incs    x_inc       11 * x_group_offset  3 * + globals_y_pos add: wlm-screen
    wlm-loudness-incs   x_inc   13 * x_group_offset  3 * + globals_y_pos add: wlm-screen
    wlm-control-incs    x_inc   14 * x_group_offset  3 * + globals_y_pos add: wlm-screen
\
    wlm-functions        x_inc      4300 add: wlm-screen
    wlm-harm-series-fund x_inc 11 * 4300 add: wlm-screen
    wlm-duration-fund    x_inc 13 * 4300 add: wlm-screen
    wlm-fund-track       x_inc 15 * 4300 add: wlm-screen
    wlm-tempo            x_inc 17 * 4300 add: wlm-screen

\
    wlm-duration-range  x_inc  4800 add: wlm-screen
    wlm-pitch-range     x_inc  5350 add: wlm-screen
    wlm-loudness-range  x_inc  5950 add: wlm-screen
    wlm-control-range   x_inc  6500 add: wlm-screen
\
    wlm-duration-ranges x_inc  3000 + 4800  add: wlm-screen
    wlm-pitch-ranges    x_inc  3000 + 5350 add: wlm-screen
    wlm-loudness-ranges x_inc  3000 + 5950 add: wlm-screen
    wlm-control-ranges  x_inc  3000 + 6500 add: wlm-screen
\
    cg-time-advance     x_inc  21 * 4300 add: wlm-screen
\
    wlm-screen default-screen !
    'c wlm-screen.draw.function put.draw.function: wlm-screen
;

: TERM.WLM-SCREEN
    se-screen default-screen !
    freeall: wlm-screen
    free: wlm-screen
;



IF.FORGOTTEN TERM.WLM-SCREEN

