\ Assign Logical Volume Names to directories like on the
\ VAX and the Amiga.
\
\ Maintain two string tables with corresponding strings.
\
\ Author: Phil Burk
\ Copyright 1987 Phil Burk, Larry Polansky, David Rosenboom
\ All Rights Reserved
\
\ MOD: PLB 11/5/90 Fix ASSIGN L$ to clear
\ MOD: PLB 7/16/91 FILEWORD now uses LWORD
\ 00001 PLB 2/21/92 Save FILE-TYPE and FILE-CREATOR when replacing a file.
\ 00002 PLB 9/28/92 Add EOF
\ 960623 PLB Change MAX_#ASSIGNS from 32 to 50

decimal
ANEW TASK-FILE_TOOLS

private{
50 constant MAX_#ASSIGNS
80 constant MAX_REAL_CHARS
32 constant MAX_LOGICAL_CHARS

max_#assigns max_logical_chars $array AS-LOGICAL-NAMES
max_#assigns max_real_chars $array AS-REAL-NAMES

CREATE AS-BUFFER max_real_chars 2* 2+ allot
CREATE AS-SCRATCH max_real_chars 2* 2+ allot
CREATE AS-HOLDER max_real_chars 2+ allot
CREATE AS-#NAMES 0 ,

: AS.INIT
    0 as-logical-names max_#assigns max_logical_chars * 0 fill
    0 as-real-names max_#assigns max_real_chars * 0 fill
    0 as-#names !
;
as.init

\ Search logical table for match
: AS.MATCH ( $string -- index true | false )
    -1 swap
    as-#names @ 0
    DO  i as-logical-names
        over $match?
        IF  swap drop i swap LEAVE
        THEN
    LOOP drop
    dup 0<
    IF drop 0
    ELSE -1
    THEN
;

: AS.CHECK ( $string -- , will it fit )
    c@ max_real_chars >
    IF ." Name too big for ASSIGN!!" abort
    THEN
;

: AS.MOVE.NAMES   ( high low -- , move names down one )
    DO i 1+ as-logical-names i as-logical-names  $move
       i 1+ as-real-names i as-real-names  $move
    LOOP
;

: AS.REMOVE ( index -- , remove name from tables %Q not finished!!!)
    as-#names @ 1- over >   ( valid index? )
    IF  ( -- index )
        as-#names @ 1- swap 2dup =
        IF 2drop
        ELSE   ( #names-1 index -- ) as.move.names
        THEN
        -1 as-#names +!
    ELSE ." AS.REMOVE - index out of range!" cr drop
    THEN
;

variable EF-NAME
variable EF-TEMP-ADDR
variable EF-LOGLEN

: REMOVE.LAST.:    ( $string -- , strip off last : if there is one )
    dup count 1- + c@ ascii : =
    IF ( -- $string ) dup c@ 1- swap c!
    ELSE drop
    THEN
;

defer ASSIGN.OLD.MAP.FILENAME

}private

: ASSIGNS? ( -- , print logical assignments )
    as-#names @ 0
    DO  cr i . 4 spaces i as-logical-names count type
        bl 20 emit-to-column
        i as-real-names count type
    LOOP cr
;

: EXPAND.FILENAME ( $name -- $fullname, expand logical to full path )
    dup ef-name !
    as.check
    ef-name @ as-scratch $move   ( save in scratch area )
    as-scratch ascii : index     ( is there a ':' in the name )
    IF  ef-temp-addr !        ( address of : )
        as-scratch as-buffer $move   ( save whole name in buffer )
        ef-temp-addr @ as-scratch 1+ - ( -- len_volume_name_without_: )
        dup 1 >
        IF  dup ef-loglen !
            as-buffer c!  ( update length to chars before : )
            as-buffer as.match
            IF  as-real-names as-buffer $move  ( copy real prefix to buffer )
                as-scratch c@ ef-loglen @ - dup 0>  ( chars after prefix )
                IF  as-buffer ascii / $append.char
                    ef-temp-addr @ 1+ swap 1-
                    as-buffer $append ( copy suffix w/ : )
                ELSE drop
                THEN as-buffer
            ELSE ef-name @
            THEN
        ELSE drop ef-name @
        THEN
    ELSE ef-name @
    THEN
;

: $ASSIGN ( $logical_name $real_name -- , set assignment )
    over as.match not  ( -- $l $n index false | $l $n true )
    IF  as-#names @ dup max_#assigns <
        IF  dup 1+ as-#names !
        ELSE ." Sorry, ASSIGN table full!" cr abort
        THEN
    THEN  ( $l $n index )
    swap dup c@   ( any chars in real name? )
    IF  ( $l index $n )
        expand.filename
        over as-real-names $move
        dup as-real-names remove.last.:
        as-logical-names $move
    ELSE ( $l index $n -- , no second name, clear entry )
        drop as.remove drop
    THEN
;

: ASSIGN ( <logical> <real> -- )
    32 lword dup as.check as-holder $move as-holder
    32 lword $assign
;

: ASSIGN.ON ( -- , install ASSIGN vectors )
    what's map.filename  ['] expand.filename = not
    IF
        what's map.filename is assign.old.map.filename
        ['] expand.filename is map.filename
        ." MAP.FILENAME was set to use HMSL ASSIGN tool." cr
    THEN
;

: ASSIGN.OFF ( -- , uninstall ASSIGN vectors )
    what's map.filename  ['] expand.filename =
    IF
        what's assign.old.map.filename is map.filename
    THEN
;

privatize

: AUTO.INIT
    auto.init
    assign.on
;
: AUTO.TERM
    assign.off
    auto.term
;

if.forgotten assign.off
