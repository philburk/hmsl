\ chordal sequences
\ use stim.beep1 for these....
anew task-simple_chords

: put.simple.waveform
      4  0 do i da.channel! 5bit-wave 32 da.sample! loop ;
: put.non.simple.waveform
      4 0 do  i da.channel! 5bit-wave 32 23 wchoose da.sample! loop ;

: play.chord
             0 da.channel! 2000 1000   wchoose    dup dup prev-note0 ! 
                           da.period! 64 32 wchoose da.loudness!
             dup 1 da.channel! 10  1 wchoose / dup prev-note1 !
                           da.period! 64 35 wchoose da.loudness!
             dup 2 da.channel!  10  1 wchoose /  dup prev-note2 !
                           da.period! 64 15 wchoose da.loudness!
             dup 3 da.channel! 10 1 wchoose / dup prev-note3 !
                           da.period! 64 5 wchoose da.loudness!
             drop
	     time@ prev-time0 !
;

: harmonic.chords
         if
             play.chord          
          then
;

\  put non-simple waveform: change length of waveforms slightly
\ and add simple increment to integral multiplier....
: inharmonic.chords
         if 
            play.chord
         then
;

           
