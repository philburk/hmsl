/*
  ==============================================================================

    Terminal.cpp
    Created: 2 Jun 2019 9:46:08am
    Author:  Phil Burk

  ==============================================================================
*/

#include "Terminal.h"

Terminal *Terminal::sTerminal = nullptr;

int Terminal::getCharacter() {
    int result = mTerminalModel.getCharacter();
    if (result >= 0) {
        juce::MessageManager::callAsync([this]() {
            this->showBottom();
        });
    }
    return result;
}

// Called on UI thread.
void Terminal::showBottom() {
    if ((mNumLinesStored + 1) > mTerminalComponent.getNumLinesVisible()) {
        mScrollBar.scrollToBottom();
    }
}

// Called on UI thread.
void Terminal::adjustScrollBar() {
    int32_t numLinesStored = mTerminalModel.getNumLinesStored();
    if (numLinesStored != mNumLinesStored) {
        mNumLinesStored = numLinesStored;
        // TODO Why do we need to +2 to avoid having the current line hidden?
        double newMaximum = numLinesStored + 2.0; // +1 for current line, which is not stored
        mScrollBar.setRangeLimits(0.0, newMaximum);
        double newStart = newMaximum - mTerminalComponent.getNumLinesVisible();
        mScrollBar.setCurrentRange(newStart,
                                   mTerminalComponent.getNumLinesVisible());
        mScrollBar.scrollToBottom();
    }
}

int Terminal::putCharacter(char c) {
    int result = mTerminalModel.putCharacter(c);
    // The characters are put in a queue and read later.
    // So there is a race condition that can cause lines to be written below
    // the bottom of the terminal.
    // We check c == EOL to detect line advance.
    int32_t numLinesStored = mTerminalModel.getNumLinesStored();
    if (c == '\n' || numLinesStored != mNumLinesStored) {
        juce::MessageManager::callAsync([this]() {
            this->adjustScrollBar();
            this->mTerminalComponent.requestRepaint();
        });
    } else {
        this->mTerminalComponent.requestRepaint();
    }
    return result;
}

bool Terminal::isCharacterAvailable() {
    return mTerminalModel.isCharacterAvailable();
}

bool Terminal::isOutputFull() {
    return mTerminalModel.isOutputFull();
}

void Terminal::scrollBarMoved(ScrollBar* scrollBarThatHasMoved,
                     double newRangeStart) {
    int topLine = (int) newRangeStart;
    if (topLine != mTerminalComponent.getTopLine()) {
        mTerminalComponent.setTopLine((int)newRangeStart);
        mTerminalComponent.requestRepaint();
    }
}

void Terminal::resized() {
    int oldNumLinesVisible = mNumLinesVisible;
    int oldTopLine = mTerminalComponent.getTopLine();
    auto area = getLocalBounds();
    auto scrollBarWidth = 16;
    auto textComponentWidth = getWidth() - scrollBarWidth;
    mTerminalComponent.setBounds(area.removeFromLeft(textComponentWidth));
    mScrollBar.setBounds(area.removeFromRight(scrollBarWidth));
    int numLinesVisible = mTerminalComponent.getNumLinesVisible();
    int topLine = oldTopLine + numLinesVisible - oldNumLinesVisible;
    mScrollBar.setCurrentRange(topLine, numLinesVisible);
}
