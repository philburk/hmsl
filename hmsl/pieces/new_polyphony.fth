\ Demonstrate new way to do polyphony in HMSL

ANEW TASK-NEW_POLYPHONY

ob.shape NP-SH
ob.player NP-PL
ob.midi.instrument NP-INS

: NEWP.INIT
    32 4 new: np-sh
    stuff{   ( load it up )
\     time no  ve on
        0   5  90 16
        0   9  80 16
        20 12  86 16
        10  7  70  2
        10  9  72  4
        10 10  74  6
        10 11  76  8
        10 12  78 10
        10 13  80 12
        10 14  82 14
        10 15  84 16
        10 16  86 18
        20 17  88 20
    }stuff: np-sh
\
    np-sh np-ins build: np-pl
    3 put.on.dim: np-pl
    100 put.repeat: np-pl
    np-sh add: shape-holder
;

: NEWP.TERM
    cleanup: np-pl
    np-sh delete: shape-holder
;

: NEWP
    newp.init
    np-pl hmsl.play
    newp.term
;

if.forgotten newp.term

." Enter: NEWP"
