/*
  ==============================================================================

    LocalSynth.cpp
    Created: 2 Nov 2019 3:39:55pm
    Author:  Phil Burk

  ==============================================================================
*/

#include "spmidi/include/midi.h"
#include "spmidi/include/spmidi.h"
#include "spmidi/include/spmidi_util.h"
#include "spmidi/include/spmidi_print.h"
#include "spmidi/include/spmidi_play.h"
#include "spmidi/include/spmidi_jukebox.h"

#include "LocalSynth.h"

#define SAMPLE_RATE         (44100)
#define SAMPLES_PER_FRAME   (2)
#define BITS_PER_SAMPLE     (sizeof(short)*8)

#define CALL_JUKEBOX   1

void LocalSynth::audioDeviceIOCallback(const float **inputChannelData,
                                            int           numInputChannels,
                                            float **      outputChannelData,
                                            int           numOutputChannels,
                                            int           numSamples) {
    int framesLeft = numSamples;
    int commonChannels = std::min(numOutputChannels, SAMPLES_PER_FRAME);
    int frameCursor = 0;

    /* The audio buffer is probably bigger than the synthesizer buffer so we
     * may have to call the synthesizer several times to fill it.
     */
    while( framesLeft )
    {
        int framesToSynthesize = std::min(framesLeft, mFramesPerTick);
#if CALL_JUKEBOX
        int framesGenerated = JukeBox_SynthesizeAudioTick( mShortBuffer.get(), framesToSynthesize, SAMPLES_PER_FRAME );
#else
        int framesGenerated = framesToSynthesize;
#endif
        if (framesGenerated <= 0) {
            return; // TODO report the error
        }
        short *shortData = mShortBuffer.get();
        for (int frame = 0; frame < framesGenerated; frame++) {
            for (int channel = 0; channel < commonChannels; channel++) {
#if CALL_JUKEBOX
                float floatSample = shortData[channel] * (1.0f / 32768);
#else
                float floatSample = (drand48() - 0.5) * 0.1;
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

// ============== Clock Time ===================================


double LocalSynth::getNativeTime() {
    return JukeBox_GetTime();
}

cell_t LocalSynth::getNativeRate() const {
    return SAMPLE_RATE / JukeBox_GetFramesPerTick();
}

// Called by HMSL upon initializing MIDI
//
// Returns error code (0 for no error)
cell_t LocalSynth::init() {
    mHmslTicksPerSecond = kDefaultTicksPerSecond;
    setTime(0);

    mAudioDeviceManager.initialiseWithDefaultDevices(0, 2); // audio device
    
    int result = JukeBox_Initialize(SAMPLE_RATE);
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
// vtime - time in ticks to play the data
//
// Returns error code (0 for no error)
cell_t LocalSynth::write(ucell_ptr_t data, cell_t count, cell_t ticks) {
    uint8_t *byteData = reinterpret_cast<uint8_t *>(data);
    if( count > 0 )
    {
        int timeOut = 20;

        const cell_t scheduledNativeTicks = ticksToNative(ticks);
        const cell_t playTimeNativeTicks = std::max(scheduledNativeTicks, (cell_t) getNativeTime());
        while( (JukeBox_SendMIDI( (int)playTimeNativeTicks, (int)count, byteData ) < 0) && (timeOut-- > 0) )
        {
            hostSleep(50);
        }
    }
    return 0;
}
