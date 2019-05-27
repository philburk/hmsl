/*
  ==============================================================================

    ForthThread.cpp
    Created: 14 May 2019 8:51:30pm
    Author:  Phil Burk

  ==============================================================================
*/

#include "pforth.h"

#include "ForthThread.h"
#include "HostFileManager.h"

#define PF_COMPILE_SYSTEM     0

void ForthThread::run() {
    HostFileManager *hostFileManager = HostFileManager::getInstance();
#if PF_COMPILE_SYSTEM
    // Build Forth dictionary
    hostFileManager->setCurrentDirectory(hostFileManager->getPForthDirectory());
    pfDoForth(NULL, hostFileManager->getSystemFileName(), true);
#else
    // Load precompiled HMSL dictionary.
    hostFileManager->setCurrentDirectory(hostFileManager->getHmslDirectory());
    pfDoForth(hostFileManager->getDictionaryFileName(), NULL, false);
#endif
}
