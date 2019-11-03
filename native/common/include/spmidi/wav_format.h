#ifndef _PARS_WAV_H
#define _PARS_WAV_H
/*
 * WAV parser.
 * Parses a WAV file image from an in-memory image.
 *
 * Author: Phil Burk
 * @author Phil Burk, Copyright 2002 Mobileer, PROPRIETARY and CONFIDENTIAL
 */

#ifdef __cplusplus
extern "C"
{
#endif

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

#ifdef __cplusplus
};
#endif

#endif /* _PARS_WAV_H */
