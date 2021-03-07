/*
  ==============================================================================

    MidiBase.cpp
    Created: 2 Nov 2019 4:08:20pm
    Author:  Phil Burk

  ==============================================================================
*/

#include "MidiBase.h"

cell_t MidiBase::init() {
    mHmslTicksPerSecond = kDefaultTicksPerSecond;
    setTime(0);
    cell_t result1 = mLocalMidiPort.init();
    cell_t result2 = mExternalMidiPort.init();
    return result1 ? result1 : result2;
}

void MidiBase::term() {
    mLocalMidiPort.term();
    mExternalMidiPort.term();
}

// @return error code (0 for no error)
cell_t MidiBase::write(ucell_ptr_t data, cell_t count, cell_t ticks) {
    cell_t nativeTicks = ticksToNative(ticks);
    return getCurrentPort()->write(data, count, nativeTicks);
}
