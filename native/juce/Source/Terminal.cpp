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
        double newMaximum = numLinesStored + 1.0; // +1 for current line, which is not stored
        mScrollBar.setRangeLimits(0.0, newMaximum);
        double newStart = newMaximum - mTerminalComponent.getNumLinesVisible();
        mScrollBar.setCurrentRange(newStart,
                                   mTerminalComponent.getNumLinesVisible());
        mScrollBar.scrollToBottom();
    }
}

// Called on the Forth thread.
int Terminal::putCharacter(char c) {
    int result = mTerminalModel.putCharacter(c);
    requestUpdate();
    return result;
}

// Called on the Forth thread. Schedule one update() on the UI thread.
void Terminal::requestUpdate() {
    if (!mUpdateRequested.exchange(true)) {
        juce::MessageManager::callAsync([this]() {
            this->update();
        });
    }
}

// Called on UI thread.
// Move the queued output into the stored lines, then scroll, then repaint.
// Doing these in order ensures that the last line is not hidden below the bottom.
void Terminal::update() {
    mUpdateRequested = false; // clear first so that new output requests another update
    mTerminalModel.processOutputQueue();
    adjustScrollBar();
    mTerminalComponent.repaint();
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
