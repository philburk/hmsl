
anew task-load-swirl

assign hf    hmsl:fth
assign hh   hmsl:amiga/hostdep
assign ju   hmsl:amiga/util
assign hs   hmsl:amiga/samples

-1 constant offset_beginning
0 constant offset_current
1 constant offset_end

: FSEEK { fileid offset mode | pos0 pos1 ior -- prev-position | -1 }
    fileid file-position -> ior
    d>s -> pos0
    ior IF
        ." file-position returned " ior . cr
    ELSE
        mode CASE
        offset_beginning OF offset -> pos1 ENDOF
        offset_current OF offset pos0 + -> pos1 ENDOF
        offset_end OF fileid file-size abort" Bad file-size"
                d>s offset - -> pos1
            ENDOF
        ENDCASE
        pos1 s>d fileid reposition-file -> ior
    THEN
    pos0 ior
;

\ Amiga memory flags
$ 01 constant MEMF_PUBLIC
$ 02 constant MEMF_CHIP
$ 04 constant MEMF_FAST
$ 10000 constant MEMF_CLEAR

\ PForth memory is all the same so ignore the MEMF mode.
: ALLOCBLOCK { mode size -- address | false }
    size allocate   \ -- addr ior
    IF  drop false
    ELSE  \ -- addr
        mode memf_clear AND
        IF dup size erase    \ clear memory
        THEN
    THEN
;

: FREEBLOCK ( address -- )
    free drop
;

include? task-amiga_sound        hh:amiga_sound.fth
include? task-tunings            hf:tunings.fth
include? task-ratios             hf:ratios.fth
include? task-envelopes          hh:envelopes.fth
include? task-8svx.j             hh:8svx.j
include? task-waveforms          hh:waveforms.fth
include? task-amiga_instrument   hh:amiga_instrument.fth
include? task-bsort              ju:bsort.fth

