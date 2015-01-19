\ @(#) test_ode.fth 96/06/11 1.1
\ Test ODE
\
\ Author: Phil Burk
\ Copyright 1995 Phil Burk

anew task-test_ode.fth

\ create a simple object
object obj1

' obj1 >body  address: obj1 - abort" address: obj1 doesn't return body"
12             space: obj1   - abort" space: obj1 doesn't return 12"

." Class of obj1 should be 'object' = " .class: obj1

dump: obj1

\ create an integer object

ob.int  int1
876 constant val_1
778899 constant val_2
val_1 put: int1
val_1    get: int1  - abort" get: int1 doesn't return proper value"

\ check late binding
val_2 put: int1
val_2    int1 get: []  - abort" int1 get: [] doesn't return proper value"


\ check compile time late binding
: tode1
	val_1 put: int1
	val_1    int1 get: []
	- abort" compiled get: int1 doesn't return proper value"
;
tode1
\ check compile time late binding
: tode2
	val_2 put: int1
	val_2    int1 get: []
	- abort" compiled int1 get: [] doesn't return proper value"
;
tode2

