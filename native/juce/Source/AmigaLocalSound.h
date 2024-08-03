/*
  ==============================================================================

    AmigaLocalSound.h
    Created: 2 Aug 2024 3:47:59pm
    Author:  Phil Burk

  ==============================================================================
*/

#include <algorithm>
#include <atomic>

#pragma once

class AmigaSoundChannel {
public:
    float render();

    void setPhaseIncrement(float phaseIncrement) {
        mPhaseIncrement = phaseIncrement;
    }

    void setAmplitude(float amplitude) {
        mAmplitudeScaler = amplitude / 128; // Including scaling for conversion from byte to float.
    }

    void setPeriod(int32_t ticksPerSample) {
        const float ticksPerSecond = 3579545.0; // Based on Amiga clock
        ticksPerSample = std::max(124, ticksPerSample);
        ticksPerSample = std::min(65535, ticksPerSample);
        float samplesPerSecond = ticksPerSecond / ticksPerSample;
        const float framesPerSecond = 44100.0f; // Audio sample rate
        mPhaseIncrement = samplesPerSecond / framesPerSecond;
    }

    void setNextAddress(const int8_t *address) {
        mNextData = address;
    }

    void setNextNumBytes(int32_t numBytes) {
        mNextNumBytes = numBytes;
    }

    void setEnabled(bool enabled) {
        mEnabled = enabled;
    }

private:
    std::atomic<float> mPhaseIncrement{0.01f};
    float mAmplitudeScaler = 1.0f / 128;
    float mCursor = 0.0f;
    const int8_t *mData = mSine;
    int32_t mNumBytes = 0;
    const int8_t *mNextData = mSine;
    int32_t mNextNumBytes = sizeof(mSine);
    bool mEnabled = false;

    const int8_t mSine[8] = { 0, 80, 127, 80, 0, -80, -128, -80};
};


class AmigaLocalSound {

public:
    AmigaLocalSound();
    ~AmigaLocalSound() = default;

    float renderLeft();
    float renderRight();

    void writeRegister(int32_t amigaAddress, int64_t value);

private:
    static constexpr int kNumChannels = 4;
    AmigaSoundChannel channels[kNumChannels];
    uint32_t mDmaControl = 0;
    bool mEnabled = false;

};
