#ifndef _SPMIDI_H
#define _SPMIDI_H

/* $Id: spmidi.h,v 1.50 2011/10/03 21:01:06 phil Exp $ */
/**
 *
 * @file spmidi.h
 * @brief <b>Primary API description for Scaleable Polyphonic MIDI Engine</b>
 * @author Phil Burk, Copyright 2002 Mobileer, PROPRIETARY and CONFIDENTIAL
 */

/* This next comment builds the main page and is only used in this file. */

/** @mainpage Scaleable Polyphonic MIDI Engine for Ringtones
 *
 * @section Intro
 * The SPMIDI Engine is a product of
 * <a href="http://www.mobileer.com/" target="_blank">Mobileer</a>.
 *
 * Most important API docs in <a href="spmidi_8h.html">"spmidi.h"</a>.
 *
The SPMIDI Engine is a software based MIDI synthesizer which can be
used to play ringtones or other songs on a handheld device. It is designed
to run on low-cost CPUs with a minimal footprint. The software may be licensed
for use with Handspring products.

<h3>Features</h3>

<ul>
<li>
Play polyphonic ringtones from Standard SP-MIDI files (Scaleable Polyphony)</li>

<li>
Support General MIDI Lite as a minimum capability.</li>

<li>
Support swapping between multiple synthesis engines.</li>

<li>
Synthesize audio at a variety of sample rates from 8 to 48 KHz.</li>

<li>
Software written in portable ANSI 'C'.</li>

<li>
Use fixed point math for embedded CPUs.</li>

<li>
Software design minimizes system dependencies and memory allocations for
easy maintainance and tuning.</li>

<li>
Edit proprietary instrument libraries graphically using a Java based application.</li>

<li>
Read instrument libraries or songs from files or RAM resident images.</li>
</ul>

 *
 */

#include <stdint.h>

#include "spmidi_config.h"
#include "spmidi_errors.h"

/**
 * Basic data types used by SPMIDI to ease portability.
 */
typedef int32_t spmSInt32;
typedef uint32_t spmUInt32;
typedef int16_t spmSInt16;
typedef uint16_t spmUInt16;
typedef int8_t spmSInt8;
typedef uint8_t spmUInt8;
typedef int16_t spmSample;
typedef uint8_t spmBoolean;

/** This data type is used for values that can be either 16 or 32 bit data.
 * By not requiring one or the other we can optimize this for the platform.
 */
typedef int spmSInt;
typedef unsigned int spmUInt;

/** This is the release version number time 100. Thus for V 1.94 this would be 194. */
#define SPMIDI_VERSION  (232)

/**
 * The Scaleable Polyphony standard defines a special bank and program for
 * the mobile telephone vibrator. This allows a composer to embed commands
 * to trigger the phone vibrator during a song.
 * See SPMIDI_SetVibratorCallback().
 */
#define SPMIDI_VIBRATOR_BANK       (((0x79)<<SPMIDI_BANK_MSB_SHIFT) | 0x06)
#define SPMIDI_VIBRATOR_PROGRAM    (0x7C)

/**
 * When General-MIDI mode is OFF, notes received on this bank
 * will be mapped to special test instruments.
 * The identity of these instruments may change without notice.
 * So don't rely on using this bank.
 */
#define SPMIDI_TEST_BANK           (((0x70)<<SPMIDI_BANK_MSB_SHIFT) | 0x00)

/** Default volume for SPMIDI_SetMasterVolume */
#define SPMIDI_DEFAULT_MASTER_VOLUME   (0x80)

/** Nominal gain for SPMIDI_PARAM_VEQ_BASS_CUTOFF.
 * Nominal means it is equivalent to 1.0 and will not change the velocity.
 */
#define SPMIDI_VEQ_NOMINAL_GAIN   (0x80)

/** Maximum number of frames that an SPMIDI synth can calculate in one burst.
 * The actual number may be lower, and can be queried by calling
 * SPMIDI_GetFramesPerBuffer()
 */
#define SPMIDI_MAX_FRAMES_PER_BUFFER   (256)

