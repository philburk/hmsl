\ "Script file" for turnkeying TWLM

\ actions don't seem to be in 421
\ forget task-action_utils
forget task-shape_editor
include wlm:wlm_load
include hsys:turnkey.f
\ 2/8/93: added this to avoid HMSL confusions, as per new manual
\ but didn't work
\ " TWLM" ostype: 'TWLM'
\ 'TLWM' -> MIDIM_CLIENT
'c wlm.init 'c do.wlm 'c wlm.term turnkey
