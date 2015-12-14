\ Translators are used for converting from one numeric system to another.
\ Examples might be converting a generic note index to a midi value in 
\ the key of D minor.  This would be a key translator. A scale translator
\ would take a note index and return a pitch or period value for an
\ instrument for a given tuning.
\
\ Author: Phil Burk
\ Copyright 1986 - David Rosenboom, Larry Polansky, Phil Burk.
\
\ MOD: PLB 10/21/86 Convert to new IV.LONG
\ MOD: PLB 3/6/87 Changed starting offset for keys to 0.
\ MOD: PLB 5/24/87 Add TRANSLATE function for custom translators.
\ MOD: PLB 5/28/87 Add PRINT:
\ MOD: PLB 10/30/90 Use Floored division in TRANSLATE: for rems>0

ANEW TASK-TRANSLATORS

\ Declare methods.
METHOD TRANSLATE:
METHOD DETRANSLATE:
METHOD PUT.MODULUS:
METHOD GET.MODULUS:
METHOD PUT.TRANSLATE.FUNCTION:
METHOD GET.TRANSLATE.FUNCTION:

\ Definition of terms:
\ TRANSLATE = Convert from an input value to an output value.
\ DETRANSLATE = Perform the inverse function of the translate.
\ OFFSET = value added to output before being returned.
\ MODULUS = The length of the repeating pattern in the output.
\    For western scales this might be 12 for 12 notes per octave.
\ SIZE = Number of entries in the translation table, 7 for a minor scale.

\ The formula for translation may vary with the subclass of translator.
\ Essentially they divide the input by the size,
\ multiply the result by the modulus,
\ and do a table lookup with the remainder of the division.
\ Those two are then added.

[NEED] FL/MOD
: FL/MOD  ( n d -- rem quo )
    dup>r /mod over 0<
    IF 1- swap r@ + swap
    THEN
    rdrop
;
[THEN]
[NEED] FL/
: FL/ ( n d -- quo )
    fl/mod nip
;
[THEN]


:CLASS OB.TRANSLATOR <SUPER OB.ARRAY
    IV.LONG IV-TR-OFFSET
    IV.LONG IV-TR-MODULUS
    IV.LONG IV-TR-FUNCTION    ( Custom function for translation. )

:M INIT:
    init: super
    0 iv=> iv-tr-offset
    12 iv=> iv-tr-modulus
    0 iv=> iv-tr-function
;M

:M PUT.OFFSET: ( offset -- , store value to add at end )
    iv=> iv-tr-offset
;M
:M GET.OFFSET: ( -- offset , fetch value to add at end )
    iv-tr-offset 
;M

:M PUT.MODULUS: ( modulus -- , store repeat length )
    iv=> iv-tr-modulus
;M
:M GET.MODULUS: ( -- modulus , fetch repeat length )
    iv-tr-modulus 
;M

:M PUT.TRANSLATE.FUNCTION: ( cfa -- , set custom translator )
( The custom translate function must have this stack diagram: )
( index translator -- value )
    iv=> iv-tr-function
;M

:M GET.TRANSLATE.FUNCTION: ( -- cfa , get custom translator )
    iv-tr-function
;M

:M TRANSLATE:  ( index -- value , translate index to a value )
    iv-tr-function ?dup
    IF  self swap -1 exec.stack? \ should ( index trobj -- value )
    ELSE
        size: self fl/mod  ( r d )
        iv-tr-modulus *
        swap at.self +
        iv-tr-offset +
    THEN
;M

:M DETRANSLATE: ( value -- [index] flag , reverse translate if valid output)
    get.offset: self -
    get.modulus: self /mod ( r d )
    size: self *
    swap indexof: self
    IF + true
    ELSE drop false
    THEN
;M

:M PRINT: ( -- )
    print: super
    ."  Offset   = " iv-tr-offset . cr
    ."  Modulus  = " iv-tr-modulus . cr
    ."  Function = " iv-tr-function ?dup
    IF cfa->nfa id.
    ELSE 0 .
    THEN cr
;M

;CLASS

\ There will be some predefined translators for certain keys.
OB.TRANSLATOR TR-CURRENT-KEY

\ This is too wierd and is considered obsolete.
: TR.SET.KEY ( key_offset VN-1 VN-2 ... V0 N -- , Set key to use those values. )
    dup  new: tr-current-key
    stuff: tr-current-key
    put.offset: tr-current-key
;

\ To set a key, enter something like:   TR_KEY_G# TR.MAJOR.KEY
: MAJOR_SCALE  ( -- 0 2 4 5 7 9 11 )
    0 2 4 5 7 9 11
;
: HARMONIC_MINOR_SCALE ( -- 0 2 3 5 7 8 11 )
    0 2 3 5 7 8 11
;
: PENTATONIC_SCALE ( -- 0 2 4 5 7 9 11 )
    0 2 4 7 9
;
: HUNGARIAN_MINOR_SCALE ( -- 0 2 3 6 7 8 11 )
    0 2 3 6 7 8 11
;
: RUMANIAN_MINOR_SCALE ( -- 0 2 3 6 7 9 10 )
    0 2 3 6 7 9 10
;

: TR.MAJOR.KEY  ( key_offset -- , set current key to major key )
    put.offset: tr-current-key
    stuff{ major_scale }stuff: tr-current-key
;
: TR.HARMONIC.MINOR  ( key_offset -- , set current key to minor key )
    put.offset: tr-current-key
    stuff{ harmonic_minor_scale }stuff: tr-current-key
;


0  dup constant TR_KEY_C
1+ dup constant TR_KEY_C#
1+ dup constant TR_KEY_D
1+ dup constant TR_KEY_D#
1+ dup constant TR_KEY_E
1+ dup constant TR_KEY_F
1+ dup constant TR_KEY_F#
1+ dup constant TR_KEY_G
1+ dup constant TR_KEY_G#
1+ dup constant TR_KEY_A
1+ dup constant TR_KEY_A#
1+     constant TR_KEY_B

: TR.INDEX->KEY ( note_index -- note_in_key , )
    translate: tr-current-key
;

\ Simple commands for playing notes in a specific key.
: TR.MIDI.ON  ( index velocity -- , translate and turn note on )
    swap tr.index->key 36 +  ( offset to good midi start )
    swap midi.noteon
;

: TR.MIDI.OFF  ( index velocity -- , translate and turn note off )
    swap tr.index->key 36 +
    swap midi.noteoff
;

: TR.INIT ( -- , Initialize translators )
    tr_key_d tr.harmonic.minor
;

: SYS.INIT sys.init tr.init ;
: SYS.TERM free: tr-current-key sys.term ;
