
#ifndef _SPMIDI_CONFIG_H
#define _SPMIDI_CONFIG_H

/* $Id: spmidi_config.h,v 1.40 2007/10/10 00:25:19 philjmsl Exp $ */

/**
 * @file spmidi_config.h
 * @brief Configuration file to select compile time options.
 *
 * These configuration options control the compilation of the Mobileer code.
 * we do not recommend changing this file because your changes may be overwritten by our next code release.
 * Instead, you can define these parameters using compiler options such as:
 *
 * <pre>    -DSPMIDI_PRODUCTION=1
 * </pre>
 *
 * Or by defining SPMIDI_USER_CONFIG you can set your compile time configuration variables
 * in file called "spmidi_user_config.h". They will override the values in this file.
 *
 * @author Phil Burk, Copyright 2002 Mobileer PROPRIETARY and CONFIDENTIAL
 */

/* Define these parameters at compile time so we can tune them for embedded systems. */

#ifdef SPMIDI_USER_CONFIG
#include "spmidi_user_config.h"
#endif

#ifndef SPMIDI_ME3000
    #ifdef SPMIDI_ME2000
        #define SPMIDI_ME3000   (0)
    #else
/** Define this as one to compile the additional ME3000 support.
 * If it is set to zero, then you get the ME1000 or ME2000.
 */
        #define SPMIDI_ME3000   (1)
    #endif
#endif

#ifndef SPMIDI_ME2000
/** Define this as one to compile the additional ME2000 support.
 * If it is set to zero, then you get the ME1000.
 */
#define SPMIDI_ME2000   (1)
#endif

#ifndef SPMIDI_PRODUCTION
/** Define this as one to optimize the build for a production environment.
 * If it is set to zero, then such things as full error message texts are defined, which
 * take up RAM.
 */
#define SPMIDI_PRODUCTION   (0)
#endif

#ifndef SPMIDI_MAX_VOICES
/** Absolute maximum number of voices allowed.
 * Internal structures will be allocated based on this value.
 * The actual maximum number of voices can be lowered dynamically by passing a value to SPMIDI_SetMaxVoices().
 */
#define SPMIDI_MAX_VOICES          (64)
#endif

#ifndef SPMIDI_MAX_SAMPLEMEM
/** Parsing a DLS file requires that the parser know how much sample RAM (in samples) is available.
 * This allows a DLS author to specify alternate instrument definitions given different RAM
 * availability.
 */
#define SPMIDI_MAX_SAMPLEMEM       (15*1024)
#endif

#ifndef SPMIDI_MUTE_UNSPECIFIED_CHANNELS
/** If a Scaleable Polyphony MIP message does not specify voices for a channel
 * then it would normally be muted. But some commercial SP-MIDI files fail to specify all
 * channels. This controls whether they will be muted or not.
 */
#define   SPMIDI_MUTE_UNSPECIFIED_CHANNELS  (0)
#endif

#ifndef SPMIDI_MAX_SAMPLES_PER_FRAME
/** User can select mono or stereo synthesis when calling SPMIDI_ReadFrames().
 * One can save some memory by setting this to (1) at compile time but that
 * will prevent calling SPMIDI_ReadFrames() with samplesPerFrame greater than one.
 */
#define SPMIDI_MAX_SAMPLES_PER_FRAME   (2)
#endif

#ifndef SPMIDI_MAX_SAMPLE_RATE
/** Maximum rate that can be specified in call to SPMIDI_CreateContext().
 * This compile time maximum will affect the size of buffers such
 * as the compressor delay line.
 * RAM can be saved by setting this to the maximum that you expect to use.
 */
#define SPMIDI_MAX_SAMPLE_RATE   (48000)
#endif

/**
 * Determine internal block size for calculations.
 * This may be set to 2,3 or 4.
 * The block size will be (1<<SPMIDI_FRAMES_PER_BLOCK_LOG2).
 * A larger block size is more CPU efficient.
 * But the timing intervals for MIDI are also larger resulting
 * in less precise musical timings.
 * We recommend 3 for low sample rates and 4 for high sample rates.
 * The MIDI timing interval is:
 * <pre>
 *    minimumDuration = (1<<SPMIDI_FRAMES_PER_BLOCK_LOG2)*(1<<SPMIDI_FRAMES_PER_BLOCK_LOG2)/sampleRate
 * </pre>
 */

#ifndef SPMIDI_FRAMES_PER_BLOCK_LOG2
#define SPMIDI_FRAMES_PER_BLOCK_LOG2    (3)
#endif

#ifndef SPMIDI_USE_COMPRESSOR
/** Define this as zero to disable the dynamic range compressor. */
#define SPMIDI_USE_COMPRESSOR          (0)
#endif

#ifndef SPMIDI_USE_SOFTCLIP
/** Define this as one to enable soft clipping.
 * This results in a gentle distortion when the volume is
 * raised above the normal limits.
 */
#define SPMIDI_USE_SOFTCLIP         (0)
#endif

#ifndef SPMIDI_USE_REVERB
/** Define this as one to enable the reverberation effect. */
#define SPMIDI_USE_REVERB           (0)
#endif

#ifndef SPMIDI_SQUARE_VELOCITY
/**
 * Define this as (1) if you want a concave transform, gain = velocity^2.
 * Define this as (0) if you want a linear transform, gain = velocity.
 * The MIDI specification asks for an exponential transform.
 * GM2 says the transform is undefined.
 * DLS2 specifies the square transform.
 */
#define SPMIDI_SQUARE_VELOCITY       (0)
#endif

