\ mega concert, four glissing  actions
anew task-mega_gliss

v: up/down?
: down/up up/down? @ choose  0= if -1 else 1 then ;
: down/up.util down/up 15 choose * + 128 max 3000 min ;

: rsp.gliss0
      if 0 da.channel! 
         prev-note0 @ down/up.util
         dup prev-note0 ! da.period!
         64 32 wchoose da.loudness!
         time@ prev-time0 !
      then
;

: rsp.gliss1
      if 1 da.channel!
         prev-note1 @ down/up.util
         dup prev-note1 ! da.period! 
         64 32 wchoose da.loudness!
         time@ prev-time1 !
      then
;

: rsp.gliss2
      if 2 da.channel!
         prev-note2 @ down/up.util
         dup prev-note2 ! da.period!
         64 32 wchoose da.loudness!
         time@ prev-time2 !
      then
;

: rsp.gliss3
      if 3 da.channel! 
         prev-note3 @ down/up.util
         dup prev-note3 ! da.period!
         64 32 wchoose da.loudness!
         time@ prev-time3 !
      then
;

: init.gliss0 0 da.channel! da.start time@ prev-time0 ! ;
: init.gliss1 1 da.channel! da.start time@ prev-time1 ! ;
: init.gliss2 2 da.channel! da.start time@ prev-time2 ! ;
: init.gliss3 3 da.channel! da.start time@ prev-time3 ! ;

: inc.up/down?
    if up/down? @ 1+ 1000 min up/down? ! then 
;

: dec.up/down? 
    if up/down? @ 1- 1 max up/down? ! then
;
