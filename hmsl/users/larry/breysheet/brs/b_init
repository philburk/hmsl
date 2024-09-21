\ b'rey'sheet initialization file
\ MOD: PLB init LAST-ADC-VALUE, add B.SLAVE B.MASTER,
\          add TIME@ RAND-SEED ! and DA.KILL

anew task-b_init

\ these values need to be hueristically determined
1855 local-hi-freq !
30 local-lo-freq !

: PATCH.ACTION.PROBS  ( -- , patch bug in CG.HIT.MIDDLE V3.41 )
    'c n>text put.text.function: action-prob-grid-0
    'c n>text put.text.function: action-prob-grid-1
    'c n>text put.text.function: action-prob-grid-2
    'c n>text put.text.function: action-prob-grid-3
;

: B.INIT
    time@ rand-seed !
    patch.action.probs
    " Decr-#" 'c var.down.response se.set.custom
	1 midi.channel! \ set for fbo1
	8 adc-debounce !
        0 last-adc-value !  ( PLB )
	dep-5.init
	init.pitch
	init.wst
	build.b_dep-algorithm
	build.b.acts
	0 da.channel! use: wst-0 from.l.array scaled.da.freq! da.start
	1 da.channel! use: wst-1 from.l.array scaled.da.freq! da.start
	2 da.channel! use: wst-2 from.l.array scaled.da.freq! da.start
	3 da.channel! use: wst-3 from.l.array scaled.da.freq! da.start
;


: B.TERM
	free.pitch.arrays
	clear: action-table
	free.wst
	free: algorithm-array
	free: b_dep-algorithm
    da.kill
    se.reset.custom
;

: BREYSHEET  ( -- )
    b.init hmsl b.term
;

: B.SLAVE  ( -- )
    slave-mode on breysheet
;

: B.MASTER  ( -- )
    slave-mode off  breysheet
;

if.forgotten b.term
