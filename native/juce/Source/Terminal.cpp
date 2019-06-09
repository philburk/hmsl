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
        mScrollBar.setRangeLimits(0.0, numLinesStored + 1);
        mScrollBar.setCurrentRange(mScrollBar.getCurrentRangeStart(),
                                   mTerminalComponent.getNumLinesVisible());
        mNumLinesStored = numLinesStored;
        mScrollBar.scrollToBottom();
    }
}

int Terminal::putCharacter(char c) {
    int result = mTerminalModel.putCharacter(c);
    int32_t numLinesStored = mTerminalModel.getNumLinesStored();
    if (numLinesStored != mNumLinesStored) {
        juce::MessageManager::callAsync([this]() {
            this->adjustScrollBar();
        });
    }
    this->mTerminalComponent.requestRepaint();
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
    auto area = getLocalBounds();
    auto scrollBarWidth = 16;
    auto textComponentWidth = getWidth() - scrollBarWidth;
    mTerminalComponent.setBounds(area.removeFromLeft(textComponentWidth));
    mScrollBar.setBounds(area.removeFromRight(scrollBarWidth));
    mScrollBar.setCurrentRange(mScrollBar.getCurrentRangeStart(),
                               mTerminalComponent.getNumLinesVisible());
}
