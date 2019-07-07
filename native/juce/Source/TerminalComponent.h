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
#include "TerminalModel.h"
#include "TerminalComponent.h"

//==============================================================================
/*
*/
class TerminalComponent    : public Component, KeyListener
{
public:
    explicit TerminalComponent(TerminalModel &model);
    ~TerminalComponent();

    /**
     * Request a single repaint.
     * Uses an atomic bool that is cleared by paint();
     */
    void requestRepaint();
    void paint (Graphics&) override;

    bool keyPressed (const KeyPress &key, Component *originatingComponent) override;

    void setTopLine(int32_t topLine) {
        mTopLine = topLine;
    }

    int32_t getTopLine() {
        return mTopLine;
    }

    int32_t getNumLinesVisible() {
        int32_t linesAvailable = (getHeight() - kBottomMargin) / kLineSpacing;
        return std::min(linesAvailable, mTerminalModel.getNumLinesStored() + 1);
    }

private:

    static constexpr  int  kMaxLinesVisible = 200; // allow scrolling
    static constexpr  int  kLineSpacing = 16;
    static constexpr  int  kLeftMargin = 5;
    static constexpr  int  kBottomMargin = 20;
    static constexpr  int  kWidthMin = 200;
    static constexpr  int  kHeightMin = 100;

    int32_t                mWidestLine = kWidthMin;
    TerminalModel         &mTerminalModel;
    Colour                 mCursorColour;
    int32_t                mTopLine = 0;

    int32_t                mNumPaints = 0;
    int32_t                mNumRepaintsRequested = 0;

    std::atomic<bool>      mRepaintRequested{false};

    JUCE_DECLARE_NON_COPYABLE_WITH_LEAK_DETECTOR (TerminalComponent)
};
