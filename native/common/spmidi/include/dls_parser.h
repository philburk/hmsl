#ifndef _DLS_PARSER_H
#define _DLS_PARSER_H
/**
 * @file dls_parser.h
 * @brief Parses a DLS file image from an in-memory image.
 *
 * DLS stands for DownLoadable Sound. It is a file that contains
 * one or more wavetable based instruments.
 * 
 * This code is only used by the ME3000 API.
 * It is not used by the ME1000 or ME2000.
 *
 * @author Phil Burk, Robert Marsanyi Copyright 2004 Mobileer, PROPRIETARY and CONFIDENTIAL
 */
#include "spmidi/include/streamio.h"
#include "spmidi/include/spmidi.h"

#ifdef __cplusplus
extern "C"
{
#endif

    /** Opaque data type representing an internal DLS structure. */
    typedef void * DLSParser;

    /**
     * Create a parser for a DLS file.
     * [We associate image with parser at time of creation so
     * we cannot reuse parser on another image.]
     * @param dlsImage address of DLS file image in memory
     * @param numBytes size of DLS file image
     * @return 0 if no error, or the following:
     * @exception SPMIDI_Error_OutOfMemory not enough free memory to allocate parser
    */
    SPMIDI_Error DLSParser_Create( DLSParser **parserPtr,
                                   unsigned char *dlsImage, spmSInt32 numBytes );

    /**
    * Set sample rate for DLS parsing.  This is used by conditional chunks
    * when querying device capabilities.
    * @return 0 if no error, or the following:
    * @exception SPMIDI_Error_IllegalArgument if parser is not initialized
    */
    SPMIDI_Error DLSParser_SetSampleRate( DLSParser *parser, spmSInt32 sampleRate );

    /**
    * Get sample rate for DLS parsing.  This is used by conditional chunks
    * when querying device capabilities.
    * @return 0 if no error, or the following:
    * @exception SPMIDI_Error_IllegalArgument if parser is not initialized
    */
    spmSInt32 DLSParser_GetSampleRate( DLSParser *parser );

    /**
     * Read DLS instruments and wavetables from image.
     * @return 0 if no error, or one of the following:
     * @exception SPMIDI_Error_IllegalArgument if parser is not initialized
     * @exception DLSParser_Error_NotDLS Form chunk is not DLS
     * @exception SPMIDI_Error_OutOfMemory couldn't allocate required memory.  Memory is allocated for
     *  waves, articulations, instruments, regions and the pool table.
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
     */
    SPMIDI_Error DLSParser_Parse( DLSParser *parser );

    /**
     * Load DLS instruments into SPMIDI synthesizer.
     * Note that this may only be called <b>once</b> for an spmidiContext.
     * You must delete the context and create a new context if you
     * want to load another DLS Orchestra.
     * @return 0 if no error, or one of the following:
     * @exception SPMIDI_Error_IllegalArgument parser or midi context has not been initialized
     * @exception DLSParser_Error_NotParsed DLSParser_Parse() has not been successfully called
     * @exception SPMIDI_Error_DLSAlreadyLoaded this midi context already has a DLS Orchestra
     */
    SPMIDI_Error DLSParser_Load( DLSParser *parser, SPMIDI_Context *spmidiContext );

    /**
     * Delete the DLS Parser.
     */
    void DLSParser_Delete( DLSParser *parser );

#ifdef __cplusplus
};
#endif

#endif /* _DLS_PARSER_H */
