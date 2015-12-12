\ @(#) ob_ivars.fth 96/06/11 1.1
\ Optimized Instance Variables
\ These are intended to make it easier to use instance variables.
\ These IVARS will automatically fetch their data.  This can be optimized
\ like crazy.  If you want to store into them, you use IV=> .
\
\ Author: Phil Burk
\ Copyright 1986 Delta Research
\
\ MOD: PLB 5/13/87 Make iv&> immediate, use os+
\ MOD: PLB 9/13/88 Convert to new addressing mode, add IV.BYTES
\      Add signed ivars.
\ MOD: PLB 2/7/90 Add IV.STRUCT
\ 00001 PLB 4/8/92 Added IV.ARRAY
\ 960710 PLB Add IV.RPTR

ANEW TASK-OB_IVARS.FTH

decimal
\ Support for fetching and storing into instance variables .
\ These should not be called directly.

\ Make JFORTH compile @ ! etc. inline for speed.
#host_amiga_jforth [IF]
max-inline @ 20 max-inline !
[THEN]

false [IF]
: IV@  ( offset -- value , fetch from LONG instance variable )
    os+ @
;
: IVW@ ( offset -- value , fetch from SHORT instance variable )
    os+ w@
;
: IVC@ ( offset -- value , fetch from SHORT instance variable )
    os+ c@
;

: IV!  ( value offset -- , store into LONG instance variable )
    os+ !
;
: IVW!  ( value offset -- , store into SHORT instance variable )
    os+ w!
;
: IVC!  ( value offset -- , store into BYTE instance variable )
    os+ c!
;
[THEN]

: IV+!  ( value offset -- , store into LONG instance variable )
    os+ +!
;

#host_amiga_jforth [IF]
    max-inline !
[THEN]

: CREATE.IVAR ( size <name> -- )
    CREATE ob.make.member   immediate
    DOES>  ( -- address-ivar )
        ?comp compile os.copy
        ob.stats compile+@bytes
;

\ These words are for declaring instance variables.
\ Some of this code appears redundant but is needed because they
\ are CREATE-DOES> words.
: IV.LONG  ( <name> --IN-- , declare a cell wide instance variable )
    4 create.ivar
;

: IV.RPTR  ( <name> --IN-- , declare a relocatable pointer instance variable )
    -4 create.ivar
;

: IV.SHORT  ( <name> --IN-- , declare a 16 bit wide instance variable )
    -2 create.ivar
;

: IV.USHORT  ( <name> --IN-- , declare a 16 bit wide instance variable )
    2 create.ivar
;

: IV.BYTE  ( <name> --IN-- , declare a byte wide instance variable )
    -1 create.ivar
;

: IV.UBYTE  ( <name> --IN-- , declare a byte wide instance variable )
    1 create.ivar
;

: IV=>  ( value <ivar> -- , store into ivar )
    ?COMP
    compile os.copy
    ob.stats? compile+!bytes
; immediate

: IV+>  ( value <ivar> -- , add value to ivar )
    ?COMP
    ob.stats? cell =
    IF [compile] literal compile iv+!
    ELSE " IV+>" " only works on IV.LONG !!"
        er_fatal er.report
    THEN
; immediate

: IV&   ( offset -- address_ivar )
    os+
;

: IV&>  ( <ivar> --IN-- address_ivar , calculate address of ivar )
    ?COMP
    ob.findit ob.offset@ [compile] literal compile os+
; immediate

\ This is for declaring a field of bytes in an object.
: IV.BYTES ( n <name> -- , declare a field of bytes )
    CREATE ob.make.member immediate
    DOES> ?comp @ [compile] literal compile os+
;

: IV.STRUCT ( <structure> <name> -- ) ( -- addr )
    [compile] sizeof() iv.bytes
;


\ Fast internal arrays 00001
: (IV.ARRAY) ( index offset -- addr )
    os+
    swap cell* +
;

: IV.ARRAY  ( size <name> -- )
    CREATE cells ob.make.member immediate
    DOES> ( index addr-ivar )
        ?comp ob.offset@ [compile] literal
        compile (iv.array)
;

: (IV.WARRAY) ( index offset -- addr )
    os+
    swap 2* +
;

: IV.WARRAY  ( size <name> -- )
    CREATE 2* ob.make.member immediate
    DOES> ( index addr-ivar )
        ?comp ob.offset@ [compile] literal
        compile (iv.warray)
;

: (IV.BARRAY) ( index offset -- addr )
    os.copy + +
;

: IV.BARRAY  ( size <name> -- )
    CREATE ob.make.member immediate
    DOES> ( index addr-ivar )
        ?comp ob.offset@ [compile] literal
        compile (iv.barray)
;

