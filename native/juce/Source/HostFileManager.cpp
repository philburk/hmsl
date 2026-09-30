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

#define DIR_HMSL_SUB         "hmsl"
#define DIR_HMSL_PFORTH_FTH  "pforth/fth"
#define DIR_BUNDLED_HMSL     "Contents/Resources/hmsl"
#define REPO_MARKER_FILE     "hmsl/fth/make_hmsl.fth"

HostFileManager::HostFileManager() {
    File appFile = File::getSpecialLocation(File::SpecialLocationType::currentApplicationFile);
    File bundledDictionary = appFile.getChildFile("Contents/Resources/" PF_DEFAULT_DICTIONARY);
    if (bundledDictionary.existsAsFile()) {
        // Installed app. The work folder is set later by setWorkFolder().
        mInstalled = true;
        mBundledHmslDir = appFile.getChildFile(DIR_BUNDLED_HMSL);
        mDictionaryPath = bundledDictionary.getFullPathName().toStdString();
    } else {
        // Built in the repository. Look for the top of the repository.
        mRepoDir = appFile.getParentDirectory();
        while (!mRepoDir.getChildFile(REPO_MARKER_FILE).existsAsFile()) {
            File parentDir = mRepoDir.getParentDirectory();
            if (parentDir == mRepoDir) { // at root! Not in an HMSL repository
                break;
            }
            mRepoDir = parentDir;
        }
        mHmslDir = mRepoDir.getChildFile(DIR_HMSL_SUB);
        mDictionaryPath = mHmslDir.getChildFile(PF_DEFAULT_DICTIONARY).getFullPathName().toStdString();
    }
    setCurrentDirectory(mHmslDir);
}

bool HostFileManager::setWorkFolder(const File &folder) {
    if (!folder.createDirectory()) {
        return false;
    }
    // Copy files that the user does not already have. Never overwrite their files.
    for (const DirectoryEntry &entry : RangedDirectoryIterator(mBundledHmslDir, true, "*",
                                                              File::findFiles)) {
        File source = entry.getFile();
        File destination = folder.getChildFile(source.getRelativePathFrom(mBundledHmslDir));
        if (!destination.exists()) {
            destination.getParentDirectory().createDirectory();
            source.copyFileTo(destination);
        }
    }
    mHmslDir = folder;
    setCurrentDirectory(mHmslDir);
    return true;
}

void HostFileManager::setCurrentDirectory(const File &dir) {
    mCurrentDirectory.reset(new File(dir));
}

File HostFileManager::getCurrentDirectory() {
    return File(*mCurrentDirectory.get());
}

File HostFileManager::getPForthDirectory() {
    return mRepoDir.getChildFile(StringRef(DIR_HMSL_PFORTH_FTH));
}

File HostFileManager::getHmslDirectory() {
    return mHmslDir;
}

const char *HostFileManager::getSystemFileName() {
    return "system.fth";
}

const char *HostFileManager::getDictionaryFileName() {
    return mDictionaryPath.c_str();
}

FILE *HostFileManager::openFile( const char *fileName, const char *mode ) {
    File file = mCurrentDirectory->getChildFile(StringRef(fileName));
    const char *name = file.getFullPathName().toRawUTF8();

//    pfMessage("openFile: ");
//    pfMessage(fileName);
//    pfMessage("\n");

    FILE *filePtr  = fopen(name, mode);
    if (filePtr == NULL) {
        pfMessage("ERROR - failed to open ");
        pfMessage(name);
        pfMessage("\n");
    }
    return filePtr;
}