/** MIDI Bank indices are made from two 7 bit fields concatenated together.
 * Set this to 8 for systems assume that treat the MSB and LSB as actual bytes.
 */
#define SPMIDI_BANK_MSB_SHIFT   (7)

/** These parameters can be used to control various synthesizer values. */
typedef enum SPMIDI_Parameter_e
{
    /**
     * Set to 1 to enable compressor. The compressor raises the volume of quiet sections
     * and lowers the volume of overly loud sections.
     * This can increase the perceived loudness of a song.
     * Set to zero to disable the compressor, one to enable it. Default is 1.
     */
    SPMIDI_PARAM_COMPRESSOR_ON,
    /**
     * Determines softness of compressor gain curve.
     * Values closer to zero result in more extreme compression.
     * Suggested value is 20.
     */
    SPMIDI_PARAM_COMPRESSOR_CURVE,
    /**
     * Determines target loudness of compressor as a percentage of the maximum volume.
     * Note that the signal will sometimes exceed the target when a sudden peak occurs.
     * Suggested value is 88.
     */
    SPMIDI_PARAM_COMPRESSOR_TARGET,
    /**
     * Determines percentage of maximum for threshold.
     * Signals with an amplitude below the threshold are not compressed.
     * This prevents low level noise from being amplified to extremely loud levels.
     * Suggested value is 2.
     */
    SPMIDI_PARAM_COMPRESSOR_THRESHOLD,
    /**
     * Pitches below this pitch value will have their velocity modified.
     * The velocity of this pitch will be unchanged.
     * The velocity of pitch zero will be scaled by SPMIDI_PARAM_VEQ_GAIN_AT_ZERO.
     * Intermediate pitches will be scaled using a linearly interpolated gain value.
     * Set this parameter to zero to disable this effect.
     * Suggested cutoff value for mobile phone speakers with
     * poor bass response is 60, which is 261 Hz.
     */
    SPMIDI_PARAM_VEQ_BASS_CUTOFF,
    /**
     * Gain at zero pitch.
     * Values less than SPMIDI_VEQ_NOMINAL_GAIN will reduce the velocity of low notes
     * Values higher than SPMIDI_VEQ_NOMINAL_GAIN will increase the velocity.
     * You can use a negative value for a more extreme bass reduction.
     * Resulting negative velocities will be clipped to zero so notes below the
     * pitch where the gain function crosses zero will not be heard.
     * Note that a pitch of 24 corresponds to a frequency of 33 Hz,
     * which is below the range of hearing..
     * Suggested value for mobile phone speakers with
     * poor bass response is (-SPMIDI_VEQ_NOMINAL_GAIN/2)
     */
    SPMIDI_PARAM_VEQ_GAIN_AT_ZERO,

    /**
     * Set overall volume of rhythm instruments on the "drum channel"
     * relative to the instruments on other channels.
     * This volume control is independant of the MasterVolume and the
     * MIDI channel volume controller.
     * This function is normally not called but may be used to make
     * a synthesizer less percussive.
     *
     * This volume control uses a low resolution value of SPMIDI_DEFAULT_MASTER_VOLUME for
     * unity gain so that the resolution of the audio signal can be preserved.
     * Because of the granularity of this control, we do not recommend
     * using it for continuous control of volume, for example fading in or out,
     * because it can cause zipper noise.
     * The maximum allowable value is SPMIDI_DEFAULT_MASTER_VOLUME
     * so this parameter can only be used to reduce the rhythm channel volume.
     */
    SPMIDI_PARAM_RHYTHM_VOLUME,

    /**
     * Transpose the pitch of a NoteOn command by this many semitones.
     * Drum triggers will not be affected.
     * The NoteOffs will still match up with the correct NoteOn even if teh synthesizer
     * is transposed in the middle of a note.
     */
    SPMIDI_PARAM_TRANSPOSITION

} SPMIDI_Parameter;

