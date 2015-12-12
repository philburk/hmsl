/*
** Doubly Linked List
**
** Author: Phil Burk
** Copyright 1996 Phil Burk
** All Rights Reserved.
*/
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "dbl_list.h"

static void DLL_Connect( DoubleNode *dln1, DoubleNode *dln2);

#define STOP_DEBUG  { *((int *)NULL) = 1; }  /* Piss off CPU */
#ifdef PARANOID
int DLL_CheckNodeInList( DoubleNode *dln )
{
/* Check to see whether node is connected to neighbors. */
	if( (DLL_Next(DLL_Previous(dln)) != dln) |
		(DLL_Previous(DLL_Next(dln)) != dln) )
	{
		printf("DLL node not properly in list! 0x%x\n", dln);
		fflush(stdout);
		return 1;
	}
	else
	{
		return 0;
	}
}
#define CHECK_NODE(n) { if( DLL_CheckNodeInList(n) ) STOP_DEBUG; }

int DLL_CheckNodeInit( DoubleNode *dln )
{
/* Check to see whether node is connected to neighbors. */
	if( (DLL_Next(dln) != dln) |
		(DLL_Previous(dln) != dln) )
	{
		printf("DLL node not initialized! 0x%x\n", dln);
		fflush(stdout);
		return 1;
	}
	else
	{
		return 0;
	}
}
#define CHECK_NODE_INIT(n) { if( DLL_CheckNodeInit(n) ) STOP_DEBUG; }

int DLL_CheckPreviousLink( DoubleNode *dlnPrev, DoubleNode *dln )
{
/* Check to see whether node is connected to neighbors. */
	if( (DLL_Previous(dln) != dlnPrev) )
	{
		printf("DLL_CheckPreviousNode: list broken! 0x%x 0x%x\n", dlnPrev, dln );
		fflush(stdout);
		return 1;
	}
	else
	{
		return 0;
	}
}
#define CHECK_PREVIOUS_LINK(n,p) { if( DLL_CheckPreviousLink(n,p) ) STOP_DEBUG; }

int DLL_CheckNextLink( DoubleNode *dln, DoubleNode *dlnNext )
{
/* Check to see whether node is connected to neighbors. */
	if( (DLL_Next(dln) != dlnNext) )
	{
		printf("DLL_CheckNextLink: list broken! 0x%x 0x%x\n", dln, dlnNext);
		fflush(stdout);
		return 1;
	}
	else
	{
		return 0;
	}
}
#define CHECK_NEXT_LINK(n,nx) { if( DLL_CheckNextLink(n,nx) ) STOP_DEBUG; }
#else
#define CHECK_NODE(n) /* I'm sure it's fine, really. */
#define CHECK_NODE_INIT(n) /* I'm sure it's fine, really. */
#define CHECK_PREVIOUS_LINK(n,p) /* I'm sure it's fine, really. */
#define CHECK_NEXT_LINK(n,nx) /* I'm sure it's fine, really. */
#endif

/* connect dn2 after dn1 */
static void DLL_Connect( DoubleNode *dln1, DoubleNode *dln2)
{
	(dln1)->dln_Next = dln2;
	(dln2)->dln_Previous = dln1;
}

void DLL_InsertAfter( DoubleNode *dln, DoubleNode *dlnNew )
{
	DoubleNode *dlnTemp = DLL_Next(dln);
	CHECK_NODE_INIT(dlnNew);
	CHECK_PREVIOUS_LINK(dln,dlnTemp);
/* Connect new one first so other tasks that only use next can still read safely. */
	DLL_Connect( dlnNew, dlnTemp );
	DLL_Connect( dln, dlnNew );
	CHECK_NODE(dlnNew);
}

void DLL_InsertBefore( DoubleNode *dln, DoubleNode *dlnNew )
{
	DoubleNode *dlnTemp = DLL_Previous(dln);
	CHECK_NODE_INIT(dlnNew);
	CHECK_NEXT_LINK(dlnTemp,dln);
	DLL_Connect( dlnNew, dln );
	DLL_Connect( dlnTemp, dlnNew );
	CHECK_NODE(dlnNew);
}

