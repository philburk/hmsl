\ @(#) memalloc.fth 96/06/11 1.1
\ ------------------------------------------------------
\
\ ANSI based memory allocator
\
\ Author: Phil Burk
\ Copyright 1986 Phil Burk, Larry Polansky, David Rosenboom
\ All Rights Reserved
\
\ Created 8/20/86
\ MOD: PLB 10/20/86 Separated from AJF_RTC
\ MOD: PLB 2/3/96 Convert to ANSI
\
\ -------------------------------------------------------

ANEW TASK-MEMALLOC.FTH

\ -------------------------------------------------------
\ Host Independant Memory Manager
\

\ -------------------------------------------------------
\ Memory Manager

: MM.ALLOC?  ( numbytes -- address | 0, allocate bytes) 
	allocate drop
;
: MM.ALLOC  ( numbytes -- address , allocate bytes) 
    allocate abort" MM.ALLOC - Not enough memory!!!"
;

: MM.ZALLOC? ( numbytes -- address | 0, allocate and zero out memory )
    dup mm.alloc? dup
    IF dup rot 0 fill
	ELSE nip
    THEN
;

: MM.ZALLOC ( numbytes -- address , allocate and zero out memory )
    dup mm.alloc
    dup rot 0 fill
;

: MM.FREE ( address -- , free allocated memory )
   	free abort" MM.FREE - already freed!"
;
