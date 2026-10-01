\ Select which MIDI inputs HMSL listens to.
\
\ MIDI input always comes from external devices, whatever MIDI-PORT is set to.
\ If a device sends the same notes on more than one input then you will
\ receive each note twice. Use MIDI.INPUTS to see which inputs are receiving,
\ then MIDI.INPUT.OFF to turn off the extra ones.
\ HMSL remembers which inputs you turned on or off, by name.
\
\ Example:
\     MIDI.INPUTS
\     3 MIDI.INPUT.OFF
\
\ Author: Phil Burk
\ Copyright 2026

ANEW TASK-MIDI_INPUTS

80 constant MIDI_INPUT_NAME_MAX
create MIDI-INPUT-NAME midi_input_name_max allot

: MIDI.INPUT.NAME ( index -- addr count , name of MIDI input )
    midi-input-name midi_input_name_max hostMIDI_InputName()
    midi-input-name swap
;

: MIDI.INPUTS ( -- , list MIDI inputs and how many messages each received )
    cr ."  #  State  Messages  Name" cr
    hostMIDI_NumInputs() 0
    ?DO
        i 2 .r 2 spaces
        i hostMIDI_InputEnabled()
        IF ." ON    " ELSE ." off   " THEN
        i hostMIDI_InputCount() 8 .r 2 spaces
        i midi.input.name type cr
    LOOP
    ." Use: n MIDI.INPUT.ON  or  n MIDI.INPUT.OFF" cr
;

: MIDI.INPUT.ON ( index -- , turn on a MIDI input )
    true hostMIDI_EnableInput()
;

: MIDI.INPUT.OFF ( index -- , turn off a MIDI input )
    false hostMIDI_EnableInput()
;
