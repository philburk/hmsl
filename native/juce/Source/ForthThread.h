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
    ForthThread() : Thread("Forth") {}
    virtual ~ForthThread() = default;
    
    void run() override;

private:
};
