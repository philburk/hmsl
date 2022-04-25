\ ------------------------------------------------------
\
\ Host specific code for AMIGA running JFORTH
\ for support of HMSL
\
\ Author: Phil Burk
\
\ Copyright 1986 Phil Burk
\
\ Created 8/20/86
\ MOD: PLB 10/20/86 Separated from AJF_RTC
\ MOD: PLB 3/32/90 Added MM.ALLOC?
\ 00001 PLB 11/20/91 Change ER.REPORT to ABORT"
\ 00002 PLB 12/4/91 Fixed stack bug in MM.ZALLOC?

\ -------------------------------------------------------

ANEW TASK-AJF_MM

V: MM-TYPE  ( Only used on AMIGA, for specifying CHIP | PUBLIC, etc. )
MEMF_PUBLIC mm-type !

: MM.ALLOC?  ( numbytes -- address | 0 , allocate bytes, 0 if can't )
    mm-type @ swap allocblock
    MEMF_PUBLIC mm-type !  ( set back to default )
;

: MM.ALLOC  ( numbytes -- address, allocate bytes, error if can't )
    mm.alloc? dup 0=
    abort" MM.ALLOC - Not enough memory!!!" \ 00001
;

: MM.ZALLOC ( numbytes -- address , allocate and zero out memory )
    dup mm.alloc
    dup rot 0 fill
;

: MM.ZALLOC? ( numbytes -- address | 0, allocate and zero out memory )
    dup mm.alloc? dup \ 00002
    IF dup rot 0 fill
    ELSE nip
    THEN
;

: MM.FREE ( address -- , free allocated memory )
    freeblock
;
