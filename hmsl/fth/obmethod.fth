\ @(#) obmethod.fth 96/06/11 1.1
\ This file defines the words used to define METHODS for a class.
\ Methods are used to manipulate an objects instance variables.
\
\ Author: Phil Burk
\ Copyright 1986 Phil Burk
\
\ MOD: PLB 11/29/86 Store CFAs in relocatable form for MAC
\ MOD: PLB 2/10/87 Catch redeclared Methods!
\ MOD: PLB 9/5/87 Add METHODS.OF and other tools.
\ MOD: PLB 9/10/87 Attempt smart forget.
\ MOD: PLB 11/16/87 Add CURRENT.OBJECT
\ MOD: PLB 1/13/87 Use PFA for backlinking methods instead of NFA.
\ MOD: PLB 9/13/88 Add [FORGET] to eliminate need for MRESET
\ MOD: PLB 5/22/89 Add 0 ob-state ! to [FORGET]
\ MOD: PLB 9/22/89 Fix stack checking for H4th.
\ MOD: PLB 12/15/89 Add Defining Class for METHODS.OF
\ MOD: PLB 3/31/92 Added INHERIT.METHOD
\ 00001 PLB 8/3/92 Objects put absolute address on stack.

ANEW TASK-OBMETHOD

: MI++  ( -- index , allocate new method index )
    mi-next @  ( current )
    dup 1+ mi-next !   ( increment )
;

\ Method contents:
\    CELL 0 = method index.
\    CELL 1 = method back link (in relocatable form ).

\ Holds PFA of last defined method, relocatable.
CREATE METHOD-LAST 0 ,

: (METHOD)  ( <name:> -- , declare method for later definition )
    CREATE
        here  ( for linking )
        mi++ ,  ( cell1: set index )
        method-last @ , ( cell2: back pointer )
        use->rel method-last !   ( point to PFA of this method. )
        immediate  ( make it immediate )
    DOES>   @  ob.bind  ( bind message to object )
;

: METHOD  ( <name:>  -- , declare method if new )
    >in @ >r \ save input pointer
    ho.find.pfa
    r> >in !  \ restore input pointer
    IF
        @ mi-next <
        IF bl word count type ."  - method already declared." cr
        ELSE   (method)
        THEN
    ELSE (method)
    THEN
;

: OB.MIND@ ( <WORD> -- INDEX , return index )
    ho.find.pfa NOT
    IF
        " OB.MIND@" " Method not declared!"
        ER_FATAL  ER.REPORT
    ELSE  ( save NFA of method for debugger )
        dup pfa->nfa current-method !  @
    THEN
;

\ Pairs checking for Method definitions.
: OB.CHECK:M  ( flag -- , report pairing error if flag different )
    dup ob-inside-:m @ =
    IF  not ob-inside-:m !
    ELSE drop " OB.CHECK:M" " Missing :M or ;M in class definition!"
        er_fatal er.report
    THEN
;

\ :M is one of the most complicated words in the system.
\ It generates a headerless secondary with some object stack manipulations
\ at the beginning and end.
\ It will have to be hand tweaked for each FORTH because of
\ differences in the compilers.

: :M ( <method> -- , COMPILE A METHOD FOR A CLASS )
    false ob.check:m
    ob.mind@  dup ob-current-mind !
    :noname ( -- mi exectoken , save exectoken )
\
\ Calculate offset into cfa table for this method.
    swap cell*                ( -- cfa moffset )
\ Store CFA in methods table.
    ob-current-class @    ob_cfas +   ( -- base_cfas ) + !
;

defer ;M immediate

: <;M> ( -- , Terminate method definition )
    true ob.check:m
    current-method off
    -1 ob-current-mind !
    [compile] ;     ( Go back to interpretation mode , checks stack )
;  immediate
\ Use deferred ;M for Locals and Debugger.
    ' <;M> is ;M
    

0 MI-NEXT !  ( reset method counter )
METHOD INIT:  ( INIT: MUST have method index = 0 !!! )

\ This is handy for inside Forth words called from a method.
: CURRENT.OBJECT ( -- object )
    os.copy
\ use->rel \ 00001
;

create MRESET-WARN true ,

: MRESET ( <method> -- )
    32 word
    mreset-warn @
    IF  ." MRESET "  $type
        ."  is no longer needed!" cr
    ELSE drop
    THEN
;

: [FORGET] ( -- , reset method index )
    [forget]
    method-last @ rel->use  ( get last method )
    BEGIN dup here > ( is it forgotten )
    WHILE ( -- method_pfa )
        cell+ @ if.rel->use
    REPEAT
    dup if.use->rel method-last !  ( set pointer to last )
    @ 1+ mi-next !    ( reset index so CFA tables don't grow)
    0 ob-state !   ( reset state to avoid :CLASS warnings )
;

: METHOD.LINK ( method_PFA -- index previous_pfa )
    dup @ swap cell+ @ ?dup
    IF rel->use
    ELSE 0  ( for the Mac )
    THEN
;

: (.METHOD)  ( method_pfa method_index -- , print it )
    4 .r space pfa->nfa id.
;

: ALL.METHODS ( -- list all methods )
    cr method-last @ rel->use
    BEGIN dup
    WHILE dup method.link -rot
        (.method) cr ?pause
    REPEAT drop
;

variable OB-SCRATCH

: ?DEFINING.CLASS ( method_index pfa_class -- pfa_class' )
\ Scan backwards in Class list to find first occurrence of method.
\ Do this by checking superclass for bad method, index overrange,
\   or 0 pointer.
    2dup method@ >r  ( cfa to match with )
\ Give up if 0 super link.
    BEGIN dup ..@ ob_super dup ob-scratch ! ( non-zero? )
        IF  ( super class = 0 for object class )
\ Give up if method count of superclass too low.
            ob-scratch @ ..@ ob_#methods 2 pick >
\ Give up if method CFA doesn't match
            IF  over ob-scratch @ method@ r@ =
                IF drop ob-scratch @ ( use super ) false
                ELSE true
                THEN
            ELSE true
            THEN
        ELSE true
        THEN
    UNTIL rdrop nip
;

: METHODS.OF ( <class> -- , list valid methods for class )
    cr ho.find.pfa
    IF  dup ob.check.class
        >r
\ Start with last method defined, scan all methods,
\ print it if its method cfa is not the OB.BAD.METHOD cfa.
        method-last @ rel->use
        BEGIN dup  ?pause
\ Link to next method header in dictionary.
        WHILE dup method.link -rot ( -- prev pfa i )
\ Check to see if class method table is big enough.
            dup r@ ..@ ob_#methods <  ( -- prev pfa i f )
            IF  ( prev pfa index )
\ Compare CFA of method.
                dup r@ method@ 'c ob.bad.method -
                IF  tuck (.method) 4 spaces
                    r@ ?defining.class pfa->nfa
                    BL 20 emit-to-column id. cr
                ELSE 2drop
                THEN
            ELSE 2drop
            THEN
        REPEAT drop
        rdrop
    ELSE " METHODS.OF" " Not a class!"
        er_fatal er.report
    THEN
;

: IS.SUPER? { pfa_class1 pfa_class2 | flag -- flag , is class2 a superclass of class1 }
    false -> flag
    pfa_class1
    BEGIN
        ..@ ob_super ?dup
    WHILE
        dup pfa_class2 =
        IF
            true -> flag
        THEN
    REPEAT
    flag
;

: INHERIT.METHOD  ( <method> <class> -- )
    ob-state @ 0=
    abort" INHERIT.METHOD only valid between :CLASS and ;CLASS"
\
\ get method index of method given
    ho.find.pfa NOT
    IF " INHERIT.METHOD" " METHOD not found"
        ER_FATAL ER.REPORT
    THEN ( -- method-pfa )
    @ >r \ get method index
\
\ get class
    ho.find.pfa NOT
    IF " INHERIT.METHOD" " CLASS not found"
        ER_FATAL ER.REPORT
    THEN ( -- class-pfa )
    dup ob.check.class
\
\ warn if not superclass of current class
    ob-current-class @ over is.super? not
    IF
        ." Warning from INHERIT.METHOD. "
        dup pfa->nfa id.
        ."  not a SUPER-class of "
        ob-current-class @ pfa->nfa id. cr
    THEN
\
\ get cfa for that method
    .. ob_cfas
    r@ cells + @  ( method cfa )
\
\ save in current class
    ob-current-class @  ( -- pfa-class )
    .. ob_cfas
    r> cells + !
;

\ Required Initialization
: OB.INIT ( -- )
    os.sp!   ( set object stack pointers )
    0 ob-state !
    0 ob-current-class !
    0 ob-self-cfas !
    0 ob-super-cfas !
    0 ob-dooper-cfas !
    true ob-if-check-bind !
;
: OB.TERM ( -- )
;
