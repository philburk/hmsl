/* $Id: ima_adpcm.h,v 1.2 2005/11/28 19:12:53 philjmsl Exp $ */
#ifndef _IMA_ADPCM
#define _IMA_ADPCM
/**
 * @file ima_adpcm.h
 * @brief IMA Intel/DVI type ADPCM encoder and decoder.
 *
 * @author Phil Burk, Copyright 1997-2005 Phil Burk, Mobileer, PROPRIETARY and CONFIDENTIAL
 */

#ifdef __cplusplus
extern "C"
{
#endif

    /**
     * Decode an array of packed IMA Intel/DVI ADPCM data into an array of shorts.
     * Set initialValue and initialStepIndex which may come from block headers
     * in an encoded stream.
     * @param numSamples Two samples per byte of encodedArray.
     * @param initialValue Typically 0
     * @param initialStepIndex Value between 0 and 88, typically 0
     * @param decodedArray Output array must be large enough for numSamples.
     * @return final stepIndex;
     */
    int IMA_DecodeArray( const unsigned char *encodedArray,
                         int   numSamples,         /* Two samples per byte of encodedArray. */
                         short initialValue,       /* Typically 0. */
                         int   initialStepIndex,   /* Value between 0 and 88, typically 0. */
                         short *decodedArray       /* Output array must be large enough for numSamples. */
                       );
    /**
     * Decode one 4 bit nibble of ADPCM data.
     */
    short IMA_DecodeNibble( unsigned char encodedSample,
                            short previousValue,
                            int   *stepIndexPtr   /* Value between 0 and 88, typically 0. */
                          );

    /**
     * Encode an array of packed IMA Intel/DVI ADPCM data from an array of shorts.
     *
     * @param decodedArray Input array of uncompresed samples.
     * @param numSamples
     * @param previousSamplePtr pointer to previousSample whose value is used then updated with decoded value.
     * @param stepIndexPtr pointer to step index whose value is used then updated
     * @param encodedArray Two samples per byte of encodedArray.
     * @return final stepIndex;
     */
    void IMA_EncodeArray(
        const short *decodedArray,         /* Input array of uncompresed samples. */
        int   numSamples,
        short *previousSamplePtr,    /* Updated with estimated new value. */
        int   *stepIndexPtr,         /* Value between 0 and 88, typically 0. */
        unsigned char *encodedArray  /* Two samples per byte of encodedArray. */
    );

    /************************************************************************************
     * Encode a short as an IMA Intel/DVI ADPCM nibble.
     * previousSamplePtr - pointer to previousSample whose value is used then updated with decoded value.
     * stepIndexPtr - pointer to step index whose value is used then updated.
     * @param previousSamplePtr pointer to previousSample whose value is used then updated with decoded value.
     * @param stepIndexPtr pointer to step index whose value is used then updated
     * @return decoded value.
     */
    unsigned char IMA_EncodeNibble(
        short inputSample,
        short *previousSamplePtr,
        int   *stepIndexPtr
    );

#ifdef __cplusplus
};
#endif

#endif /* _IMA_ADPCM */
