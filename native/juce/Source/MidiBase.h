/*
  ==============================================================================

    MidiBase.h
    Created: 2 Nov 2019 4:08:20pm
    Author:  Phil Burk

  ==============================================================================
*/

#pragma once

#import "hmsl_host.h"

/**
 * Abstract base class for various kinds of MIDI devices.
 */
class MidiBase {
public:
    virtual ~MidiBase() = default;

    virtual cell_t init() = 0;
    virtual void term() = 0;

    virtual cell_t write(ucell_ptr_t data, cell_t count, cell_t ticks) = 0;

    /** ------- CLOCK ----------- */

    cell_t queryTime() {
        return nativeToTicks(getNativeTime());
    }

    void setTime( cell_t time ) {
        mNativeStartTime = getNativeTime();
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

protected:

    virtual double getNativeTime() = 0;
    virtual cell_t getNativeRate() const = 0;

    //  Convert from milliseconds to HMSL clock ticks
    cell_t nativeToTicks( double millis ) {
        cell_t elapsed = (cell_t) (mHmslTicksPerSecond * (millis - mNativeStartTime)
                                   / getNativeRate());
        return elapsed + mHmslTickOffset;
    }

    double ticksToNative( cell_t ticks ) {
        cell_t elapsedTicks = ticks - mHmslTickOffset;
        double elapsedHighResTicks = (elapsedTicks * getNativeRate()) / mHmslTicksPerSecond;
        return elapsedHighResTicks + mNativeStartTime;
    }

    static constexpr int kDefaultTicksPerSecond = 60; // original tick rate, rtc.rate@
    static constexpr const char *kMidiName = "HMSL"; // name for external MIDI ports

    double mNativeStartTime = 0.0;
    cell_t mHmslTickOffset = 0;
    cell_t mHmslTicksPerSecond = kDefaultTicksPerSecond;
};
