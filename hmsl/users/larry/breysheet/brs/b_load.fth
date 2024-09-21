\ load sequence for b'rey'sheet

include? task-global_util brs_utils:global_util.fth

\ Change FALSE to TRUE to use ADC insteaed of MIDI
FALSE .IF
include? task-par_util brs_utils:par_util.fth
.ELSE
include? task-midi_input brs:midi_input.fth
.THEN

include? task-fb_util brs_utils:fb_util.fth
include? task-dep-5_util brs_utils:dep-5_util.fth
include? task-b_variables brs:b_variables.fth
include? task-b_utils  brs:b_utils.fth
include? task-b_tests brs:b_tests.fth
include? task-b_pitch brs:b_pitch.fth
include? task-b_wst brs:b_wst.fth
include? task-b_dep brs:b_dep.fth
include? task-b_acts brs:b_acts.fth
include? task-b_init brs:b_init.fth
