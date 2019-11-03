#ifndef _MIDIFILE_PARSER_H
#define _MIDIFILE_PARSER_H

/* $Id: midifile_parser.h,v 1.2 2007/10/02 16:20:00 philjmsl Exp $ */
/**
 *
 * @file midifile_parser.h
 * @brief MIDI File Parser
 * @author Phil Burk, Copyright 2002 Mobileer, PROPRIETARY and CONFIDENTIAL
 */

#include "spmidi/include/spmidi.h"

#ifdef __cplusplus
extern "C"
{
#endif

typedef struct MIDIFileParser_s
{   
    /** Called by MIDIFile_Parse() when the beginning of a track is encountered. */
    int     (*beginTrackProc)( struct MIDIFileParser_s *parser, int index, int trackSize );

    /** Called by MIDIFile_Parse() when the end of a track is encountered. */
    int     (*endTrackProc)( struct MIDIFileParser_s *parser, int index );

    /** Called by MIDIFile_Parse() when regular MIDI event, like a NoteOn, is encountered. */
    int     (*handleEventProc)( struct MIDIFileParser_s *parser, int ticks, int command, int data1, int data2 );

    /** Called by MIDIFile_Parse() when MetaEvent, like a Tempo or Copyright event, is encountered. */
    int     (*handleMetaEventProc)( struct MIDIFileParser_s *parser, int ticks, int type,
                                    const unsigned char *addr, int numBytes );

    /** Called by MIDIFile_Parse() when System Exclusive event is encountered. */
    int     (*handleSysExProc)( struct MIDIFileParser_s *parser, int ticks, int type,
                                const unsigned char *addr, int numBytes );

    /** Pointer to a memory image of a MIDI File. */
    const unsigned char *imageStart;
    /** Number of bytes in the "file". */
    int       imageSize;
    /** How many bytes have been read by the parser. */
    int       bytesRead;
    /** MIDI File format: 0,1 or 2 */
    int       format;
    /** Number of tracks read from header. */
    int       numTracks;
    /** Number of ticks in a quarter note read from header. */
    int       ticksPerBeat;
    /** Tick rate, updated by Tempo MetaEvents. */
    int       ticksPerSecond;
    /** Sample rate of synthesis engine. */
    int       sampleRate;
    /** Used to parse running status. */
    int       lastCommand;
    /** Number of NoteOn commands encountered. This can be used to detect hung notes or other file errors. */
    int       noteOnCount;
    /** Number of NoteOff commands encountered. */
    int       noteOffCount;
    /** User can store data in the parser and use it in the callback functions. */
    void     *userData;

    /** Flag set to true when MIDI_META_END_OF_TRACK MetaEvent encountered. */
    char      gotEndOfTrack;
}
MIDIFileParser_t;

/**
 * Parse variable length quentity from memory. Data is stored as 7 bits per byte.
 * Last byte has high bit clear. Preceding bytes have high bit set.
 */
int MIDIFile_ReadVariableLengthQuantity( const unsigned char **addrPtr );

/**
 * Parse a MIDI File image.
 * The parser will call back to functions that you specify.
 * You must set the following fields in the MIDIFileParser_t structure:
 * <ul>
 * <li>MIDIFileParser_s::image</li>
 * <li>MIDIFileParser_s::imageSize</li>
 * <li>MIDIFileParser_s::userData</li>
 * <li>MIDIFileParser_s::beginTrackProc</li>
 * <li>MIDIFileParser_s::endTrackProc</li>
 * <li>MIDIFileParser_s::handleEventProc</li>
 * <li>MIDIFileParser_s::handleMetaEventProc</li>
 * </ul>
 */

int MIDIFile_Parse( MIDIFileParser_t *parser );

#ifdef __cplusplus
}
#endif

#endif

