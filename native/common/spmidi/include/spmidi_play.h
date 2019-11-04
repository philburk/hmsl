/* $Id: spmidi_play.h,v 1.14 2007/10/02 16:20:00 philjmsl Exp $ */
#ifndef _SPMIDI_PLAY_H
#define _SPMIDI_PLAY_H
/**
 * @file spmidi_util.h
 * @brief Tools for playing SPMIDI on portaudio or to a WAV file.
 * @author Phil Burk, Copyright 2002 Mobileer, PROPRIETARY and CONFIDENTIAL
 */

#include "spmidi/include/spmidi.h"
#include "spmidi/include/spmidi_util.h"

#ifdef __cplusplus
extern "C"
{
#endif

#define SPMUTIL_OUTPUT_MONO   (1)
#define SPMUTIL_OUTPUT_STEREO (2)

    /**
     * Start the SPMIDI Synthesizer and call SPMUtil_StartVirtualAudio().
     */
    int SPMUtil_Start( SPMIDI_Context **spmidiContextPtr, int sampleRate, const char *fileName, int samplesPerFrame );

    /**
     * Open an virtual audio output stream that may be a WAV file or an audio hardware device.
     * @param sampleRate Synthesis rate in Hertz.
     * @param fileName If NULL then output to the default audio device.
     *          Otherwise output 16 bit audio to the named WAV file. Recommend ".wav" suffix.
     * @param samplesPerFrame May be 1 for mono or 2 for stereo.
     */
    int SPMUtil_StartVirtualAudio( int sampleRate, const char *fileName, int samplesPerFrame );

    /**
     * Write a buffer full of audio samples to the audio output stream.
     */
    int SPMUtil_WriteVirtualAudio( short *samples, int samplesPerFrame, int numFrames );

    /**
     * CLose whatever was opened by SPMUtil_StartVirtualAudio().
     */
    int SPMUtil_StopVirtualAudio( void );

    /**
     * Syntheize multiple buffers and write them to the audio output stream 
     * requested in SPMUtil_Start().
     * @return result from SPMIDI_ReadFrames().
     */
    int SPMUtil_PlayBuffers( SPMIDI_Context *spmidiContext, int numBuffers );

    /**
     * Play enough buffers to sleep approximately msec milliseconds.
     * This is not an accurate timer. Only use it for simple tests.
     * @return the number of buffers played
     */
    int SPMUtil_PlayMilliseconds( SPMIDI_Context *spmidiContext, int msec );

    /**
     * Advance the track players forward in the file by a time corresponding
     * to the given number of audio frames.
     * Generate one buffers worth of data and write it to the output stream.
     * @return 0 if more events available to play. 1 if finished. Negative if an error occurs.
     */
    int SPMUtil_PlayFileBuffer( MIDIFilePlayer *player, SPMIDI_Context *spmidiContext );

    /**
     * Stop the synthesizer and close the audio output device.
     */
    int SPMUtil_Stop( SPMIDI_Context *spmidiContext );

    int SPMUtil_StartAsync( SPMIDI_Context **contextPtr, int sampleRate );

    int SPMUtil_StopAsync( SPMIDI_Context *spmidiContext );

    /**
     * Write a MIDI byte to a FIFO, which will be read and processed
     * by the background audio/MIDI thread.
     * Using this will prevent race conditions between the foreground
     * thread and the audio/MIDI callback.
     * Use instead of SPMIDI_WriteCommand.
     * Return 0 if successful, or -1 if buffer full.
     */
    int SPMUtil_WriteByteAsync( int data );

#ifdef __cplusplus
}
#endif

#endif /* _SPMIDI_PLAY_H */
