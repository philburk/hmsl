#ifndef _STREAMIO_H
#define _STREAMIO_H

/*
 * Generic Stream I/O that uses a simple object with vectored functions.
 *
 * Author: Phil Burk
 * Copyright 1999 Phil Burk
 */
#ifndef NULL
#define NULL   ((void *) 0)
#endif

#ifdef __cplusplus
extern "C"
{
#endif

typedef struct StreamIO
{
    /* Read data from stream at current position. Return number of bytes read. */
    int (*read)( struct StreamIO *stream, char *buf, int numBytes );
    /* Write data to stream at current position. Return number of bytes read. */
    int (*write)( struct StreamIO *stream, char *buf, int numBytes );
    /* Seek to a certain position in the stream. */
    int (*setPosition)( struct StreamIO *stream,  int offset );
    /* Tell current position in stream. */
    int (*getPosition)( struct StreamIO *stream );
    /* Close stream. */
    void (*close)( struct StreamIO *stream );
    /* Get address if an in-memory stream, or return NULL. */
    char *(*getAddress)( struct StreamIO *stream );
}
StreamIO;

StreamIO *Stream_OpenImage( char *dataPtr, int numBytes );

/**
 * Create a stream object for reading a file wuth stdio.
 * This function is in "spmidi/util/streamio_file.c".
 * @param fileName Name or path of the file.
 * @param mode Generally "r", "rb", "w", "wb".
 */
StreamIO *Stream_OpenFile( char *fileName, char *mode );

int Stream_Read( StreamIO *sio, char *buffer, int numBytes );
int Stream_Write( StreamIO *sio, char *buffer, int numBytes );
int Stream_SetPosition( StreamIO *sio, int offset );
int Stream_GetPosition( StreamIO *sio );
void Stream_Close( StreamIO *sio );

#define Stream_GetAddress(sio)  ((sio)->getAddress(sio))

#ifdef __cplusplus
};
#endif

#endif
