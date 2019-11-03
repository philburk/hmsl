#ifndef _SPMIDI_EDITOR_H
#define _SPMIDI_EDITOR_H

/* $Id: spmidi_editor.h,v 1.14 2007/10/10 00:25:19 philjmsl Exp $ */
/**
 *
 * Used internally by Instrument Editor
 * This is not normally called by an application.
 * API is subject to change without notice.
 *
 * @author Phil Burk, Copyright 2002 Mobileer, PROPRIETARY and CONFIDENTIAL
 *
 */

#include "spmidi/include/spmidi_config.h"
#include "spmidi/engine/wave_manager.h"
#include "spmidi/include/spmidi.h"

#ifdef __cplusplus
extern "C"
{
#endif

    /** Download an instrument definition as a byte stream.
     * @param insIndex index within internal presets array
     */
    int SPMIDI_SetInstrumentDefinition( SPMIDI_Orchestra *orchestra, int insIndex, ResourceTokenMap_t *tokenMap, unsigned char *data, int numBytes );

    /** Map a MIDI program number to an instrument index.
     * This allows multiple programs to be mapped to a single instrument.
     */
    int SPMIDI_SetInstrumentMap( SPMIDI_Orchestra *orchestra, int bankIndex, int programIndex, int insIndex );

    /** Map a MIDI drum pitch to an instrument index.
     * This allows multiple drums to be mapped to a single instrument.
     * @param noteIndex MIDI pitch of note on rhythm channel that triggers this drum
     * @param insIndex index used when defining instrument with SPMIDI_SetInstrumentDefinition()
     * @param pitch pitch of instrument when playing this drum sound
     */
    int SPMIDI_SetDrumMap( SPMIDI_Orchestra *orchestra, int bankIndex, int programIndex, int noteIndex, int insIndex, int pitch );

    SPMIDI_Orchestra *SPMIDI_GetCompiledOrchestra( void );

    /** Identify beginning of data stream. */
#define SPMIDI_BEGIN_STREAM    (0x00FF)
    /** Identify end of data stream. */
#define SPMIDI_END_STREAM    (0x00FE)

    typedef enum SPMIDI_StreamID_e
    {
        SPMIDI_INSTRUMENT_STREAM_ID = 1,
        SPMIDI_WAVETABLE_STREAM_ID,
        SPMIDI_WAVESET_STREAM_ID
    } SPMIDI_StreamID;


#if SPMIDI_ME2000

    /** Download a WaveTable for internal storage and use.
     * Returns negative error or positive waveTable token.
     */
    int SPMIDI_LoadWaveTable( SPMIDI_Orchestra *orchestra, unsigned char *data, int numBytes );

    /* Delete WaveTable if WaveSet reference count is zero. */
    int SPMIDI_UnloadWaveTable( SPMIDI_Orchestra *orchestra, spmSInt32 token );

    /** Download a WaveSet for internal storage and use.
     * Returns negative error or positive waveSet token.
     */
    int SPMIDI_LoadWaveSet( SPMIDI_Orchestra *orchestra, ResourceTokenMap_t *tokenMap, unsigned char *data, int numBytes );

    /* Delete WaveSet if instrument reference count is zero. */
    int SPMIDI_UnloadWaveSet( SPMIDI_Orchestra *orchestra, spmSInt32 token );

    int SPMIDI_UnloadAllWaveData( );

    /** Add a WaveTable for internal storage and use.
     * The contents of the definition are specific to the synthesizer in use.
     * Returns negative error or positive waveTable token.
     */
    int SPMIDI_AddWaveTable( WaveTable_t *waveTable );

    /** Add a WaveSet for internal storage and use.
     * The contents of the definition are specific to the synthesizer in use.
     * Returns negative error or positive waveSet token.
     */
    int SPMIDI_AddWaveSet( WaveSet_t *waveSet, int id );

#endif /* SPMIDI_ME2000 */

#ifdef __cplusplus
}
#endif

#endif /* _SPMIDI_EDITOR_H */

