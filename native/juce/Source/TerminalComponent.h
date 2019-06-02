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
class TerminalComponent    : public AnimatedAppComponent, KeyListener
{
public:
    explicit TerminalComponent(TerminalModel &model, Viewport &viewport);
    ~TerminalComponent();
    
    void update() override;
    void paint (Graphics&) override;
    void resized() override;
    bool keyPressed (const KeyPress &key, Component *originatingComponent) override;

private:
    static constexpr  int  kLineSpacing = 16;
    static constexpr  int  kLeftMargin = 5;
    static constexpr  int  kBottomMargin = 30;
    static constexpr  int  kWidthMin = 200;
    static constexpr  int  kHeightMin = 100;

    int32_t                mWidestLine = kWidthMin;
    TerminalModel         &mTerminalModel;
    Viewport              &mScrollingViewport;
    Colour                 mCursorColour;

    JUCE_DECLARE_NON_COPYABLE_WITH_LEAK_DETECTOR (TerminalComponent)
};
