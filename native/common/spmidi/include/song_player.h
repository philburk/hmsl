#ifndef _SONG_PLAYER_H
#define _SONG_PLAYER_H
/**
 * @file song_player.h
 * @brief Simple interface to play any supported song format.
 * 
 * SongPlayer will examine the file to see if it is an SMF or XMF file.
 * It will then choose the appropriate parser and do the necessary setup to
 * play the file.
 * 
 * Please see the "examples/play_song.c" for an example of how to use the API.
 * There is also a SongPlayer section in the Programming Guide.
 *
 * @author Phil Burk, Robert Marsanyi Copyright 2004 Mobileer, PROPRIETARY and CONFIDENTIAL
 */

#include "spmidi/include/spmidi.h"

#ifdef __cplusplus
extern "C"
{
#endif

    /** Opaque data type representing an internal XMF Parser structure. */
    typedef void * SongPlayer;

    typedef enum SongPlayer_Type_e
    {
        /** No error occured. */
        SongPlayer_Type_Unsupported = 0,
        SongPlayer_Type_SMF,
        SongPlayer_Type_XMF
    } SongPlayer_Type;

    /**
     * @return type of song based on an examination of the header.
     */
    SongPlayer_Type SongPlayer_GetType( unsigned char *songImage, spmSInt32 numBytes );

    /**
     * Create a player for supported song type.
     * Set song to beginning.
     * If song is an XMF song then it will load the associated DLS instruments.
     * Note that this may only be called <b>once</b> for an spmidiContext.
     * You must delete the context and create a new context if you
     * want to play another song.
     * @param songImage address of song file image in memory
     * @param numBytes size of song file image
     * @return 0 if no error, or one of the following:
     * @exception SPMIDI_Error_IllegalArgument one or more pointers are NULL, or numBytes is not positive
     * @exception SPMIDI_Error_OutOfMemory can't allocate memory for songplayer or its components
     * @exception XMFParser_Error_ParseError miscellaneous parsing error
     *     - FileNode does not contain ResourceFormatID, or
     *     - Unpacker for FileNode is unrecognized
     * @exception XMFParser_Error_WrongType file is not XMF Type 2 (Mobile XMF)
     * @exception XMFParser_Error_SizeError file length, Tree Start or Tree End in header exceed actual size
     * @exception DLSParser_Error_NotDLS Form chunk is not DLS
     * @exception DLSParser_Error_ParseError miscellaneous parsing error:
     *   - no DLS instruments found
     *   - no pool table found
     *   - no wave data found
     *   - number of instruments found doesn't match list
     *   - number of regions found doesn't match list
     *   - region doesn't include WLNK or RGNH chunks
     *   - articulation chunk not contained in region or instrument
     *   - conditional chunk expression doesn't evaluate to true or false
     *   - wave data not inside WAVE chunk
     *   - wave data found before FMT chunk
     *   - number of loops in WSMP chunk is greater than 1
     *   - WSMP chunk is not associated with region or wave
     * @exception SPMIDI_Error_BadFormat couldn't resolve pool table to loaded wave data
     * @exception DLSParser_Error_UnsupportedSampleFormat wave data is not in a usable format
     * @exception XMFParser_Error_DetachedNodeContentFound Mobile XMF does not allow content outside the file
     * @exception SPMIDI_Error_DLSAlreadyLoaded this midi context already has a DLS Orchestra
     * @exception MIDIFile_Error_NotSMF can't find midifile in image
     * @exception MIDIFile_Error_IllegalFormat midi header or track is not valid
     * @exception MIDIFile_Error_MissingEndOfTrack file ends before end of track
     * @see XMFParser_Create, XMFParser_Parse, XMFParser_GetDLS, DLSParser_Create, DLSParser_Parse, DLSParser_Load
     */
    SPMIDI_Error SongPlayer_Create( SongPlayer **playerPtr, SPMIDI_Context *spmidiContext,
                                    unsigned char *songImage, spmSInt32 numBytes );

    /**
     * Start playing song.
     * @return SPMIDI_Error_None
     */
    SPMIDI_Error SongPlayer_Start( SongPlayer *player );

    /**
     * Rewind song to beginning.
     * @return 0 if no error, or one of the following:
     * @exception MIDIFile_Error_NotSMF can't find midifile in image
     * @exception MIDIFile_Error_IllegalFormat midi header or track is not valid
     * @exception MIDIFile_Error_MissingEndOfTrack file ends before end of track
     */
    SPMIDI_Error SongPlayer_Rewind( SongPlayer *player );

    /**
     * Stop playing song.
     * @return SPMIDI_Error_None
     */
    SPMIDI_Error SongPlayer_Stop( SongPlayer *player );

    /**
     * Get MIDIFile player if song is an SMF or XMF.
     */
    MIDIFilePlayer *SongPlayer_GetMIDIFilePlayer( SongPlayer *player );

    /**
     * Advance the player forward in the song by a time corresponding
     * to the given number of audio frames.
     * After this, call SPMIDI_ReadFrames() to harvest the synthesized audio.
     * @return 0 if more events are available to play. 1 if finished.
     */
    int SongPlayer_PlayFrames( SongPlayer *player, int numFrames );

    /**
     * Delete the player data. This does not delete the in-memory image.
     * If song is an XMF song then it will unload the associated DLS instruments.
     */
    void SongPlayer_Delete( SongPlayer *player );

#ifdef __cplusplus
}
#endif

#endif  /* _SONG_PLAYER_H */


