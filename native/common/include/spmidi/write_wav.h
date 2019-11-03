#ifndef _WRITE_WAV_H
#define _WRITE_WAV_H

/**
 * Write WAV formatted audio to a file.
 *
 * @author Phil Burk, Copyright 1997 Mobileer, PROPRIETARY and CONFIDENTIAL
 */

#include <stdio.h>

#ifdef __cplusplus
extern "C"
{
#endif

    /** This structure contains information needed when writing a WAV file image. */
    typedef struct WAV_Writer_s
    {
        FILE *fid;                 /**< ID for the WAV file. */
        int   dataSizeOffset;      /**< Offset in file for audio data size. */
        int   dataSize;            /**< Size of audio data chunk. */
        int   samplesPerFrame;
    }
    WAV_Writer;

    /**
     * Create a structure for writing a WAV file.
     */
    int Audio_WAV_CreateWriter( WAV_Writer **writerPtr, const char *fileName );

    void Audio_WAV_DeleteWriter( WAV_Writer *writer );

    /**
     * Open named file and write WAV header to the file.
     * The header includes the DATA chunk type and size.
     * Returns number of bytes written to file or negative error code.
     */
    long Audio_WAV_OpenWriter( WAV_Writer *writer, int frameRate, int samplesPerFrame );

    /**
     * Write to the data chunk portion of a WAV file.
     * Returns bytes written or negative error code.
     */
    long Audio_WAV_WriteShorts( WAV_Writer *writer,
                                short *samples,
                                int numSamples
                              );

    /**
     * Close WAV file.
     * Update chunk sizes so it can be read by audio applications.
     */
    long Audio_WAV_CloseWriter( WAV_Writer *writer );

#ifdef __cplusplus
}
#endif


#endif /* _WRITE_WAV_H */
