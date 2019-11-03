/* $Id: ima_adpcm_wav.h,v 1.3 2007/10/02 16:20:00 philjmsl Exp $ */
#ifndef _IMA_ADPCM_WAV
#define _IMA_ADPCM_WAV
/**
 * WAV file IMA Intel/DVI ADPCM Encoder and Decoder
 *
 * <pre>
 * Format of ADPCM data in WAV DATA chunk:
 *   Blocks of encoded samples:
 *      2 bytes: initial sample, 16 bit signed PCM, little endian
 *      1  byte: initial Step Index for ADPCM decoder
 *      1  byte: reserved
 *      N bytes: ADPCM nibbles, least significant nibble is earlier sample
 * </pre>
 *
 * @author Phil Burk, Copyright 1997-2005 Phil Burk, Mobileer, PROPRIETARY and CONFIDENTIAL
 */

#include "spmidi/include/streamio.h"
#include "spmidi/include/read_wav.h"

#ifdef __cplusplus
extern "C" {
#endif

typedef struct IMA_WAV_Coder
{
    StreamIO      *sio;   /* Stream to read or write data to. */
    unsigned char *encodedBlock; /* Allocated buffer to hold encoded block. */
    int            samplesPerBlock;
    int            bytesPerBlock;
    int            stepIndex;
    int            bytesEncoded;
    short          previousValue;
} IMA_WAV_Coder;

#define IMA_WAV_TYPICAL_BYTES_PER_BLOCK  (0x100)

/**
 * Setup Coder structure for block-by-block decoding or encoding of an ADPCM stream.
 * Block size is specified by samplesPerBlock which is normally
 * read from a WAV file.
 */
int IMA_WAV_InitializeCoder( IMA_WAV_Coder *imacod, int samplesPerBlock, StreamIO *encodedStream );

void IMA_WAV_TerminateCoder( IMA_WAV_Coder *imacod );

/**
 * Decode succesive blocks of an ADPCM stream.
 * @exception SPMIDI_Error_BufferTooSmall if buffer too small to receive decoded samples.
 * Return number of samples decoded, or -1 if at end of sample.
 */
int IMA_WAV_DecodeNextBlock( IMA_WAV_Coder *imacod, short *decodedData, int maxSamples );

int IMA_WAV_CalculateEncodedSize(
                        int bytesPerBlock, /* Typically 0x100 */
                        int minSamples /* Number of blocks will be rounded up to accomodate all samples. */
                        );
/**
 * Setup an AudioSample to receive encoded ADPCM data.
 */
void IMA_WAV_SetupSample( AudioSample *asmp,
                        int bytesPerBlock, /* Typically 0x100 */
                        long frameRate
                        );

/**
 * Encode next block of an ADPCM stream.
 */
int IMA_WAV_EncodeNextBlock( IMA_WAV_Coder *imacod, unsigned char *decodedData );

#define IMA_WAV_SamplesPerBlock(bytesPerBlock) ((((bytesPerBlock) - 4)*2) + 1)
#define IMA_WAV_BytesPerBlock(samplesPerBlock) (((samplesPerBlock-1)/2)+4)

#ifdef __cplusplus
};
#endif

#endif /* _IMA_ADPCM_WAV */
