/*
  ==============================================================================

    TerminalComponent.h
    Created: 18 May 2019 8:04:21am
    Author:  Phil Burk

  ==============================================================================
*/

#pragma once

#include <list>
#include "../JuceLibraryCode/JuceHeader.h"
#include "AtomicQueue.h"

//==============================================================================
/*
*/
class TerminalComponent    : public AnimatedAppComponent, KeyListener
{
public:
    TerminalComponent();
    ~TerminalComponent();
    
    void update() override;
    void paint (Graphics&) override;
    void resized() override;

    bool keyPressed (const KeyPress &key, Component *originatingComponent) override {
        onKeyPressed(key.getTextCharacter());
        return true; // true if consumed
    }

    // These are used for Forth character IO.
    int getCharacter();
    int putCharacter(char c);
    bool isCharacterAvailable();
    bool isOutputFull();

    static TerminalComponent *getInstance() {
        return sTerminalComponent;
    }

    void requestClose();

private:

    void displayCharacter(char c);

    void onKeyPressed(juce_wchar keyCode);

    
    static TerminalComponent    *sTerminalComponent;

    static constexpr  int  kLineSpacing = 16;
    static constexpr  int  kMaxLinesStored = 200; // allow scrolling
    static constexpr  int  kLeftMargin = 5;
    static constexpr  int  kBottomMargin = 30;
    static constexpr  char kEndOfLineChar = '\r';
    static constexpr  char kEndOfTransmissionChar = 0x04;
    static constexpr  char kBackspaceChar = 0x08;
    static constexpr  char kDeleteChar = 0x7F;


    AtomicQueue<char>     mInputQueue;
    AtomicQueue<char>     mOutputQueue;
    bool                  mCloseRequested = false;

    String                mLine;
    std::list<String>     mPreviousLines;

    JUCE_DECLARE_NON_COPYABLE_WITH_LEAK_DETECTOR (TerminalComponent)
};
