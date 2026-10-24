\ Select which MIDI outputs HMSL sends to.
\
\ MIDI-PORT chooses between the internal synthesizer and external MIDI.
\ These words choose which external outputs are used when MIDI-PORT is
\ set to MIDI_PORT_EXTERNAL. Messages are sent to every output that is on.
\ Output 0 is the virtual "HMSL" port that other apps, eg. Logic Pro,
\ can listen to. It is on by default. Other outputs, eg. a hardware
\ synthesizer, are off until you turn them on.
\ HMSL remembers which outputs you turned on or off, by name.
\
\ Example:
\     MIDI.OUTPUTS
\     2 MIDI.OUTPUT.ON
\     midi_port_external midi-port !
\
\ Author: Phil Burk
\ Copyright 2026

ANEW TASK-MIDI_OUTPUTS

80 constant MIDI_OUTPUT_NAME_MAX
create MIDI-OUTPUT-NAME midi_output_name_max allot

: MIDI.OUTPUT.NAME ( index -- addr count , name of MIDI output )
    midi-output-name midi_output_name_max hostMIDI_OutputName()
    midi-output-name swap
;

: MIDI.OUTPUTS ( -- , list MIDI outputs and how many messages each was sent )
    cr ."  #  State  Messages  Name" cr
    hostMIDI_NumOutputs() 0
    ?DO
        i 2 .r 2 spaces
        i hostMIDI_OutputEnabled()
        IF ." ON    " ELSE ." off   " THEN
        i hostMIDI_OutputCount() 8 .r 2 spaces
        i midi.output.name type cr
    LOOP
    ." Use: n MIDI.OUTPUT.ON  or  n MIDI.OUTPUT.OFF" cr
    midi-port @ midi_port_external =
    IF
        ." MIDI-PORT is external, so these outputs are used." cr
    ELSE
        ." MIDI-PORT is internal. Enter  midi_port_external midi-port !  to use these." cr
    THEN
;

: MIDI.OUTPUT.ON ( index -- , turn on a MIDI output )
    true hostMIDI_EnableOutput()
;

: MIDI.OUTPUT.OFF ( index -- , turn off a MIDI output )
    false hostMIDI_EnableOutput()
;
