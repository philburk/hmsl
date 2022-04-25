\ The ENVELOPE class provides a way of modulating one audio
\ channel with another.
\ This was written for the AMIGA but may be adaptable to other
\ machines.
\
\ Author: Phil Burk
\ Copyright 1986 - David Rosenboom, Larry Polansky, Phil Burk.
\
\ MOD: PLB 3/13/87 Do a DA.CATCH after stop to prevent glitches.
\ MOD: PLB 3/18/87 Extend delay after stop for long periods.
\ MOD: PLB 10/27/87 Moved PUT.PERIOD: to waveforms.
\ MOD: PLB 12/15/87 Removed STOP: declaration.
\ MOD: PLB 4/27/88 Set limits of 0-64

MRESET PUT.HOLDAT:
ANEW TASK-ENVELOPES

decimal
\ Declare Methods
METHOD PUT.HOLDAT:
METHOD GET.HOLDAT:
METHOD PUT.MSEC:
METHOD GET.MSEC:

\ AMIGA CONSTANT for ticks per millisecond.
3579 constant DA_TICKS/MS

\ The Amiga Modulation values are 2 bytes wide.
\ The maximum value is 64.

:CLASS OB.ENVELOPE <SUPER OB.SHAPE
    IV.LONG IV-ENV-PERIOD   ( time between values )
    IV.LONG IV-ENV-HOLDAT   ( sustain point )
    IV.LONG IV-ENV-DELAY    ( kludge to latch DMA )

:M INIT:
    init: super
    8000 iv=> iv-env-period
    -1 iv=> iv-env-holdat
    2 set.width: self
    100 iv=> iv-env-delay
;M

:M NEW:  ( N -- , allow only one dimension )
    mm-type @  >r MEMF_CHIP mm-type !  ( Allocate in CHIP RAM )
    1 new: super
    r> mm-type !
    0 64 0 put.dim.limits: self
;M

:M PUT.PERIOD:  ( period -- , set ticks between values )
    iv=> iv-env-period
;M
:M GET.PERIOD:  ( -- period , get ticks between values )
    iv-env-period 
;M

\ Adjust this variable to ensure two samples pass
\ after a DA.STOP .  Not too small or audible delays.
\ If too large then some notes will not sound.
VARIABLE ENV-DELAY-FACTOR
8 env-delay-factor !

:M PUT.MSEC:   ( #msec -- , set the period so an envelope will last #msec )
    da_ticks/ms many: self */   2/
    dup put.period: self
\ Need longer delay for slower envelopes.
    env-delay-factor @  / iv=> iv-env-delay
;M

:M GET.MSEC:   ( -- #msec , calc. how many msec env will last. )
    get.period: self   2*
    many: self da_ticks/ms */
;M

:M PUT.HOLDAT:  ( holdat -- , sustain point )
    iv=> iv-env-holdat
;M
:M GET.HOLDAT:  ( -- holdat , sustain point )
    iv-env-holdat 
;M


:M STOP:    ( -- , stop the current envelope )
    1 da.period! da.stop
    iv-env-delay 0 DO LOOP  ( delay to catch change. %Q )
;M

: ENV.SETEND ( -- ,  Remain at last value. )
    data.addr: self many: self 1- 2* + 1 da.envelope!  
;

:M START:   ( -- , start the envelope happening )
    stop: self
    get.period: self da.period!
    get.holdat: self  dup 0> 
    IF
        data.addr: self   swap 2dup da.envelope!
        da.start
        2* +  1 da.envelope!  ( stay at sustain point when done )
    ELSE
        drop data.addr: self many: self da.envelope!
        da.start
        env.setend
    THEN        
;M

:M FINISH:  ( -- , Continue with envelope after sustain point )
    get.holdat: self dup 0 >
    IF
        stop: self
\ Continue from sustain point of envelope.
        data.addr: self   over 1+ 2* + ( start of release )
        many: self rot - 1- ( length remaining ) da.envelope!
        da.start
        env.setend
    ELSE drop
    THEN
;M

;CLASS   

\ Stock envelope.
OB.ENVELOPE ENV-BANG
: FILL.ENV-BANG
    200 new: env-bang
    64 0 DO
       64 i 2/ -  add: env-bang
    LOOP
    192 64 DO
       192 i - 4/ add: env-bang
    LOOP
    2  da.channel!
    200 put.msec: env-bang
    32 0 put: env-bang      ( slightly soften the attack )
;

: SYS.INIT sys.init fill.env-bang ;
: SYS.TERM free: env-bang sys.term ;

\ Test ----------------------------------------
if-testing @ .IF
\ Test envelopes
: TE.INIT
    env.init
\ Set up channels 2 & 3
    3 da.channel!
    da_complex da.wave!
    500 da.period!
    da.start
    2 da.channel!
    true da.ampmod!
;

VARIABLE TE-DELAY
150 te-delay !
: TEST.ENV   ( test envelope ) 
    2  da.channel!
    start: env-bang 
    te-delay @ msec
    finish: env-bang
;

: TE.LOOP
    0 DO test.env
    LOOP
;

.THEN
