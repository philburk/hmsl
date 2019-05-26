/*
  ==============================================================================

    TerminalComponent.h
    Created: 18 May 2019 8:04:21am
    Author:  Phil Burk

  ==============================================================================
*/

#pragma once

#include <list>
#include "../JuceLibraryCode/JuceHeader.h"
#include "AtomicQueue.h"

//==============================================================================
/*
*/
class TerminalComponent    : public AnimatedAppComponent, KeyListener
{
public:
    TerminalComponent();
    ~TerminalComponent();
    
    void update() override;
    void paint (Graphics&) override;
    void resized() override;

    bool keyPressed (const KeyPress &key, Component *originatingComponent) override;

    // These are used for Forth character IO.
    int getCharacter();
    int putCharacter(char c);
    bool isCharacterAvailable();
    bool isOutputFull();

    static TerminalComponent *getInstance() {
        return sTerminalComponent;
    }

    void requestClose();

private:

    void displayCharacter(char c);
    void sendEscapeBracket();
    void sendCharacter(char c); // to application
    // return true if handled
    bool handleEscapeSequence(char c);

    
    static TerminalComponent    *sTerminalComponent;

    static constexpr  int  kLineSpacing = 16;
    static constexpr  int  kMaxLinesStored = 200; // allow scrolling
    static constexpr  int  kLeftMargin = 5;
    static constexpr  int  kBottomMargin = 30;
    static constexpr  char kEndOfLineChar = '\r';
    static constexpr  char kEndOfTransmissionChar = 0x04;
    static constexpr  char kBackspaceChar = 0x08;
    static constexpr  char kDeleteChar = 0x7F;
    static constexpr  char kEscapeChar = 0x1B;

    static constexpr  char kUpArrowCode = 0x41;
    static constexpr  char kDownArrowCode = 0x42;
    static constexpr  char kRightArrowCode = 0x43;
    static constexpr  char kLeftArrowCode = 0x44;

    int32_t               mAnsiCount = 0;
    int32_t               mLineCursor = 0;

    enum AnsiState {
        ANSI_STATE_IDLE,
        ANSI_STATE_GOT_ESCAPE,
        ANSI_STATE_GOT_BRACKET,
    };
    AnsiState             mAnsiState = ANSI_STATE_IDLE;

    AtomicQueue<char>     mInputQueue;
    AtomicQueue<char>     mOutputQueue;
    bool                  mCloseRequested = false;

    String                mLine;
    std::list<String>     mPreviousLines;

    JUCE_DECLARE_NON_COPYABLE_WITH_LEAK_DETECTOR (TerminalComponent)
};
