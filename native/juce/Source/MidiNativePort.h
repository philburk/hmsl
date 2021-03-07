/*
  ==============================================================================

    MidiNativePort.h
    Created: 28 Feb 2021 6:04:52pm
    Author:  Phil Burk

  ==============================================================================
*/

#pragma once

#import "hmsl_host.h"

/**
 * Base class for a MIDI port that you can write to.
 * This is a superclass for the local synth and the external MIDI port.
 */
class MidiNativePort {
public:
    virtual ~MidiNativePort() = default;

    virtual cell_t init() = 0;
    virtual void term() = 0;

    virtual cell_t write(ucell_ptr_t data, cell_t count, double nativeTicks) = 0;

    virtual double getNativeTime() = 0;
    virtual cell_t getNativeRate() const = 0;

    double getNativeStartTime() {
        return mNativeStartTime;
    }

    void setNativeStartTime( double time ) {
        mNativeStartTime = time;
    }

protected:
    double mNativeStartTime = 0.0;
};
