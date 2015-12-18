\ %Z% %M% %E% %I%
\ make_hmsl.fth
\ Create HMSL dictionary

include fth/load_hmsl.fth

\ Do not execute auto.init chain if stack is large.
\ This is a hack so that SAVE-FORTH won't trigger HMSL.INIT,
\ which asks the user Y/N, which messes up the XCode build script.
\ We have to block this using the stack because if
\ we used a variable, the variable value would get saved in the dictionary
\ preventing HMSL.INIT when HMSL was run.
: AUTO.INIT ( -- )
    depth 4 > IF
        ." AUTO.INIT disabled because DEPTH > 4." cr
        .S
	ELSE
        auto.init
    THEN
;

." Block AUTO.INIT that is called by SAVE-FORTH" cr
1 2 3 4 5 6
c" pforth.dic" save-forth
6 0 DO drop LOOP
