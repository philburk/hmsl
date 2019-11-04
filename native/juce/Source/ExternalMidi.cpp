/*
  ==============================================================================

    ExternalMidi.cpp
    Created: 2 Nov 2019 4:08:33pm
    Author:  Phil Burk

  ==============================================================================
*/

#include "ExternalMidi.h"


static std::unique_ptr<MidiOutput> sMidiOutput;

// ============== Clock Time ===================================


double ExternalMidi::getNativeTime() {
    return Time::getMillisecondCounterHiRes();
}

// ============== MIDI ===================================
// for callFunctionOnMessageThread()
static void *createNewMidiOutput(void *text) {
    // Save in a static unique_ptr.
    sMidiOutput = MidiOutput::createNewDevice(String((char *)text));
    return text;
}

// Called by HMSL upon initializing MIDI
//
// Returns error code (0 for no error)
cell_t ExternalMidi::init() {
    mHmslTicksPerSecond = kDefaultTicksPerSecond;
    setTime(0);

    MessageManager *messageManager = MessageManager::getInstance();
    messageManager->callFunctionOnMessageThread(createNewMidiOutput,
                                                (void *) kMidiName);
    // This will crash if another instance of HMSL is running.
    assert(sMidiOutput != nullptr);
    sMidiOutput->startBackgroundThread();
    return 0;
}

// Called by HMSL to terminate the MIDI connection
void ExternalMidi::term() {
    if (sMidiOutput) sMidiOutput->stopBackgroundThread();
    sMidiOutput.reset(nullptr);
}

// Called when HMSL wants to schedule a MIDI packet
//
// addr - Array of unsigned chars to write to MIDI (the data)
// count - the number of bytes in the addr array
// vtime - time in ticks to play the data
//
// Returns error code (0 for no error)
cell_t ExternalMidi::write(ucell_ptr_t data, cell_t count, cell_t ticks) {
    // Use the timestamp to schedule the MIDI events in the future.
    MidiBuffer midiBuffer(MidiMessage((const void *)data, (int)count));
    const double scheduledMillis = ticksToNative(ticks);
    const double nowMillis = Time::getMillisecondCounterHiRes();
    const double playTimeMillis = std::max(scheduledMillis, nowMillis);
    sMidiOutput->sendBlockOfMessages(midiBuffer, playTimeMillis, 44100 /* sample rate */);
    return 0;
}
