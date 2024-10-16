\ @(#) obobject.fth 96/06/11 1.1
\ Basic Classes of Object, Integer and Array.
\
\ Author: Phil Burk
\ Copyright 1986 Delta Research
\
\ MOD: PLB 6/29/86 Clear OB-PNTR in INIT:, use INIT: SUPERs
\ MOD: PLB 7/03/86 Do FREE: in NEW: , FREE: only if allocated.
\ MOD: PLB 7/14/86 Add USE.DICT: method., changed OB-#ELEMS to OB-#CELLS
\ MOD: PLB 7/16/86 Fixed bug introduced by last mod, WARRAY & ARRAY
\      weren't using INIT: SUPER and so weren't initing OB-USE-DICT
\      to false.  Therefore lot's of things were getting allocated
\      in the dictionary!
\ MOD: PLB 7/26/86 Added STUFF: method.
\ MOD: PLB 7/27/86 Added ?DUP IF to INDEXOF: to fix size=0 bug.
\                  Moved INDEXOF: from ELMNTS.
\ MOD: PLB 7/29/86 Added OB.REPORT for object error reporting.
\ MOD: PLB 9/12/86 Added GET.NAME: and PUT.NAME: and +TO:
\ MOD: PLB 10/12/86 Changed to new OB.IVAR to IV.LONG system.
\ MOD: PLB 10/13/86 Vectored AT: and TO: to allow width changes.
\ MOD: PLB 11/21/86 Added width:
\ MOD: PLB 12/3/86  Put AR.SELECT.CFA in NEW: for MAC
\ MOD: PLB 1/20/87  Change EVENUP.DP to ALIGN
\ MOD: PLB 1/21/87 Added INSTANTIATE and DEINSTANTIATE
\ MOD: PLB 2/10/87 Added 0 iv=> iv-#cells to FREE:
\ MOD: PLB 2/13/87 Added EXTEND: method.
\ MOD: PLB 2/19/87 Added EMPTY: stub.  , use MM.ZALLOC
\ MOD: PLB 4/2/87  Added USE->REL to OS.DUMP, changed order.
\ MOD: PLB 11/16/87 Add RUN.FASTER and RUN.SAFER
\          Put CR before name in PRINT:
\ MOD: PLB 11/17/87 Added USE->REL to <INSTANTIATE>,
\          0 out object when DEINSTANTIATEd to prevent
\          continued use.
\ MOD: PLB 12/15/87 EXTEND: now does a NEW: if no data.
\ MOD: PLB 9/13/88 Allow INSTANTIATE to pass params to INIT:
\ MOD: PLB 10/4/89 Add CLASS check to <instantiate>.
\ MOD: PLB 11/8/89  Remove USE->REL stuff from INSTANTIATE
\ MOD: PLB 12/15/89 Add }stuff: and }NEWStuff:
\ MOD: PLB 5/17/91 Split OBJ_ARRAY into OBJ_OBJECT & OBJ_ARRAY
\ 00001 PLB 5/22/92 Make PUT.NAME: save name if dynamic.
\ 00002 PLB 5/25/92 Add TERM: method when deinstantiated.
\ 00003 PLB 6/9/92 Clear object validation key when deinstantiated.
\ 00004 PLB 8/3/92 Objects put absolute address on stack.

ANEW TASK-OBOBJECT

variable DYNOBJ-COUNT

: <###> ( 0-999 -- addr count , make string with leading zeros )
    s->d <# # # # #>
;

\ Support the dynamic allocation of an object.
32 constant OBJ_NAME_SIZE
:STRUCT  OBJ_DYN_HEADER  \ Dynamic Header for Object
    Struct DoubleList odh_node
    OBJ_NAME_SIZE bytes odh_name
    4 bytes odh_object
;STRUCT

DoubleList OBJ-DYN-LIST  \ list of dynamically alloced objs

: OBJ.OBJ>DH  ( dynamic_object -- dynamic_header )
    odh_object -
;
: OBJ.DH>OBJ  ( dynamic_header -- dynamic_object)
    odh_object +
;

: ODH.INIT obj-dyn-list dll.newlist ;

: OB.INIT  ob.init odh.init ;
: AUTO.INIT  auto.init ob.init ;

( declare methods for object, define OBJECT class )
METHOD TERM: \ 00002
METHOD ADDRESS:
METHOD SPACE:
METHOD DUMP:
METHOD NAME:
METHOD PUT.NAME:
METHOD GET.NAME:
METHOD .CLASS:

:CLASS OBJECT   ( root class )
    IV.RPTR IV-NAME  ( This must always be the first IVAR )

:M INIT:  ( -- , setup object )
    0 iv=> iv-name
;M

:M TERM: ( -- ) \ 00002
;M

:M ADDRESS:  ( -- addr , leave address of object )
    os.copy
;M

:M SPACE: ( -- NBYTES , size of ivariable space )
    os.copy  ob.obj->class ( point to base of class )
    @
;M

:M DUMP: ( -- , hex dump ivars )
    os.copy space: self  dump
;M

:M GET.NAME: ( -- $name , put name of object on pad as string )
    iv-name ?dup 0=
    IF address: self pfa->nfa nfa->$
    ELSE dup c@ 31 >
        IF nfa->$
        THEN
    THEN
