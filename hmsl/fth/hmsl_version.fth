\ Set Version Number
ANEW TASK-HMSL_VERSION

\ The version number is set in the host app so that there is only
\ one source of truth. See "native/juce/Source/hmsl_version.h".
\ It is encoded as major*10000 + minor*100 + patch,
\ eg. 50100 for V5.1.0, or 50217 for V5.2.17
HOSTVERSION() value HMSL_VERSION#

: $APPEND ( addr count $string -- , append text to counted string )
    >r  r@ count +  ( addr count end )
    over >r swap cmove
    r> r@ c@ + r> c!
;

create VERSION-PAD 16 allot

: VERSION$ ( n -- addr count , format version number, eg. 50217 => 5.2.17 )
    100 /mod 100 /mod  ( patch minor major )
    0 version-pad c!
    s->d <# #S #> version-pad $append
    s" ." version-pad $append
    s->d <# #S #> version-pad $append
    s" ." version-pad $append
    s->d <# #S #> version-pad $append
    version-pad count
;

\ Title string, eg. "HMSL V5.1.0"
create HMSL-TITLE$ 32 allot
s" HMSL V" hmsl-title$ place
hmsl_version# version$ hmsl-title$ $append

: (HMSL.TITLE)  ( -- $string )
    hmsl-title$
;
