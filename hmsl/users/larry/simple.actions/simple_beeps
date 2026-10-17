\ simple concert, four beeping actions
anew task-simple_beeps

\ ============== stimuli =========================

\ tempo tempo n -- tempo+some.little.bit 
: choose.util choose + swap wchoose ;

: stim.beep0
      tempo0 @ dup 25 choose.util
      prev-time0 @ + doitnow? 
;
: stim.beep1
      tempo1 @ dup 15 choose.util
      prev-time1 @ + doitnow? 
;
: stim.beep2
      tempo2 @ dup 10 choose.util
      prev-time2 @ + doitnow? 
;
: stim.beep3
      tempo3 @ dup 5 choose.util
      prev-time3 @ + doitnow? 
;

: stim.midi.beep
	midi-tempo @ 
	midi-prev-time @ + doitnow?
;

\ ================ responses ===================

: loud.util 64 choose da.loudness! ;

: rsp.beep0
      if 0 da.channel! 1500  128 wchoose 
         dup prev-note0 ! da.period!
         loud.util
         8bit-wave 256 128 wchoose da.sample!
         256 choose 8bit-wave get.local-counter: sact-4
         256  mod + c!
         time@ prev-time0 !
      then
;

: rsp.beep1
      if 1 da.channel! 1500 128 wchoose 
         dup prev-note1 ! da.period!
         loud.util
         5bit-wave 32 23  wchoose da.sample!
         256 choose 5bit-wave get.local-counter: sact-5
         32  mod + c!
         time@ prev-time1 !
      then
;

: rsp.beep2
      if 2 da.channel! 1000 200  wchoose 
         dup prev-note2 ! da.period!
         loud.util
         3bit-wave 8 4 wchoose da.sample!
         256 choose 3bit-wave get.local-counter: sact-6
         8  mod + c!
         time@ prev-time2 !
      then
;

: rsp.beep3
      if 3 da.channel! 1000 128  wchoose 
         dup prev-note3 ! da.period!
         loud.util
         6bit-wave 53  31 wchoose da.sample! 
         256 choose 6bit-wave get.local-counter: sact-7
         64  mod + c!
         time@ prev-time3 !
      then
;

: rsp.midi.beep
     if 1 midi-channel !
	23 choose 
	dup cr ." midi preset: " .
	midi.preset
	time@ midi-prev-time !
     then
;

\ =============  initializations ===========

: init.util da.channel! da.start time@ ;

: init.beep0 0 init.util prev-time0 ! ;
: init.beep1 1 init.util prev-time1 ! ;
: init.beep2 2 init.util prev-time2 ! ;
: init.beep3 3 init.util prev-time3 ! ;
: init.midi.beep time@ midi-prev-time ! ;

\ ============= terms =====================

: term.beep0 0 da.channel! da.stop ;
: term.beep1 1 da.channel! da.stop ;
: term.beep2 2 da.channel! da.stop ;
: term.beep3 3 da.channel! da.stop ;


: dec.tempo0 if tempo0 @ 1- 15  max tempo0 ! then ; 
: dec.tempo1 if tempo1 @ 1- 5  max tempo1 ! then ; 
: dec.tempo2 if tempo2 @ 1- 3  max tempo2 ! then ; 
: dec.tempo3 if tempo3 @ 1- 1  max tempo3 ! then ; 
: dec.midi-tempo if midi-tempo @ 1- 1 max midi-tempo ! then ;

: inc.tempo0 if tempo0 @ 1+ 20000 min tempo0 ! then ; 
: inc.tempo1 if tempo1 @ 1+ 7000  min tempo1 ! then ; 
: inc.tempo2 if tempo2 @ 1+ 5000  min tempo2 ! then ; 
: inc.tempo3 if tempo3 @ 1+ 4700 min tempo3 ! then ; 
: inc.midi-tempo if midi-tempo @ 1+ 10000 min midi-tempo ! then ;

