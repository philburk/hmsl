#ifndef _MBIS_PARSER_H
#define _MBIS_PARSER_H
/**
 * @file mbis_parser.h
 * @brief Parses an MBIS file image from an in-memory image.
 *
 * MBIS stands for MoBileer Instrument Set. It is a file that contains
 * one or more ME1000 or ME2000 instruments.
 *
 * @author Phil Burk Copyright 2007 Mobileer, PROPRIETARY and CONFIDENTIAL
 */
#include "spmidi/include/streamio.h"
#include "spmidi/include/spmidi.h"

#ifdef __cplusplus
extern "C"
{
#endif

    /** Opaque data type representing an internal MBIS structure. */
    typedef void * MBISParser;

    /**
     * Create a parser for a MBIS file.
     * @param parserPtr Pointer to a variable that will receive a pointer to the new parser.
     * @param sio Stream of a file or memory image containing a MBIS data
     * @return 0 If no error, or the following:
     * @exception SPMIDI_Error_OutOfMemory not enough free memory to allocate parser
    */
    SPMIDI_Error MBISParser_Create( MBISParser **parserPtr,
                                   StreamIO *sio );

    /**
     * Load MBIS instruments into SPMIDI synthesizer.
     * @return 0 if no error, or one of the following:
     * @exception SPMIDI_Error_IllegalArgument parser or midi context has not been initialized
     * @exception MBISParser_Error_NotParsed MBISParser_Parse() has not been successfully called=
     */
    SPMIDI_Error MBISParser_Load( MBISParser *parser );

    /**
     * Delete the MBIS Parser.
     */
    void MBISParser_Delete( MBISParser *parser );

#ifdef __cplusplus
};
#endif

#endif /* _MBIS_PARSER_H */
