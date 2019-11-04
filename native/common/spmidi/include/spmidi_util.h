#ifndef _SPMIDI_UTIL_H
#define _SPMIDI_UTIL_H
/* $Id: spmidi_util.h,v 1.15 2007/10/02 16:20:00 philjmsl Exp $ */
/**
 *
 * @file spmidi_util.h
 * @brief Tools for playing notes, converting units, etc.
 * @author Phil Burk, Copyright 2002 Mobileer, PROPRIETARY and CONFIDENTIAL
 */

#include "spmidi/include/spmidi.h"
#include "spmidi/include/spmidi_errortext.h"
#include "spmidi/include/midifile_player.h"

#ifdef __cplusplus
extern "C"
{
#endif

    /**
     * Convert frames to milliseconds based on the given frameRate.
     * The algorithm preserves precision and reduces the chance of numeric overflow.
     */
    unsigned long SPMUtil_ConvertFramesToMSec( unsigned long frameRate, unsigned long numFrames );

    /**
     * Convert milliseconds to frames based on the given frameRate.
     * The algorithm preserves precision and reduces the chance of numeric overflow.
     */
    unsigned long SPMUtil_ConvertMSecToFrames( unsigned long frameRate, unsigned long msec );

    /**
     * Turn on General MIDI mode which also resets all controllers
     * on all channels, sets all programs to 0, resets volume and pan.
     * It is called internally when SPMIDI is started.
     * You should call it again before you play another MIDI file if you
     * have not stopped and restarted the SPMIDI engine.
     */
    void SPMUtil_GeneralMIDIOn( SPMIDI_Context *spmidiContext  );

    /**
     * Change the bank of instruments for the given MIDI channel.
     * If there is not a custom bank then it will default to GM.
     * @param channel Index of the MIDI channel ranging from 0 to 15. Not 1 to 16!
     * @param bankIndex complete bank in the form of ((MSB<<8) + LSB)
     */
    void SPMUtil_BankSelect( SPMIDI_Context *spmidiContext, int channel, int bankIndex );

    /**
     * Change the program (instrument) on the given MIDI channel.
     * @param channel Index of the MIDI channel ranging from 0 to 15. Not 1 to 16!
     * @param program Instrument index ranging from 0 to 127. Not 1 to 128!
     */
    void SPMUtil_ProgramChange( SPMIDI_Context *spmidiContext, int channel, int program);

    /**
     * Turn on a note..
     * @param channel Index of the MIDI channel ranging from 0 to 15. Not 1 to 16!
     * @param pitch Pitch index ranging from 0 to 127. Middle C is 60.
     * @param velocity Loudness control ranging from 0 to 127. Typically 64.
     */
    void SPMUtil_NoteOn( SPMIDI_Context *spmidiContext, int channel, int pitch, int velocity );

    /**
     * Turn off a note. Equivalent to lifting a key on a keyboard.
     * The note will continue to sound for a short time.
     * @param channel Index of the MIDI channel ranging from 0 to 15. Not 1 to 16!
     * @param pitch Pitch index ranging from 0 to 127. Middle C is 60.
     * @param velocity Loudness control ranging from 0 to 127. Typically 0.
     */
    void SPMUtil_NoteOff( SPMIDI_Context *spmidiContext, int channel, int pitch, int velocity );

    /**
     * Change the pitch of all the notes on a channel.
     * @param channel Index of the MIDI channel ranging from 0 to 15. Not 1 to 16!
     * @param bend A 14 bit unsigned pitchbend value. Value for no bend is MIDI_BEND_NONE.
     */
    void SPMUtil_PitchBend( SPMIDI_Context *spmidiContext, int channel, int bend );

    /**
     * Change a controller value for a channel.
     * @param channel Index of the MIDI channel ranging from 0 to 15. Not 1 to 16!
     * @param controller Controller index from 0 to 127. 7 is volume control.
     * @param value Controller value from 0 to 127.
     */
    void SPMUtil_ControlChange( SPMIDI_Context *spmidiContext, int channel, int controller, int value );

    /**
     * Set maximum pitch bend range a channel.
     * @param channel Index of the MIDI channel ranging from 0 to 15. Not 1 to 16!
     * @param semitones Pitch offset for maximum pitch bend from 0 to 12.
     * @param cents Fractional offset from 0 to 99.
     */
    void SPMUtil_SetBendRange( SPMIDI_Context *spmidiContext, int channel, int semitones, int cents);

    /**
     * Turn off all notes on the given channel.
     */
    void SPMUtil_AllNotesOff( SPMIDI_Context *spmidiContext, int channel  );

    /**
     * Turn off all notes on all channels.
     * Turn General MIDI ON which resets all controllers.
     * This function simply returns if SPMIDI_CreateContext() has not been called.
     */
    void SPMUtil_Reset( SPMIDI_Context *spmidiContext );

    /**
     * Play the file and measure the maximum amplitude
     * assuming 16 bit samples.
     * This function calls SPMIDI_CreateContext() and SPMIDI_DeleteContext() so
     * do not call it while in the middle of synthesizing a song.
     *
     * @param samplesPerFrame Use 1 for mono, 2 for stereo.
     * @param masterVolume A value of 0x80 is unity gain.
     * @return maxAmplitude assuming 16 bit samples or negative if an error occurs.
     */
    int SPMUtil_GetMaxAmplitude( MIDIFilePlayer *player, int samplesPerFrame,
                                 int masterVolume, int sampleRate );
    /**
     * Play the file and measure the maximum amplitude
     * assuming 16 bit samples.
     * This function does not call SPMIDI_CreateContext() or SPMIDI_DeleteContext().
     * You will need to do that yourself.
     * This allows you to set SPMIDI parameters for the measurement.
     *
     * @param samplesPerFrame Use 1 for mono, 2 for stereo.
     * @return maxAmplitude assuming 16 bit samples or negative if an error occurs.
     */
    int SPMUtil_MeasureMaxAmplitude( MIDIFilePlayer *player, SPMIDI_Context *spmidiContext, int samplesPerFrame );

    /**
     * Play the file and estimate the maximum amplitude by
     * calling SPMIDI_EstimateMaxAmplitude().
     * This function is much quicker but less accurate than SPMUtil_GetMaxAmplitude().
     * This function calls SPMIDI_CreateContext() and SPMIDI_DeleteContext() so
     * do not call it while in the middle of synthesizing a song.
     *
     * @param masterVolume A value of 0x80 is unity gain.
     * @return maxAmplitude assuming 16 bit samples or negative if an error occurs.
     */
    int SPMUtil_EstimateMaxAmplitude( MIDIFilePlayer *player, int samplesPerFrame,
                                      int masterVolume, int sampleRate );

#ifdef __cplusplus
}
#endif

#endif /* _SPMIDI_UTIL_H */