/* Declare prototypes as 'C' in case some C++ code includes this file. */
#ifdef __cplusplus
extern "C"
{
#endif /* __cplusplus */

    typedef void (SPMIDI_VibratorCallback)( void *vibratorUserData, int pitch, int velocity );

    /** Opaque data type representing an internal SPMIDI context. */
    typedef void SPMIDI_Context;

    /** Opaque data type representing an internal SPMIDI orchestra containing multiple instruments. */
    typedef void SPMIDI_Orchestra;

    /** Initialize SPMIDI Library.
     * This should be called before calling any other Mobileer functions.
     * It may be called multiple times without danger.
     */
    int SPMIDI_Initialize( void );

    /** Terminate SPMIDI Library.
     */
    int SPMIDI_Terminate( void );

    /**
     * Allocate a context that will contain all of the internal data
     * for a synthesizer. This is used to isolate multiple
     * threads or processes using the SPMIDI system.
     * Subsequent calls to the SPMIDI system will take this context as a parameter.
     * This allows you to synthesize multiple songs at the same time.
     *
     * Please note that this specific function is not thread safe.
     * If you anticipate separate threads calling this function, then please
     * use a semaphore to prevent simultaneous calls by different threads.
     *
     * @param spmidiContextPtr address of variable to receive a pointer to an SPMIDI_Context
     * @param sampleRate frame rate in Hertz. Typical values are 22050 or 44100. Must not exceed SPMIDI_MAX_SAMPLE_RATE.
     *        Supported rates include: 8000, 11025, 12000, 16000, 22050, 24000, 32000, 44100, 48000, and 96000 Hz.
     * @warning The quality will sound muted with a sampleRate below 20000.
     *
     * @return Zero or negative error code.
     * @exception SPMIDI_Error_OutOfRange sampleRate exceeds SPMIDI_MAX_SAMPLE_RATE
     * @exception SPMIDI_Error_UnsupportedRate sampleRate not one of the typical rates
     */
    int SPMIDI_CreateContext( SPMIDI_Context **spmidiContextPtr, int sampleRate );

    /** Terminate SPMIDI Library.
     * Please note that this specific function is not thread safe.
     * If you anticipate separate threads calling this function, then please
     * use a semaphore to prevent simultaneous calls by different threads.
     * @param spmidiContext context to be terminated, may not be used after this call
     */
    int SPMIDI_DeleteContext( SPMIDI_Context *spmidiContext );

    /**
     * Set maximum number of voices that can sound simultaneously.
     * @param maxNumVoices Maximum number of simultaneous voices.
     * If set to zero then SPMIDI_MAX_VOICES will be used.
     * The maxNumVoices parameter cannot be set higher than SPMIDI_MAX_VOICES.
     * Default is SPMIDI_MAX_VOICES.
     * @return New maxNumVoices adjusted to supported range.
     */
    int SPMIDI_SetMaxVoices( SPMIDI_Context *spmidiContext, int maxNumVoices );

    /**
     */
    int SPMIDI_GetMaxVoices( SPMIDI_Context *spmidiContext );

    /**
     * Set channel priorities and Maximum Instantaneous Polyphony
     * as per Scaleable Polyphony MIDI standard.
     * @param mipData Sequence of pairs of data { cc vv } { cc vv } etc. where
     * cc is the channel (zero indexed) and vv is the polyphony required to hear that channel.
     */
    int SPMIDI_SetScaleablePolyphony( const unsigned char *mipData, int numChannels );

    /**
     * Write one MIDI byte to the synthesizer for processing.
     * This will handle running status.
     */
    void SPMIDI_WriteByte( SPMIDI_Context *spmidiContext, int byte );

    /**
     * Write a block of bytes to the MIDI parser.
     * Commands do not have to be aligned to the beginning of the block
     * as long as the overall stream is legal.
     */
    void SPMIDI_Write( SPMIDI_Context *spmidiContext, const unsigned char *data, int numBytes );

    /**
     * Write a complete channel command to the synthesizer for processing.
     *
     * @param command A MIDI command byte consisting of two nibbles,
     *      a MIDI command between 0x80 and 0xF0
     *      and a channel from 0x00 to 0x0F.
     * @param data1 First data byte.
     * @param data2 Second data byte.
     *      If the command does not require a second byte then data2 will be ignored.
     * @see MIDI commands listed in midi.h
     */
    void SPMIDI_WriteCommand( SPMIDI_Context *spmidiContext, int command, int data1, int data2 );

    /**
     * Synthesize audio data and place it in the *samples array.
     *
     * @param samples Pointer to buffer to be filled with synthesized audio data.
     *      Data type determined by bytesPerSample parameter.
     * @param numFrames Number of frames to be generated and written to the samples buffer.
     *      Recommend a multiple of the value returned by SPMIDI_GetFramesPerBuffer(),
     *      or SPMIDI_MAX_FRAMES_PER_BUFFER.
     *      A frame is one sample for mono, and two samples for stereo.
     * @param samplesPerFrame May be 1 for mono or 2 for stereo.
     * @param bitsPerSample May be 8-32. Data will be right justified in the word.
     *              Eight bit sample will be delivered as unsigned bytes.
     *              Samples between 9 and 16 bits will be delivered in a 16 bit signed short.
     *              Samples between 17 and 32 bits will be delivered in a 32 bit signed long.
     * @return Number of frames generated. May be less than numFrames requested if numFrames is
     *      not a multiple of SPMIDI_GetFramesPerBuffer(), or:
     * @exception SPMIDI_Error_OutOfRange samplesPerFrame value is not 1 or 2
     * @exception SPMIDI_Error_IllegalSize bitsPerSample is less than 8 or greater than 32
     */
    int SPMIDI_ReadFrames( SPMIDI_Context *spmidiContext, void *samples, int numFrames, int samplesPerFrame, int bitsPerSample );

    /**
     * Can be used in place of SPMIDI_ReadFrames() to estimates the max
     * amplitude of synthesized audio.
     * Analysis is performed by running envelopes, voice assignment, and by processing
     * velocity, pan, mix and other controllers. The oscillators and filters are not generated
     * to save time.
     * A frame is one sample for mono, and two samples for stereo.
     * @param numFrames Number of frames to be analysed.
     *      Recommend a multiple of the value returned by SPMIDI_GetFramesPerBuffer(),
     *      or SPMIDI_MAX_FRAMES_PER_BUFFER.
     * @param samplesPerFrame May be 1 for mono or 2 for stereo.
     * @return Estimated max amplitude based on 16 bit signed samples.
     */
    int SPMIDI_EstimateMaxAmplitude( SPMIDI_Context *spmidiContext, int numFrames, int samplesPerFrame );

    /**
     * Return number of frames synthesized so far..
     */
    int SPMIDI_GetFrameCount( SPMIDI_Context *spmidiContext );

    /**
     * @return Synthesis sample rate passed to SPMIDI_CreateContext().
     */
    int SPMIDI_GetSampleRate( SPMIDI_Context *spmidiContext );

    /**
     * Return the number of notes currently sounding.
     * A note will continue to sound for a short times after a NoteOff is received.
     */
    int SPMIDI_GetActiveNoteCount( SPMIDI_Context *spmidiContext );

    /**
     * Return the highest number of notes played simultaneously since reset.
     */
    int SPMIDI_GetMaxNoteCount( SPMIDI_Context *spmidiContext );

    /**
     * Reset the highest number of notes played simultaneously to zero.
     *
     * @warning This is not thread safe and should only be called by
     * the same thread that is parsing the MIDI bytes.
     */
    void SPMIDI_ResetMaxNoteCount( SPMIDI_Context *spmidiContext );

    /**
     * Return the number of notes currently sounding on a given channel.
     * A note will continue to sound for a short times after a NoteOff is received.
     */
    int SPMIDI_GetChannelActiveNoteCount( SPMIDI_Context *spmidiContext, int channelIndex );

    /**
     * Return the number of bytes associated with a MIDI command.
     * For example, a NoteOn would have three bytes, command+pitch+velocity.
     * This information is useful when parsing a MIDI byte stream.
     * @return number of bytes for message, or 0 if not a legal command.
     */
    int SPMIDI_GetBytesPerMessage( int command );

    /** Return number of frames that are calculated in a single burst.
     * This determines the smallest time resolution for controlling the synthesizer.
     */
    int SPMIDI_GetFramesPerBuffer( void );

    /**
     * Set scaleable polyphony tables to reasonable default
     * for the given number of voices.
     */
    int SPMIDI_SetDefaultPolyphony( SPMIDI_Context *spmidiContext, int maxNumVoices );

    /**
     * Set master volume for rendering MIDI.
     * You can raise the volume as high as you want but the output
     * will start clipping at some point.
     * I would not raise the volume beyond twice the default unity gain.
     *
     * This volume control uses a low resolution value of SPMIDI_DEFAULT_MASTER_VOLUME for
     * unity gain so that the resolution of the audio signal can be preserved.
     * Because of the granularity of this control, we do not recommend
     * using it for continuous control of volume, for example fading in or out,
     * because it can cause zipper noise.
     *
     * @param masterVolume Use a value of SPMIDI_DEFAULT_MASTER_VOLUME for unity gain.
     */
    void SPMIDI_SetMasterVolume( SPMIDI_Context *spmidiContext, int masterVolume );

    /**
     * Print status of MIDI parser and voice allocator.
     * This is only called when debugging.
     */
    void SPMIDI_PrintStatus( SPMIDI_Context *spmidiContext );

    /**
     * Set function to be called when a telephone rings
     * vibrator message is received. This is defined as an option by the
     * Scaleable Polyphony standard. The vibrator is triggered by
     * playing notes on program 125 (0x7C) on bank MSB=0x79, LSB=0x06.
     * Please call this with a pointer to a function that will turn on
     * the vibrator on a mobile phone.
     * Must be called after SPMIDI_CreateContext() or it will return SPMIDI_Error_NotStarted.
     */
    int SPMIDI_SetVibratorCallback( SPMIDI_Context *spmidiContext, SPMIDI_VibratorCallback *vibratorCallback,
                                    void *vibratorUserData );

    /**
     * Query whether a channel has been disabled using SPMIDI_SetChannelEnable().
     *
     * @param channelIndex Index of the channel starting with zero.
     * @exception SPMIDI_Error_IllegalChannel if channelIndex not 0-15
     * @return 1 if channel is enabled, 0 if disabled, or negative error code
     */
    int SPMIDI_GetChannelEnable( SPMIDI_Context *context, int channelIndex );

    /**
     * Enable or disable NoteOn events on a channel.
     * NoteOff events will still be played to prevent stuck notes.
     * All other events will be played as well to maintain the state of track.
     *
     * @param channelIndex Index of the channel starting with zero.
     * @param onOrOff Zero to disable a channel, non-zero to enable a channel.
     * @exception SPMIDI_Error_IllegalChannel if channelIndex not 0-15
     */
    int SPMIDI_SetChannelEnable( SPMIDI_Context *spmidiContext, int channelIndex, int onOrOff );

    /**
     * Set indexed parameter for synthesizer, for example SPMIDI_PARAM_COMPRESSOR_ON.
     * @return zero or native error code
     */
    int SPMIDI_SetParameter( SPMIDI_Context *spmidiContext, SPMIDI_Parameter parameterIndex, int value );

    /**
     * Get indexed parameter value for synthesizer.
     * @return zero or native error code
     */
    int SPMIDI_GetParameter( SPMIDI_Context *spmidiContext, SPMIDI_Parameter parameterIndex, int *valuePtr );

    /**
     * Immediately kill all voices on all contexts. This may cause a pop.
     * This is normally only used internally by the editor.
     * To stop the sound without a pop use the MIDI_CONTROL_ALLSOUNDOFF
     * or MIDI_CONTROL_ALLNOTESOFF controllers.
     * @return zero or native error code
     */
    int SPMIDI_StopAllVoices( void );

    int SPMIDI_CreateOrchestra( SPMIDI_Orchestra **spmidiOrchestraPtr, spmSInt32 numInstruments );
    void SPMIDI_DeleteOrchestra( SPMIDI_Orchestra *spmidiOrchestra );

#ifdef __cplusplus
}
#endif /* __cplusplus */

#endif /* _SPMIDI_H */

