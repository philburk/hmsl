\ @(#) ob_bind.fth 96/06/11 1.1
\ BINDING for Object Oriented Development Environment
\
\ This code provides words for binding a message to the appropriate
\ method for an object.  Binding can occur at compile time ( "EARLY" ),
\ or at run time, ( "LATE" )
\
\ Author: Phil Burk
\ Copyright 1986 Phil Burk
\
\ MOD: PLB 11/29/86 Added MAC RO calls.
\   For relocating systems, like on the MAC, relocatable tokens
\   are stored in the dictionary, and absolute addresses are used at
\   run time (when possible ).  The object stack contains absolute
\   addresses.  The CFAs for methods are stored as relocatable tokens.
\ MOD: PLB 5/13/87 Change OS-STACK-PTR to OSSTACKPTR for Mac
\ MOD: PLB 5/24/87 Compile time check for Illegal Method.
\ MOD: PLB 9/6/87 Add binding for Instance Objects.
\ MOD: PLB 9/8/87 Preshift late bound offset in OB.LATE.BIND
\      mdh 7/2/88 changed appropriate 'literal's to 'aliterals's
\ MOD: PLB 7/25/88 USE OB.OBJ->CFA_BASE in OB.BIND.RUN
\ MOD: PLB 11/27/90 Warn if recursive call to self.
\ 00001 PLB 10/24/91 Allow binding to local variables.
\ 00002 PLB 11/12/91 Call LOCAL.REFERENCE to force fetch.
\ 00003 PLB 1/22/92 Assembled OB.BAD.CLASS? and added odd check.
\ 00004 PLB 6/9/92 Use OB_VALID_OBJECT in OB.VALID?
\ 00005 PLB 8/3/92 Objects put absolute address on stack.
\ 19961106 PLB Port binding to objects passed as local variables to Pforth.

ANEW TASK-OB_BIND.FTH

( Bind a method found in a CFA array. )
( Object base holds a pointer to an array of method CFAS )
: OB.OBJ->CFA_BASE  ( use_obj_base -- use_cfa_base )
	@  rel->use  ( relocate rel_cfa_base )
;

: OB.OBJ->CLASS  ( use_obj_base -- use_class_base )
	@ rel->use ob_cfas -
;

: OB.CFA@ ( use_obj_base method_index -- rel_method_cfa , CFA for method )
	cell* swap @ rel->use
	+ @
;

\ Error Checking for binding --------------------------------------
: OB.VALID?  ( abs_object -- true_if_ok )
\ rel->use \ 00005
	dup in.dict?   \ FIXME - what about instantiated objects?
	IF
        s@ obj_key ob_valid_object = \ 00004
	ELSE
		drop 0
    THEN
;

: OB.IN.DICT? ( object -- flag )
\ rel->use \ 00005
	in.dict?
;

: OB.BAD.CLASS? ( use_class_base -- bad? )
	dup 1 and
	IF
		drop true
	ELSE
		..@ ob_valid_key ob_valid_class = NOT
	THEN
;

: OB.CHECK.CLASS  ( use_class_base -- , abort if not a class )
	ob.bad.class?
	IF
		" OB.CHECK.CLASS" " Not an ODE class!"
		er_fatal er.report
	THEN
;

: OB.CHECK.METHOD  ( method_index use_class_base -- , abort if bad method )
	..@ ob_#methods >
	IF   " OB.CHECK.METHOD" " Method not supported for that object!"
		er_fatal er.report
	THEN
;

: OB.CHECK.OBJECT  ( use_object -- , abort if not an object )
	s@ obj_key ob_valid_object - \ 00004
	IF
		" OB.CHECK.OBJECT" " Not an ODE object!"
		er_fatal er.report
	THEN
;

: OB.CHECK.BIND ( use_object method_index -- , abort if bad )
	swap dup ob.check.object
	ob.obj->class
	ob.check.method
;

\ DO compile time checking for illegal methods.
: OB.CHECK.ILLEGAL ( rel_method_cfa -- )
	rel->use 'c ob.bad.method =
	IF " OB.CHECK.ILLEGAL" " Method not defined for this class."
		er_fatal er.report
	THEN
;

\ Compile code to execute method for an object. ---------------
#HOST_PFORTH [IF]
: OB.BIND.CFA  ( use_obj_base rel_method_cfa -- , binds method to object )
	dup ob.check.illegal swap
	STATE @ IF
		[compile] aliteral
		compile os.push
		compile,
		compile os.drop
	ELSE
		os.push
		execute  os.drop
	THEN
;

: OB.BIND.INSTANCE.CFA ( instance_offset rel_method_cfa -- )
	dup ob.check.illegal swap
	state @
	IF  [compile] literal
		compile os+push
		compile,
		compile os.drop
	ELSE
		os+push
		execute os.drop
	THEN
;

[THEN]

#HOST_AMIGA_JFORTH [IF]
: OB.BIND.CFA  ( use_obj_base rel_method_cfa -- , binds method to object )
	dup ob.check.illegal swap
	STATE @ IF
		[compile] aliteral
		compile os.push
		calladr,
		compile os.drop
	ELSE
		os.push
		execute  os.drop
	THEN
;

: OB.BIND.INSTANCE.CFA ( instance_offset rel_method_cfa -- )
	dup ob.check.illegal swap
	state @
	IF  [compile] literal
		compile os+push
		calladr,
		compile os.drop
	ELSE
		os+push
		execute os.drop
	THEN
;

[THEN]

#HOST_MAC_H4TH [IF]
: (OB.EXEC.METHOD)  ( rel_method_cfa rel_obj_base -- )
\	rel->use \ 00005
	os.push ro.execute os.drop
;

: OB.BIND.CFA  ( use_obj_base rel_method_cfa -- , binds method to object )
	dup ob.check.illegal
	STATE @ IF
		[compile] literal  ( cfa )
\	use->rel [compile] literal    ( obj_base  00005 )
		[compile] Aliteral    ( obj_base  00005 )
		compile (ob.exec.method)
	ELSE
		swap os.push ro.execute os.drop
	THEN
;

: (OB.EXEC.METHOD.I)  ( rel_method_cfa offset -- )
	os+push ro.execute os.drop
;

: OB.BIND.INSTANCE.CFA ( instance_offset rel_method_cfa -- )
	dup ob.check.illegal
	state @
	IF
		[compile] literal  ( cfa )
		[compile]  literal  ( offset )
		compile (ob.exec.method.i)
	ELSE
		swap os+push
		ro.execute os.drop
	THEN
;
[THEN]

variable OB-IF-CHECK-BIND
variable OB-CURRENT-MIND  \ currently compiling method index


: OB.BIND.RUN  ( object method_index*4 -- , run time binding act)
	>r
\ rel->use \ 00005
	ob-if-check-bind @
	IF dup r@ 4/ ob.check.bind
	THEN
	dup os.push   ( push object onto object stack )
	@ rel->use r> +  ( index to method cfa )
	@ ( rel->use ) execute   ( Perform method on object. )
	os.drop
;

: OB.LATE.BIND  ( [object] method_index -- , do late binding of method )
\  object not present at compile time.
	STATE @
	IF
		cell* ( preshift for faster run time )
		[compile] literal  ( save method index for late binding )
		compile ob.bind.run
	ELSE  cell* ob.bind.run
	THEN
;

: SELF ( -- rel_obj_base, of_self )
	os.copy
\	use->rel ( %R 00005 )
;

EXISTS? [] NOT [IF]
: []   ( -- , use late binding if 'method: []' )
	" OBJECT USE" " '[]' CAN ONLY BE AFTER A METHOD"
		er_fatal  er.report
;
[THEN]

: SUPER ( --- , stub for superbinding )
	" OBJECT USE" " 'SUPER' can only be used inside a METHOD definition"
	er_fatal  er.report
;

\ Binding with super-dooper uses the method defined in a superclasses'
\ superclass.
: SUPER-DOOPER ( --- , stub for superbinding with skip )
	" OBJECT USE"
	" 'SUPER-DOOPER' can only be used inside a METHOD definition"
	er_fatal  er.report
;


#HOST_AMIGA_JFORTH [IF]
: OB.BIND.'BASE ( CFA -- , bind CFA to current object )
	?comp calladr,
;
[THEN]


#HOST_PFORTH [IF]
: OB.BIND.'BASE ( CFA -- , bind CFA to current object )
	?comp compile,
;
[THEN]

#HOST_MAC_H4th [IF]
: OB.BIND.'BASE  ( rel_CFA -- , bind CFA to current object )
	?comp [compile] literal   compile ro.execute
;
[THEN]

\ These words work off of a variable that contains a use_cfa_base.
: OB.BIND.VAR ( method_index cfa_base_variable -- , bind from that variable )
	@ swap cell* + @  ( -- method_cfa )
	dup ob.check.illegal
	ob.bind.'base  ( %? )
;

: OB.BIND.INSTANCE ( method_index pfa_object_def -- )
	dup ..@ obi_offset ( get offset )
	-rot  s@ obi_rel_class .. ob_cfas ( -- off mi acfas )
	swap cell* + @
	ob.bind.instance.cfa
;

: OB.BIND.NORMAL  ( method_index pfa_object -- )
	dup rot 2dup ob.check.bind
	ob.cfa@ ob.bind.cfa
;

: OB.EARLY.BIND  ( method_index cfa_object -- )
	cfa->pfa
	ob-state @ ob_def_class =
	IF  dup ob-current-class @
		ob.is.instance? ( Check to see if this is an Instance Object.)
		IF ob.bind.instance
		ELSE ob.bind.normal
		THEN
	ELSE ob.bind.normal
	THEN
;

: OB.FIND.OBJECT  { | $name cfa -- cfa , abort if not found }
	0 -> cfa
	bl word -> $name
\ ." Word = " $name count type cr
\
\ is this a local variable
	local-compiler @ ?dup
	IF  ( -- 'compiler )
		$name swap execute
		IF \ if so compile reference and use late binding
			['] [] -> cfa   
		THEN
	THEN
	
\ do we already have a winner
	cfa 0=
	IF
		$name find NOT
		IF
			>newline count type ."  ?" cr
			" OB.FIND.OBJECT" " Object not found!"
			er_fatal  er.report
		THEN
		-> cfa
	THEN	
	cfa
;

: OB.CHECK.RECURSE  ( method_index -- , warn in recurse: self )
	ob-current-mind @ =
	IF
		" OB.CHECK.RECURSE" " Recursive message to self!"
		er_warning er.report
		current-method @ id. ."  SELF" cr
	THEN
;


: OB.BIND   ( method_index <object> -- , bind )
	ob.find.object  ( -- mi cfa )
	CASE  ( Different types of binding. )
\ Assume rel_obj_base also on stack at runtime for late binding.
		'c []
		OF ob.late.bind
		ENDOF
\
		'c SELF
		OF	dup ob.check.recurse
			ob-self-cfas ob.bind.var
		ENDOF
\
		'c SUPER
		OF ob-super-cfas ob.bind.var
		ENDOF
\
		'c SUPER-DOOPER
		OF ob-dooper-cfas ob.bind.var
		ENDOF
\
\ Bind named object.
		ob.early.bind 0   ( needs zero for dropping )
	ENDCASE
;
