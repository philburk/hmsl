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
#define MANIFEST_FILE_NAME   ".hmsl_manifest"

HostFileManager::HostFileManager() {
    // Settings are saved in "~/Library/Application Support/HMSL/HMSL.settings" on Mac.
    PropertiesFile::Options options;
    options.applicationName = "HMSL";
    options.folderName = "HMSL";
    options.filenameSuffix = "settings";
    options.osxLibrarySubFolder = "Application Support";
    mSettings.setStorageParameters(options);

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

PropertiesFile *HostFileManager::getSettings() {
    return mSettings.getUserSettings();
}

bool HostFileManager::loadManifest(const File &folder) {
    mManifest.clear();
    File manifestFile = folder.getChildFile(MANIFEST_FILE_NAME);
    if (!manifestFile.existsAsFile()) {
        return false;
    }
    StringArray lines;
    manifestFile.readLines(lines);
    for (const String &line : lines) {
        int tabIndex = line.indexOfChar('\t');
        if (tabIndex > 0) {
            String hash = line.substring(0, tabIndex).trim();
            String relPath = line.substring(tabIndex + 1).trim();
            if (hash.isNotEmpty() && relPath.isNotEmpty()) {
                mManifest[relPath] = hash;
            }
        }
    }
    return true;
}

void HostFileManager::saveManifest(const File &folder) const {
    File manifestFile = folder.getChildFile(MANIFEST_FILE_NAME);
    String content;
    for (const auto &pair : mManifest) {
        content << pair.second << "\t" << pair.first << "\n";
    }
    manifestFile.replaceWithText(content);
}

bool HostFileManager::setWorkFolder(const File &folder) {
    if (!folder.createDirectory()) {
        return false;
    }
    bool hadManifest = loadManifest(folder);
    mPendingConflicts.clear();

    // Copy missing or unmodified updated files from the app bundle.
    // If a file was modified by the user and differs from the bundle, record a conflict.
    for (const DirectoryEntry &entry : RangedDirectoryIterator(mBundledHmslDir, true, "*",
                                                               File::findFiles)) {
        File source = entry.getFile();
        if (source.getFileName() == ".DS_Store") {
            continue;
        }
        String relPath = source.getRelativePathFrom(mBundledHmslDir).replaceCharacter('\\', '/');
        File destination = folder.getChildFile(relPath);
        String sourceHash = SHA256(source).toHexString();

        if (!destination.existsAsFile()) {
            destination.getParentDirectory().createDirectory();
            source.copyFileTo(destination);
            mManifest[relPath] = sourceHash;
        } else {
            String destHash = SHA256(destination).toHexString();
            if (destHash == sourceHash) {
                // Destination already matches the bundled file.
                mManifest[relPath] = sourceHash;
            } else {
                auto it = mManifest.find(relPath);
                if (!hadManifest || (it != mManifest.end() && it->second == destHash)) {
                    // Either there was no manifest file yet (upgrading from an older version
                    // without manifest support) or destination matches what HMSL previously
                    // installed (unmodified by user), so safely update it to the new bundled version.
                    source.copyFileTo(destination);
                    mManifest[relPath] = sourceHash;
                } else {
                    // Destination was modified by the user.
                    mPendingConflicts.push_back({source, destination, relPath, sourceHash});
                }
            }
        }
    }
    saveManifest(folder);
    mHmslDir = folder;
    setCurrentDirectory(mHmslDir);
    return true;
}

void HostFileManager::resolveConflicts(bool overwriteWithBackup) {
    if (overwriteWithBackup) {
        for (const FileConflict &conflict : mPendingConflicts) {
            File backup = conflict.destination.getSiblingFile(
                    conflict.destination.getFileName() + ".bak");
            conflict.destination.copyFileTo(backup);
            conflict.source.copyFileTo(conflict.destination);
            mManifest[conflict.relativePath] = conflict.sourceHash;
        }
        saveManifest(mHmslDir);
    }
    mPendingConflicts.clear();
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
