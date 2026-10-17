anew task-mega_acts


: MOD.PAIR ( base_channel -- , modulate next higher channel )
     dup da.channel!
     64000 choose 2* 20000 da.sample!   ( modulator )
     20000 da.period!
     1 da.freqmod!
   1 da.ampmod!
     da.start
     1+ da.channel!
     da_complex da.wave!
     da.start
;

: MOD.MANIA ( Use all channels )
     0 mod.pair 200 msec
     2 mod.pair
;

\ update of mod.mania, with some more complex choosing of
\ period, sample size, and carrier waveshape

: MOD.PAIR2 ( base_channel -- , modulate next higher channel )
     dup da.channel!
     64000 choose 2* 40000 30000 wchoose da.sample!   ( modulator )
     40000 20000 wchoose da.period!
     1 da.freqmod!
   1 da.ampmod!
     da.start
     1+ da.channel!
     5 choose  da.wave!
     da.start 
;

: MOD.MANIA2 ( Use all channels )
     0 mod.pair2 200 msec
     2 mod.pair2

;

: MOD.PAIR3 ( base_channel -- , modulate next higher channel )
     dup da.channel!
     64000 choose 2* 40000 1000 wchoose da.sample!   ( modulator )
     40000 10000 wchoose da.period!
     1 da.freqmod!
	1 da.ampmod!
     da.start
     1+ da.channel!
     5 choose  da.wave!
     da.start 
;

: MOD.MANIA3 ( Use all channels )
     0 mod.pair3 200 msec
     2 mod.pair3
;


