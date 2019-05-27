/*
  ==============================================================================

    HostFileManager.cpp
    Created: 26 May 2019 4:03:53pm
    Author:  Phil Burk

  ==============================================================================
*/

#include "../JuceLibraryCode/JuceHeader.h"
#include "HostFileManager.h"

#ifndef PF_DEFAULT_DICTIONARY
// TODO use relative path
#define PF_DEFAULT_DICTIONARY "pforth.dic"
#endif

std::unique_ptr<HostFileManager> HostFileManager::mInstance;

#define DIR_HMSL_TOP         "HMSL"
#define DIR_HMSL_SUB         "hmsl"
#define DIR_HMSL_PFORTH_FTH  "pforth/fth"

HostFileManager::HostFileManager() {
    // Look for the top HMSL folder.
    File appFile = File::getSpecialLocation(File::SpecialLocationType::currentApplicationFile);
    mAppDir = appFile.getParentDirectory();
    mHMSLDir = mAppDir;
    while (mHMSLDir.getFileName().compare(DIR_HMSL_TOP)) {
        File parentDir = mHMSLDir.getParentDirectory();
        if (parentDir == mHMSLDir) { // at root!
            mHMSLDir = mAppDir; // so just use the directory the app is in.
            break;
        }
        mHMSLDir = parentDir;
    }
    setCurrentDirectory(mHMSLDir);
}

void HostFileManager::setCurrentDirectory(const File &dir) {
    mCurrentDirectory.reset(new File(dir));
}

File HostFileManager::getCurrentDirectory() {
    return File(*mCurrentDirectory.get());
}

File HostFileManager::getPForthDirectory() {
    return mHMSLDir.getChildFile(StringRef(DIR_HMSL_PFORTH_FTH));
}

File HostFileManager::getHmslDirectory() {
    return mHMSLDir.getChildFile(StringRef("hmsl"));
}

const char *HostFileManager::getSystemFileName() {
    return "system.fth";
}

const char *HostFileManager::getDictionaryFileName() {
    return PF_DEFAULT_DICTIONARY;
}

FILE *HostFileManager::openFile( const char *fileName, const char *mode ) {
    File file = mCurrentDirectory->getChildFile(StringRef(fileName));
    const char *name = file.getFullPathName().toRawUTF8();
    return fopen(name, mode);
}
