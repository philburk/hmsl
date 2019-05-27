/*
  ==============================================================================

    HostFileManager.h
    Created: 26 May 2019 4:03:53pm
    Author:  Phil Burk

  ==============================================================================
*/

#pragma once

#include <memory>
#include "stdio.h"

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
     * @return current dictionary file, typically "{path}/pforth.dic".
     */
    const char *getDictionaryFileName();

    FILE *openFile( const char *fileName, const char *mode );

private:
    static std::unique_ptr<HostFileManager> mInstance;
    
    std::unique_ptr<File>  mCurrentDirectory;
    File                   mAppDir;
    File                   mHMSLDir;
};
