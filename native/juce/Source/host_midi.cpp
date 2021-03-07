//
//  Host Dependent MIDI
//     hmsl_midi.cpp
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
#include "MidiBase.h"
#include "ExternalMidi.h"
#include "LocalSynth.h"

static std::unique_ptr<MidiBase> sMidiBase;

// ============== Clock Time ===================================
void hostClock_Init() {
    sMidiBase = std::make_unique<MidiBase>();
    sMidiBase->init();
}

void hostClock_Term() {
    sMidiBase->term();
    sMidiBase.reset();
}

cell_t hostClock_QueryTime() {
    return sMidiBase->queryTime();
}

void hostClock_SetTime( cell_t time ) {
    sMidiBase->setTime(time);
}

void hostClock_AdvanceTime( cell_t delta ) {
    sMidiBase->advanceTime(delta);
}

cell_t hostClock_QueryRate() {
    if (sMidiBase) return sMidiBase->queryRate();
    else return 1000;
}

void hostClock_SetRate( cell_t rate ) {
    sMidiBase->setRate(rate);
}

void hostSleep(cell_t msec) {
    usleep((useconds_t)(msec * 1000));
}

// Called by HMSL upon initializing MIDI
//
// Returns error code (0 for no error)
cell_t hostMIDI_Init() {
    // MIDI is initialized in hostClock_Init()
    return 0;
}

// Called by HMSL to terminate the MIDI connection
void hostMIDI_Term() {
    sMidiBase->term();
}

// Called when HMSL wants to schedule a MIDI packet
//
// addr - Array of unsigned chars to write to MIDI (the data)
// count - the number of bytes in the addr array
// vtime - time in ticks to play the data
//
// Returns error code (0 for no error)
cell_t hostMIDI_Write(ucell_ptr_t data, cell_t count, cell_t ticks) {
    if (sMidiBase) sMidiBase->write(data, count, ticks);
    return 0;
}

cell_t hostMIDI_Recv(void) {
    return 0; // TODO MIDI input
}

// @return address of MIDI-PORT variable
cell_t hostMIDI_Port(void) {
    return sMidiBase->getMidiPortAddress();
}

