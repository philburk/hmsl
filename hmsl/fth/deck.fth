\ @(#) deck.fth 96/06/11 1.1
\ test diff
\ Model deck of cards.
\
\ Author: Phil Burk
\ Copyright 1986 -  Phil Burk, Larry Polansky, David Rosenboom.
\ All Rights Reserved
\
\ MOD: PLB 8/18/87 Remove card after being dealt to prevent
\      endless search.

MRESET DEAL:
ANEW TASK-DECK

METHOD DEAL:
METHOD SHUFFLE:

:CLASS OB.DECK <SUPER OB.LIST

:M DEAL:  ( -- index )
    many: self ?dup
    IF  choose
        dup at: self
        swap remove: self  ( repack deck )
    ELSE
        " DEAL: OB.DECK" " No More Cards Left!"
        er_fatal ob.report.error
    THEN
;M

:M SHUFFLE: ( -- )
    clear: self
    limit: self 0
    ?DO i add: self
    LOOP
;M

;CLASS
