/*
  ==============================================================================

    MidiBase.h
    Created: 2 Nov 2019 4:08:20pm
    Author:  Phil Burk

  ==============================================================================
*/

#pragma once

#import "hmsl_host.h"

#include "ExternalMidi.h"
#include "LocalSynth.h"
#include "MidiNativePort.h"

/**
 * MIDI Manager
 * TODO - Needs renaming. Was a base class for MIDI.
 */
class MidiBase {
public:
    virtual ~MidiBase() = default;

    cell_t init();
    void term();

    // @return error code (0 for no error)
    cell_t write(ucell_ptr_t data, cell_t count, cell_t ticks);

    /** ------- CLOCK ----------- */

    cell_t queryTime() {
        MidiNativePort *port = getCurrentPort();
        return nativeToTicks(port->getNativeTime());
    }

    void setTime( cell_t time ) {
        mLocalMidiPort.setNativeStartTime( mLocalMidiPort.getNativeTime() );
        mExternalMidiPort.setNativeStartTime( mExternalMidiPort.getNativeTime() );
        mHmslTickOffset = time;
    }

    void advanceTime( cell_t delta ) {
        mHmslTickOffset += delta;
    }

    cell_t queryRate() {
        return mHmslTicksPerSecond;
    }

    void setRate( cell_t rate ) {
        cell_t currentTicks = queryTime();
        mHmslTicksPerSecond = rate;
        setTime(currentTicks);
    }

    void setPort( cell_t port ) {
        mPort = port;
    }

    cell_t getPort( cell_t port ) {
        return mPort;
    }

    // @return address of MIDI-PORT so we can use @ and ! in Forth
    cell_t getMidiPortAddress() const {
        return reinterpret_cast<cell_t>(&mPort);
    }

private:

    MidiNativePort *getCurrentPort() {
        return (mPort == 0)
                ? (MidiNativePort *)&mLocalMidiPort
                : (MidiNativePort *)&mExternalMidiPort;
    }

    //  Convert from native Ticks to HMSL clock ticks
    cell_t nativeToTicks( double nativeTicks ) {
        MidiNativePort *port = getCurrentPort();
        cell_t elapsed = (cell_t) (mHmslTicksPerSecond * (nativeTicks - port->getNativeStartTime())
                                   / port->getNativeRate());
        return elapsed + mHmslTickOffset;
    }

    double ticksToNative( cell_t hmslTicks ) {
        MidiNativePort *port = getCurrentPort();
        cell_t elapsedTicks = hmslTicks - mHmslTickOffset;
        double elapsedHighResTicks = (elapsedTicks * port->getNativeRate()) / mHmslTicksPerSecond;
        return elapsedHighResTicks + port->getNativeStartTime();
    }

    static constexpr int kDefaultTicksPerSecond = 60; // original tick rate, rtc.rate@
    cell_t mHmslTicksPerSecond = kDefaultTicksPerSecond;
    cell_t mHmslTickOffset = 0;

    cell_t       mPort = 0;         // used to switch between internal and external MIDI
    LocalSynth   mLocalMidiPort;    // Built-in internal synthesizer
    ExternalMidi mExternalMidiPort; // Appears as "HMSL" MIDI input to other apps.
};