#ifndef SPMIDI_SUPPORT_EDITING
/** Define this as one to enable the instrument editing support. */
#define SPMIDI_SUPPORT_EDITING      (0)
#endif

#if SPMIDI_SUPPORT_EDITING
#define SPMIDI_SUPPORT_LOADING  (1)
#else
#ifndef SPMIDI_SUPPORT_LOADING
/** Define this as one to enable loading orchestras from files
 * by calling SPMIDI_LoadOrchestra().
 */
#define SPMIDI_SUPPORT_LOADING      (0)
#endif
#endif

#ifndef SPMIDI_SMOOTH_MIXER_GAIN
/** Smooth succesive gain values inside mixer. This will reduce zippering noise
 * but will also increase the CPU load slightly.
 */
#define SPMIDI_SMOOTH_MIXER_GAIN    (1)
#endif

#ifndef SPMIDI_RELOCATABLE
/**
 * Initialize all addresses in structures using code. This will allow
 * the code to be compiled as relocatable. A side effect of this is
 * that some RW memory will be created. This data will need to be
 * copied from ROM to RAM by the loader.
 *
 * If SPMIDI_RELOCATABLE is set to zero, then some structures will contain
 * addresses initialized at run-time. This allows the code to be created
 * with no RW memory. This can simplify loading on some ROM based systems.
 */
#define SPMIDI_RELOCATABLE          (1)
#endif

#ifndef SPMIDI_SUPPORT_MALLOC
/** Define this as one to enable dynamic memory allocation. */
#define SPMIDI_SUPPORT_MALLOC       (0)
#endif

#ifndef SPMIDI_MAX_NUM_CONTEXTS
/** Define the maximum number of SPMIDI_Contexts that can be created.
 * This is only used when SPMIDI_SUPPORT_MALLOC is zero.
 * It determines the number of context data structures that
 * are statically allocated at compile time.
 */
#define SPMIDI_MAX_NUM_CONTEXTS    (2)
#endif

/** Define the maximum number of MIDIFilePlayer's that can be created.
 * This is only used when SPMIDI_SUPPORT_MALLOC is zero.
 * It determines the number of MIDIFile player data structures that
 * are statically allocated at compile time.
 */
#ifndef SPMIDI_MAX_NUM_PLAYERS
#define SPMIDI_MAX_NUM_PLAYERS   (SPMIDI_MAX_NUM_CONTEXTS * 2)
#endif

/**
 * If defined as (1) then SPMIDI will call functions like memset() and memcpy().
 * If set to (0) then it will call equivalent functions that we provide.
 * It is probably more efficient to use the system functions if they are available.
 */
#ifndef SPMIDI_USE_STDLIB
#define SPMIDI_USE_STDLIB (1)
#endif

#ifndef SPMIDI_USE_INTERNAL_MEMHEAP
/**
 * Use a memory allocator provided by Mobileer.
 * This will cause all allocation to be made from a statically allocated
 * internal array. Thus allocations will not interfere with other tasks
 * in the system.
 */
#define SPMIDI_USE_INTERNAL_MEMHEAP (0)
#endif

#ifndef SPMIDI_MEMHEAP_SIZE
    #if SPMIDI_ME3000
/**
 * Determine size for internal memory heap.
 * The ME3000 needs extra memory for decoding Mobile XMF files.
 * Please tune this for your system.
 */
#define SPMIDI_MEMHEAP_SIZE (128*1024)
    #else
        #define SPMIDI_MEMHEAP_SIZE (32*1024)
    #endif
#endif

#ifndef SPMIDI_DIR
/**
 * Define where the SPMIDI folder lives on the host.  This is used to
 * determine paths to needed files; for example, the QA suite expects
 * to find data files at SPMIDI_DIR/qa/data.
 */
#define SPMIDI_DIR "/nomad/MIDISynth/code/spmidi/"
//#define SPMIDI_DIR  "code/spmidi/"
#endif

#ifndef SPMIDI_LEAVE_DLS_WAVES_IN_IMAGE
/** This controls how the DLS parser handles sample WAVE data.
 * If this is (1) and the WAVE data is in memory
 * and can be played where it lies
 * then do not copy it to an allocated memory buffer.
 * This can save significant amounts of memory when using
 * DLS files.
 */
#define SPMIDI_LEAVE_DLS_WAVES_IN_IMAGE  (1)
#endif

#ifndef SPMIDI_USE_REGIONS
/** The original ME2000 automatically determined the pitch
 * zones at run time based on the wavetable pitch. A newer version
 * determines defines WaveSetRegions using the editor. To use
 * orchestras generated by the new editor set SPMIDI_USE_REGIONS to (1).
 * To compile with older versions of the orchestra set it to (0).
 */
#define SPMIDI_USE_REGIONS  (1)
#endif

#ifndef SPMIDI_USE_PRINTF
/** Use the stdio printf function for debug messages if set to 1.
 * Otherwise it will use special low level functions that you can define.
 */
#define SPMIDI_USE_PRINTF (0)
#endif

/********************************************************************/
/*** Do not change definitions below this line. *********************/
/********************************************************************/

/* Turn on specific features required by ME3000 */
#if SPMIDI_ME3000

/* ME3000 is a superset of ME2000 so we must also turn on ME2000 features. */
#undef SPMIDI_ME2000
#define SPMIDI_ME2000   (1)

/* We require memory allocation for ME3000 */
#undef SPMIDI_SUPPORT_MALLOC
#define SPMIDI_SUPPORT_MALLOC  (1)

#endif

#endif /* _SPMIDI_CONFIG_H */

