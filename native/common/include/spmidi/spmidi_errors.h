#ifndef _SPMIDI_ERRORS_H
#define _SPMIDI_ERRORS_H

/* $Id: spmidi_errors.h,v 1.17 2007/10/02 16:20:00 philjmsl Exp $ */
/**
 *
 * @file spmidi_errors.h
 * @brief Definition of errors returned by the spmidi system.
 * @author Phil Burk, Robert Marsanyi, Copyright 2005 Mobileer, PROPRIETARY and CONFIDENTIAL
 */

#ifdef __cplusplus
extern "C"
{
#endif

/** Error codes returned by SPMIDI functions. */
typedef enum SPMIDI_Error_e
{
    SPMIDI_Error_None = 0,
    SPMIDI_Error_IllegalChannel = -1000, /**< The channelIndex is out of range. Must be 0-15. */
    SPMIDI_Error_NotStarted,      /**< SPMIDI_CreateContext() not called before using SPMIDI. */
    SPMIDI_Error_IllegalSize,      /**< Illegal size parameter. */
    SPMIDI_Error_UnsupportedRate,   /**< Unusual sample rates need pitch offset added to synth code. */
    SPMIDI_Error_UnrecognizedParameter,   /**< Bad parameterIndex for SPMIDI_SetParameter(). */
    SPMIDI_Error_OutOfRange,         /**< Value out of range. */
    SPMIDI_Error_OutOfMemory,         /**< Could not allocate memory. Cannot occur in basic ME1000 runtime. */
    SPMIDI_Error_BadFormat,         /**< Data is corrupt or incorrectly formatted. */
    SPMIDI_Error_BadToken,         /**< Token not found. May have been deleted. */
    SPMIDI_Error_BufferTooSmall,    /**< Buffer too small to hold data. */
    SPMIDI_Error_IllegalArgument,    /**< Argument had illegal value. */
    SPMIDI_Error_Unsupported,      /**< Feature not supported by this build. */
    SPMIDI_Error_DLSAlreadyLoaded,      /**< Can only load orchestra once. */

    MIDIFile_Error_NotSMF,              /**< The file being parsed is not a standard MIDI file! */
    MIDIFile_Error_IllegalFormat,       /**< The MIDI file may be damaged. */
    MIDIFile_Error_IllegalTrackIndex,   /**< TrackIndex is out of range. */
    MIDIFile_Error_MissingEndOfTrack,   /**< We ran out of bytes in the track before finding the EndOfTrack MetaEvent */
    MIDIFile_Error_PrematureEndOfTrack, /**< We still had bytes left in the track after finding the EndOfTrack MetaEvent */
    MIDIFile_Error_IllegalMetaEventType,/**< MetaEvent type must be in range 0-127. */
    MIDIFile_Error_TooManyTracks,       /**< Too many tracks in MIDI File. */

    DLSParser_Error_NotDLS,             /**< Not a DLS file based on the initial chunk ID. */
    DLSParser_Error_ParseError,         /**< Data inside the file did not make sense. Perhaps the file was corrupted. */
    DLSParser_Error_UnsupportedSampleFormat, /**< Wavetable data is in a non-standard format that is not supported. */
    DLSParser_Error_NotParsed,          /**< The file was never parsed successfully. */

    XMFParser_Error_StreamError,        /**< Error reading XMF file image. */
    XMFParser_Error_NotXMF,             /**< Not an XMF file based on the initial chunk ID. */
    XMFParser_Error_WrongType,          /**< File is not a Mobile XMF file. */
    XMFParser_Error_ParseError,         /**< Data inside the file did not make sense. Perhaps the file was corrupted. */
    XMFParser_Error_SizeError,          /**< Chunk size went past end of data. */
    XMFParser_Error_WrongDLSType,       /**< DLS files in Mobile XMF files must be Mobile DLS format. */
    XMFParser_Error_ExtraSMF,           /**< Mobile XMF files should have just one SMF file. */
    XMFParser_Error_DetachedNodeContentFound, /**< Data stored outside the file. Illegal for Mobile XMF */
    XMFParser_Error_VLQTooLarge,        /**< VLQ exceeds stated maximum */

    MIDIStream_Error_NotSMID,           /**< The file being parsed is not a Mobileer MIDI Stream file! */

    SDLSStream_Error_NotSDLS,           /**< The file being parsed is not a Mobileer SDLS Stream file! */
    SDLSStream_Error_WrongVersion,       /**< The file version is not current */

    MBISParser_Error_NotMBIS,           /**< Not a MBIS file based on the initial chunk ID. */
    MBISParser_Error_ParseError        /**< Data inside the file did not make sense. Perhaps the file was corrupted. */
} SPMIDI_Error;


#ifdef __cplusplus
}
#endif /* __cplusplus */

#endif /* _SPMIDI_H */

