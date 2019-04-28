\ Send output to a file or device.
\
\ You can send to the printer with   LOGTO PRT:
\
\ Author: Phil Burk
\ Copyright 1990 Phil Burk
\
\ MOD: PLB 12/28/86 Add filtering of CRs.
\ MOD: PLB 9/9/88 Add IF.FORGOTTEN , SAVE-FORTH fix.
\ MOD: PLB 1/21/89 Add PRINTER.ON, some reorganization
\ MOD: PLB 4/3/90 Converted to Mac HMSL

ANEW TASK-LOGTO

decimal
\ Provide a log of the output to a file.
variable LOGTO-ID
variable LOGTO-OLDTYPE
variable LOGTO-OLDCR

decimal

: LOGGED?  ( -- flag )
  logto-oldtype @ 0= 0=
;

: <LOGSTOP>  ( -- , Stop logging files )
  logged?
  IF  logto-oldtype @ is type
      logto-oldtype off
      logto-oldcr @ is cr
  THEN
;

: FLOGTYPE  ( addr count-- , send chars to console, if appropriate )
  logto-id @  -rot
  dup>r fwrite    r> -
  IF   <logstop>
       ." FLOGtype failed to write buffer; recommend LOGEND" abort
  THEN
;

: FLOGCR  ( -- , send carriage return )
    logto-id @ $ 0D femit
;

: LOGTO&TYPE ( addr count -- , send to both file and screen )
    2dup logto-oldtype @execute
    flogtype
;

: LOGTO&CR  ( -- )
    logto-oldcr @ execute
    flogcr
;

: LOGSTART  ( -- , Start logging characters )
  LOGGED?
  IF   ." can't LOGSTART, already logged." cr
  ELSE what's type logto-oldtype !  ( save old cfa )
       ' logto&type is type         ( set vector )
       what's cr  logto-oldcr !
       ' logto&cr is cr
  THEN
;

: $LOGTO  ( $filename -- , Open file and log characters to it. )
    logto-id @ 0=
    IF  new $FOPEN ?dup
        IF   logto-id !   logstart
        ELSE ." Could not be opened!" cr abort
        THEN
    ELSE ." Can't LOGTO " $type  ." , already logged."
    THEN
;

: LOGTO ( <name> --IN-- , Log characters to a file. )
    fileword  $logto
;

: LOGSTOP  ( -- , temporarily stop logging )
    logged?
    IF <logstop>
    THEN
;

: <LOGEND> ( -- , used internally )
    cr logstop
    logto-id @ fclose
    logto-id off
;

: LOGEND ( -- . terminate logto, close file )
    logto-id @
    IF <logend>
    ELSE ." Can't LOGEND, not logged!" cr
    THEN
;

: LOGTERM ( -- , used internally for cleanup )
    logto-id @
    IF  ." Turning off LOGTO !!!" cr
        <logend>
    THEN
;

decimal
if.forgotten logterm

: AUTO.TERM  logterm auto.term ;
