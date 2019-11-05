\ Device independant TIME handling.
\ These words are vectored to allow a composer to change the notion
\ of time in HMSL.
\
\ Author: Phil Burk
\ Copyright 1986 -  Phil Burk, Larry Polansky, David Rosenboom.
\ All Rights Reserved
\
\ MOD: PLB 10/14/87 Added calls to HARD.TIME.INIT and TERM
\ MOD: PLB 11/16/89 Add RATE->MICS/BEAT
\ MOD: PLB 11/17/89  Big changes.
\        Removed TIME-BASE  HARD.TIME@ SOFT.TIME@ .
\        TIME@ TIME! and TIME+! are now deferred!!
\        Default is ahead.time , time-advance set to zero.
\ MOD: PLB 2/9/90 Added VTIME.SAVE stuff from SES
\ MOD: PLB 3/18/90 Add DELAY
\ MOD: PLB 4/13/90 Change AO.REPEAT to SELF.CLOCK
\ MOD: PLB 6/7/90 Fixed Stack for delay.
\ MOD: PLB 1/2/91 Changed DELAY , no abort, BUMPS vtime with MAX
\ MOD: PLB 2/7/91 Set defaults for TIME@ TIME! and TIME+!
\ MOD: PLB 4/9/91 Set default for TIME@ to FALSE
\ MOD: PLB 7/1/91 Comment out SYS.INIT so that MIDI can INIT when ready.
\ MOD: PLB 2/18/92 Add SYS.TASK

ANEW TASK-TIME

defer TIME@
' false is time@
defer TIME!
' drop is time!
defer TIME+!
' drop is time+!

: TIME+1  ( -- , used by software clocks )
    1 time+!
;

\ This word is used to decide if it's time for an event.
\ It compares the time on the stack to the current time.
max-inline @ 12 max-inline !
: TIME> ( time1 time2 -- flag , use circular number system )
    - 0> both
;
: TIME< ( time1 time2 -- flag )
    - 0< both
;
max-inline !

: DOITNOW? ( atime -- flag , true if time is now or past)
     dup time-virtual !
     time@ time> not  ( careful with changing this word, subtle )
;

: VTIME@ ( -- virtual_time )
    time-virtual @
;

: VTIME! ( virtual_time -- )
    time-virtual !
;

: VTIME+! ( N -- )
    time-virtual +!
;

: AHEAD.TIME@ ( -- time , give time ahead of RTC )
      rtc.time@ time-advance @ +
;

: AHEAD.TIME! ( time -- , set ahead time )
      time-advance @ - 0 max rtc.time!
;

: ANOW  ( -- , set virtual time to be advance time )
    time@ vtime!
;

: RNOW ( -- , set virtual time to be real time )
    rtc.time@ vtime!
;

\ Reserve for self incrementing clock.
defer SELF.CLOCK ( function to call each cycle of HMSL scheduler)

: USE.SELF.TIMER  ( -- , advance time as HMSL scans )
    rtc.stop
    'c time+1 is self.clock
;

: USE.HARDWARE.TIMER ( -- , Use HARDWARE timer )
    rtc.start
    'c noop is self.clock
;

: USE.SOFTWARE.TIMER ( -- , Use SOFTWARE timer )
    rtc.stop
    'c noop is self.clock
;

: 0TIME  ( -- zero out timer variables )
    0 rtc.time!
    0 time-virtual !
;

32 constant VTIME_SMAX
CREATE VTIME-DATA vtime_smax cell* allot

stack.header vtime-stack

: VTIME.PUSH  ( vtime -- , push onto time stack )
    vtime-stack stack.push
;
: VTIME.POP ( -- vtime )
    vtime-stack stack.pop
;

: VTIME.SAVE  ( -- , save current virtual time , PUSH)
    vtime@ vtime.push
;
: VTIME.RESTORE ( -- , restore from stack , POP)
    vtime.pop vtime!
;

: VTIME.COPY ( -- , copy from vtime stack , COPY)
    vtime-stack stack.copy vtime!
;
: VTIME.DROP ( -- , drop from vtime stack )
    vtime-stack stack.drop
;

: TIME.INIT ( -- , initialize vectors )
    " TIME.INIT" debug.type
    0 time-current !
    rtc.init
    'c ahead.time! is time!
    'c ahead.time@ is time@
    'c rtc.time+!  is time+!
    'c noop is self.clock
    rtc.rate@ 6 / time-advance !
    rtc.rate@ 2* 3 / ticks/beat !
    anow
    vtime-data vtime_smax vtime-stack stack.setup
;

: TIME.TERM  ( -- )
    " TIME.TERM" debug.type
    rtc.term
;

: SYS.INIT sys.init time.init ;
: SYS.TERM time.term sys.term ;

: WATCH ( -- )
    BEGIN
        time@ . cr
        ?terminal
    UNTIL
;

: RATE->MICS/BEAT  ( ticks/second -- microseconds/beat )
    >r ticks/beat @ 1000000 r> */
;

: DELAY  ( ticks -- , delay N ticks and advance VTIME )
\ force VTIME to be N past now
    dup vtime@ rtc.time@ max + vtime!
    time@ +
    BEGIN dup time@ time<
    UNTIL drop
;


: ?DELAY  { ticks | flag -- flag , delay N ticks and advance VTIME }
\ force VTIME to be N past now
    ticks vtime@ rtc.time@ max + vtime!
    ticks time@ +
    BEGIN dup time@ time<
        ?terminal dup -> flag
        OR
    UNTIL
    drop
    flag
;

: SYS.TASK sys.task self.clock ;

