#ifndef _SPMIDI_JUKEBOX_H
#define _SPMIDI_JUKEBOX_H

/* $Id: spmidi_jukebox.h,v 1.6 2007/10/02 16:20:00 philjmsl Exp $ */
/**
 * @file spmidi_jukebox.h
 * @brief Tools for playing from a selection of songs.
 *
 * @author Phil Burk, Copyright 2004 Mobileer, PROPRIETARY and CONFIDENTIAL
 */

#include "spmidi/include/spmidi.h"
//#include "spmidi_custom_playlist.h"

/* Declare prototypes as 'C' in case some C++ code includes this file. */
#ifdef __cplusplus
extern "C"
{
#endif /* __cplusplus */

#define JUKEBOX_LOOP_FOREVER      (0)
#define JUKEBOX_INVALID_SONG_ID   (-1)
#define JUKEBOX_MAX_LOOPS         (250)

    /**
     * Initialize ME2000 engine and song playlist based on custom include files.
     */
    SPMIDI_Error JukeBox_Initialize( int sampleRate );
    SPMIDI_Error JukeBox_Terminate( void );

    /**
     * Warning: do not use this context while another thread is calling any SPMIDI routines
     * including JukeBox_SynthesizeAudio.
     * @return SPMIDI_Context used by JukeBox.
     */
    SPMIDI_Context *JukeBox_GetMIDIContext( void );

    /**
     * Add the selected song to the queue.
     * The index will be determined by a header file exported
     * by the Mobileer Editor. 
     * @param songID between zero and (JukeBox_GetNumSongs()-1)
     * @param numLoops number of times to repeat entire song. Use JUKEBOX_LOOP_FOREVER for endless repetition.
     */
    SPMIDI_Error JukeBox_QueueSong( int songID, int numLoops );

    /**
     * Remove any songs currently in the queue.
     * You may need to call this if you want to start a song immediately.
     */
    SPMIDI_Error JukeBox_ClearSongQueue( void );

    /**
     * Immediately stop the current song.
     * Notes will be allowed to decay naturally to silence.
     */
    SPMIDI_Error JukeBox_StopSong( void );

    /**
     * Finish the current song at the end of the current loop.
     */
    SPMIDI_Error JukeBox_FinishSong( void );

    /**
     * Pause the current song.
     * Turns off any notes currently on.
     */
    SPMIDI_Error JukeBox_PauseSong( void );

    /**
     * Resume the current song. No effect if not paused.
     */
    SPMIDI_Error JukeBox_ResumeSong( void );

    /**
     * Stop all sound output as quickly as possible without causing a click.
     * To make sure there is not a click when shutting down,
     * call JukeBox_SynthesizeAudio()
     * with at least 256 frames between calling this and JukeBox_Terminate().
     * Resets all controllers.
     */
    SPMIDI_Error JukeBox_StopSound( void );

    /**
     * Set overall audio volume.
     * @param volume default is 128, zero for silence
     */
    SPMIDI_Error JukeBox_SetVolume( int volume );

    /**
     * Set the maximum number of instruments that can be played simultaneously.
     * A typical major chord, for example, would take three voices.
     */
    SPMIDI_Error JukeBox_SetMaxVoices( int maxVoices );

    /**
     * @return current maximum number of instruments that can be played simultaneously.
     */
    int JukeBox_GetMaxVoices( void );

    /**
     * @return number of songs available to be played.
     */
    int JukeBox_GetNumSongs( void );

    /**
     * @return number of songs in the queue
     */
    int JukeBox_GetSongQueueDepth( void );

    /**
     * @return ID of the currently playing song or JUKEBOX_INVALID_SONG_ID if none playing.
     */
    int JukeBox_GetCurrentSongID( void );

    /**
     * Enable or disable a track on the song.
     * Note that in a format one type MIDI file that track zero is usually a tempo map.
     * @param songID between zero and (JukeBox_GetNumSongs()-1)
     * @param trackIndex
     * @param onOrOff 1 for on and 0 for off
     */
    SPMIDI_Error JukeBox_EnableSongTrack( int songID, int trackIndex, int onOrOff );

    /**
     * Enable or disable a MIDI channel. This will affect both Songs and MIDI commands.
     * @param channel Index of the MIDI channel ranging from 0 to 15. Not 1 to 16!
     * @param onOrOff 1 for on and 0 for off
     */
    SPMIDI_Error JukeBox_EnableChannel( int channel, int onOrOff );

    /**
     * Return the current time of the JukeBox engine.
     * Here is an example of scheduling an event 1/2 second in the future:
     * <pre>
     *   int time = JukeBox_GetTime();
     *   // Only do this calculation once.
     *   int ticksPerSecond = sampleRate / JukeBox_GetFramesPerTick();
     *   int delay = ticksPerSecond / 2;
     *   JukeBox_NoteOn( time+delay, 0, 60, 64 );
     * </pre>
     * @return current time in ticks
     */
    int JukeBox_GetTime( void );

    /**
     * The tick rate is the framesPerSecond / framesPerTick.
     * Remember divides are expensive.
     * @return number of audio frames in a tick
     */
    int JukeBox_GetFramesPerTick( void );

    /**
     * Remove any events in the command event buffer.
     */
    SPMIDI_Error JukeBox_ClearCommands( void );

    /**
     * Send arbitrary MIDI command
     * If specified command takes less than 2 data bytes, the additional data will
     * be ignored.
     * @param time in ticks when event should occur
     * @param cmd MIDI command byte
     * @param d1 First data byte
     * @param d2 Second data byte
     */
    SPMIDI_Error JukeBox_MIDICommand( int time, int cmd, int d1, int d2);

    /**
     * Change the program (instrument) on the given MIDI channel.
     * @param time in ticks when event should occur
     * @param channel Index of the MIDI channel ranging from 0 to 15. Not 1 to 16!
     * @param program Instrument index ranging from 0 to 127. Not 1 to 128!
     */
    SPMIDI_Error JukeBox_ProgramChange( int time, int channel, int program);

    /**
     * Turn on a note.
     * @param time in ticks when event should occur
     * @param channel Index of the MIDI channel ranging from 0 to 15. Not 1 to 16!
     * @param pitch Pitch index ranging from 0 to 127. Middle C is 60.
     * @param velocity Loudness control ranging from 0 to 127. Typically 64.
     */
    SPMIDI_Error JukeBox_NoteOn( int time, int channel, int pitch, int velocity );

    /**
     * Turn off a note. Equivalent to lifting a key on a keyboard.
     * The note will continue to sound for a short time.
     * @param time in ticks when event should occur
     * @param channel Index of the MIDI channel ranging from 0 to 15. Not 1 to 16!
     * @param pitch Pitch index ranging from 0 to 127. Middle C is 60.
     * @param velocity Loudness control ranging from 0 to 127. Typically 0.
     */
    SPMIDI_Error JukeBox_NoteOff( int time, int channel, int pitch, int velocity );

    /**
     * Change the pitch of all the notes on a channel.
     * @param time in ticks when event should occur
     * @param channel Index of the MIDI channel ranging from 0 to 15. Not 1 to 16!
     * @param bend A 14 bit unsigned pitchbend value. Value for no bend is MIDI_BEND_NONE.
     */
    SPMIDI_Error JukeBox_PitchBend( int time, int channel, int bend );

    /**
     * Change a controller value for a channel.
     * @param time in ticks when event should occur
     * @param channel Index of the MIDI channel ranging from 0 to 15. Not 1 to 16!
     * @param controller Controller index from 0 to 127. 7 is volume control.
     * @param value Controller value from 0 to 127.
     */
    SPMIDI_Error JukeBox_ControlChange( int time, int channel, int controller, int value );

    /**
     * Set maximum pitch bend range a channel.
     * @param time in ticks when event should occur
     * @param channel Index of the MIDI channel ranging from 0 to 15. Not 1 to 16!
     * @param semitones Pitch offset for maximum pitch bend from 0 to 12.
     * @param cents Fractional offset from 0 to 99.
     */
    SPMIDI_Error JukeBox_SetBendRange( int time, int channel, int semitones, int cents);

    /**
     * Turn off all notes on the given channel.
     * @param time in ticks when event should occur
     * @param channel Index of the MIDI channel ranging from 0 to 15. Not 1 to 16!
     */
    SPMIDI_Error JukeBox_AllNotesOff( int time, int channel  );

    /**
     * Send MIDI byte to the synthesizer through the command FIFO.
     * This can be used to build arbitrary MIDI commands
     * @param time in ticks when event should occur
     * @param bytes MIDI protocol command or data ranging from 0 to 255
     */
    SPMIDI_Error JukeBox_SendMIDI( int time, int numBytes, unsigned char bytes[] );

    /**
     * Generate one tick worth of audio and write it to the buffer for playback.
     * The synthesized audio must fit into the maximum 
     * This may be called by an interrupt or separate Thread.
     * All other functions must be called from the same thread or
     * be protected using semaphores to prevent thread collisions.
     *
     * @param maxFrames is the max number of mono or stereo groups of samples that can fit in the buffer
     * @param channelsPerFrame is 1 for mono and 2 for stereo
     * @return number of frames synthesized
     */
    SPMIDI_Error JukeBox_SynthesizeAudioTick( short *buffer, int maxFrames, int channelsPerFrame );


#ifdef __cplusplus
}
#endif /* __cplusplus */

#endif /* _SPMIDI_JUKEBOX_H */
