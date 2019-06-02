/*
  ==============================================================================

    Terminal.h
    Created: 2 Jun 2019 9:46:08am
    Author:  Phil Burk

  ==============================================================================
*/

#pragma once

#include <list>
#include "../JuceLibraryCode/JuceHeader.h"
#include "TerminalModel.h"
#include "TerminalComponent.h"

/**
 * A console terminal with a scrolling display.
 */
class Terminal
{
public:
    Terminal()
    : mTerminalComponent(mTerminalModel, mScrollingViewport) {
        sTerminal = this;
        mScrollingViewport.setSize (800, 600);
        mScrollingViewport.setViewedComponent(&mTerminalComponent, false);
    }

    // These are used for Forth character IO.
    int getCharacter();
    int putCharacter(char c);
    bool isCharacterAvailable();
    bool isOutputFull();

    void requestClose() {
        mTerminalModel.requestClose();
    }

    /**
     * @return component to display
     */
    Component  *getComponent() {
        return &mScrollingViewport;
    }

    static Terminal *getInstance() {
        return sTerminal;
    }

    // Allow user to type into Terminal when the Scrollbar has the focus.
    class KeyPassingViewport : public Viewport {
    public:
        bool keyPressed (const KeyPress &key) override {
            return ((TerminalComponent*)getViewedComponent())
            ->keyPressed(key, getViewedComponent());
        }
    };

private:
    TerminalModel       mTerminalModel;
    TerminalComponent   mTerminalComponent;
    KeyPassingViewport  mScrollingViewport;

    static Terminal    *sTerminal;
};

