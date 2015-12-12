#ifndef _HMSL_MIDI
#define _HMSL_MIDI
/***************************************************************
** Interface for HMSL MIDI functions
**
** Author: Phil Burk
***************************************************************/


int hostMIDI_Init();

void hostMIDI_Term( void );

int hostMIDI_Write( unsigned char *addr, int count, int vtime );

int hostMIDI_Recv( void );

int hostClock_QueryTime( void );

int hostClock_QueryRate( void );

void hostSleep( int msec );

#endif /* _HMSL_MIDI */