
anew task-load-swirl

assign hf    hmsl:fth
assign hh   hmsl:amiga/hostdep
assign ju   hmsl:amiga/util
assign hs   hmsl:amiga/samples

include? task-amiga_sound        hh:amiga_sound.fth
include? task-tunings            hf:tunings.fth
include? task-ratios             hf:ratios.fth
include? task-envelopes          hh:envelopes.fth
include? task-8svx.j             hh:8svx.j
include? task-waveforms          hh:waveforms.fth
include? task-amiga_instrument   hh:amiga_instrument.fth
include? task-bsort              ju:bsort.fth

