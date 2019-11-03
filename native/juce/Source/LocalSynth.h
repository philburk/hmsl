/*
  ==============================================================================

    LocalSynth.h
    Created: 2 Nov 2019 3:39:55pm
    Author:  Phil Burk

  ==============================================================================
*/

#pragma once

#include <memory>

#include "../JuceLibraryCode/JuceHeader.h"
#include "MidiBase.h"

class LocalSynth : public MidiBase, AudioIODeviceCallback  {
public:

    virtual ~LocalSynth() = default;

    cell_t init() override;

    void term() override;

    cell_t write(ucell_ptr_t data, cell_t count, cell_t ticks) override;

    double getNativeTime() override;

    cell_t getNativeRate() const override;

    /** -------------- AUDIO ----------------------------------- */
    void audioDeviceIOCallback(const float **inputChannelData,
                               int           numInputChannels,
                               float **      outputChannelData,
                               int           numOutputChannels,
                               int           numSamples) override;

    void audioDeviceAboutToStart(AudioIODevice *device) override {};
    void audioDeviceStopped() override {};

private:
    AudioDeviceManager mAudioDeviceManager;
    int                mFramesPerTick = 0;
    std::unique_ptr<short> mShortBuffer;
};
