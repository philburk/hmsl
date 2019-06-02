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

    bool processOutputQueue();

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

    std::list<String>     mPreviousLines;

private:
    void displayCharacter(char c);
    void sendEscapeBracket();
    void sendCharacter(char c); // to application
    // return true if handled
    bool handleEscapeSequence(char c);

    static constexpr  int  kMaxLinesStored = 500; // allow scrolling
    static constexpr  char kEndOfLineChar = '\r';
    static constexpr  char kEndOfTransmissionChar = 0x04;
    static constexpr  char kBackspaceChar = 0x08;
    static constexpr  char kDeleteChar = 0x7F;
    static constexpr  char kEscapeChar = 0x1B;

    static constexpr  char kUpArrowCode = 0x41;
    static constexpr  char kDownArrowCode = 0x42;
    static constexpr  char kRightArrowCode = 0x43;
    static constexpr  char kLeftArrowCode = 0x44;

    int32_t                mAnsiCount = 0;
    int32_t                mLineCursor = 0;

    bool                   mCloseRequested = false;

    enum AnsiState {
        ANSI_STATE_IDLE,
        ANSI_STATE_GOT_ESCAPE,
        ANSI_STATE_GOT_BRACKET,
    };
    AnsiState              mAnsiState = ANSI_STATE_IDLE;

    AtomicQueue<char>      mInputQueue;
    AtomicQueue<char>      mOutputQueue;

    String                 mLine;
};
