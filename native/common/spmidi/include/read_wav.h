/* $Id: read_wav.h,v 1.3 2007/10/02 16:20:00 philjmsl Exp $ */
#ifndef _READ_WAV_H
#define _READ_WAV_H
/**
 * WAV parser.
 * Parses a WAV file image from an in-memory image or a stream.
 *
 * @author Phil Burk, Copyright 1997-2005 Phil Burk, Mobileer, PROPRIETARY and CONFIDENTIAL
 */

#include "spmidi/include/streamio.h"

#ifdef __cplusplus
extern "C"
{
#endif

    typedef struct AudioSample_s
    {
        void            *data;             /* Pointer to sample data in memory. */
        unsigned long    dataOffset;       /* Offset to sample data in file. */
        unsigned long    maxNumberOfBytes; /* Maximum number of bytes in buffer. */
        unsigned long    numberOfBytes;    /* Total number of actual bytes in sample. */
        unsigned long    numberOfFrames;   /* Number of mono or stereo frames in file. */
        unsigned long    frameRate;        /* Typically 22050, 44100, or 48000 */
        unsigned long    samplesPerBlock;  /* Used by ADPCM decoders */
        unsigned long    bytesPerBlock;    /* Used by ADPCM decoders */
        unsigned char    bitsPerSample;    /* Typically 8 or 16 */
        unsigned char    samplesPerFrame;  /* 1 for mono, 2 for stereo */
        unsigned char    format;           /* PCM or ADPCM, etc. */
    }
    AudioSample;

#define AUDIO_FORMAT_PCM              (1)
#define AUDIO_FORMAT_FLOAT            (2)
#define AUDIO_FORMAT_IMA_ADPCM        (3)    /* Raw IMA ADPCM with no block headers. */
#define AUDIO_FORMAT_IMA_ADPCM_WAV    (4)    /* IMA ADPCM with WAV style block headers. */

#define AUDIO_ERR_ILLEGAL_FORMAT      (-1)   /* Sample format is inappropriate. */
#define AUDIO_ERR_NULL_POINTER        (-2)   /* Sample data pointer is NULL. */
#define AUDIO_ERR_INSUFFICIENT_MEMORY (-3)   /* Not enough room for operation. */

    /* Define WAV Chunk and FORM types as 4 byte integers. */
#define RIFF_ID   (('R'<<24) | ('I'<<16) | ('F'<<8) | 'F')
#define WAVE_ID   (('W'<<24) | ('A'<<16) | ('V'<<8) | 'E')
#define FMT_ID    (('f'<<24) | ('m'<<16) | ('t'<<8) | ' ')
#define DATA_ID   (('d'<<24) | ('a'<<16) | ('t'<<8) | 'a')
#define FACT_ID   (('f'<<24) | ('a'<<16) | ('c'<<8) | 't')

    /* Errors returned by Audio_ParseSampleImage_WAV */
#define WAV_ERR_CHUNK_SIZE     (-1)   /* Chunk size is illegal or past file size. */
#define WAV_ERR_FILE_TYPE      (-2)   /* Not a WAV file. */
#define WAV_ERR_ILLEGAL_VALUE  (-3)   /* Illegal or unsupported value. Eg. 927 bits/sample */
#define WAV_ERR_FORMAT_TYPE    (-4)   /* Unsupported format, eg. compressed. */
#define WAV_ERR_TRUNCATED      (-5)   /* End of file missing. */

    /* WAV PCM data format ID */
#define WAVE_FORMAT_PCM        (1)
#define WAVE_FORMAT_IMA_ADPCM  (0x0011)

    /* Parse a raw image of a WAV file and return information in an AudioSample structure.
     * After this call. asmp->asmp_Data will contain a pointer to the data inside the image wavFileImage.
     *
     * A zero is returned if no error occurs.
     * A negative number is returned if a parsing error occurs.
     */
    long Audio_WAV_ParseSampleImage(
        unsigned char *wavFileImage, /* In-memory image of WAV file. Byte array. */
        unsigned long imageSize,   /* Number of bytes in image. */
        AudioSample *asmp,         /* Pre-allocated but empty structure to be completely filled in by parser. */
        unsigned long asmpSize     /* Number of bytes for asmp structure. Allows future extension. */
    );

    /* Parse a StreamIO of a WAV file and return information in an AudioSample structure.
     * A zero is returned if no error occurs.
     * A negative number is returned if a parsing error occurs.
     * @param wavStream Streaming access to WAV file.
     * @param asmp Pre-allocated but empty structure to be completely filled in by parser.
     */
    long Audio_WAV_ParseSampleStream(
        StreamIO *wavStream,
        AudioSample *asmp         /*  */
    );

    /* Write a raw image of a WAV file based on information in an AudioSample structure.
     * Returns image size or negative error code.
     */
    long Audio_WAV_WriteSampleImage(
        AudioSample  *asmp,         /* Valid AudioSample */
        unsigned char *wavFileImage, /* In-memory image of WAV file. Byte array. */
        unsigned long imageSize   /* Number of bytes in image. */
    );
    /*********************************************************************************
     * Write a raw image of a WAV file header based on information in an AudioSample structure.
     * The header includes the DATA chunk type and size.
     * Returns actual image size or negative error code.
     */
    long Audio_WAV_WriteHeader(
        AudioSample  *asmp,         /* Valid AudioSample */
        unsigned char *wavFileImage, /* In-memory image of WAV file header. Byte array. */
        unsigned long headerSize     /* Number of bytes allocated for header. */
    );

    /********************************************************************************
    ** Estimate the size of the WAV image for an audio sample.
    */
    long Audio_WAV_CalculateHeaderSize( AudioSample *asmp );

    /* Parse data from a Little Endian byte stream. */
    unsigned long ParseLongLE( unsigned char **addrPtr );
    unsigned short ParseShortLE( unsigned char **addrPtr );
    unsigned long ParseChunkType( unsigned char **addrPtr );

    /* Write data to a little endian format byte array. */
    void WriteLongLE( unsigned char **addrPtr, unsigned long data );
    void WriteShortLE( unsigned char **addrPtr,  unsigned short data );
    void WriteChunkType( unsigned char **addrPtr, unsigned long cktyp );

#ifndef STATUS
    #define STATUS int
#endif

    STATUS waveParserInit ( int (**waveParser)() );

#ifdef __cplusplus
};
#endif

#endif /* _READ_WAV_H */
