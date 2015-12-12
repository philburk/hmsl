/***************************************************************
** HMSL Event handling functions
**
** Author: Robert Marsanyi
***************************************************************/

#include <windows.h>
#include "pf_all.h"
#include "hmsl_graphics.h"
#include "hmsl_event.h"
#include "dbl_list.h"

extern HMSLContext *gHMSLContext;

LRESULT WINAPI HMSLWndProc( HWND hWnd, UINT uMsg, WPARAM wParam, LPARAM lParam )
{
	switch( uMsg )
	{
	case WM_LBUTTONDOWN:
		HMSL_BufferMessage( EV_MOUSE_DOWN, wParam, lParam );
		break;
	case WM_LBUTTONUP:
		HMSL_BufferMessage( EV_MOUSE_UP, wParam, lParam );
		break;
	case WM_MOUSEMOVE:
		HMSL_BufferMessage( EV_MOUSE_MOVE, wParam, lParam );
		break;
	case WM_PAINT:
		HMSL_BufferMessage( EV_REFRESH, wParam, lParam );
		break;
	case WM_CLOSE:
		HMSL_BufferMessage( EV_CLOSE_WINDOW, wParam, lParam );
		break;
	case WM_KEYDOWN:
		HMSL_BufferMessage( EV_KEY, wParam, lParam );
		break;
	}

	return( DefWindowProc( hWnd, uMsg, wParam, lParam ) );
}

BOOLEAN HMSL_InitMessages( void )
{
	HANDLE hMutex;
	int i;
	HMSLMsg *hmslMsg;

	/* create and lock the list mutex */
	hMutex = CreateMutex( NULL, TRUE, "HMSL_Message_Mutex" );
	gHMSLContext->hg_MsgMutex = hMutex;

	/* create the active message list */
	DLL_InitList( &(gHMSLContext->hg_MsgQueue) );

	/* create the free message list */
	DLL_InitList( &(gHMSLContext->hg_FreeMsgList) );

	/* create a bunch of messages, and add them to the free list */
	for( i=0; i<HE_NUM_MSGS; i++ )
	{
		hmslMsg = malloc( sizeof( HMSLMsg ) );
		if( hmslMsg != NULL )
		{
			DLL_InitNode( &(hmslMsg->hm_Node) );
			DLL_AddTail( &(gHMSLContext->hg_FreeMsgList), &(hmslMsg->hm_Node) );
		}
	}

	/* release the list mutex */
	ReleaseMutex( hMutex );

	/* create the active queue semaphore, and initialize the count to 0 */
	gHMSLContext->hg_MsgSemaphore = CreateSemaphore( NULL, 0, HE_NUM_MSGS, "HMSL_Message_Semaphore" );

	return( FALSE );
}

void HMSL_TermMessages( void )
{
	HANDLE hMutex = gHMSLContext->hg_MsgMutex;
	HANDLE hSem = gHMSLContext->hg_MsgSemaphore;
	HMSLMsg *hmslMsg;

	/* lock the list mutex */
	WaitForSingleObject( hMutex, INFINITE );

	/* remove any active messages */
	while( (hmslMsg = (HMSLMsg*)DLL_RemoveFirst( &(gHMSLContext->hg_MsgQueue))) != NULL )
	{
		free( hmslMsg );
	}

	/* remove any free messages */
	while( (hmslMsg = (HMSLMsg*)DLL_RemoveFirst( &(gHMSLContext->hg_FreeMsgList))) != NULL )
	{
		free( hmslMsg );
	}

	/* kill the list mutex */
	CloseHandle( hMutex );
	gHMSLContext->hg_MsgMutex = NULL;

	/* kill the semaphore */
	CloseHandle( hSem );
	gHMSLContext->hg_MsgSemaphore = NULL;
}

void HMSL_BufferMessage( enum HMSLEventID msgID, WPARAM wParam, LPARAM lParam )
{
	HANDLE hMutex;
	HANDLE hSemaphore;
	HMSLMsg *hmslMsg;
	BOOLEAN release;

	/* open and lock the list mutex */
	hMutex = OpenMutex( MUTEX_ALL_ACCESS, TRUE, "HMSL_Message_Mutex" );

	/* if you succeed, */
	if( hMutex )
	{
		/* open the list semaphore */
		hSemaphore = OpenSemaphore( SEMAPHORE_ALL_ACCESS, TRUE, "HMSL_Message_Semaphore" );

		/* check for free messages */
		if( (hmslMsg = (HMSLMsg*)DLL_RemoveFirst( &(gHMSLContext->hg_FreeMsgList) )) != NULL )
		{
			/* copy the contents of msg into it */
			hmslMsg->hm_ID = msgID;
			hmslMsg->hm_Time = GetMessageTime();
			switch( msgID )
			{
			case EV_MOUSE_DOWN:
			case EV_MOUSE_UP:
			case EV_MOUSE_MOVE:
				hmslMsg->hm_At = MAKEPOINTS(lParam);
				break;
			default:
				hmslMsg->hm_At.x = 0;
				hmslMsg->hm_At.y = 0;
				break;
			}
			/* add it to the active queue */
			DLL_AddTail( &(gHMSLContext->hg_MsgQueue), &(hmslMsg->hm_Node) );

			/* increment semaphore */
			release = TRUE;
		}
		else release = FALSE;

		/* unlock the list mutex */
		ReleaseMutex( hMutex );
		CloseHandle( hMutex );
		
		/* release the active queue semaphore */
		if( release ) ReleaseSemaphore( hSemaphore, 1, NULL );
		CloseHandle( hSemaphore );
	}
}

enum HMSLEventID HMSL_GetEvent( int32 timeout )
{
	DWORD waitResult;
	HMSLMsg *hmslMsg;
	
	/* wait on the active queue semaphore */
	waitResult = WaitForSingleObject( gHMSLContext->hg_MsgSemaphore, timeout );
	
	if( waitResult == WAIT_OBJECT_0 )
	{
		/* lock the list mutex */
		WaitForSingleObject( gHMSLContext->hg_MsgMutex, INFINITE );

		/* remove the next message from the active list */
		hmslMsg = (HMSLMsg*)DLL_RemoveFirst( &(gHMSLContext->hg_MsgQueue) );

		/* set the last message time and position variables */
		gHMSLContext->hg_ev_mouseXY = hmslMsg->hm_At;
		gHMSLContext->hg_ev_time = hmslMsg->hm_Time;

		/* place the message on the free list */
		DLL_AddTail( &(gHMSLContext->hg_FreeMsgList), &(hmslMsg->hm_Node) );

		/* unlock the list mutex */
		ReleaseMutex( gHMSLContext->hg_MsgMutex );

		/* return the HMSLEventID */
		return( hmslMsg->hm_ID );
	}
	else
	{
		return( EV_NULL );
	}
}

int32 hostGetEvent( int32 timeout )
{
	return( HMSL_GetEvent( timeout ) );
}
