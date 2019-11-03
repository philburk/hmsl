/* $Id: spmidi_load.h,v 1.5 2005/05/03 22:04:00 philjmsl Exp $ */
#ifndef _SPMIDI_LOAD_H
#define _SPMIDI_LOAD_H
/**
 * @file spmidi_util.h
 * @brief Tools for playing SPMIDI on portaudio or to a WAV file.
 * @author Phil Burk, Copyright 2002 Mobileer, PROPRIETARY and CONFIDENTIAL
 */

#ifdef __cplusplus
extern "C"
{
#endif


    /**
     * Load a file from disk into a memory image and return a pointer.
     * @return Pointer to image or NULL if load failed.
     */
    void *SPMUtil_LoadFileImage( const char *fileName, int *sizePtr );

    /**
     * Free a memory image aallocated by SPMUtil_LoadFileImage().
     */
    void SPMUtil_FreeFileImage( void *image );


#ifdef __cplusplus
}
#endif

#endif /* _SPMIDI_LOAD_H */
