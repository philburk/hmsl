/* $Id: spmidi_audio.h,v 1.7 2005/11/28 19:14:02 philjmsl Exp $ */
#ifndef _SPMIDI_AUDIO_H
#define _SPMIDI_AUDIO_H
/**
 * @file spmidi_audio.h
 * @brief Abstraction layer for host specific audio I/O.
 *
 * Porting this API to an embedded target system will allow
 * the SPMIDI example programs to be played without modification.
 * This interface is based on a blocking write model,
 * which is the standard model for Unix audio drivers.
 *
 * Because these are only used by the example programs you can use
 * a different model, for example a callback model, when integrating
 * SP-MIDI with your system software.
 *
 * @author Phil Burk, Copyright 1997-2005 Phil Burk, Mobileer, PROPRIETARY and CONFIDENTIAL
 */


#ifdef __cplusplus
extern "C"
{
#endif

    typedef void  * SPMIDI_AudioDevice;

    /**
     * Prepare the audio device for output at the desired sample rate.
     * @param frameRate Commonly referred to as the "sample rate", eg. 44100 or 22050.
     * @param samplesPerFrame The number of samples played simultaneously in a frame. For stereo this would be 2.
     * @return Negative error code or zero.
     */
    int SPMUtil_StartAudio( SPMIDI_AudioDevice *devicePtr, int frameRate, int samplesPerFrame );

    /**
     * Write a block of audio samples to the device. 
     * The function should not return until all of the audio has been
     * played or copied to an internal buffer.
     * 
     * @param audioSamples Pointer to first sample in the buffer to be played.
     * @param numFrames Number of frames to be written. For stereo this would be (numSamples/2).
     * @return Negative error code or zero.
     */
    int SPMUtil_WriteAudioBuffer( SPMIDI_AudioDevice device, short *audioSamples, int numFrames );

    /**
     * Close the audio device and free any associated resources.
     */
    int SPMUtil_StopAudio( SPMIDI_AudioDevice device );


#ifdef __cplusplus
}
#endif

#endif /* _SPMIDI_AUDIO_H */
