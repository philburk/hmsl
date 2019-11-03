#ifndef _MIDISTREAM_PLAYER_H
#define _MIDISTREAM_PLAYER_H

/* $Id: midistream_player.h,v 1.2 2007/10/02 16:20:00 philjmsl Exp $ */
/**
 *
 * @file midistream_player.h
 * @brief MIDI Stream File Player
 *
 * A MIDI Stream is a very simple form of MIDIFile that can be played
 * sequentially with very little CPU load.
 *
 * This file format is designed for temporary storage of MIDI data.
 * It is not intended as a file interchange format across platforms.
 * 
 * <pre>
 *  unsigned long 'SMID' // stored 'S' first
 *  unsigned short framesPerTick  // stored in BigEndian format
 *  unsigned short framesPerSecond // stored in BigEndian format
 *
 *  packets consisting of
 *  {
 *    unsigned char tickDelay
 *    unsigned char numBytes
 *    unsigned char data[numBytes]
 *  }
 * </pre>

 * @author Phil Burk, Copyright 2002 Mobileer, PROPRIETARY and CONFIDENTIAL
 */
#include "spmidi/include/spmidi.h"

#define MIDISTREAM_HEADER_SIZE  (8)

typedef struct MIDIStreamPlayer_s
{
    const spmUInt8  *image;
    spmSInt32  streamFramesPerStreamTick;
    spmSInt32  streamFramesPerPlayTick;
    spmSInt32  nextFrameToPlay;
    spmSInt32  currentFrame;
    spmSInt    numBytes;
    spmSInt    cursor;
} MIDIStreamPlayer;

#ifdef __cplusplus
extern "C"
{
#endif

    /**
     * Setup a player for a MIDI stream file image.
     * @exception MIDIStream_Error_NotSMID if type in header does not match.
     */
    SPMIDI_Error MIDIStreamPlayer_Setup( MIDIStreamPlayer *player, int framesPerTick, int sampleRate,
                                        const unsigned char *image, int numBytes );

    /**
     * Reposition the image cursor so that we can replay the song.
     */
    SPMIDI_Error MIDIStreamPlayer_Rewind( MIDIStreamPlayer *player );

    /**
     * Play one ticks worth of packets.
     * @return 0 if more events are available to play. 1 if at end of stream.
     */
    int MIDIStreamPlayer_PlayTick( MIDIStreamPlayer *player, SPMIDI_Context *spmidiContext );

#ifdef __cplusplus
}
#endif

#endif

