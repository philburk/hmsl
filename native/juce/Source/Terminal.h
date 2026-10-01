/*
  ==============================================================================

    Terminal.h
    Created: 2 Jun 2019 9:46:08am
    Author:  Phil Burk

  ==============================================================================
*/

#pragma once

#include <atomic>
#include <list>
#include "../JuceLibraryCode/JuceHeader.h"
#include "TerminalModel.h"
#include "TerminalComponent.h"

/**
 * A console terminal with a scrolling display.
 */
class Terminal : public Component, ScrollBar::Listener
{
public:
    Terminal()
    : mTerminalComponent(mTerminalModel)
    , mScrollBar(true)
    {
        sTerminal = this;
        addAndMakeVisible(mTerminalComponent);
        addAndMakeVisible(mScrollBar);
        mScrollBar.addListener(this);
        mScrollBar.setAutoHide(false);
        mScrollBar.setRangeLimits(0.0, 200.0); // TODO

        setSize(1024, 640); // window size in pixels
    }
    virtual ~Terminal() = default;

    // These are used for Forth character IO.
    int getCharacter();
    int putCharacter(char c);
    bool isCharacterAvailable();
    bool isOutputFull();

    void requestClose() {
        mTerminalModel.requestClose();
    }

    /**
     * Send text to Forth as if it was typed on the keyboard.
     */
    void typeText(const String &text) {
        for (int i = 0; i < text.length(); i++) {
            mTerminalModel.sendCharacter((char) text[i]);
        }
    }

    void scrollBarMoved (ScrollBar* scrollBarThatHasMoved,
                         double newRangeStart) override;

    void resized() override;

    void paint (Graphics&) override {}

    static Terminal *getInstance() {
        return sTerminal;
    }

private:

    void requestUpdate();
    void update();
    void adjustScrollBar();
    void showBottom();

    TerminalModel       mTerminalModel;
    TerminalComponent   mTerminalComponent;
    ScrollBar           mScrollBar;

    int32_t             mNumLinesVisible = 0;
    int32_t             mNumLinesStored = 0;
    std::atomic<bool>   mUpdateRequested{false};

    static Terminal    *sTerminal; // singleton

    JUCE_DECLARE_NON_COPYABLE_WITH_LEAK_DETECTOR (Terminal)
};

