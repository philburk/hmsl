/*
  ==============================================================================

    TerminalComponent.cpp
    Created: 18 May 2019 8:04:21am
    Author:  Phil Burk

  ==============================================================================
*/

#include "../JuceLibraryCode/JuceHeader.h"
#include "TerminalComponent.h"

TerminalComponent *TerminalComponent::sTerminalComponent = nullptr;

//==============================================================================
TerminalComponent::TerminalComponent()
: mInputQueue(1024)
, mOutputQueue(4 * 1024)
{
    sTerminalComponent = this;
    // In your constructor, you should add any child components, and
    // initialise any special settings that your component needs.

    setSize (800, 600);

    addKeyListener(this);
    setWantsKeyboardFocus(true);
    setFramesPerSecond(60);
}

TerminalComponent::~TerminalComponent()
{
    removeKeyListener(this);
}

void TerminalComponent::onKeyPressed(juce_wchar textCharacter) {
    mInputQueue.write((char)textCharacter);
}

void TerminalComponent::displayCharacter(char c) {
    if (c == '\r' || c == '\n') {
        if (mPreviousLines.size() >= kMaxLinesStored) {
            mPreviousLines.pop_front();
        }
        mPreviousLines.push_back(mLine);
        mLine = String();
    } else if (c == kBackspaceChar || c == kDeleteChar) {
        mLine = mLine.dropLastCharacters(1);
    } else {
        mLine += c;
    }
}

void TerminalComponent::requestClose() {
    mCloseRequested = true;
    usleep(500 * 1000); // TODO handshake
}

void TerminalComponent::update() {
    int maxCharacters = 1000;
    while (!mOutputQueue.empty() && maxCharacters-- > 0) {
        char c = mOutputQueue.read();
        mOutputQueue.advanceRead();
        displayCharacter(c);
    }
}

void TerminalComponent::paint (Graphics& g)
{
    /* This demo code just fills the component's background and
       draws some placeholder text to get you started.

       You should replace everything in this method with your own
       drawing code..
    */

    g.fillAll (getLookAndFeel().findColour (ResizableWindow::backgroundColourId));   // clear the background

    g.setColour (Colours::grey);
    g.drawRect (getLocalBounds(), 1);   // draw an outline around the component
    g.setColour (Colours::white);

    g.setFont({Font::getDefaultMonospacedFontName(), 14.0f, Font::plain});

    // Draw previous lines.
    const int currentLineY =getHeight() - kBottomMargin;
    int y = currentLineY - (kLineSpacing * (int)mPreviousLines.size());
    auto it = mPreviousLines.begin();
    while(it != mPreviousLines.end())
    {
        if (y > 0) {
            g.drawSingleLineText(*it, kLeftMargin, y);
        }
        y += kLineSpacing;
        it++;
    }

    // Draw current line.
    g.drawSingleLineText(mLine, kLeftMargin, currentLineY);

    // Draw cursor.
    int cursorX = kLeftMargin + g.getCurrentFont().getStringWidth(mLine);
    g.setColour(Colours::orange);
    int cursorHeight = (int) g.getCurrentFont().getHeight();
    int cursorWidth = 4;
    g.fillRect(cursorX, currentLineY - cursorHeight + 2, cursorWidth, cursorHeight);
}

void TerminalComponent::resized()
{
    // This method is where you should set the bounds of any child
    // components that your component contains..
}

int TerminalComponent::getCharacter() {
    if (mCloseRequested) {
        return kEndOfTransmissionChar;
    } else if (mInputQueue.empty()) {
        return -1;
    } else {
        int c = mInputQueue.read();
        mInputQueue.advanceRead();
        return c;
    }
}

int TerminalComponent::putCharacter(char c) {
    mOutputQueue.write(c);
    return 0;
}

bool TerminalComponent::isCharacterAvailable() {
    return !mInputQueue.empty() || mCloseRequested;
}

bool TerminalComponent::isOutputFull() {
    return mOutputQueue.full();
}

