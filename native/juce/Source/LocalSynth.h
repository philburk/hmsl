/*
  ==============================================================================

    LocalSynth.h
    Created: 2 Nov 2019 3:39:55pm
    Author:  Phil Burk

  ==============================================================================
*/

#pragma once

#include "../JuceLibraryCode/JuceHeader.h"

class MyAudioCallback : public AudioIODeviceCallback {
public:
    void audioDeviceIOCallback(const float **inputChannelData,
                               int           numInputChannels,
                               float **      outputChannelData,
                               int           numOutputChannels,
                               int           numSamples) override;

    void audioDeviceAboutToStart(AudioIODevice *device) override {};
    void audioDeviceStopped() override {};

};

class LocalSynth {
public:
    int initialize();

private:
    AudioDeviceManager mAudioDeviceManager;
    MyAudioCallback    mCallback;
};
