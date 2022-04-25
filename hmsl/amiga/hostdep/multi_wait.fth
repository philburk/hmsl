\ Multiple Event Wait to prevent HMSL from
\ doing a busy wait.
\
\ Author: Phil Burk
\ Copyright 1990 Phil Burk

\ MOD: PLB 9/5/91 00001 0 -> xxx_SIGBIT in FREEs

include? allocsignal() ju:exec_support

getmodule includes
getmodule hmod:hmsl-includes

ANEW TASK-MULTI_WAIT

0 value TIMER_SIGBIT
0 value MIDI_SIGBIT
0 value GRAPHICS_SIGBIT
0 value TIMER_SIGMASK
0 value MIDI_SIGMASK
0 value GRAPHICS_SIGMASK
0 value ALL_SIGMASK

: ALLOC.TIMER.SIGNAL  ( -- )
    timer_sigbit 0=
    IF -1 allocsignal()
       dup 0< abort" ALLOC.TIMER.SIGNAL - No signals!"
       dup -> timer_sigbit
       1 swap +shift  ( convert to mask )
       dup -> timer_sigmask
       0 findtask()
       swap set.timer.signal2
    THEN
;

: FREE.TIMER.SIGNAL  ( -- )
    timer_sigbit
    IF  0 0 set.timer.signal2
        timer_sigbit freesignal()
        0 -> timer_sigbit \ 00001
    THEN
;

: ALLOC.MIDI.SIGNAL  ( -- )
    midi_sigbit 0=
    IF -1 allocsignal()
       dup 0< abort" ALLOC.MIDI.SIGNAL - No signals!"
       dup -> midi_sigbit
       1 swap +shift  ( convert to mask )
       dup -> midi_sigmask
       0 findtask()
       swap set.rbf.signal
    THEN
;

: FREE.MIDI.SIGNAL  ( -- )
    midi_sigbit
    IF  0 0 set.rbf.signal
        midi_sigbit freesignal()
        0 -> midi_sigbit \ 00001
    THEN
;

: OR.SIGNAL.BIT  ( mask bit# -- mask' )
    ?dup
    IF 1 swap +shift OR
    THEN
;

: ALL.SIGNALS.MASK  ( -- mask )
    0
    timer_sigbit or.signal.bit
    midi_sigbit or.signal.bit
    hmsl-window @ ?dup
    IF  ..@ wd_userport >rel
        ..@ mp_sigbit
        1 over +shift -> graphics_sigmask
        or.signal.bit
    THEN
;

: MW.INIT  ( -- , allocate signals )
    alloc.timer.signal
    alloc.midi.signal
;

: MW.TERM  ( -- , allocate signals )
    free.timer.signal
    free.midi.signal
;

IF.FORGOTTEN  MW.TERM

: SYS.INIT  sys.init  mw.init ;
: SYS.TERM  mw.term  sys.term ;

