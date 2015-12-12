\ @(#) dbl_list.fth 96/06/11 1.1
\ Doubly Linked List Support
\ This is similar but not as fancy as an Amiga Exec List
\
\ Author: Phil Burk
\ Copyright 1991 Phil Burk

ANEW TASK-DBL_LIST.FTH

:STRUCT DoubleList
	RPTR dll_Head
	RPTR dll_Tail
	RPTR dll_TailPrev
;STRUCT


:STRUCT DoubleNode
	RPTR dln_Next
	RPTR dln_Prev
;STRUCT

\ List handling macros.

: DLL.NODE.INIT  ( node -- , initialize node )
	>r ( save node address )
	NULL r@ ..!  dln_next
	NULL r@ ..!  dln_Prev
	rdrop
;

: DLL.NEWLIST ( list -- , Initialize list header.)
	dup ..  dll_Tail over ..!  dll_Head
	dup ..  dll_Head over ..!  dll_TailPrev
	NULL swap ..!  dll_Tail
;

: DLL.EMPTY? ( list -- flag , true if empty )
	..@  dll_head ..@  dln_next 0=
;

: DLL.FIRST ( list -- first_node , get first node in list )
	..@  dll_head
;

: DLL.LAST ( list -- last_node , get last node in list )
	..@  dll_TailPrev
;

: DLL.NEXT ( node -- succeeding_node )
	..@  dln_next
;

: DLL.PREVIOUS ( node -- succeeding_node )
	..@  dln_prev
;

: DLL.CONNECT  ( node1 node0 -- , connect node1 after node0)
	2dup swap ( -- n1 n0 n0 n1 ) ..!  dln_Prev
	swap swap ( -- n1 n0 ) ..!  dln_next
;

: DLL.REMOVE ( node -- , remove from list )
	dup dll.next
	over dll.previous
	dll.connect
	dll.node.init
;

: DLL.ADD.TAIL ( node list -- )
	2dup dll.last  ( -- n l n lastn )
	dll.connect
	..  dll_tail swap dll.connect
;

: DLL.ADD.HEAD ( node list -- )
	2dup dll.first  ( -- n l n firstn )
	swap dll.connect
	dll.connect
;

: DLL.INSERT  ( node1 node0 -- , insert n1 after n0 )
	2dup dll.next swap dll.connect ( n1<->n2 )
	dll.connect ( n0<->n1 )
;

: DLL.END?  ( node -- , is this beyond the last node ? )
	dll.next 0=
;

: DLL.LAST?  ( node -- , is this the last node ? )
	dll.next dll.end?
;

DEFER DLL.PROCESS.NODE ( node )
' . is DLL.PROCESS.NODE

: DLL.SCAN.LIST ( list -- , dump nodes of list )
	dll.first
	BEGIN
		dup dll.next ?dup
	WHILE
		swap dll.process.node
	REPEAT drop
;

\ Test code
true [IF]
DOubleList LIST1
DoubleNode NODE1
DoubleNode NODE2
DoubleNode NODE3
DoubleNode NODE4
DoubleNode NODE5

: TEL.INIT
	list1 dll.newlist
	node1 dll.node.init
	node2 dll.node.init
	node3 dll.node.init
;

: TEL.LINK
	node1 list1 dll.add.tail
	node2 list1 dll.add.tail
	node3 list1 dll.add.tail
;

: DUMP.NODE ( node -- )
	dup body> >name id.
	dll.last? not
	IF  ."  -> " cr?
	ELSE cr
	THEN
;

: SCANL
	'c dump.node is dll.process.node
	list1 dll.scan.list
;

[THEN]


