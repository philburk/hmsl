/*
  ==============================================================================

    HostFileManager.cpp
    Created: 26 May 2019 4:03:53pm
    Author:  Phil Burk

  ==============================================================================
*/

#include "../JuceLibraryCode/JuceHeader.h"
#include "HostFileManager.h"
#include "pforth.h"

#ifndef PF_DEFAULT_DICTIONARY
#define PF_DEFAULT_DICTIONARY "pforth.dic"
#endif

std::unique_ptr<HostFileManager> HostFileManager::mInstance;

#define DIR_HMSL_TOP         "HMSL"
#define DIR_HMSL_SUB         "hmsl"
#define DIR_HMSL_PFORTH_FTH  "pforth/fth"
#define DIR_HMSL_IN_MUSIC    "~/Music/HMSL"

HostFileManager::HostFileManager() {
    File appFile = File::getSpecialLocation(File::SpecialLocationType::currentApplicationFile);
    // Look for the top HMSL folder.
    mAppDir = appFile.getParentDirectory();
#if 1
    mHMSLDir = mAppDir;
    while (mHMSLDir.getFileName().compare(DIR_HMSL_TOP)) {
        File parentDir = mHMSLDir.getParentDirectory();
        if (parentDir == mHMSLDir) { // at root! Not in an HMSL subfolder
            mHMSLDir = File(DIR_HMSL_IN_MUSIC);
            break;
        }
        mHMSLDir = parentDir;
    }
#else
    mHMSLDir = File(DIR_HMSL_IN_MUSIC);
#endif
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

    pfMessage("openFile: ");
    pfMessage(fileName);
    pfMessage("\n");
    pfMessage("mAppDir = ");
    pfMessage(mAppDir.getFullPathName().toRawUTF8());
    pfMessage("\n");
    pfMessage("mHMSLDir = ");
    pfMessage(mHMSLDir.getFullPathName().toRawUTF8());
    pfMessage("\n");
    pfMessage("full name = ");
    pfMessage(name);
    pfMessage("\n");

    return fopen(name, mode);
}
