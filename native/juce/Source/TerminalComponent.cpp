/*
  ==============================================================================

    TerminalComponent.cpp
    Created: 18 May 2019 8:04:21am
    Author:  Phil Burk

  ==============================================================================
*/

#include "../JuceLibraryCode/JuceHeader.h"
#include "TerminalComponent.h"

TerminalComponent::TerminalComponent(TerminalModel &model)
    : mTerminalModel(model)
    , mCursorColour(0xffC08020) {
    setSize(400, 100);

    addKeyListener(this);
    setWantsKeyboardFocus(true);
}

TerminalComponent::~TerminalComponent() {
    removeKeyListener(this);
}

bool TerminalComponent::keyPressed (const KeyPress &key,
                                Component *originatingComponent) {
    return mTerminalModel.onKeyPressed(key);
}

void TerminalComponent::paint (Graphics& g)
{
    mRepaintRequested = false;
    mNumPaints++;

    mTerminalModel.processOutputQueue();

    g.fillAll (getLookAndFeel().findColour (ResizableWindow::backgroundColourId));   // clear the background
    g.setFont({Font::getDefaultMonospacedFontName(), 14.0f, Font::plain});

    std::list<String> &storedLines = mTerminalModel.getStoredLines();
    const int numLines = (int) storedLines.size();
    int y = getHeight() - (getNumLinesVisible() * kLineSpacing);
    int yLimit = getHeight() + kLineSpacing;
    if ( numLines > 0) {
        // Draw previous lines starting with mTopLine
        g.setColour (Colours::white);
        int maxWidth = kWidthMin;
        int32_t lineCounter = 0;
        auto it = storedLines.begin();
        while(it != storedLines.end() && y < yLimit) {
            if (lineCounter >= mTopLine) {
                g.drawSingleLineText(*it, kLeftMargin, y);
                maxWidth = std::max(maxWidth, (int) g.getCurrentFont().getStringWidth(*it));
                y += kLineSpacing;
            }
            lineCounter++;
            it++;
        }
        mWidestLine = kLeftMargin + maxWidth;
    }

    if (y < yLimit) {
        // Draw cursor under the current line.
        int32_t cursor = mTerminalModel.getLineCursor();
        String &line = mTerminalModel.getCurrentLine();
        const int cursorX = kLeftMargin
                + g.getCurrentFont().getStringWidth(line.substring(0, cursor)) - 1;
        g.setColour(mCursorColour);
        const int cursorHeight = (int) g.getCurrentFont().getHeight();
        const int cursorWidth = (int) g.getCurrentFont().getStringWidth(String(" "));
        g.fillRect(cursorX, y - cursorHeight + 2, cursorWidth, cursorHeight);

        // Draw current line.
        g.setColour (Colours::white);
        g.drawSingleLineText(line, kLeftMargin, y);
    }
/*
    // Display debug info
    String info = "stored = ";
    info += numLines;
    info += ", top = ";
    info += mTopLine;
    info += ", #rq = ";
    info += mNumRepaintsRequested;
    info += ", #pt = ";
    info += mNumPaints;
    g.setColour (Colours::yellow);
    const int leftX = getWidth() - (int)g.getCurrentFont().getStringWidth(info);
    g.drawSingleLineText(info, leftX, kLineSpacing);
 */
}

void TerminalComponent::requestRepaint() {
    if (!mRepaintRequested.exchange(true)) {
        juce::MessageManager::callAsync([this]() {
            mNumRepaintsRequested++;
            this->repaint();
        });
    }
}
