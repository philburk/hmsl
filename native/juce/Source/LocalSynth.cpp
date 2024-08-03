/*
  ==============================================================================

    LocalSynth.cpp
    Created: 2 Nov 2019 3:39:55pm
    Author:  Phil Burk

  ==============================================================================
*/

#include <stdlib.h>

#include "spmidi/include/midi.h"
#include "spmidi/include/spmidi.h"
#include "spmidi/include/spmidi_util.h"
#include "spmidi/include/spmidi_print.h"
#include "spmidi/include/spmidi_play.h"
#include "spmidi/include/spmidi_jukebox.h"

#include "LocalSynth.h"

#define SAMPLES_PER_FRAME   (2)
#define BITS_PER_SAMPLE     (sizeof(short)*8)

// Set to 1 if you want to generate white noise instead of notes.
// This could be handy testing the audio interface.
#define PLAY_WHITE_NOISE   0

void LocalSynth::renderMIDI(float **      outputChannelData,
                            int           numOutputChannels,
                            int           numFrames) {
    int framesLeft = numFrames;
    int commonChannels = std::min(numOutputChannels, SAMPLES_PER_FRAME);
    int frameCursor = 0;

    /* The audio buffer is probably bigger than the MIDI synthesizer buffer so we
     * may have to call the synthesizer several times to fill it.
     */
    while( framesLeft )
    {
        int framesToSynthesize = std::min(framesLeft, mFramesPerTick);
#if PLAY_WHITE_NOISE
        int framesGenerated = framesToSynthesize;
#else
        int framesGenerated = JukeBox_SynthesizeAudioTick( mShortBuffer.get(), framesToSynthesize, SAMPLES_PER_FRAME );
#endif
        if (framesGenerated <= 0) {
            return; // TODO report the error
        }
        short *shortData = mShortBuffer.get();
        for (int frame = 0; frame < framesGenerated; frame++) {
            for (int channel = 0; channel < commonChannels; channel++) {
#if PLAY_WHITE_NOISE
                float floatSample = (drand48() - 0.5) * 0.1;
#else
                float floatSample = shortData[channel] * (1.0f / 32768);
#endif
                float *channelArray = outputChannelData[channel];
                channelArray[frameCursor] = floatSample;
            }
            frameCursor++;
            shortData += SAMPLES_PER_FRAME;
        }
        /* Calculate how many frames are remaining. */
        framesLeft -= framesGenerated;
    }
}

void LocalSynth::audioDeviceIOCallback(const float ** /*inputChannelData */,
                                       int           /* numInputChannels*/,
                                       float **      outputChannelData,
                                       int           numOutputChannels,
                                       int           numFrames) {
    renderMIDI(outputChannelData, numOutputChannels, numFrames);
                                           
   if (numOutputChannels >= 2) {
       // Get the two mono arrays.
       float *outputLeft = outputChannelData[0];
       float *outputRight = outputChannelData[1];
       // Mix the Amiga sound on top of the MIDI sound.
       for (int i = 0; i < numFrames; i++) {
           outputLeft[i] += mAmigaLocalSound.renderLeft();
           outputRight[i] += mAmigaLocalSound.renderRight();
       }
   }
}

// ============== Clock Time ===================================


double LocalSynth::getNativeTime() {
    return JukeBox_GetTime();
}

cell_t LocalSynth::getNativeRate() const {
    return mSampleRate / JukeBox_GetFramesPerTick();
}

// Called by HMSL upon initializing MIDI
//
// Returns error code (0 for no error)
cell_t LocalSynth::init() {

    mAudioDeviceManager.initialiseWithDefaultDevices(0, 2); // audio device
    AudioDeviceManager::AudioDeviceSetup audioSetup =
            mAudioDeviceManager.getAudioDeviceSetup();
    mSampleRate = audioSetup.sampleRate;
    int result = JukeBox_Initialize(mSampleRate);
    mFramesPerTick = JukeBox_GetFramesPerTick();
    int maxSamples = mFramesPerTick * SAMPLES_PER_FRAME;
    mShortBuffer = std::make_unique<short[]>(maxSamples);

    // Start the synth.
    mAudioDeviceManager.addAudioCallback(this);
    return result;
}

// Called by HMSL to terminate the MIDI connection
void LocalSynth::term() {
    mAudioDeviceManager.removeAudioCallback(this);
    mAudioDeviceManager.closeAudioDevice();
    JukeBox_Terminate();
}

// Called when HMSL wants to schedule a MIDI packet
//
// addr - Array of unsigned chars to write to MIDI (the data)
// count - the number of bytes in the addr array
// nativeTicks - time in ticks to play the data
//
// @return error code (0 for no error)
cell_t LocalSynth::write(ucell_ptr_t data, cell_t count, double nativeTicks) {
    uint8_t *byteData = reinterpret_cast<uint8_t *>(data);
    if( count > 0 )
    {
        int timeOut = 20;
        // Cannot playt it in the past.
        const cell_t playTimeNativeTicks = (cell_t)std::max(nativeTicks, getNativeTime());
        while( (JukeBox_SendMIDI( (int)playTimeNativeTicks, (int)count, byteData ) < 0) && (timeOut-- > 0) )
        {
            hostSleep(50);
        }
    }
    return 0;
}