void DLL_Remove( DoubleNode *dln )
{
	CHECK_NODE(dln);
	DLL_Connect( DLL_Previous(dln), DLL_Next(dln) );
	DLL_InitNode(dln);
}

/* Remove first element or return NULL if empty. */
DoubleNode *DLL_RemoveFirst( DoubleList *dll )
{
	DoubleNode *dln;
	if( !((dln = dll->dll_First) == (DoubleNode *) dll))
	{
			DLL_Remove( dln );
	}
	else
	{
		dln = NULL;
	}
	return dln;
}

void DLL_InitNode( DoubleNode *dln )
{
	dln->dln_Next = dln;
	dln->dln_Previous = dln;
}

/* Point it to itself in a degenerate loop. */
void DLL_InitList( DoubleList *dll )
{
	DLL_InitNode( (DoubleNode *) dll );
}

int DLL_IsEmpty( DoubleList *dll )
{
	return ( dll->dll_First == (DoubleNode *) dll );
}

/********************************************************************/
/* Add a list of nodes to the tail of another list. */
void DLL_AddListToTail( DoubleList *dll, DoubleList *subList )
{
	if( !DLL_IsEmpty( subList ) )
	{
		DoubleNode *dlnTemp = dll->dll_Last;
		DLL_Connect( subList->dll_Last, (DoubleNode *)(dll) );
		DLL_Connect( dlnTemp, subList->dll_First );
		DLL_InitList( subList );
	}
}

int DLL_CountNodes( DoubleList *dll )
{
	DoubleNode *dln;
	int count = 0;
	dln = DLL_First( dll );
	while( !DLL_IsEnd( dll, dln ) )
	{
		count++;
		dln = DLL_Next( dln );
	}
	return count;
}


/*******************************************************
 * Find NamedNode with matching name.
 *
 * Returns 0 if not found, 1 if found;
 */
int DLL_FindNodeByName( DoubleList *dll, char *name, NamedNode **nnPtr )
{
	int result = 0;
	NamedNode  *nn = NULL;

// printf("DLL_FindNodeByName( .., %s, .. )\n", name );
	*nnPtr = NULL;

/* Scan list. */
	nn = (NamedNode *) DLL_First( dll );
	while( !DLL_IsEnd( dll, &nn->nn_Node ) )
	{
/* Does name match? */
		if( strcmp(nn->nn_Name, name) == 0 )
		{
			*nnPtr = nn;
			result = 1;
// printf("DLL_FindNodeByName: found %s\n", name );
			break;
		}
		nn = (NamedNode *) DLL_Next( &nn->nn_Node );
	}

	return result;
}

/*******************************************************
 * Find NamedNode with matching ID.
 *
 * Returns 0 if not found, 1 if found;
 */
int DLL_FindNodeByID( DoubleList *dll, int ID, NamedNode **nnPtr )
{
	int result = 0;
	NamedNode  *nn = NULL;

// printf("DLL_FindNodeByID( .., %d, .. )\n", ID );
	*nnPtr = NULL;

/* Scan list. */
	nn = (NamedNode *) DLL_First( dll );
	while( !DLL_IsEnd( dll, &nn->nn_Node ) )
	{
/* Does name match? */
		if( nn->nn_ID == ID )
		{
			*nnPtr = nn;
			result = 1;
// printf("DLL_FindNodeByID: found %d\n", ID );
			break;
		}
		nn = (NamedNode *) DLL_Next( &nn->nn_Node );
	}

	return result;
}


/*******************************************************
 * Count how many nodes have the same name.
 *
 * Returns number found.
 */
int DLL_CountNodesByName( DoubleList *dll, char *name )
{
	int count = 0;
	NamedNode  *nn = NULL;

// printf("DLL_CountNodesByName( .., %s, .. )\n", name );

/* Scan list. */
	nn = (NamedNode *) DLL_First( dll );
	while( !DLL_IsEnd( dll, &nn->nn_Node ) )
	{
/* Does name match? */
		if( strcmp(nn->nn_Name, name) == 0 ) count++;
		nn = (NamedNode *) DLL_Next( &nn->nn_Node );
	}

	return count;
}

