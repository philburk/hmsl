\ Tunings for instruments.
\ These classes contain the frequencies or periods for
\ specific notes within a given tuning.
\
\ Author: Phil Burk
\ Copyright 1986 - David Rosenboom, Larry Polansky, Phil Burk.
\
\ MOD: PLB 12/17/86 Changed PLAY.OCTAVES: to PLAY:
\ MOD: PLB 5/20/87 Use LIMIT: in PLAY:
\ MOD: PLB 5/24/87 Add SYS.INIT
\ MOD: PLB 6/3/87 Extend Equal Tempered tuning.
\ MOD: PLB 9/1/87 Correct bad values in low octaves of EQT.

ANEW TASK-TUNINGS

.NEED PLAY:
METHOD PLAY:
.THEN

:CLASS OB.TUNING <SUPER OB.TRANSLATOR

:M TRANSLATE: ( index -- period , generate period for a given note )
    limit: self 1- min   ( clip at tuning limit )
    at: self
;M

:M DETRANSLATE:  ( value -- [index] flag , reverse translate )
    indexof: self
;M

:M PLAY:  ( -- , play scale )
    da.start
    limit: self 0
    DO  i translate: self
        da.period! 500 msec
        ?terminal IF leave THEN
    LOOP
    da.stop
;M

;CLASS

\ Predefined translators.
OB.TUNING TUNING-EQUAL
: TU.BUILD.EQUAL
    60 new: tuning-equal
    134 142 151 160 169 179
    190 201 213 226 240 254

    269 285 302 320 339 359
    381 403 427 452 480 508

    539 570 604 641 677 719
    760 807 835 905 960 1016

    1077 1141 1209 1281 1357 1438
    1523 1614 1710 1811 1919 2033

    2154 2283 2418 2562 2714 2876
    3047 3228 3420 3623 3839 4067

    60 stuff: tuning-equal
;

: SYS.INIT sys.init tu.build.equal ;
: SYS.TERM free: tuning-equal  sys.term ;
