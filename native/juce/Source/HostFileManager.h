/*
  ==============================================================================

    HostFileManager.h
    Created: 26 May 2019 4:03:53pm
    Author:  Phil Burk

  ==============================================================================
*/

#pragma once

#include <map>
#include <memory>
#include <string>
#include <vector>
#include "stdio.h"

/**
 * Finds the HMSL files.
 *
 * An installed app has the dictionary and a copy of the HMSL source in its
 * Resources folder. The source is copied to a work folder chosen by the user,
 * eg. ~/Documents/HMSL, which becomes the current directory for Forth.
 *
 * An app built in the HMSL repository has no bundled dictionary. It uses
 * the "hmsl" folder in the repository as its work folder.
 */
class HostFileManager {
public:
    struct FileConflict {
        File source;
        File destination;
        String relativePath;
        String sourceHash;
    };

    static HostFileManager *getInstance() {
        if (mInstance == nullptr) {
            mInstance.reset(new HostFileManager());
        }
        return mInstance.get();
    }

    HostFileManager();

    /**
     * @return true if the dictionary and HMSL source are bundled inside the app
     */
    bool isInstalled() const { return mInstalled; }

    /**
     * Set the folder that contains the user's copy of the HMSL source.
     * Copy any missing or unmodified updated files from the app bundle into it,
     * and record any user-modified conflicts in getPendingConflicts().
     * Only used by an installed app.
     * @return true if the folder can be used
     */
    bool setWorkFolder(const File &folder);

    /**
     * @return files in the work folder that differ from the app bundle and
     *         appear to have been modified by the user.
     */
    const std::vector<FileConflict> &getPendingConflicts() const {
        return mPendingConflicts;
    }

    /**
     * Resolve conflicts found by setWorkFolder().
     * @param overwriteWithBackup if true, backs up each destination file to .bak
     *                            and overwrites it with the bundled version.
     */
    void resolveConflicts(bool overwriteWithBackup);

    /**
     * Set default directory for relative file paths.
     */
    void setCurrentDirectory(const File &dir);

    /**
     * @return default directory for relative file paths.
     */
    File getCurrentDirectory();

    /**
     * @return directory that contains the PForth "fth" files.
     */
    File getPForthDirectory();

    /**
     * @return directory that contains HMSL source and the "fth/" folder.
     */
    File getHmslDirectory();

    /**
     * @return path to file for compiling pForth
     */
    const char *getSystemFileName();

    /**
     * @return full path of the HMSL dictionary, typically "{path}/pforth.dic".
     */
    const char *getDictionaryFileName();

    FILE *openFile( const char *fileName, const char *mode );

    /**
     * Settings that are saved between launches, eg. the work folder
     * and which MIDI inputs are on. Shared so that values are not overwritten.
     */
    PropertiesFile *getSettings();

private:
    bool loadManifest(const File &folder);
    void saveManifest(const File &folder) const;

    static std::unique_ptr<HostFileManager> mInstance;

    std::unique_ptr<File>     mCurrentDirectory;
    bool                      mInstalled = false;
    File                      mRepoDir;        // top of HMSL repository, if not installed
    File                      mBundledHmslDir; // HMSL source inside the app, if installed
    File                      mHmslDir;        // work folder
    std::string               mDictionaryPath;
    ApplicationProperties     mSettings;
    std::map<String, String>  mManifest;       // relativePath -> SHA256 hex of installed file
    std::vector<FileConflict> mPendingConflicts;
};
