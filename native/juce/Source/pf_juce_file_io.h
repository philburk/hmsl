/***************************************************************
 ** I/O subsystem for PForth based on 'C'
 **
 ** Author: Phil Burk
 ** Copyright 1994 3DO, Phil Burk, Larry Polansky, David Rosenboom
 **
 ** The pForth software code is dedicated to the public domain,
 ** and any third party may reproduce, distribute and modify
 ** the pForth software code or any derivative works thereof
 ** without any compensation or license.  The pForth software
 ** code is provided on an "as is" basis without any warranty
 ** of any kind, including, without limitation, the implied
 ** warranties of merchantability and fitness for a particular
 ** purpose and their equivalents under the laws of any jurisdiction.
 **
 ***************************************************************/

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

