\ Set Version Number
ANEW TASK-HMSL_VERSION

\ Set both Version Number and Title string.
500 value HMSL_VERSION#

: (HMSL.TITLE)  ( -- $string )
    HOST" HMSL V5.00"
;
