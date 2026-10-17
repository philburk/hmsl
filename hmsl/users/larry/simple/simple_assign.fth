\ assign routines to actions
anew task-simple_assign

'c mod.mania put.init: sact-1
'c mod.mania2 put.init: sact-2
'c mod.mania3 put.init: sact-3

'c da.kill put.term: sact-1
'c da.kill put.term: sact-2
'c da.kill put.term: sact-3

'c stim.beep0 put.stimulus: sact-4
'c stim.beep1 put.stimulus: sact-5
'c stim.beep2 put.stimulus: sact-6
'c stim.beep3 put.stimulus: sact-7
'c stim.midi.beep put.stimulus: sact-33

'c rsp.beep0 put.response: sact-4
'c rsp.beep1 put.response: sact-5
'c rsp.beep2 put.response: sact-6
'c rsp.beep3 put.response: sact-7
'c rsp.midi.beep put.response: sact-33

'c init.beep0 put.init: sact-4
'c init.beep1 put.init: sact-5
'c init.beep2 put.init: sact-6
'c init.beep3 put.init: sact-7
'c init.midi.beep put.init: sact-33

'c term.beep0 put.term: sact-4
'c term.beep1 put.term: sact-5
'c term.beep2 put.term: sact-6
'c term.beep3 put.term: sact-7

: voice.reset
     init.prev-times
     da.kill
     0 da.channel! 8bit-wave 256 da.sample!
	0 da.freqmod! 0 da.ampmod!
     1 da.channel! 5bit-wave 32 da.sample!
	0 da.freqmod! 0 da.ampmod!
     2 da.channel! 3bit-wave 8 da.sample!
	0 da.freqmod! 0 da.ampmod!
     3 da.channel! 6bit-wave 64 da.sample!
	0 da.freqmod! 0 da.ampmod!  
;

: start.4
    4 0 do i da.channel! da.start loop 
;

: init.harm
    start.4 put.simple.waveform ;
: init.inharm
    start.4 put.non.simple.waveform ;

'c always put.stimulus: sact-8
'c always put.stimulus: sact-9
'c always put.stimulus: sact-10
'c always put.stimulus: sact-11
'c always put.stimulus: sact-12
'c always put.stimulus: sact-13
'c always put.stimulus: sact-14
'c always put.stimulus: sact-15
'c always put.stimulus: sact-34
'c always put.stimulus: sact-35

'c inc.tempo0 put.response: sact-8
'c inc.tempo1 put.response: sact-9
'c inc.tempo2 put.response: sact-10
'c inc.tempo3 put.response: sact-11
'c inc.midi-tempo put.response: sact-34

'c dec.tempo0 put.response: sact-12
'c dec.tempo1 put.response: sact-13
'c dec.tempo2 put.response: sact-14
'c dec.tempo3 put.response: sact-15
'c dec.midi-tempo put.response: sact-35

'c always put.stimulus: sact-16
'c always put.stimulus: sact-17
'c always put.stimulus: sact-18
'c always  put.stimulus: sact-19

'c rsp.gliss0 put.response: sact-16
'c rsp.gliss1 put.response: sact-17
'c rsp.gliss2 put.response: sact-18
'c rsp.gliss3 put.response: sact-19

\ 'c term.beep0 put.term: sact-16
\ 'c term.beep1 put.term: sact-17
\ 'c term.beep2 put.term: sact-18
\ 'c term.beep3 put.term: sact-19

'c init.beep0 put.init: sact-16
'c init.beep1 put.init: sact-17
'c init.beep2 put.init: sact-18
'c init.beep3 put.init: sact-19                   


'c inc.up/down? put.response: sact-20
'c dec.up/down? put.response: sact-21
'c always put.stimulus: sact-20
'c always put.stimulus: sact-21


'c always put.stimulus: sact-22
'c always put.stimulus: sact-23
'c always put.stimulus: sact-24
'c always put.stimulus: sact-25

'c change.wave1 put.response: sact-22
'c change.wave2 put.response: sact-23
'c change.wave3 put.response: sact-24
'c change.wave4 put.response: sact-25

'c am.on.0 put.init: sact-26
'c am.off.0 put.term: sact-26
'c fm.on.1 put.init: sact-27
'c fm.off.1 put.term: sact-27
'c am.on.2 put.init: sact-28
'c am.off.2 put.term: sact-28
'c fm.on.3 put.init: sact-29
'c fm.off.3 put.term: sact-29


'c stim.beep0 put.stimulus: sact-30
'c harmonic.chords put.response: sact-30
'c stim.beep0 put.stimulus: sact-31
'c inharmonic.chords put.response: sact-31

'c init.harm put.init: sact-30
'c init.inharm  put.init: sact-31

'c voice.reset  put.term:  sact-32

