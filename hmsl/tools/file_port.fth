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
    .S cr
    dup ." open file " count type cr
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
    drop r>
;

." TODO define remaining FILE words." cr
