/* $Id$ */
/**
 *
 * Use JukeBox to provide MIDI and time capabilities to HMSL.
 * Copyright 2004 Mobileer, Inc., PROPRIETARY and CONFIDENTIAL
 *
 */
#include <stdio.h>
#include <conio.h>

#include <math.h>
#include "midi.h"
#include "spmidi.h"
#include "spmidi_util.h"
#include "spmidi_print.h"
#include "spmidi_play.h"
#include "spmidi_jukebox.h"

/* PortAudio is an open-source audio API available free from www.portaudio.com */
#include "portaudio.h"

/*
 * Adjust these for your system.
 */
#define SAMPLE_RATE         (44100)
#define SAMPLES_PER_FRAME   (2)
#define BITS_PER_SAMPLE     (sizeof(short)*8)


#define VALUE_UNDEFINED  (-1)

static int ticksPerSecond = 0;

/*******************************************************************/
/*******************************************************************/
/*******************************************************************/
/*******************************************************************/
/*******************************************************************/

/****************************************************************/
/**
 * Get Audio from Jukebox to fill PortAudio buffer..
 */

int JBDemo_Callback(
    void *inputBuffer, void *outputBuffer,
    unsigned long framesPerBuffer,
    PaTimestamp outTime, void *userData )
{
	/* Use information passed from foreground thread. */
	int framesLeft = framesPerBuffer;
	int framesGenerated = 0;
	short *outputPtr = (short *) outputBuffer;
	(void) inputBuffer;
	(void) outTime;
	(void) userData;

	/* The audio buffer is bigger than the synthesizer buffer so we
	 * have to call the synthesizer several times to fill it.
	 */
	while( framesLeft )
	{
		framesGenerated = JukeBox_SynthesizeAudioTick( outputPtr, framesPerBuffer, SAMPLES_PER_FRAME );
		if( framesGenerated <= 0 )
		{
			PRTMSGNUMH("Error: JukeBox_SynthesizeAudioTick returned ", framesGenerated );
			return 1; /* Tell PortAudio to stop. */
		}

		/* Advance pointer to next part of large output buffer. */
		outputPtr += SAMPLES_PER_FRAME * framesGenerated;

		/* Calculate how many frames are remaining. */
		framesLeft -= framesGenerated;
	}

	return 0;
}

PortAudioStream *audioStream;

/*******************************************************************/
int JBDemo_StartAudio( void )
{
	int result;

	/* Initialize audio hardware and open an output stream. */
	Pa_Initialize();
	result = Pa_OpenDefaultStream( &audioStream,
	                               0, SAMPLES_PER_FRAME,
	                               paInt16,
	                               (double) SAMPLE_RATE,
	                               JukeBox_GetFramesPerTick(),
	                               0,
	                               JBDemo_Callback,
	                               NULL );
	if( result < 0 )
	{
		PRTMSG( "Pa_OpenDefaultStream returns " );
		PRTMSG( Pa_GetErrorText( result ) );
		PRTMSG( "\n" );

		goto error;
	}

	Pa_StartStream( audioStream );

error:
	return result;
}


/*******************************************************************/
int JBDemo_StopAudio( void )
{
	Pa_StopStream( audioStream );
	Pa_Terminate();
	return 0;
}


/*******************************************************************/
// hostMIDI_Init() ( -- )
int hostMIDI_Init()
{
	SPMIDI_Error err;
	SPMIDI_Context *spmidiContext;

	err = JukeBox_Initialize( SAMPLE_RATE );
	if( err < 0 )
		goto error;

	ticksPerSecond = SAMPLE_RATE / JukeBox_GetFramesPerTick();
	
	spmidiContext = JukeBox_GetMIDIContext();

	err = SPMIDI_SetParameter( spmidiContext, SPMIDI_PARAM_VEQ_BASS_CUTOFF, 0 );
	if( err < 0 )
		goto error;

	JBDemo_StartAudio();
error:
	return err;
}

/*******************************************************************/
// hostMIDI_Term() ( -- )
void hostMIDI_Term( void )
{
	JBDemo_StopAudio();

	JukeBox_Terminate();
}

/*******************************************************************/
// hostMIDI_Write() ( addr count vtime -- )
void hostMIDI_Write( unsigned char *addr, int count, int vtime )
{
	/* printf( "hostMIDI_Write: addr = %p, count = %d, vtime = %d\n", addr, count, vtime ); */
	if( count > 0 )
	{
		int timeOut = 20;
		while( (JukeBox_SendMIDI( vtime, count, addr ) < 0) && (timeOut-- > 0) )
		{
			Pa_Sleep( 100 );
		}
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
	return JukeBox_GetTime();
}

/*******************************************************************/
// hostQueryClockRate() ( -- ticks )
int hostClock_QueryRate( void )
{
	return SAMPLE_RATE / SPMIDI_GetFramesPerBuffer();
}

/*******************************************************************/
// hostSleep() ( )
void hostSleep( int msec )
{
	Pa_Sleep( msec );
}
