/*
  ==============================================================================

    ForthThread.cpp
    Created: 14 May 2019 8:51:30pm
    Author:  Phil Burk

  ==============================================================================
*/

#include "ForthThread.h"
#include "pforth.h"

#ifndef PF_DEFAULT_DICTIONARY
// TODO use relative path
#define PF_DEFAULT_DICTIONARY "/Users/phil/Work/hmsl/HMSL/hmsl/pforth.dic"
#endif

void ForthThread::run() {
    // usleep(200 * 1000);
    // TODO if SHIFT key held down then rebuild Forth
    pfDoForth(PF_DEFAULT_DICTIONARY, NULL, false);
}
