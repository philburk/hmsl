\ simple  actions utilities

anew task-simple_utilitiess

v: tempo0 v: tempo1 v: tempo2 v: tempo3 v: tempo4
10 tempo0 ! 30 tempo1 ! 50 tempo2 ! 110 tempo3 !

v: midi-tempo 10 midi-tempo !

v: prev-time0 v: prev-time1 v: prev-time2 v: prev-time3
v: prev-note0 v: prev-note1 v: prev-note2 v: prev-note3

v: midi-prev-time

: init.prev-times time@  prev-time0 ! time@  prev-time2 ! time@  prev-time3 !
                  time@  prev-time1 ! time@ midi-prev-time ! ;


\ declare some waveforms
v: 3bit-wave 8 allot
v: 5bit-wave 32 allot
v: 6bit-wave 64 allot
v: 8bit-wave 256 allot


0 da.channel! 8bit-wave 256 da.sample!
1 da.channel! 5bit-wave  32 da.sample!
2 da.channel! 3bit-wave 8 da.sample!
3 da.channel! 6bit-wave 64 da.sample!

: put.util put.action: action-table ;

: sact.init
   sact-1 put.util
   sact-2 put.util
   sact-3 put.util
   sact-4 put.util
   sact-5 put.util
   sact-6 put.util
   sact-7 put.util
   sact-8 put.util
   sact-9 put.util
   sact-10 put.util
   sact-11 put.util
   sact-12 put.util
   sact-13 put.util
   sact-14 put.util
   sact-15 put.util
   sact-16 put.util
   sact-17 put.util
   sact-18 put.util
   sact-19 put.util
   sact-20 put.util
   sact-21 put.util
   sact-22 put.util
   sact-23 put.util
   sact-24 put.util
   sact-25 put.util
   sact-26 put.util
   sact-27 put.util
   sact-28 put.util
   sact-29 put.util
   sact-30 put.util
   sact-31 put.util
   sact-32 put.util
   sact-33 put.util
   sact-34 put.util
   sact-35 put.util
;

: SACT.PLAY ( -- )
    midi.clear midi.parser.on
    default-screen @
    action-screen default-screen !
    HMSL  ( no preposted morphs )
    default-screen !
    midi.parser.off
;

: sact.term
   clear: action-table
   da.kill
;

if.forgotten sact.term

: SACT
    sact.init
    sact.play
    sact.term
;

