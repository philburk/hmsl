\ @(#) ob_main.fth 96/06/11 1.1
\ ODE - Object Oriented Development Environment
\
\ This file contains the basis for the Object Oriented
\ Development Environment used by HMSL.  The essential
\ words like :CLASS and <SUPER are defined here.
\
\ Notes:
\  RELOCATION: When addresses are stored in the dictionary,
\  they are stored in a relocatable form.  For JForth and HForth
\  this means they are stored as addresses relative to the base of
\  the dictionary.
\
\ (sizes are for a 32-bit Forth)
\ Data Structures:    ( offsets are from PFA )
\  CLASS Definition Structure
\  offset     name           contents
\    0     OB_SIZE        size of object
\    4     OB_#METHODS    number of methods
\    8     OB_VALID_KEY   key for class validation
\   12     OB_SUPER       rel pointer to base of super class
\   16     OB_LAST_IVAR   rel pointer to cfa of last of linked ivars
\   20     OB_CFAS        base of the CFA array, method_0 CFA
\   24       ---          method_1 CFA
\   28       ---          method_2 CFA
\            etc.

\ INSTANCE VARIABLE Definition Structure
\  offset     contents
\    0      offset in object
\    4      size of instance variable
\
\ INSTANCE OBJECT Definition Structure
\  offset     name          contents
\    0     OBI_OFFSET     offset in parent object
\    4     OBI_SIZE       size of object
\    8     OBI_PREVIOUS   link to previous Instance Object
\   12     OBI_REL_CLASS  rel pointer to class
\
\ OBJECT Structure
\  offset     contents
\    0      rel pointer to OB_CFAS of associated class.
\    4      object validation flag
\    8      start of instance variable space - rel name pointer
\
\ Parameter description:
\    USE_        = Prefix for Forth normal useable address.
\    REL_        = Prefix for relocatable token.
\ (Note: In JForth: USE_ = REL_ , in HForth: ABS_ = REL_ REL->USE )
\    _OBJ_BASE   = Base of object, contains REL_CFA_BASE
\    _CFA_BASE   = Address of first CFA in method array.
\    _CLASS_BASE = Base of class, offsets added to get to #ivars
\    OBJ_TOKEN   = Identifying token for object.
\    METHOD_INDEX = index of method in cfa table.
\    METHOD_CFA  = CFA for a method.
\
\ Author: Phil Burk
\ Copyright 1986 Phil Burk
\
\ MOD: PLB 7/14/86 Converted late binding to use relative addresses.
\ MOD: PLB 7/15/86 Added pairing checks to :M - ;M
\ MOD: PLB 7/17/86 Added OB.INIT, must be called before any objects.
\ MOD: PLB 7/25/86 Fixed stack leftovers bug, added " ! " to :CLASS.
\ MOD: PLB 8/16/86 Put error checking in BIND operation.
\ MOD: PLB 9/15/86 Converted to work with JForth
\      Put conditional compilation for OB.IVAR techniques.
\ MOD: PLB 9/16/86 Broke up into smaller files:
\      OBJ_STACK , OBJ_MAIN , OBJ_BINDING , OBJ_METHODS .
\      Added :STRUCT .
\ MOD: PLB 10/20/86 Moved :STRUCT to c_struct.
\ MOD: PLB 10/23/86 Made MAC mods.
\ MOD: PLB 11/29/86 Relocatable method tokens, CREATE MI-NEXT
\ MOD: PLB 2/20/87  Put 0 OB-STATE ! in MRESET
\ MOD: PLB 5/13/87  Zero ivars when instantiated, add os.push.
\ MOD: PLB 9/3/87   Add INHERITANCE.OF
\ MOD: PLB 9/8/87   Use structures for CLASS and INSTANCE OBJECTs.
\      Support Instance Objects.
\ MOD: PLB 1/13/88 Add relocation for Mac for Instance Objects
\ MOD: PLB 4/26/88 Add USE->REL to OB.PRELOAD.CFAS for Mac.
\      MDH 7/5/88   Modified MAKE.OBJECT to set CLASS_BIT in SFA
\      MDH 7/15/88  Modified :CLASS to set :CLASS_BIT in SFA
\ 00001 PLB 9/20/91 Sped up OB.SET.NAME on Mac by not doing PFA->NFA
\ 00002 PLB 6/8/92  Add validation flag to object
\ 00003 PLB 6/9/92  Simplify code by using local variables
\ 00004 PLB 8/3/92  Use ..@ and ..! to simplify code
\ 00005 PLB 8/3/92 Objects put absolute address on stack.

ANEW TASK-OB_MAIN

\ Error Detection and reporting. ================================
: OB.BAD.METHOD ( use_obj_base -- , Give error for undefined meth.)
    pfa->nfa id.
    " OB.BAD.METHODS" " Illegal method for object!"
    ER_FATAL  ER.REPORT
;

: OB.PRELOAD.CFAS ( use_cfa_base N -- , Load N methods into table. )
    0 ?DO ( FOR EACH METHOD )
        dup i cell* +
        'c ob.bad.method use->rel swap !
    LOOP drop
;

\ Method index counter ========================================
\ Every method is assigned a unique index when it is declared.
\ This index is used to lookup the appropriate CFA in a table
\ kept in the CLASS .

CREATE MI-NEXT 0 ,

\ Class definition  =========================================
\ Define CLASS structure ----------------------------------

U: OB-INSIDE-:M   ( flag for pairs checking )

\ Structures of Class and Instance Object Definition.
:STRUCT OB.CLASS
    LONG OB_SIZE
    LONG OB_#METHODS
    LONG OB_VALID_KEY
    RPTR OB_SUPER
    RPTR OB_LAST_IVAR    ( relative address of last ivar )
    LONG OB_CFAS
;STRUCT

:STRUCT OB.INSTANCE.OBJECT
    LONG OBI_OFFSET
    LONG OBI_SIZE
    RPTR OBI_PREVIOUS    ( relative )
    RPTR OBI_REL_CLASS
;STRUCT

:STRUCT OB.OBJECT
    RPTR  OBJ_CLASS_CFAS
    LONG  OBJ_KEY
    RPTR  OBJ_NAME
;STRUCT

\ An unlikely number, used for recognizing valid classes.
$ 518279AF CONSTANT OB_VALID_CLASS
\ An unlikely number, used for recognizing valid objects.
$ 4F626A74 CONSTANT OB_VALID_OBJECT

\ ----------------------------------------------------------
V: OB-SELF-CFAS ( use_cfa_base, for current class, fake instance )

1 [IF]
\ Set the IV-NAME instance variable in OBJECTS to
\ point to the NFA of the Instance Object Definition
: OB.SET.NAME ( addr_inst_obj_def addr_object -- , set IV-NAME )
\ This is a rather nasty thing to do - SO DON'T DO IT - TOO SLOW ON MAC!
\    swap pfa->nfa swap cell+ !   \  PFA->NFA is very slow! 00001
    >r drop " INSTOBJ" r> ..! obj_name
;
[ELSE]
: OB.SET.NAME ( addr_inst_obj_def addr_object -- , set IV-NAME )
    >r pfa->nfa r> ..! obj_name
;
[THEN]

: OB.SETUP  \ Setup data in object
dbug" ob.setup"
{ use_object use_class_base | obi_def use_obi use_cfas -- }
\
\ Recursively setup instance objects.
    use_class_base ..@ ob_last_ivar -> obi_def
    BEGIN obi_def ( is it zero )
dbug" ob.setup - recurse through instance objects."
    WHILE
        obi_def ..@ obi_offset ( get offset )
        use_object + -> use_obi ( calc address of instance object )
\
\ recursively call
        use_obi
        obi_def ..@ obi_rel_class   ( class of instance object )
        RECURSE

        obi_def use_obi ob.set.name
        obi_def ..@ obi_previous -> obi_def
    REPEAT
dbug" ob.setup - finish recursion."
\
\ Compile rel_cfa_base at obj_base.
    ( -- obj_base class_base )
    use_class_base .. ob_cfas -> use_cfas
    use_cfas use_object ..! obj_class_cfas ( set methods pointer in object)
\
dbug" ob.setup - store validation flag in object"
    ob_valid_object use_object ..! obj_key
\
dbug" ob.setup - execute INIT: method"
\ use_object  use_cfas  abort
    use_object os.push           ( push object address for method )
    \ Don't do rel->use for pForth cuz EXECUTE takes a relocatable token.
    use_cfas @ ( rel->use ) execute     ( execute INIT: method )
    os.drop
dbug" ob.setup - done"
;

#HOST_AMIGA_JFORTH [IF]
: MAKE.OBJECT ( abs_class_base -- , Instantiate an object. )
    CREATE  ( make object header )
\
\ Mark as CLASS definition for CLONE...
\
    latest name> cell-   dup @ CLASS_BIT or  swap !
\
\
        here swap                ( addr_object abs_class_base )
        dup ..@ ob_size allot    ( make room for ivars )
        2dup ..@ ob_size erase   ( zero out ivar space )
        ob.setup
        IMMEDIATE
    DOES> ( addr )
        [compile] aliteral
;
[ELSE]
: MAKE.OBJECT ( abs_class_base -- , Instantiate an object. )
    CREATE  ( make object header )
        here swap         ( addr_object abs_class_base )
        dup @ allot       ( make room for ivars )
        2dup @
        dbug" MAKE.OBJECT - zero out ivar space"
        erase      ( zero out ivar space )
        ob.setup
\   DOES> 00005
\       use->rel    ( run time action of object 00005 )
;
[THEN]

: MAKE.INSTANCE.OBJECT  ( abs_class_base -- , Template for embedded object )
    CREATE here >r
        dup @ ob.make.member
\ Link new instance object to previous instance object.
        ob-current-class @ ..@ ob_last_ivar
        if.use->rel , ( relocatable )
\
\ Update ob_last_ivar field in current class.
        r> ( -- abs_class_base inst_ivar )
        ob-current-class @ ..! ob_last_ivar
\ Save pointer to class, OB_REL_CLASS .
        use->rel ,
    DOES>
        @ ( get offset )
        os+
\ use->rel  ( -- rel_instance_object 00005 )
;

: :CLASS (  -- , Create a class with N methods )
\ Check pairs
    ob-state @
    IF " :CLASS" " Previous :STRUCT or :CLASS unterminated!"
        er_warning er.report
    THEN
    ob_def_class ob-state !     ( set pair flags )
    false ob-inside-:m !
\
\ Create new class defining word.
    CREATE
\
\
\ Added mdh...
[ #HOST_AMIGA_JFORTH [IF] ]
\
\ Mark as :CLASS definition for CLONE...
\
        latest name> cell-   dup @ :CLASS_BIT or  swap !
[ [THEN] ]
\
\
        here dup ob-current-class !  ( set current )
        .. ob_cfas ob-self-cfas !       ( for self binding )
\ Fill fields in CLASS, must match order as defined !
        obj_name ,               ( OB_IVAR_SPACE , initial ivar offset 00002 )
        mi-next @ dup ,         ( OB_#METHODS , # methods allowed )
        ob_valid_class ,        ( OB_VALID_KEY , key for validation )
        0 ,                     ( OB_SUPER , space for superclass pointer )
        0 ,                     ( OB_LAST_IVAR , space for pointer to last )
        here over cell* allot   ( OB_CFAS , make room for CFAS )
        swap ob.preload.cfas     ( put error method in for safety)
    DOES>
        ob-state @ ob_def_class =
        IF make.instance.object
        ELSE make.object
        THEN
;

\ INHERITANCE =============================================
( Methods will be inherited by copying CFAS into CFA array. )
V: OB-SUPER-CFAS   ( abs_cfa_base of SUPER CLASS )
V: OB-DOOPER-CFAS  ( abs_cfa_base of SUPER's SUPER CLASS )

: OB.SET.DOOPER    ( -- , set dooper cfas based on super )
    ob-super-cfas @       ( base of cfas )
    ob_cfas - ..@ ob_super ( superclass of superclass )
    ob_cfas + ob-dooper-cfas !
;

: <SUPER ( <WORD> ---- , COPY METHODS )
    ho.find.pfa NOT
    IF " <SUPER" " CLASS NOT FOUND"
        ER_FATAL ER.REPORT
    THEN ( -- super-pfa )
    ob-current-class @ ( -- super-pfa class-pfa )

\ Save superclass pointer in class.
    2dup ..! ob_super
\
\ Save pointer to last linked ivar object.
    over ..@ ob_last_ivar
    over ..! ob_last_ivar
\
\ Increment IVAR offset to include superclass' ivars
    2dup
    swap ..@ ob_size ( -- sp cp cp s# , space for super's ivars )
    over ..@ ob_size cell- + ( -- sp cp cp c#, 1 cell for class*)
    swap ..! ob_size

\ Copy method cfas from superclass
    over ..@ ob_#methods      ( sp cp #-inherited-methods )
    cell*                     ( sp cp #bytes , calc bytes to copy )
    rot  .. ob_cfas           ( cp #bytes super_cfas )
\
\ Save super_cfas for later binding.
    dup ob-super-cfas !
    rot .. ob_cfas            ( #bytes super_cfas class_cfas )
    rot cmove                 ( copy methods )
    ob.set.dooper
;

: ;CLASS ( -- , terminate class )
    ob-state @ ob_def_class = NOT
    IF " ;CLASS" " Missing :CLASS above" er_fatal er.report
    THEN
    0 ob-state !
;

: INHERITANCE.OF ( <class> -- , list superclasses of class )
    ho.find.pfa
    IF  cr
        BEGIN  ..@ ob_super dup
        WHILE  dup pfa->nfa id. space space cr? ?pause
        REPEAT drop
    THEN cr
;

: OB.IS.INSTANCE? { pfa_object_def class_base | prev result -- flag }
\ Scans list of instance variables in class for match.
    0 -> result   ( default answer = false )
    class_base ..@ ob_last_ivar -> prev
    BEGIN  prev
    WHILE
        pfa_object_def prev =
        IF
            true -> result
            0 -> prev
        ELSE
            prev ..@ obi_previous -> prev
        THEN
    REPEAT
    result
;


\ Tools for debugging ODE
: 'P ( <created_data_structure> -- pfa )
    [compile] 'c cfa->pfa
;

: METHOD@ ( method_index pfa_class -- abs_method_cfa )
    .. ob_cfas
    swap cell* + @ rel->use
;

: GET.METHOD ( method_index <class> -- method_cfa )
    'p method@
;
