/* $Id$ */
/**
 *
 * Use PortMIDI to provide MIDI and time capabilities to HMSL.
 * Copyright 2004 Mobileer, Inc., PROPRIETARY and CONFIDENTIAL
 *
 */
#include <stdio.h>
#include <conio.h>

#include <math.h>
#include <windows.h>

#include "portmidi.h"
#include "porttime.h"

#define INPUT_BUFFER_SIZE 100
#define OUTPUT_BUFFER_SIZE 0
#define DRIVER_INFO NULL
#define TIME_PROC ((long (*)(void *)) Pt_Time)
#define TIME_INFO NULL
#define TIME_START Pt_Start(1, 0, 0) /* timer started w/millisecond accuracy */

long latency = 200;

PmStream * midi;
PmEvent buffer[1];
PmTimestamp timestamp;


/*******************************************************************/
// hostMIDI_Init() ( -- )
int hostMIDI_Init()
{
	PmError err;
    /* It is recommended to start timer before PortMidi */
    TIME_START;

    /* open output device -- since PortMidi avoids opening a timer
       when latency is zero, we will pass in a NULL timer pointer
       for that case. If PortMidi tries to access the time_proc,
       we will crash, so this test will tell us something. */
    err = Pm_OpenOutput(&midi, 
                  Pm_GetDefaultOutputDeviceID(), 
                  DRIVER_INFO,
                  OUTPUT_BUFFER_SIZE, 
                  (latency == 0 ? NULL : TIME_PROC),
                  (latency == 0 ? NULL : TIME_INFO), 
                  latency);

    printf("Midi Output opened with %ld ms latency.\n", latency);

	return err;
}

/*******************************************************************/
// hostMIDI_Term() ( -- )
void hostMIDI_Term( void )
{
    Pm_Close(midi);
    Pm_Terminate();
}

/*******************************************************************/
// hostMIDI_Write() ( addr count vtime -- )
void hostMIDI_Write( unsigned char *addr, int count, int vtime )
{
	/* printf( "hostMIDI_Write: addr = %p, count = %d, vtime = %d\n", addr, count, vtime ); */
	if( count > 0 )
	{
		buffer[0].timestamp = vtime;
		buffer[0].message = Pm_Message(addr[0], addr[1], addr[2]);
		Pm_Write(midi, buffer, 1);
	}
}

/*******************************************************************/
// hostMIDI_Recv() ( -- byte|-1 )
int hostMIDI_Recv( void )
{
	return -1;
}

/*******************************************************************/
// hostQueryTime() ( -- ticks )
int hostClock_QueryTime( void )
{
	return TIME_PROC( TIME_INFO );
}

/*******************************************************************/
// hostQueryClockRate() ( -- ticks )
int hostClock_QueryRate( void )
{
	return 1000;
}

/*******************************************************************/
// hostSleep() ( )
void hostSleep( int msec )
{
	Sleep( msec );
}
