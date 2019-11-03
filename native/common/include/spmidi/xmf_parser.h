#ifndef _XMF_PARSER_H
#define _XMF_PARSER_H
/*
 * @brief Parses an XMF formatted file as an in-memory image.
 *
 * This code is only used by the ME3000 API.
 * It is not used by the ME1000 or ME2000.
 *
 * @author Phil Burk, Robert Marsanyi Copyright 2004 Mobileer, PROPRIETARY and CONFIDENTIAL
 */

#ifdef __cplusplus
extern "C"
{
#endif

#include "spmidi/include/spmidi.h"

#ifndef FALSE
#define FALSE    (0)
#endif

#ifndef TRUE
#define TRUE    (1)
#endif

    /** Opaque data type representing an internal XMF Parser structure. */
    typedef void * XMFParser;

    /**
     * @return TRUE if header of xmfImage is consistent with a valid XMF header, FALSE otherwise.
     */
    int XMFParser_IsXMF( unsigned char *xmfImage );

    /**
     * Create a parser for an XMF file.
     * @param xmfImage address of XMF file image in memory
     * @param numBytes size of XMF file image
     * @return 0 if no error, or one of the following:
     * @exception SPMIDI_Error_OutOfMemory not enough free memory to allocate parser or stream
     */
    SPMIDI_Error XMFParser_Create( XMFParser **parserPtr,
                                   unsigned char *xmfImage, spmSInt32 numBytes );

    /**
     * This function will parse an XMF file
     * and locate the SMF file and the DLS file.
     * @return 0 if no error, or one of the following:
     * @exception SPMIDI_Error_IllegalArgument parameter "parser" is null
     * @exception XMFParser_Error_ParseError miscellaneous parsing error
     *     - FileNode does not contain ResourceFormatID, or
     *     - Unpacker for FileNode is unrecognized
     * @exception XMFParser_Error_NotXMF file does not start with XMF file ID
     * @exception XMFParser_Error_WrongType file is not XMF Type 2 (Mobile XMF)
     * @exception XMFParser_Error_SizeError file length, Tree Start or Tree End in header exceed actual size
     */
    SPMIDI_Error XMFParser_Parse( XMFParser *parser );

    /**
     * You must call XMFParser_Parse before calling this function.
     *
     * @param maxSizePtr points to variable to receive maximum size of SMF.
     * It may not be possible to determine the actual size of the SMF
     * from the XMF information.
     * @return address of SMF file within image or NULL if not found.
     */
    unsigned char *XMFParser_GetSMF( XMFParser *parser, spmSInt32 *maxSizePtr );

    /**
     * You must call XMFParser_Parse before calling this function.
     *
     * @param maxSizePtr points to variable to receive maximum size of DLS.
     * It may not be possible to determine the actual size of the DLS
     * from the XMF information.
     * @return address of DLS file within image or NULL if not found.
     */
    unsigned char *XMFParser_GetDLS( XMFParser *parser, spmSInt32 *maxSizePtr );

    /**
     * Delete the parser data. This does not delete the in-memory image.
     */
    void XMFParser_Delete( XMFParser *parser );

    /**
     * Convenience function to parse XMF image and return SMF and DLS in one call.
     *
     * @param xmfImage address of XMF file image in memory
     * @param numBytes size of XMF file image
     *
     * @param smfImagePtr pointer to variable to recive address of SMF image.
     * @param maxSMFSizePtr points to variable to receive maximum size of SMF.
     *  It may not be possible to determine the actual size of the SMF
     *  from the XMF information.
     *
     * @param dlsImagePtr pointer to variable to recive address of DLS image.
     * @param maxDLSSizePtr points to variable to receive maximum size of DLS.
     *  It may not be possible to determine the actual size of the DLS
     *  from the XMF information.
     *
     * @return 0 if no error, or an error code from XMFParser_Create or XMFParser_Parse.
     * @see XMFParser_Create, XMFParser_Parse
     */
    SPMIDI_Error XMFParser_ParseMobile(
        unsigned char *xmfImage, spmSInt32 numBytes,
        unsigned char **smfImagePtr, spmSInt32 *maxSMFSizePtr,
        unsigned char **dlsImagePtr, spmSInt32 *maxDLSSizePtr );

#ifdef __cplusplus
}
#endif

#endif  /* _XMF_PARSER_H */


