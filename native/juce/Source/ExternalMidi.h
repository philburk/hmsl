/*
  ==============================================================================

    ExternalMidi.h
    Created: 2 Nov 2019 4:08:33pm
    Author:  Phil Burk

  ==============================================================================
*/

#pragma once

#include <mutex>
#include <vector>
#include "../JuceLibraryCode/JuceHeader.h"

#include "AtomicQueue.h"
#include "MidiNativePort.h"

/**
 * Provide an external port that can drive DAWs like Logic Pro
 * or physical MIDI ports.
 * To target individual channels in Logic:
 *   goto File>Project Settings>Recording and check 'Auto Demix by Channel...'
 */
class ExternalMidi : public MidiNativePort, private MidiInputCallback {
public:
    virtual ~ExternalMidi() = default;

    cell_t init() override;

    void term() override;

    cell_t write(ucell_ptr_t data, cell_t count, double nativeTicks) override;

    double getNativeTime() override;

    cell_t getNativeRate() const override {
        return kMillisPerSecond; // JUCE MIDI uses a millisecond timer
    }

    /**
     * Read the next byte received from any MIDI input that is on.
     * MIDI input always uses the external port, whatever MIDI-PORT is set to.
     * @return byte, or -1 if none available
     */
    cell_t recv();

    // MIDI input selection. Inputs are numbered from 0 in the order listed.
    int getNumInputs() const { return (int) mInputPorts.size(); }
    String getInputName(int index) const;
    bool isInputEnabled(int index) const;
    int getInputMessageCount(int index) const;
    /** Turn an input on or off, and remember the choice by name. */
    void setInputEnabled(int index, bool enabled);

private:
    struct InputPort {
        MidiDeviceInfo             info;
        bool                       isHmslInput = false; // our own virtual input
        bool                       enabled = false;
        std::unique_ptr<MidiInput> input;               // open if enabled
        std::atomic<MidiInput *>   source{nullptr};     // to identify callbacks
        std::atomic<int>           numMessages{0};
    };

    void openInputs();
    void closeInputs();
    bool openInput(InputPort &port);
    void closeInput(InputPort &port);
    bool isEnabledByDefault(int deviceIndex, const MidiDeviceInfo &info) const;
    void saveInputSetting(const String &name, bool enabled);

    // Called on a MIDI thread for each message received.
    void handleIncomingMidiMessage(MidiInput *source, const MidiMessage &message) override;

    static constexpr int kInputQueueSize = 4096; // must be a power of 2
    static constexpr const char *kInputsOnKey = "midiInputsOn";   // names the user turned on
    static constexpr const char *kInputsOffKey = "midiInputsOff"; // names the user turned off

    std::vector<std::unique_ptr<InputPort>> mInputPorts;
    std::mutex                              mInputWriteLock; // inputs may call back at the same time
    AtomicQueue<uint8_t>                    mInputQueue{kInputQueueSize};
    std::atomic<int>                        mNumBytesDropped{0};

    static constexpr const char *kMidiName = "HMSL"; // name for external MIDI ports
    static constexpr int kMillisPerSecond = 1000;
};
