\ Allocate numbered resources, track with an array.
\
\ Author: Phil Burk
\ Copyright 1986 -  Phil Burk, Larry Polansky, David Rosenboom.
\
\ MOD: PLB 5/13/87 Add block allocation.
\ MOD: PLB 10/22/87 Add MARK: for forced allocation.

MRESET ALLOCATE:

ANEW TASK-ALLOCATOR

METHOD ALLOCATE:
METHOD ALLOCATE.RANGE:
METHOD DEALLOCATE:
METHOD ALLOCATE.BLOCK:
METHOD ALLOCATE.BLOCK.RANGE:
METHOD DEALLOCATE.BLOCK:
METHOD PUT.OFFSET:
METHOD GET.OFFSET:
METHOD MARK:

:CLASS OB.ALLOCATOR <SUPER OB.BARRAY
    IV.LONG IV-ALLOC-OFFSET

:M INIT: ( -- )
    init: super
    0 iv=> iv-alloc-offset
;M

:M NEW: ( -- , make sure clear )
    new: super
    clear: self
;M

:M PUT.OFFSET: ( offset -- )
    iv=> iv-alloc-offset
;M

:M GET.OFFSET: ( -- offset)
    iv-alloc-offset
;M

: <ALLOC.MARK> ( actual_index -- )
    1 swap +to: self
;
: <ALLOC.UNMARK> ( actual_index -- )
    dup>r at: self 1- 0 max
    r> to: self
;

\ This is used when you want to grab a resource
\ and don't care if it's already allocated.
:M MARK: ( index -- , mark a resource as allocated )
    iv-alloc-offset - <alloc.mark>
;M

: <ALLOC.RANGE>  ( hi_index lo_index --  index true | false )
    false -rot
    ?DO i at: self 0=
        IF i <alloc.mark>  ( mark as allocated )
           drop i iv-alloc-offset + true leave
        THEN
    LOOP
;

:M ALLOCATE.RANGE: ( lo hi -- index true | false , alloc within range)
    1+ iv-alloc-offset -
    swap iv-alloc-offset -
    <alloc.range>
;M

:M ALLOCATE: ( -- index true | false , allocate one if available )
    size: self 0
    <alloc.range>
;M

:M DEALLOCATE: ( index -- )
    iv-alloc-offset - <alloc.unmark>
;M

: <ALLOC.BLOCK.RANGE>
( #in_block lo hi -- index true | false , allocate contiguous)
    >r >r false swap r> r>
    ?DO  i at: self 0=
        IF ( -- false #in , contiguous block? )
           true over i + i
           ?DO  i at: self
               IF drop false LEAVE
               THEN
           LOOP   ( -- false #in contiguous? )
           IF  i + i
               ?DO  i <alloc.mark>  ( mark as allocated )
               LOOP
               drop i iv-alloc-offset + true 0 ( sacrifice 0 ) leave
           THEN
        THEN
    LOOP drop
;

:M ALLOCATE.BLOCK.RANGE:
( #in_block lo hi -- index true | false , allocate contiguous)
    2 pick - 2+ 
    iv-alloc-offset -
    swap iv-alloc-offset -
    <alloc.block.range>
;M

:M ALLOCATE.BLOCK: ( #in_block -- index true | false , allocate contiguous)
    size: self 
    over - 1+ 0
    <alloc.block.range>
;M

:M DEALLOCATE.BLOCK: ( index size -- , deallocate contiguous)
    0 ?DO
        dup deallocate: self 1+
    LOOP drop
;M

:M PRINT.ELEMENT:  ( index -- )
    dup iv-alloc-offset + 3 .r
    at.self
    IF ."  In Use"
    ELSE ."  Available"
    THEN cr
;M

;CLASS

