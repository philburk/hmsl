anew task-mega_acts


\ Note: On the original Amiga with JForth, addresses were relative to the
\ JForth dictionary base and converted by >ABS, so `64000 choose 2*` read
\ random slices of the compiled Forth dictionary/program in CHIP RAM.
\ In pForth, addresses are native pointers (>ABS is a no-op), so passing
\ a raw offset like `64000 choose 2*` dereferences unmapped low memory.
\ Adding `codebase` offsets the random address into the valid pForth
\ code dictionary.

: MOD.PAIR ( base_channel -- , modulate next higher channel )
     dup da.channel!
\    64000 choose 2* 20000 da.sample!   ( modulator - original Amiga/JForth code )
     64000 choose 2* codebase + 20000 da.sample!   ( modulator )
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
\    64000 choose 2* 40000 30000 wchoose da.sample!   ( modulator - original Amiga/JForth code )
     64000 choose 2* codebase + 40000 30000 wchoose da.sample!   ( modulator )
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
\    64000 choose 2* 40000 1000 wchoose da.sample!   ( modulator - original Amiga/JForth code )
     64000 choose 2* codebase + 40000 1000 wchoose da.sample!   ( modulator )
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


