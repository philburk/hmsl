\ Add HMSL File access words to pForth.
\ Define them in terms of the ANSI file words.
\
\ Licensed under Apache Open Source License V2

ANEW TASK-FILE_PORT

variable FILE-IF-NEW

: NEW ( -- , create next file )
    true file-if-new !
;

: $FOPEN ( $filename -- refnum | 0 , open a file )
    dup ." open file " count type
    map.filename    \ apply ASSIGN
    dup ."  => " count type cr
    count
    file-if-new @ IF
        r/w create-file
        false file-if-new !
    ELSE
        r/w open-file
    THEN
    IF \ error?
        drop 0
    THEN
    .s cr
;

: FILEWORD  ( <filename> -- addr , parse name with quote delimiters )
    bl lword
    dup 1+ c@ ascii " =  ( is first char a " )
    IF ( -- addr , reset >in and reparse )
        c@ negate >in +!
        ascii " lword
    THEN
;

: FOPEN ( <filename> -- refnum | 0 , open a file )
    fileword $fopen
;

: FCLOSE ( refnum -- , close the file )
    close-file
    IF ." ERROR closing the file." cr
    THEN
;

: FREAD ( refnum addr num_bytes -- bytes_read )
    rot read-file drop
;

: FWRITE ( refnum addr num_bytes -- bytes_written )
    dup >r
    rot write-file
    r> swap IF
        drop 0   \ error so return 0 bytes written
    THEN
;

: FEMIT ( refnum char -- , write single char to the file, abort on error )
    0 >r rp@ c! \ store char on return stack
    rp@ 1 rot  ( --  addr 1 refnum )
    write-file abort" failed in FEMIT"
    rdrop
;

-1 constant EOF \ 00002
VARIABLE FIO-CHAR-BUFFER
: FKEY  ( fid -- char | -1)
    fio-char-buffer 1 fread
    1 =
    IF   fio-char-buffer c@
    ELSE EOF \ 00002
    THEN
;

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

