/***************************************************************
 ** I/O subsystem for PForth based on 'C'
 **
 ** Author: Phil Burk
 ** Copyright 1994 3DO, Phil Burk, Larry Polansky, David Rosenboom
 **
 ** The pForth software code is dedicated to the public domain,
 ** and any third party may reproduce, distribute and modify
 ** the pForth software code or any derivative works thereof
 ** without any compensation or license.  The pForth software
 ** code is provided on an "as is" basis without any warranty
 ** of any kind, including, without limitation, the implied
 ** warranties of merchantability and fitness for a particular
 ** purpose and their equivalents under the laws of any jurisdiction.
 **
 ***************************************************************/

#include <unistd.h>

#include "pf_juce_io.h"
#include "Terminal.h"

int  sdTerminalOut(char c)
{
    while (Terminal::getInstance()->isOutputFull()) {
        usleep(15 * 1000); // block until we have room to write
        // TODO While in here we may also handle event queues and abort signals.
    }
    return Terminal::getInstance()->putCharacter(c);
}

int  sdTerminalEcho(char c)
{
    return sdTerminalOut(c);
}

int  sdTerminalIn()
{
    while (!Terminal::getInstance()->isCharacterAvailable()) {
        usleep(15 * 1000); // block until we get a character
        // TODO While in here we may also handle event queues and abort signals.
    }
    return Terminal::getInstance()->getCharacter();
}

int  sdTerminalFlush()
{
    return 0;
}

int sdQueryTerminal()
{
    return Terminal::getInstance()->isCharacterAvailable();
}

void sdTerminalInit()
{
}

void sdTerminalTerm()
{
}
