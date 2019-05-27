/*
  ==============================================================================

    pf_juce_file_io.h
    Created: 26 May 2019 7:48:28am
    Author:  Phil Burk

  ==============================================================================
*/

#pragma once
#include <stdio.h>

typedef FILE FileStream;

#ifdef __cplusplus
extern "C" {
#endif

FileStream *sdOpenFile( const char *fileName, const char *mode );

#ifdef __cplusplus
}
#endif

#define sdDeleteFile    remove
#define sdFlushFile     fflush
#define sdReadFile      fread
#define sdWriteFile     fwrite

/*
 * Note that fseek() and ftell() only support a long file offset.
 * So 64-bit offsets may not be supported on some platforms.
 * At one point we supported fseeko() and ftello() but they require
 * the off_t data type, which is not very portable.
 * So we decided to sacrifice vary large file support in
 * favor of portability.
 */
#define sdSeekFile      fseek
#define sdTellFile      ftell

#define sdCloseFile     fclose
#define sdRenameFile    rename
#define sdInputChar     fgetc

#define PF_STDIN  ((FileStream *) stdin)
#define PF_STDOUT ((FileStream *) stdout)

#define  PF_SEEK_SET   (SEEK_SET)
#define  PF_SEEK_CUR   (SEEK_CUR)
#define  PF_SEEK_END   (SEEK_END)

/* TODO review the Size data type. */
ThrowCode sdResizeFile( FileStream *, uint64_t Size);

/*
 ** printf() is only used for debugging purposes.
 ** It is not required for normal operation.
 */
#define PRT(x) { printf x; sdFlushFile(PF_STDOUT); }

