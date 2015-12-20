\ Define some stock actions
\ author: Polansky
\ MOD: PLB 4/15/87 Added INIT: of each action for Mac

ANEW TASK-TEST_ACTIONS

ob.action act-1		ob.action act-9
ob.action act-2		ob.action act-10
ob.action act-3		ob.action act-11
ob.action act-4		ob.action act-12
ob.action act-5		ob.action act-13
ob.action act-6		ob.action act-14
ob.action act-7		ob.action act-15
ob.action act-8		ob.action act-16

ob.action act-null

: INIT.STOCK.ACTIONS  ( -- , Sets CFAs for Mac )
    init: act-1    init: act-2
    init: act-3    init: act-4
    init: act-5    init: act-6
    init: act-7    init: act-8
    init: act-9    init: act-10
    init: act-11    init: act-12
    init: act-13    init: act-14
    init: act-15    init: act-16
\ initialize ACT-NULL, very important...
    init: act-null
;


