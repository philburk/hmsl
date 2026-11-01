\ This file was added in 2026 by Phil Burk.
\ It provides a memory area that is similar to
\ the JForth program RAM used by Simple Actions as a wave table.
\ It looks for the hmsl-archive repository.
\ If present then it loads an image of HMSL4th into RAM and uses it.
\ Otherwise it uses the pForth dictionary RAM.

ANEW TASK-SIMPLE_RAM

\ Likely paths to the HMSL4th file.
: $SAR-PATH1 ( -- $path1 )
    " ~/hmsl-archive/users/henry/HWork/hmsl4th"
;
: $SAR-PATH2 ( -- $path1 )
    " ~/work/hmsl-archive/users/henry/HWork/hmsl4th"
;

: SAR.REPORT.RAM ( $path -- )
    cr ." Loaded " count type ."  for Amiga Sound RAM" cr
;

: SAR.OPEN.FILE ( -- fid ior , try to open HMSL4th in two possible places )
    $sar-path1   count r/o open-file
    dup 0=
    IF
        $sar-path1 sar.report.ram
    ELSE
        2drop
        $sar-path2   count r/o open-file
        dup 0=
        IF
            $sar-path2 sar.report.ram
        ELSE
            cr ." HMSL4th file not found. Using pForth CODEBASE instead." cr
        THEN
    THEN
;

\ In simple_acts.fth, there is code that determines how much RAM we need to load:
\    64000 choose 2* sar.code.ram + 40000 30000 wchoose da.sample!
64000 2* 40000 +  \ maximum that I can see
    1024 + \ a little margin
    constant SAR_RAM_SIZE
variable SAR-RAM
variable SAR-RAM-ENABLED \ if true then try to use Amiga RAM, if false then use codebase
true sar-ram-enabled !

: SAR.LOAD.HMSL4TH { | fid mem -- addr | null }
    0 -> mem
    sar.open.file 0=
    IF
        -> fid
        sar_ram_size allocate 0=
        IF
            -> mem
            mem sar_ram_size fid read-file
            IF
                ." Could not read HMSL4th" cr
                mem free drop
                0 -> mem
            THEN
            drop  \ num read
        THEN
        fid close-file drop
    ELSE
        0
    THEN
    mem
;

: SAR.TERM ( -- )
    sar-ram @
    IF
        sar-ram @ free drop
        0 sar-ram !
    THEN
;

if.forgotten sar.term

: SAR.USE.AMIGA.RAM ( -- flag )
    sar-ram @ 0=
    sar-ram-enabled @ 0= OR
;

: SAR.USE.PFORTH.RAM ( -- flag )
    sar-ram @ 0=
    sar-ram-enabled @ 0= OR
;

: SAR.INIT ( -- )
    sar.term
    sar.load.hmsl4th sar-ram !

    sar.use.pforth.ram IF
        ." Using pForth "
    ELSE
        ." Using Amiga JForth "
    THEN
    ." dictionary as an audio waveform." cr
;

: SAR.CODE.RAM ( -- addr , either HMSL4th or pForth code )
    sar.use.pforth.ram IF
        codebase
    ELSE
        sar-ram @
    THEN
;
