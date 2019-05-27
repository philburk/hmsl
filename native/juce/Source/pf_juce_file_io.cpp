/*
  ==============================================================================

    pf_juce_file_io.cpp
    Created: 26 May 2019 7:48:28am
    Author:  Phil Burk

  ==============================================================================
*/

#include "pf_all.h"

#include "../JuceLibraryCode/JuceHeader.h"
#include "HostFileManager.h"

FileStream *sdOpenFile( const char *fileName, const char *mode ) {
    return HostFileManager::getInstance()->openFile(fileName, mode);
}
