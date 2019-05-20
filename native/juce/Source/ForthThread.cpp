/*
  ==============================================================================

    ForthThread.cpp
    Created: 14 May 2019 8:51:30pm
    Author:  Phil Burk

  ==============================================================================
*/

#include "ForthThread.h"
#include "pforth.h"

void     ForthThread::run() {
    usleep(2000 * 1000);
    pfDoForth(NULL, NULL, true);
}
