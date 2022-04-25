\ Structures for 8svx sample files.
\ These are used to support the IFF standard.
\
\ Author: Phil Burk
\ Copyright 1988 -  Phil Burk, Larry Polansky, David Rosenboom.
\ All Rights Reserved

ANEW TASK-8SVX.J

\ This stuff will probably go into a 'ju:' file. ------
: $>CODE ( $string -- 'cccc' , make 4byte value of 4 chars )
    count drop odd@
;

: CODE>$ ( code -- $string , make string out of code )
    4 pad c!
    pad 1+ odd!
    pad
;

" FORM" $>code constant 'FORM'
" CAT " $>code constant 'CAT'
" LIST" $>code constant 'LIST'
" PROP" $>code constant 'PROP'

" 8SVX" $>code constant '8SVX'
" VHDR" $>code constant 'VHDR'
" ATAK" $>code constant 'ATAK'
" BODY" $>code constant 'BODY'
" NAME" $>code constant 'NAME'
" AUTH" $>code constant 'AUTH'
" (C) " $>code constant '(C)'

:STRUCT Voice8Header
    ULONG v8h_OneShotHiSamples
    ULONG v8h_RepeatHiSamples
    ULONG v8h_SamplesPerHiCycle
    USHORT v8h_SamplesPerSec
    UBYTE v8h_ctOctave
    UBYTE v8h_sCompression
    LONG  v8h_volume
;STRUCT
