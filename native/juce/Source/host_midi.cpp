//
//  hmsl_midi.m
//  HMSL-OSX
//
//  Contributors:
//     1997 Robert Marsanyi
//     2015 Andrew C Smith
//     2019 Phil Burk
//

#include <unistd.h>

#include "../JuceLibraryCode/JuceHeader.h"

#import "hmsl_host.h"
#import "pf_all.h"

constexpr int kDefaultTicksPerSecond = 60; // original tick rate, rtc.rate@
constexpr int kMillisPerSecond = 1000;
constexpr const char *kMidiName = "HMSL"; // name for external MIDI ports

static double sHmslStartTime = 0;
static cell_t sHmslTickOffset = 0;
static cell_t sHmslTicksPerSecond = kDefaultTicksPerSecond;

static MidiOutput *sMidiOutput = nullptr;

// ============== Clock Time ===================================
void hostClock_Init() {
    sHmslTicksPerSecond = kDefaultTicksPerSecond;
    hostClock_SetTime(0);
}

void hostClock_Term() {
}

//  Convert from milliseconds to HMSL clock ticks
static cell_t hostClock_MillisToTicks( double millis ) {
    cell_t elapsed = (cell_t) (sHmslTicksPerSecond * (millis - sHmslStartTime)
                               / kMillisPerSecond);
    return elapsed + sHmslTickOffset;
}

static double hostClock_TicksToMillis( cell_t ticks ) {
    cell_t elapsedTicks = ticks - sHmslTickOffset;
    double elapsedHighResTicks = (elapsedTicks * kMillisPerSecond) / sHmslTicksPerSecond;
    return elapsedHighResTicks + sHmslStartTime;
}

cell_t hostClock_QueryTime() {
    return hostClock_MillisToTicks(Time::getMillisecondCounterHiRes());
}

void hostClock_SetTime( cell_t time ) {
    sHmslStartTime = Time::getMillisecondCounterHiRes();
    sHmslTickOffset = time;
}

void hostClock_AdvanceTime( cell_t delta ) {
    sHmslTickOffset += delta;
}

cell_t hostClock_QueryRate() {
    return sHmslTicksPerSecond;
}

void hostClock_SetRate( cell_t rate ) {
    cell_t currentTicks = hostClock_QueryTime();
    sHmslTicksPerSecond = rate;
    hostClock_SetTime(currentTicks);
}

void hostSleep(cell_t msec) {
    usleep((useconds_t)(msec * 1000));
}

// ============== MIDI ===================================
// for callFunctionOnMessageThread()
static void *createNewMidiOutput(void *text) {
    return (void *) MidiOutput::createNewDevice(String((char *)text));
}

// Called by HMSL upon initializing MIDI
//
// Returns error code (0 for no error)
cell_t hostMIDI_Init() {
    hostClock_Init();
    MessageManager *messageManager = MessageManager::getInstance();
    sMidiOutput = (MidiOutput *) messageManager->callFunctionOnMessageThread(createNewMidiOutput,
                                                               (void *) kMidiName);
    sMidiOutput->startBackgroundThread();
    return 0;
}

// Called by HMSL to terminate the MIDI connection
void hostMIDI_Term() {
    if (sMidiOutput) sMidiOutput->stopBackgroundThread();
    delete sMidiOutput;
    sMidiOutput = nullptr;
}

// Called when HMSL wants to schedule a MIDI packet
//
// addr - Array of unsigned chars to write to MIDI (the data)
// count - the number of bytes in the addr array
// vtime - time in ticks to play the data
//
// Returns error code (0 for no error)
cell_t hostMIDI_Write(ucell_ptr_t data, cell_t count, cell_t ticks) {
    // Use the timestamp to schedule the MIDI events in the future.
    MidiBuffer midiBuffer(MidiMessage((const void *)data, (int)count));
    const double scheduledMillis = hostClock_TicksToMillis(ticks);
    const double nowMillis = Time::getMillisecondCounterHiRes();
    const double playTimeMillis = std::max(scheduledMillis, nowMillis);
    sMidiOutput->sendBlockOfMessages(midiBuffer, playTimeMillis, 44100 /* sample rate */);
    return 0;
}

cell_t hostMIDI_Recv(void) {
    return 0; // TODO MIDI input
}

