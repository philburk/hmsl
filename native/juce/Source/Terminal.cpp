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
    return mTerminalModel.getCharacter();
}

int Terminal::putCharacter(char c) {
    return mTerminalModel.putCharacter(c);
}

bool Terminal::isCharacterAvailable() {
    return mTerminalModel.isCharacterAvailable();
}

bool Terminal::isOutputFull() {
    return mTerminalModel.isOutputFull();
}
