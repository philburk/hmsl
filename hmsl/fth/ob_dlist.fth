\ Doubly Linked List
\

anew task-ob_dlist.fth

METHOD GET.PREVIOUS:  ( -- prev_node )
METHOD GET.NEXT:  ( next_node -- )
METHOD PUT.NEXT:  ( new_node -- )
METHOD PUT.PREVIOUS:  ( new_node -- )
METHOD CONNECT: ( new_node -- , connect new_node after this node )
METHOD INSERT.AFTER: ( new_node -- )
METHOD INSERT.BEFORE: ( new_node -- )

:CLASS  OB.DOUBLE.NODE  <SUPER OBJECT  \ node of doubly linked list
	iv.long  iv-dbl-next
	iv.long  iv-dbl-previous

:M GET.NEXT:  ( -- next_node )
	iv-dbl-next
;M
:M GET.PREVIOUS:  ( -- prev_node )
	iv-dbl-previous
;M

:M PUT.NEXT:  ( new_node -- )
	iv=> iv-dbl-next
;M
:M PUT.PREVIOUS:  ( new_node -- )
	iv=> iv-dbl-previous
;M

:M CONNECT: { new_node -- , connect new_node after this node }
\ ." Connect " name: self ."  to " name: new_node  cr
	new_node iv=> iv-dbl-next
	self put.previous: new_node
;M

:M INSERT.AFTER: { new_node -- }
	iv-dbl-next
	new_node connect: self
	connect: new_node
;M

:M INSERT.BEFORE: { new_node -- }
	new_node iv-dbl-previous 
	self connect: new_node
	connect: []
;M

:M REMOVE:  ( -- , remove from list )
	iv-dbl-next 0= abort" REMOVE: twice from list!"
	iv-dbl-previous 0= abort" REMOVE: twice from list!"
	
	iv-dbl-next iv-dbl-previous connect: []
	
	0 iv=> iv-dbl-next
	0 iv=> iv-dbl-previous
;M

:M PRINT:
	>newline
	iv-dbl-previous
	IF
		iv-dbl-previous	get.name: [] count type ."  => " name: self
		."  => " iv-dbl-next get.name: [] count type cr
	ELSE
		name: self ."  not in list." cr
	THEN
;M

;CLASS

METHOD ADD.HEAD: ( new_node -- )
METHOD ADD.TAIL: ( new_node -- )
METHOD ?END:  ( node -- flag , end of forward or backward scan? )
METHOD ?EMPTY: ( new_node -- )

:CLASS  OB.DOUBLE.LIST  <SUPER OB.DOUBLE.NODE  \ head of doubly linked list

:M INIT:
	self iv=> iv-dbl-next
	self iv=> iv-dbl-previous
;M

:M ?EMPTY:  ( -- flag )
	iv-dbl-next self =
;M

:M ADD.HEAD: ( new_node -- )
	iv-dbl-next insert.before: []
;M
:M ADD.TAIL: ( new_node -- )
	iv-dbl-previous insert.after: []
;M

:M FIRST:  ( -- node )
	iv-dbl-next
;M

:M LAST:  ( -- node )
	iv-dbl-previous
;M

:M ?END:  ( node -- flag , end of forward or backward scan? )
	self =
;M

:M DO:  { cfa -- }
	first: self
	BEGIN
		dup ?end: self not
	WHILE
		dup cfa execute
		get.next: []
	REPEAT
	drop
;M
		
;CLASS


0 [IF]
\ test double list objects

ob.double.node nd1
ob.double.node nd2
ob.double.node nd3
ob.double.node nd4
ob.double.list dbl

: validate.result { v1 v2 $msg -- }
	v1 v2 =
	IF
		." SUCCESS - "
		$msg count type cr
	ELSE
		." ERROR - "
		$msg count type cr
		abort
	THEN
;

: print.node ( node --  )
	print: []
;

: test.dbl
	?empty: dbl   true c" Initially empty." validate.result
	
\ add to head and tail
	nd2 add.head: dbl
	first: dbl nd2 c" Add ND2 head, get first." validate.result
	nd3 add.tail: dbl
	last: dbl nd3 c" Add ND3 tail, get last." validate.result
	nd4 add.tail: dbl
	last: dbl nd4 c" Add ND4 tail, get last." validate.result
	nd1 add.head: dbl
	first: dbl nd1 c" Add ND1 head, get first." validate.result
	
\ scan list
	get.next: nd1 nd2 c" next..."  validate.result
	get.next: nd2 nd3 c" next..."  validate.result
	get.next: nd3 nd4 c" next..."  validate.result
	get.next: nd4 ?end: dbl  true c" next end..." validate.result
	get.next: nd3 ?end: dbl  false c" not next end..." validate.result
	
	get.previous: nd4 nd3 c" prev..." validate.result
	get.previous: nd3 nd2 c" prev..." validate.result
	get.previous: nd2 nd1 c" prev..." validate.result
	get.previous: nd1 ?end: dbl  true c" prev end..." validate.result
	get.previous: nd2 ?end: dbl  false c" not prev end..." validate.result
	
	remove: nd2
	get.next: nd1 nd3 c" removed, 1->3"  validate.result
	get.next: nd2 0 c" removed, next 0"  validate.result
	get.previous: nd2 0 c" removed, prev 0" validate.result
	
	
	remove: nd4
	get.next: nd3 ?end: dbl true c" removed nd4, 3->end"  validate.result
	last: dbl nd3 c" removed, last 3"  validate.result
	
\ print list
	['] print.node do: dbl
;

test.dbl

[THEN]
