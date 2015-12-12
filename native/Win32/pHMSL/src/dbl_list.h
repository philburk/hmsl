#ifndef DBL_LIST_H
#define DBL_LIST_H
/*
** Doubly Linked List
**
** Author: Phil Burk
** Copyright 1996 Phil Burk
** All Rights Reserved.
*/

typedef struct DoubleNode
{
	struct DoubleNode      *dln_Next;
	struct DoubleNode      *dln_Previous;
} DoubleNode;

typedef struct DoubleList
{
	struct DoubleNode      *dll_First;
	struct DoubleNode      *dll_Last;
} DoubleList;

typedef struct NamedNode
{
	DoubleNode              nn_Node;
	char                   *nn_Name;
	int                     nn_ID;
} NamedNode;

#define DLL_Next(dln) ((dln)->dln_Next)
#define DLL_Previous(dln) ((dln)->dln_Previous)
#define DLL_AddHead( dll ,dln ) DLL_InsertAfter( (DoubleNode *)(dll), (dln) )
#define DLL_AddTail( dll, dln ) DLL_InsertBefore( (DoubleNode *)(dll), (dln) )
#define DLL_First( dll ) ((dll)->dll_First)
#define DLL_Last( dll ) ((dll)->dll_Last)
#define DLL_IsEnd( dll, dln ) ((dll) == (DoubleList *) (dln))

#ifdef __cplusplus
extern "C" {
#endif

void DLL_InsertAfter( DoubleNode *dln, DoubleNode *dlnNew );
void DLL_InsertBefore( DoubleNode *dln, DoubleNode *dlnNew );
void DLL_Remove( DoubleNode *dln );
DoubleNode *DLL_RemoveFirst( DoubleList *dll );
void DLL_InitNode( DoubleNode * dln );
void DLL_InitList( DoubleList *dll );
int  DLL_IsEmpty( DoubleList *dll );
void DLL_AddListToTail( DoubleList *dll, DoubleList *subList );
int  DLL_CountNodes( DoubleList *dll );
int  DLL_FindNodeByName( DoubleList *dll, char *name, NamedNode **nnPtr );
int  DLL_FindNodeByID( DoubleList *dll, int ID, NamedNode **nnPtr );
int  DLL_CountNodesByName( DoubleList *dll, char *name );

#ifdef __cplusplus
}
#endif

#endif /* DBL_LIST_H */
