\ @(#) ob_stack.fth 96/06/11 1.1
\ OBJECT Stack =========================================
\ This stack is used for storing the current object address.
\ Access to instance variables is based on that address.
\ This code is a good candidate for optimization.
\
\ Author: Phil Burk
\ Copyright 1995
\
\ MOD: PLB 1/21/87 Add OS.DEPTH
\ MOD: PLB 2/10/87 Assemble and optimize OS.PUSH and OS.DROP
\ MOD: PLB 4/19/87 Optimize for Mac too.
\ MOD: PLB 4/25/88 Add OS_MAX_DEPTH and expand to 256 bytes.
\ 951227 PLB Converted to high level for pForth

ANEW TASK-OB_STACK

256 constant OS_SIZE
os_size cell/ constant OS_MAX_DEPTH
VARIABLE OBJECT-STACK os_size VALLOT
VARIABLE OSSTACKPTR  ( defined in kernel )
\ stack grows down in memory

: OS.SP!  ( -- , SET USER STACK POINTERS )
     object-stack os_size + osstackptr !
; OS.SP!

: OS.PUSH  ( N -- , Push onto object stack )
    osstackptr @
    cell-    \ pre-decrement
    dup osstackptr !
    !
;

: OS.DROP  ( -- , drop top of object stack )
    cell osstackptr +!
;

: OS.COPY  ( -- N , make copy of top of object stack )
    osstackptr @ @
;

: OS+ ( M -- N+M , add top of object stack )
    os.copy +
;

: OS+PUSH  ( N -- , Add to OS TOP and push onto object stack )
    os.copy +
    os.push
;

: OS.POP  ( -- N , pop from object stack )
    osstackptr @ dup @
    swap cell+   \ post-increment
    osstackptr !
;

: OS.DEPTH ( -- #cells , depth of object stack )
    object-stack os_size +
    osstackptr @ - cell/
;

: OS.PICK ( n -- Vn , pick value off object stack )
    cell* osstackptr @ + @
;


\ Benchmark
if-testing @ [IF]
VARIABLE #OS.BENCH
1000 #OS.BENCH !
: OS.BENCH  123 #OS.BENCH @ 0
    ?DO  os.push os.copy os.drop
    LOOP drop
;
[THEN]
