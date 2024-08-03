//
//  pf_hmsl.c
//
//  Created by Andrew C Smith on 1/27/15.
//  Copyright (c) 2015 Andrew C Smith. All rights reserved.
//

#ifndef PF_USER_CUSTOM

/***************************************************************
 ** Call Custom Functions for pForth
 **
 ** Create a file similar to this and compile it into pForth
 ** by setting -DPF_USER_CUSTOM="mycustom.c"
 **
 ** Using this, you could, for example, call X11 from Forth.
 ** See "pf_cglue.c" for more information.
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

#import "pf_all.h"
#import "hmsl_host.h"

/****************************************************************
 ** Step 1: Glue routine interface defined in header files hmsl_*
 ****************************************************************/

/****************************************************************
 ** Step 2: Fill out this table of function pointers.
 **     Do not change the name of this table! It is used by the
 **     PForth kernel.
 **     Order in CustomFunctionTable must match order in
 **     CompileCustomFunctions.
 ****************************************************************/
void * CustomFunctionTable[] =
{
    (void *) hostInit,
    (void *) hostTerm,
    (void *) hostOpenWindow,
    (void *) hostCloseWindow,
    (void *) hostSetCurrentWindow,
    (void *) hostDrawLineTo,
    (void *) hostMoveTo,
    (void *) hostDrawText,
    (void *) hostGetTextLength,
    (void *) hostFillRectangle,
    (void *) hostSetColor,
    (void *) hostSetBackgroundColor,
    (void *) hostSetDrawingMode,
    (void *) hostSetFont,
    (void *) hostSetTextSize,
    (void *) hostGetMouse,
    (void *) hostGetEvent,
    (void *) hostMIDI_Init,
    (void *) hostMIDI_Term,
    (void *) hostMIDI_Write,
    (void *) hostMIDI_Recv,
    (void *) hostMIDI_Port,
    (void *) hostSleep,
    (void *) hostClock_Init,
    (void *) hostClock_Term,
    (void *) hostClock_QueryTime,
    (void *) hostClock_SetTime,
    (void *) hostClock_AdvanceTime,
    (void *) hostClock_QueryRate,
    (void *) hostClock_SetRate,
    (void *) hostChipWrite,
};

/****************************************************************
 ** Step 3: Add them to the dictionary.
 **     Do not change the name of this routine! It is called by the
 **     PForth kernel.
 ****************************************************************/

#if (!defined(PF_NO_INIT)) && (!defined(PF_NO_SHELL))
Err CompileCustomFunctions( void )
{
    int32_t i=0;

    /* Add them to the dictionary in the same order as above table. */
    /* Parameters are: Name in UPPER CASE, Index, Mode, NumParams */
    CreateGlueToC( "HOSTINIT()", i++, C_RETURNS_VALUE, 0 );
    CreateGlueToC( "HOSTTERM()", i++, C_RETURNS_VOID, 0 );
    CreateGlueToC( "HOSTOPENWINDOW()", i++, C_RETURNS_VALUE, 1 );
    CreateGlueToC( "HOSTCLOSEWINDOW()", i++, C_RETURNS_VOID, 1 );
    CreateGlueToC( "HOSTSETCURRENTWINDOW()", i++, C_RETURNS_VOID, 1 );
    CreateGlueToC( "HOSTDRAWLINETO()", i++, C_RETURNS_VOID, 2 );
    CreateGlueToC( "HOSTMOVETO()", i++, C_RETURNS_VOID, 2 );
    CreateGlueToC( "HOSTDRAWTEXT()", i++, C_RETURNS_VOID, 2 );
    CreateGlueToC( "HOSTGETTEXTLENGTH()", i++, C_RETURNS_VALUE, 2 );
    CreateGlueToC( "HOSTFILLRECTANGLE()", i++, C_RETURNS_VOID, 4 );
    CreateGlueToC( "HOSTSETCOLOR()", i++, C_RETURNS_VOID, 1 );
    CreateGlueToC( "HOSTSETBACKGROUNDCOLOR()", i++, C_RETURNS_VOID, 1 );
    CreateGlueToC( "HOSTSETDRAWINGMODE()", i++, C_RETURNS_VOID, 1 );
    CreateGlueToC( "HOSTSETFONT()", i++, C_RETURNS_VOID, 1 );
    CreateGlueToC( "HOSTSETTEXTSIZE()", i++, C_RETURNS_VOID, 1 );
    CreateGlueToC( "HOSTGETMOUSE()", i++, C_RETURNS_VOID, 2 );
    CreateGlueToC( "HOSTGETEVENT()", i++, C_RETURNS_VALUE, 1 );
    CreateGlueToC( "HOSTMIDI_INIT()", i++, C_RETURNS_VOID, 0 );
    CreateGlueToC( "HOSTMIDI_TERM()", i++, C_RETURNS_VOID, 0 );
    CreateGlueToC( "HOSTMIDI_WRITE()", i++, C_RETURNS_VOID, 3 );
    CreateGlueToC( "HOSTMIDI_RECV()", i++, C_RETURNS_VALUE, 0 );
    CreateGlueToC( "HOSTMIDI_PORT()", i++, C_RETURNS_VALUE, 0 );
    CreateGlueToC( "HOSTSLEEP()", i++, C_RETURNS_VOID, 1 );
    CreateGlueToC( "HOSTCLOCKINIT()", i++, C_RETURNS_VOID, 0 );
    CreateGlueToC( "HOSTCLOCKTERM()", i++, C_RETURNS_VOID, 0 );
    CreateGlueToC( "HOSTQUERYTIME()", i++, C_RETURNS_VALUE, 0 );
    CreateGlueToC( "HOSTSETTIME()", i++, C_RETURNS_VOID, 1 );
    CreateGlueToC( "HOSTADVANCETIME()", i++, C_RETURNS_VOID, 1 );
    CreateGlueToC( "HOSTQUERYCLOCKRATE()", i++, C_RETURNS_VALUE, 0 );
    CreateGlueToC( "HOSTSETCLOCKRATE()", i++, C_RETURNS_VOID, 1 );
    CreateGlueToC( "HOSTWRITECHIP()", i++, C_RETURNS_VOID, 2 );

    TOUCH(i);

    return 0;
}
#else
int32 CompileCustomFunctions( void ) { return 0; }
#endif

/****************************************************************
 ** Step 4: Recompile using compiler option PF_USER_CUSTOM
 **         and link with your code.
 **         Then rebuild the Forth using "pforth -i"
 **         Test:   10 Ctest0 ( should print message then '11' )
 ****************************************************************/

#endif  /* PF_USER_CUSTOM */
