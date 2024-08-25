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

/**
 * Emulate one Amiga Sound DMA channel
 */
class AmigaSoundChannel {
public:
    float renderAudio(int32_t period, int32_t volume);
    int32_t renderModulation(int32_t period);

    void setVolume(int32_t volume) {
        mVolume = std::min(64, std::max(0, volume));
    }

    int32_t getVolume() const {
        return mVolume;
    }

    void setPeriod(int32_t period) {
        mPeriod = std::min(65535, std::max(124, period));
    }

    int32_t getPeriod() const {
        return mPeriod;
    }

    float convertPeriodToPhaseIncrement(int32_t period) {
        const float ticksPerSecond = 3579545.0; // Based on Amiga clock
        float samplesPerSecond = ticksPerSecond / period;
        const float framesPerSecond = 44100.0f; // Audio sample rate
        return samplesPerSecond / framesPerSecond;
    }

    float convertVolumeToScaler(int32_t volume) {
        return volume * (1.0f / (64 * 128));
    }

    void updateAddress();

    void setNextAddress(const int8_t *address) {
        mNextData = address;
    }

    void setNextNumWords(int32_t numWords) {
        mNextNumWords = numWords;
    }

    void setEnabled(bool enabled) {
        if (enabled && !mEnabled) {
            mCursor = 0.0f;
            updateAddress();
        }
        mEnabled = enabled;
    }

private:
    int32_t mPeriod = 400;
    int32_t mVolume = 64;
    float mCursor = 0.0f;
    const int8_t *mData = mSine;
    int32_t mNumWords = 0;
    const int8_t *mNextData = mSine;
    int32_t mNextNumWords = sizeof(mSine) / 2;
    bool mEnabled = false;
    bool mModulatePeriod = false; // modulate period of the next higher channel
    bool mModulateAmplitude = false; // modulate amplitude of the next higher channel

    const int8_t mSine[8] = { 0, 80, 127, 80, 0, -80, -128, -80};
};

/**
 * Emulate the Amiga Local Sound system for 4 channels.
 * Model the interaction between channels.
 * Interpret writes to Amiga CHIP registers.
 */
class AmigaLocalSound {

public:
    AmigaLocalSound();
    ~AmigaLocalSound() = default;

    void renderAudio(float *outputLeft, float *outputRight);

    void writeRegister(int32_t amigaAddress, int64_t value);

private:
    static constexpr int kNumChannels = 4;
    AmigaSoundChannel channels[kNumChannels];
    
    uint32_t mDmaControl = 0; // Register with flags for controlling DMA.
    uint32_t mAdkControl = 0; // Register with flags for controlling Audio Channel modulation.
    bool mEnabled = false; // Is entire DMA system enabled?
};