;M

:M NAME: ( -- , print name of object )
    get.name: self $.
;M

\ Object Error Reporting -----------------------------------
: OS.DUMP ( -- , Show objects on OBJECT-STACK )
    >newline ." Object Stack --------" cr
    os.depth 0
    ?DO  os.depth i - 1- os.pick
\ use->rel \ 00004
        4 spaces name: [] cr
    LOOP
;

: OB.REPORT.ERROR  ( $word $message level -- , report error in object )
    os.dump
    dup er_fatal =    IF os.sp! THEN
    er.report
;

:M PUT.NAME: ( $name -- , put name of object in object )
    self in.dict? not  \ is this dynamically instantiated?
    IF
        dup c@ OBJ_NAME_SIZE <
        IF
            self obj.obj>dh .. odh_name
            tuck $move  \ set dynamic name
        THEN
    THEN
    iv=> iv-name
;M

:M .CLASS: ( -- , print class of object )
    address: self ob.obj->class
    pfa->nfa id.
;M

;CLASS

: OBJ.FIND.DYN  { $name | rel_obj tempobj -- rel_obj true | false }
    0 -> rel_obj
    obj-dyn-list dll.first
    BEGIN
        dup dll.end? not
        IF
            dup obj.dh>obj
\ use->rel \ 00004
            -> tempobj
            get.name: tempobj $name
            $equal
            IF
                tempobj -> rel_obj true
            ELSE
                dll.next false
            THEN
        ELSE true
        THEN
    UNTIL drop
    rel_obj ?dup 0= 0=
;

: 'O ( <name> -- rel_obj , return relative object )
    bl word
    obj.find.dyn 0= abort" Couldn't find dynamic object!"
;

: OBJ.LIST.DYN  ( -- )
    >newline
    obj-dyn-list dll.first
    BEGIN
        dup dll.end? not
    WHILE
        dup .. odh_name 4 spaces $type cr?
        dll.next
    REPEAT
    drop
;

: <?INSTANTIATE> ( pfa_class --  rel_addr_object | 0 , instantiate class )
    dup ob.check.class
    dup >r @ ( -- size )
    odh_object + ( make room for fake name and node)
    mm.zalloc? ?dup
    IF
        dup obj-dyn-list dll.add.head
        r> ( -- dynheader class )
        over >r
        swap .. odh_object swap  \ convert to object address
        ob.setup ( use return stack to allow passing to INIT: )
\
\ Store unique name in OBJ_NAME_SIZE bytes before object.
        " DYN" r@ .. odh_name $move
        dynobj-count @ 1+ dup dynobj-count ! <###>  ( addr count )
        r@ .. odh_name $append
        r@ .. odh_name
        r> obj.dh>obj
\ use->rel \ 00004
        tuck put.name: []
    ELSE
        rdrop 0
    THEN
;

: <INSTANTIATE> (  pfa_class --  rel_addr_object | ABORT )
    <?instantiate>
    dup 0= abort" <INSTANTIATE> - insufficient memory!"
;

: INSTANTIATE ( <class> -- addr_object | abort , instantiate class )
    bl word find
    IF ( -- cfa )
        >body
        state @
        IF [compile] aliteral compile <instantiate>
        ELSE <instantiate>
        THEN
    ELSE ( -- name )
        >newline $type cr
        " INSTANTIATE" " Class could not be found!"
        er_fatal er.report
    THEN
; IMMEDIATE

: ?INSTANTIATE ( <class> -- addr_object | 0 , instantiate class )
    bl word find
    IF ( -- cfa )
        >body
        state @
        IF [compile] aliteral compile <?instantiate>
        ELSE <?instantiate>
        THEN
    ELSE ( -- name )
        >newline $type cr
        " ?INSTANTIATE" " Class could not be found!"
        er_fatal er.report
    THEN
; IMMEDIATE

: DEINSTANTIATE ( object -- , Deallocate an object )
\   rel->use \ 00004
    dup in.dict?
    IF
        drop \ in dictionary, not allocated
    ELSE
        dup ob.valid?
        IF
            dup term: []  \ give object an opportunity to clean up 00002
            0 over !  ( clear class pointer to disable object )
            0 over cell+ ! ( clear object validation key  00003 )
            obj.obj>dh dup dll.remove mm.free
        ELSE
            drop \ maybe already deinstantiated
        THEN
    THEN
;

\ define OB.INT class --------------------------------------
METHOD CLEAR:
METHOD GET:
METHOD PUT:
METHOD PRINT:
METHOD +:

:CLASS OB.INT <SUPER OBJECT
    IV.LONG IV-INT-DATA

:M CLEAR: ( -- , set to zero )
    0 iv=> iv-int-data
;M

:M INIT:  ( -- , setup )
    clear: self
;M

:M GET:  ( -- value , fetch )
    iv-int-data
;M

:M PUT: ( value -- , store )
    iv=> iv-int-data
;M

:M PRINT: ( -- , show data )
    cr get: self . cr
;M

:M +: ( value -- , add to contents )
    iv+> iv-int-data
;M
;CLASS

