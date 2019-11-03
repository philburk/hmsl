/*
  ==============================================================================

    LocalSynth.cpp
    Created: 2 Nov 2019 3:39:55pm
    Author:  Phil Burk

  ==============================================================================
*/

#include "LocalSynth.h"

#ifdef __cplusplus
extern "C"
{
#endif /* __cplusplus */
int JukeBox_Initialize( int sampleRate );

#ifdef __cplusplus
}
#endif /* __cplusplus */

void MyAudioCallback::audioDeviceIOCallback(const float **inputChannelData,
                                            int           numInputChannels,
                                            float **      outputChannelData,
                                            int           numOutputChannels,
                                            int           numSamples) {
    for (int i = 0; i < numSamples; i++) {
        outputChannelData[0][i] = (drand48() - 0.5) * 0.1;
    }
}

int LocalSynth::initialize() {
    mAudioDeviceManager.initialiseWithDefaultDevices(0, 2);
    mAudioDeviceManager.addAudioCallback(&mCallback);
    return JukeBox_Initialize(48000);
}
