/*
  ==============================================================================

    ExternalMidi.h
    Created: 2 Nov 2019 4:08:33pm
    Author:  Phil Burk

  ==============================================================================
*/

#pragma once

#include "../JuceLibraryCode/JuceHeader.h"

#include "MidiNativePort.h"

/**
 * Provide an external port that can drive DAWs like Logic Pro
 * or physical MIDI ports.
 * To target individual channels in Logic:
 *   goto File>Project Settings>Recording and check 'Auto Demix by Channel...'
 */
class ExternalMidi : public MidiNativePort {
public:
    virtual ~ExternalMidi() = default;

    cell_t init() override;

    void term() override;

    cell_t write(ucell_ptr_t data, cell_t count, double nativeTicks) override;

    double getNativeTime() override;

    cell_t getNativeRate() const override {
        return kMillisPerSecond; // JUCE MIDI uses a millisecond timer
    }

private:
    static constexpr const char *kMidiName = "HMSL"; // name for external MIDI ports
    static constexpr int kMillisPerSecond = 1000;
};
