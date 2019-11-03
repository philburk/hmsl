#ifndef _PROGRAM_LIST_H
#define _PROGRAM_LIST_H
/* $Id: program_list.h,v 1.3 2007/10/10 00:25:19 philjmsl Exp $ */
/**
 *
 * @file program_list.h
 * @brief List of bank/program/pitches used in a set of songs.
 *
 * @author Phil Burk, Copyright 2007 Mobileer, PROPRIETARY and CONFIDENTIAL
 *
 */
#include "spmidi/include/spmidi.h"
#include "spmidi/include/streamio.h"

#ifdef __cplusplus
extern "C"
{
#endif

/** Opaque type for a list of programs used in a song. */
typedef void SPMIDI_ProgramList;

/** Mark a bank and program combination for a melodic instrument as "used".
 * @param program MIDI program number from 0 to 127.
 */
int SPMIDI_SetProgramUsed( SPMIDI_ProgramList *programList, int bank, int program );

/** Mark a bank, program and noteIndex combination for a drum instrument as "in use". 
 * @param program MIDI program number from 0 to 127.
 */
int SPMIDI_SetDrumUsed( SPMIDI_ProgramList *programList, int bank, int program, int noteIndex );

int SPMIDI_ClearProgramUsed( SPMIDI_ProgramList *programList, int bank, int program );
int SPMIDI_ClearDrumUsed( SPMIDI_ProgramList *programList, int bank, int program, int noteIndex );

/** @return TRUE if the bank and program is "used". 
 * @param program MIDI program number from 0 to 127.
 */
int SPMIDI_IsProgramUsed( SPMIDI_ProgramList *programList, int bank, int program );
int SPMIDI_IsDrumUsed( SPMIDI_ProgramList *programList, int bank, int program, int noteIndex );

/** Allocate a list that can be used to keep track of bank and program combinations used in a song.
 * It can also track drums used by bank, program and pitch.
 * @param Variable to receive a pointer to the SPMIDI_ProgramList structure.
 */
int SPMIDI_CreateProgramList( SPMIDI_ProgramList **programListPtr );

void SPMIDI_DeleteProgramList( SPMIDI_ProgramList *programList );

/** Analyse a MIDI file and mark each program and drum used in the song.
 * This can be run on multiple files and the results will accumulate.
 * @param image Pointer to an in memory copy of a MIDI file.
 * @param numBytes Size of an in memory copy of a MIDI file.
 */
int MIDIFile_ScanForPrograms( SPMIDI_ProgramList *programList, unsigned char *image, int numBytes  );

/** Load a set of instruments from an MBIS file. An MBIS file is exported from the Mobileer Editor.
 * When you are done using the Orchestra you should delete it using SPMIDI_DeleteOrchestra().
 * @param programList An optional list of programs and drums to load from the MBIS file. Set to NULL to load everything.
 * @param orchestraPtr Variable to receive a pointer to the loaded orchestra.
 */
SPMIDI_Error SPMIDI_LoadOrchestra( StreamIO *instrumentStream, SPMIDI_ProgramList *programList, SPMIDI_Orchestra **orchestraPtr );

#ifdef __cplusplus
}
#endif

#endif /* _PROGRAM_LIST_H */

