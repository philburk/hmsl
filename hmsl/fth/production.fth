\ Productions - a simple morph that can be executed
\ from other morphs to perform custom functions.
\
\ Author: Phil Burk
\ Copyright 1986 -  Phil Burk, Larry Polansky, David Rosenboom.
\
\ MOD: PLB 1/27/87 Store CFAs in array, not IVAR.
\ MOD: PLB 5/23/87 Add STOP: noop.
\ MOD: PLB 5/28/87 Add ?HIERARCHICAL:
\ MOD: PLB 9/23/87 Preserve CURRENT-PRODUCTION value in EXECUTE:
\ MOD: PLB 5/23/89 Convert to new design, add vtime
\ MOD: PLB 4/5/90 New STOP code

ANEW TASK-PRODUCTION

V: CURRENT-PRODUCTION

:CLASS OB.PRODUCTION <SUPER OB.MORPH

:M ?NEW:  ( Max_elements -- addr | 0 )
	1 ?NEW: SUPER   ( declare as one dimensional )
;M

:M NEW: ( max_elements -- , abort if error )
	?new: self <new:error>
;M

\ Since this is a one-dimensional list, let's inherit a bunch
\ of list methods.
inherit.method delete: ob.list
inherit.method 0stuff: ob.list
inherit.method }stuff: ob.list

:M CUSTOM.EXEC: ( -- time true  , execute functions )
    iv-time-next vtime!
    current-production @ >r
    self current-production !
    iv-repeat 0
    ?DO many: self 0
       ?DO i at: self  ( get CFA )
           execute
       LOOP
       iv-repeat-delay vtime+!
    LOOP
    iv-repeat-delay negate vtime+!  ( in case rep=1 )
    r> current-production !
    vtime@ true
;M

:M PRINT.ELEMENT: ( e# -- )
    at: self cfa.
;M

:M PRINT.HIERARCHY: ( -- , print name and indent for children )
    >newline morph-indent @ spaces name: self
    3 morph-indent +!
    many: self 0
    ?DO  >newline morph-indent @ spaces 
        i self print.element: []
    LOOP
    -3 morph-indent +!
;M

:M ?HIERARCHICAL:  ( -- flag , true if can contain other morphs)
    false
;M

;CLASS
