/*
  ==============================================================================

    TerminalModel.h
    Created: 2 Jun 2019 9:46:20am
    Author:  Phil Burk

  ==============================================================================
*/

#pragma once

#include <list>

#include "../JuceLibraryCode/JuceHeader.h"
#include "AtomicQueue.h"

/**
 * Model for a console terminal.
 * Contains buffer of previous lines.
 * Support ANSI sequences needed for command line history.
 */
class TerminalModel {
public:
    TerminalModel();

    void processOutputQueue(int maxChars = kOutputQueueSize);

    bool onKeyPressed (const KeyPress &key);

    // These are used for Forth character IO.
    int getCharacter();
    int putCharacter(char c);
    bool isCharacterAvailable();
    bool isOutputFull();

    int32_t getLineCursor() {
        return mLineCursor;
    }

    void requestClose();

    String &getCurrentLine() {
        return mLine;
    }

    std::list<String> &getStoredLines() {
        return mStoredLines;
    }

    int32_t getNumLinesStored() const {
        return (int32_t)mStoredLines.size();
    }

private:
    void displayCharacter(char c);
    void sendEscapeBracket();
    void sendCharacter(char c); // to application
    // return true if handled
    bool handleEscapeSequence(char c);

    static constexpr  int  kMaxLinesStored = 1024;
    static constexpr  char kEndOfLineChar = '\r';
    static constexpr  char kEndOfTransmissionChar = 0x04;
    static constexpr  char kBackspaceChar = 0x08;
    static constexpr  char kDeleteChar = 0x7F;
    static constexpr  char kEscapeChar = 0x1B;
    static constexpr  char kLeftBracketChar = '[';

    // ANSI ESC[ codes
    static constexpr  char kUpArrowCode = 0x41;
    static constexpr  char kDownArrowCode = 0x42;
    static constexpr  char kRightArrowCode = 0x43;
    static constexpr  char kLeftArrowCode = 0x44;

    static constexpr  int  kOutputQueueSize = 512;
    static constexpr  int  kInputQueueSize = 1024;

    std::list<String>      mStoredLines;

    int32_t                mAnsiCount = 0;
    int32_t                mLineCursor = 0;
    String                 mLine; // current line

    bool                   mCloseRequested = false;

    enum AnsiState {
        ANSI_STATE_IDLE,
        ANSI_STATE_GOT_ESCAPE,
        ANSI_STATE_GOT_BRACKET,
    };
    AnsiState              mAnsiState = ANSI_STATE_IDLE;

    AtomicQueue<char>      mInputQueue; // hold for app to read
    AtomicQueue<char>      mOutputQueue; // hold for display

};
