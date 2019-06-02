/*
  ==============================================================================

    TerminalModel.cpp
    Created: 2 Jun 2019 9:46:20am
    Author:  Phil Burk

  ==============================================================================
*/

#include "../JuceLibraryCode/JuceHeader.h"
#include "TerminalModel.h"
#include "HostFileManager.h"

TerminalModel::TerminalModel()
: mInputQueue(1024)
, mOutputQueue(4 * 1024)
{
    // Show working directory.
    File appFile = File::getSpecialLocation(File::SpecialLocationType::currentApplicationFile);
    mPreviousLines.push_back(appFile.getFullPathName());
    mPreviousLines.push_back(HostFileManager::getInstance()->getCurrentDirectory().getFullPathName());
}

// Read chacter from queue and add them to the display model.
bool TerminalModel::processOutputQueue() {
    int maxCharacters = 1000;
    bool changed = false;
    while (!mOutputQueue.empty() && maxCharacters-- > 0) {
        char c = mOutputQueue.read();
        mOutputQueue.advanceRead();
        displayCharacter(c);
        changed = true;
    }
    return changed;
}

void TerminalModel::sendCharacter(char c) {
    mInputQueue.write(c);
}

void TerminalModel::sendEscapeBracket() {
    sendCharacter(kEscapeChar);
    sendCharacter('[');
}

bool TerminalModel::onKeyPressed(const KeyPress &key) {
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
bool TerminalModel::handleEscapeSequence(char c) {
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

void TerminalModel::displayCharacter(char c) {
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

int TerminalModel::getCharacter() {
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

int TerminalModel::putCharacter(char c) {
    mOutputQueue.write(c);
    return 0;
}

bool TerminalModel::isCharacterAvailable() {
    return !mInputQueue.empty() || mCloseRequested;
}

bool TerminalModel::isOutputFull() {
    return mOutputQueue.full();
}

void TerminalModel::requestClose() {
    mCloseRequested = true;
}
