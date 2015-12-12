/***************************************************************
** HMSL Event function headers
**
** Author: Robert Marsanyi
***************************************************************/

enum HMSLEventID
{
	EV_NULL,
	EV_MOUSE_DOWN,
	EV_MOUSE_UP,
	EV_MOUSE_MOVE,
	EV_MENU_PICK,
	EV_CLOSE_WINDOW,
	EV_REFRESH,
	EV_KEY
} anHMSLEventID;

typedef struct HMSLMsg
{
	DoubleNode  hm_Node;
	enum HMSLEventID hm_ID;
	POINTS      hm_At;
	DWORD       hm_Time;
} HMSLMsg;

#define HE_NUM_MSGS   30

LRESULT WINAPI HMSLWndProc( HWND hWnd, UINT uMsg, WPARAM wParam, LPARAM lParam );
BOOLEAN HMSL_InitMessages( void );
void HMSL_TermMessages( void );
void HMSL_BufferMessage( enum HMSLMsgID msgID, WPARAM wParam, LPARAM lParam );
enum HMSLEventID HMSL_GetEvent( int32 timeout );

int32 hostGetEvent( int32 timeout );
