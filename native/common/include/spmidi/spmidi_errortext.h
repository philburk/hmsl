#ifndef _SPMIDI_ERRORTEXT_H
#define _SPMIDI_ERRORTEXT_H

/* $Id: spmidi_errortext.h,v 1.5 2007/10/02 16:20:00 philjmsl Exp $ */
/**
 *
 * @file spmidi_errortext.h
 * @brief Text for errors returned by the spmidi system.
 * @author Phil Burk, Robert Marsanyi, Copyright 2005 Mobileer, PROPRIETARY and CONFIDENTIAL
 */

#include "spmidi/include/spmidi_errors.h"

#ifdef __cplusplus
extern "C"
{
#endif

/**
 * Provide text explanation for error code.
 * @param errorCode valid SPMIDI_Error code
 * @return pointer to const string containing error message.
 */
const char *SPMUtil_GetErrorText( SPMIDI_Error errorCode );


#ifdef __cplusplus
}
#endif /* __cplusplus */

#endif /* _SPMIDI_ERRORTEXT_H */

