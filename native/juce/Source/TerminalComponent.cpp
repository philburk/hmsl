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

    // Show working directory.
    File defaultWDIR =
    File::getSpecialLocation(File::SpecialLocationType::currentApplicationFile).getParentDirectory();

    mPreviousLines.push_back(defaultWDIR.getFullPathName());
}

TerminalComponent::~TerminalComponent()
{
    removeKeyListener(this);
}

void TerminalComponent::sendCharacter(char c) {
    mInputQueue.write(c);
}

void TerminalComponent::sendEscapeBracket() {
    sendCharacter(kEscapeChar);
    sendCharacter('[');
}

bool TerminalComponent::keyPressed (const KeyPress &key,
                                    Component *originatingComponent) {
    if (key == KeyPress::upKey) {
        sendEscapeBracket();
        sendCharacter(kUpArrowCode);
    } else if (key == KeyPress::downKey) {
        sendEscapeBracket();
        sendCharacter(kDownArrowCode);
    } else if (key == KeyPress::rightKey) {
        sendEscapeBracket();
        sendCharacter(kRightArrowCode);
    } else if (key == KeyPress::leftKey) {
        sendEscapeBracket();
        sendCharacter(kLeftArrowCode);
    } else {
        sendCharacter((char)key.getTextCharacter());
    }
    return true;
}

// State machine for handling ANSI escape sequences for cursor movement, etc.
bool TerminalComponent::handleEscapeSequence(char c) {
    bool result = true;
    switch(mAnsiState) {
        case ANSI_STATE_IDLE:
            if (c == kEscapeChar) {
                mAnsiState = ANSI_STATE_GOT_ESCAPE;
                mAnsiCount = 0;
            } else {
                result = false;
            }
            break;
        case ANSI_STATE_GOT_ESCAPE:
            if (c == '[') {
                mAnsiState = ANSI_STATE_GOT_BRACKET;
            } else {
                result = false;
                mAnsiState = ANSI_STATE_IDLE;
            }
            break;
        case ANSI_STATE_GOT_BRACKET:
            if (isdigit(c)) {
                // accumulate number
                mAnsiCount *= 10;
                mAnsiCount += c - '0';
            } else if (c == 'D') {
                // move left
                mLineCursor = std::max(0, mLineCursor - mAnsiCount);
                mAnsiState = ANSI_STATE_IDLE;
            } else if (c == 'C') {
                // move right
                mLineCursor = std::min(mLine.length(), mLineCursor + mAnsiCount);
                mAnsiState = ANSI_STATE_IDLE;
            } else if (c == 'K') {
                // erase to end if line
                mLine = mLine.dropLastCharacters(mLine.length() - mLineCursor);
                mAnsiState = ANSI_STATE_IDLE;
            } else if (c == 'J' && mAnsiCount == 2) {
                // erase screen
                mPreviousLines.clear();
                mLine = String();
                mAnsiState = ANSI_STATE_IDLE;
            }
            break;
    }
    return result;
}

void TerminalComponent::displayCharacter(char c) {
    if (handleEscapeSequence(c)) {
        return;
    }

    if (c == '\r') {
        mLineCursor = 0;
    } else if (c == '\n') {
        if (mPreviousLines.size() >= kMaxLinesStored) {
            mPreviousLines.pop_front();
        }
        mPreviousLines.push_back(mLine);
        mLine = String();
        mLineCursor = 0;
    } else if (c == kBackspaceChar || c == kDeleteChar) {
        mLine = mLine.dropLastCharacters(1);
        mLineCursor--;
    } else if (mLineCursor == mLine.length()) {
        mLine += c;
        mLineCursor++;
    } else {
        // insert c in middle of mLine
        String s = mLine.substring(0, mLineCursor);
        s += c;
        s += mLine.substring(mLineCursor);
        mLine = s;
        mLineCursor++;
    }
}

void TerminalComponent::requestClose() {
    mCloseRequested = true;
    usleep(50 * 1000); // wait for Forth to get the message
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
    const int cursorX = kLeftMargin
            + g.getCurrentFont().getStringWidth(mLine.substring(0, mLineCursor)) - 1;
    g.setColour(Colours::orange);
    const int cursorHeight = (int) g.getCurrentFont().getHeight();
    const int cursorWidth = 1;
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

