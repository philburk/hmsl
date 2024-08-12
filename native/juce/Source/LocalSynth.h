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
#include "MidiNativePort.h"
#include "AmigaLocalSound.h"
/**
 * Built-in synthesizer using ME2000 from Mobileer.
 */
class LocalSynth : public MidiNativePort, AudioIODeviceCallback  {
public:

    virtual ~LocalSynth() = default;

    cell_t init() override;

    void term() override;

    // @return error code (0 for no error)
    cell_t write(ucell_ptr_t data, cell_t count, double nativeTicks) override;

    double getNativeTime() override;

    cell_t getNativeRate() const override;
    
    /** -------------- MIDI ----------------------------------- */
    void renderMIDI(float **      outputChannelData,
                    int           numOutputChannels,
                    int           numFrames);

    /** -------------- AUDIO ----------------------------------- */
    void audioDeviceIOCallback(const float **inputChannelData,
                               int           numInputChannels,
                               float **      outputChannelData,
                               int           numOutputChannels,
                               int           numSamples) override;

    void audioDeviceAboutToStart(AudioIODevice *device) override {};
    void audioDeviceStopped() override {};

    void hostChipWrite(cell_t value, cell_t amigaAddress) {
        mAmigaLocalSound.writeRegister((int32_t) amigaAddress, value);
    }

private:
    bool               mInitialized = false;
    AudioDeviceManager mAudioDeviceManager;
    int32_t            mSampleRate = 44100;
    int                mFramesPerTick = 0;
    std::unique_ptr<short[]> mShortBuffer;


    AmigaLocalSound    mAmigaLocalSound;
};
