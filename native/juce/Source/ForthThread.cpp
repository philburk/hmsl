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
#include "pf_juce_io.h"

#define HMSL_MAKE_FILE  "fth/make_hmsl.fth"

void ForthThread::run() {
    if (mBuildDictionary) {
        gEchoTerminalToStdout = true;
        int result = buildDictionary();
        MessageManager::callAsync([result]() {
            JUCEApplication::getInstance()->setApplicationReturnValue(result);
            JUCEApplication::getInstance()->quit();
        });
        return;
    }
    // Load precompiled HMSL dictionary.
    HostFileManager *hostFileManager = HostFileManager::getInstance();
    hostFileManager->setCurrentDirectory(hostFileManager->getHmslDirectory());
    pfDoForth(hostFileManager->getDictionaryFileName(), NULL, false);
}

int ForthThread::buildDictionary() {
    HostFileManager *hostFileManager = HostFileManager::getInstance();
    File pforthDir = hostFileManager->getPForthDirectory();
    File hmslDir = hostFileManager->getHmslDirectory();
    const char *dicName = hostFileManager->getDictionaryFileName();
    File baseDic = pforthDir.getChildFile(dicName);
    File hmslDic = hmslDir.getChildFile(dicName);

    // Phase 1: build the base pForth dictionary from source.
    baseDic.deleteFile();
    hostFileManager->setCurrentDirectory(pforthDir);
    pfDoForth(NULL, hostFileManager->getSystemFileName(), true);
    if (!baseDic.existsAsFile()) {
        printf("\nERROR - failed to create %s\n", baseDic.getFullPathName().toRawUTF8());
        return 1;
    }
    if (!baseDic.moveFileTo(hmslDic)) {
        printf("\nERROR - failed to move dictionary to %s\n", hmslDic.getFullPathName().toRawUTF8());
        return 2;
    }

    // Phase 2: compile HMSL on top of pForth. This overwrites hmslDic.
    Time baseTime = hmslDic.getLastModificationTime();
    hostFileManager->setCurrentDirectory(hmslDir);
    pfDoForth(dicName, HMSL_MAKE_FILE, false);
    if (hmslDic.getLastModificationTime() == baseTime) {
        printf("\nERROR - %s did not save a new %s\n", HMSL_MAKE_FILE, hmslDic.getFullPathName().toRawUTF8());
        return 3;
    }
    printf("\nHMSL dictionary saved in %s\n", hmslDic.getFullPathName().toRawUTF8());
    return 0;
}
