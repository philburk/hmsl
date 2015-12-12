\ These lists are used for tracking morphs that are created in the system.
\
\ Author: Phil Burk
\ Copyright 1986 -  Phil Burk, Larry Polansky, David Rosenboom.
\ All Rights Reserved
\
\ MOD: PLB 5/24/87 Add SYS.INIT
\ MOD: PLB 10/28/87 Add ML.CLEAR to SYS.RESET
\ MOD: PLB 2/18/92 Add ML.CLEAR to SYS.CLEANUP
\ 00001 PLB 4/27/92 Added ML.VALIDATE and [FORGET]

ANEW TASK-MORPH_LISTS

9999 constant ML_GRID_FACTOR   ( Internal. Don't modify. )

( Morph tracking lists. )
OB.OBJLIST SHAPE-HOLDER
OB.OBJLIST COLL-HOLDER
OB.OBJLIST STRUCT-HOLDER
OB.OBJLIST PLAYER-HOLDER
OB.OBJLIST PRODUCTION-HOLDER

\ Controls whether future defined morphs have their name placed in list.
CREATE ML-IF-INIT 0 ,
CREATE ML-IF-RECORD 0 ,

: ML.INIT  ( -- )
    ml-if-init @ NOT
    IF  64 new: shape-holder
        64 new: coll-holder
        32 new: struct-holder
        32 new: player-holder
        32 new: production-holder
        true ml-if-init !
        true ml-if-record !
    THEN
;

: ML.ADD ( rel_morph_base rel_list_base -- , Add to list )
    ml-if-record @
    IF add: []
    ELSE 2drop
    THEN
;

: ML.CLEAR   ( -- , clear all holding arrays )
     clear: shape-holder
     clear: coll-holder
     clear: struct-holder
     clear: player-holder
     clear: production-holder
;

: ML.PRINT ( -- , Print contents of all holders )
    cr ." SHAPES --------" print: shape-holder
       ." COLLECTIONS----" print: coll-holder
       ." STRUCTURES ----" print: struct-holder
       ." PLAYERS -------" print: player-holder
       ." PRODUCTIONS----" print: production-holder
;

: ML.FREE
     freeall: shape-holder
     freeall: coll-holder
     freeall: struct-holder
     freeall: player-holder
     freeall: production-holder
;

: ML.TERM
    ml.free
    free: shape-holder
    free: coll-holder
    free: struct-holder
    free: player-holder
    free: production-holder
    false ml-if-init !
    false ml-if-record !
;


: OBJLIST.VALIDATE  { objlist -- , remove any invalid objects }
    many: objlist ?dup
    IF dup 0
       DO dup i - 1- get: objlist ob.valid? NOT
           IF dup i - 1- remove: objlist
              ." Removing invalid object from" name: objlist cr
           THEN
       LOOP drop
    THEN
;

: ML.VALIDATE  ( -- , make sure all objects in lists are valid )
    shape-holder objlist.validate
    coll-holder objlist.validate
    struct-holder objlist.validate
    player-holder objlist.validate
    production-holder objlist.validate
;

: [FORGET]  ( -- , clean forgotten objects out of lists )
	[forget]
	'c task-morph_lists here <  \ are lists still loaded?
	IF
		ml.validate
	THEN
;


: SYS.INIT sys.init ml.init ;
: SYS.RESET sys.reset ml.clear ;
: SYS.CLEANUP sys.cleanup ml.clear ;
: SYS.TERM ml.term sys.term ;

