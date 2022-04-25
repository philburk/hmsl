\ Spawn an Amiga Task for background processing.
\ include? dump.regs ju:debugger
\ include? dst ju:dump_struct

getmodule includes

ANEW TASK-SPAWN_TASK
decimal

: ALLOCSIGNAL() ( requested_signal# -- allocated_signal# )
    call exec_lib AllocSignal
;

: SIGNAL()  ( task signalmask -- )
    callvoid>abs exec_lib signal
;

: FREESIGNAL() ( signal# -- , Free previously allocated signal. )
    callvoid exec_lib FreeSignal
;

: FINDTASK() ( 0$taskname -- rel_task )
    if>abs call exec_lib FindTask if>rel
;

: WAIT()  ( signalmask -- signal )
    call exec_lib wait
;

: SETTASKPRI()  ( task pri --- oldpri )
    call>abs exec_lib settaskpri
;

: ADDTASK() ( task EntryPoint finalpc -- )
    if>abs >r
    >abs >r >abs r> r>
    callvoid exec_lib AddTask
;

: REMTASK() ( task -- )
    callvoid>abs exec_lib RemTask
;

\ Task Spawning
64 constant ST_DS_SIZE   ( data stack size for spawned task )
1000 constant ST_RS_SIZE ( return stack size )

ASM GET.A3A4A5 ( -- A3 A4 A5 , push A3, A4 and A5 onto stack )
    MOVE.L     TOS,-(A6)
    MOVE.L     A3,-(A6)
    MOVE.L     A4,-(A6)
    MOVE.L     A5,TOS
    RTS
END-CODE

defer TASK.FUNCTION
' noop is task.function

$ -126 constant _LVOFindTask

:STRUCT EZTask
    struct     exec_task  ezt_task  \ regular TASK at offset 0
    long       ezt_data_stack
;STRUCT

ASM TASK.ENTRY  ( -- , load registers for high level )
    MOVE.L     A7,A2              \ Get Return Stack Pointer
    ADDA.L     #4,A2              \ Offset past return address
    MOVEM.L    (A2)+,A3-A6        \ load Forth registers
    CALLCFA    TASK.FUNCTION      \ Call High Level
    RTS
END-CODE

: FREE.TASK  ( eztask -- , cleanup task )
    >r
\
\ Free Return Stack
    r@ ..@ tc_SPLower if>rel ?dup
    IF freeblock
    THEN
\
\ Free Data Stack
    r@ ..@ ezt_data_stack ?dup
    IF freeblock
    THEN
\
\ Free Task
    r> freeblock
;

: BUILD.TASK  { taskname priority | ezt -- eztask or 0 }
    0 -> ezt
\
\ Allocate EZTask Structure
    memf_clear memf_public | sizeof() eztask
    allocblock ?dup
    IF  -> ezt
\ Setup some of the task fields.
        NT_TASK ezt .. tc_Node ..! ln_Type
        priority ezt .. tc_Node ..! ln_Pri
        taskname if>abs ezt .. tc_Node ..! ln_Name
\
\ Allocate Data Stack
        memf_clear st_ds_size allocblock ?dup
        IF ezt ..! ezt_data_stack
\
\ Allocate Return Stack
           memf_clear st_rs_size allocblock ?dup
           IF >abs dup ezt ..! tc_SPLower
              st_rs_size + dup>r ezt ..! tc_SPUpper
\
\ Push Register Values onto return stack for new Task
              ezt ..@ ezt_data_stack >abs st_ds_size + 4 cells -
              r> cell- dup>r >rel !  ( push a6 )
              get.a3a4a5
              r> cell- dup>r >rel !  ( push a5 )
              r> cell- dup>r >rel !  ( push a4 )
              r> cell- dup>r >rel !  ( push a3 )
\
              r> ezt ..! tc_SPReg
           ELSE ezt free.task 0 -> ezt
           THEN
        ELSE ezt free.task 0 -> ezt
        THEN
    THEN
    ezt dup 0=
    IF ." Not enough memory for task!" cr
    THEN
;

: SPAWN.TASK ( 0taskname priority highlevelcfa -- eztask | 0)
    is task.function
    build.task dup
    IF dup 'c task.entry 0 AddTask()
    THEN
;


false .IF
variable test-task

variable test-count
variable test-kill

: SAMPLE.TASK  ( -- )
    BEGIN 1 test-count +!
        test-kill @
    UNTIL
;

: MAKE.TASK  ( -- task | 0 , setup test )
;

: START.TEST ( -- )
    test-kill off
    test-count off
\
    0" Sample" 0 'c sample.task spawntask
    test-task !
;

: STOP.TEST
    test-task @ RemTask()
    test-task @ free.task
;

.THEN

