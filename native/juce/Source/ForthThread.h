/*
  ==============================================================================

    ForthThread.h
    Created: 14 May 2019 8:51:30pm
    Author:  Phil Burk

  ==============================================================================
*/

#pragma once

#include "../JuceLibraryCode/JuceHeader.h"
#include "MainComponent.h"

class ForthThread : public Thread {
public:
    /**
     * @param buildDictionary if true then compile pForth and HMSL from source,
     *        save "hmsl/pforth.dic", then quit the app.
     */
    ForthThread(bool buildDictionary = false)
        : Thread("Forth")
        , mBuildDictionary(buildDictionary) {}
    virtual ~ForthThread() = default;

    void run() override;

private:
    /**
     * Compile pForth from "pforth/fth/system.fth", then compile HMSL
     * on top of that using "hmsl/fth/make_hmsl.fth".
     * @return 0 on success
     */
    int buildDictionary();

    bool mBuildDictionary;
};
