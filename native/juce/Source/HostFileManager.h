/*
  ==============================================================================

    HostFileManager.h
    Created: 26 May 2019 4:03:53pm
    Author:  Phil Burk

  ==============================================================================
*/

#pragma once

#include <memory>
#include <string>
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
     * Copy any missing files from the app bundle into it.
     * Only used by an installed app.
     * @return true if the folder can be used
     */
    bool setWorkFolder(const File &folder);

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

private:
    static std::unique_ptr<HostFileManager> mInstance;

    std::unique_ptr<File>  mCurrentDirectory;
    bool                   mInstalled = false;
    File                   mRepoDir;       // top of HMSL repository, if not installed
    File                   mBundledHmslDir; // HMSL source inside the app, if installed
    File                   mHmslDir;       // work folder
    std::string            mDictionaryPath;
};
