/*
  ==============================================================================

    pf_juce_io.cpp
    Created: 19 May 2019 4:50:20pm
    Author:  Phil Burk

  ==============================================================================
*/

#include "pf_juce_io.h"
#include "TerminalComponent.h"

int  sdTerminalOut(char c)
{
    while (TerminalComponent::getInstance()->isOutputFull()) {
        usleep(15 * 1000); // block until we have room to write
        // TODO While in here we may also handle event queues and abort signals.
    }
    return TerminalComponent::getInstance()->putCharacter(c);
}

int  sdTerminalEcho(char c)
{
    return sdTerminalOut(c);
}

int  sdTerminalIn()
{
    while (!TerminalComponent::getInstance()->isCharacterAvailable()) {
        usleep(15 * 1000); // block until we get a character
        // TODO While in here we may also handle event queues and abort signals.
    }
    return TerminalComponent::getInstance()->getCharacter();
}

int  sdTerminalFlush()
{
    return 0;
}

int sdQueryTerminal()
{
    return TerminalComponent::getInstance()->isCharacterAvailable();
}

void sdTerminalInit()
{
}

void sdTerminalTerm()
{
}
