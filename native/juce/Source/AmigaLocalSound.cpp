/*
  ==============================================================================

    AmigaLocalSound.cpp
    Created: 2 Aug 2024 3:47:59pm
    Author:  Phil Burk

  ==============================================================================
*/

#include <memory>

#include <stdlib.h>
#include <unistd.h>

#include "AmigaLocalSound.h"

void AmigaSoundChannel::updateAddress() {
    mData = mNextData;
    mNumWords = mNextNumWords;
}

float AmigaSoundChannel::renderAudio(int32_t period, int32_t volume) {
    float output = 0.0f;
    if (!mEnabled) {
        mCursor = 0;
    } else {
        if (mCursor >= (mNumWords * 2)) {
            mCursor -= (mNumWords * 2);
            // Update DMA address when we finish playing one segment.
            updateAddress();
        }

        int8_t sample = mData[(int)mCursor];
        mCursor += convertPeriodToPhaseIncrement(period);
        output = sample * convertVolumeToScaler(volume);
    }
    return output;
}

int32_t AmigaSoundChannel::renderModulation(int32_t period) {
    int32_t output = 0;
    if (!mEnabled) {
        mCursor = 0;
    } else {
        if (mCursor >= (mNumWords * 2)) {
            mCursor -= (mNumWords * 2);
            // Update DMA address when we finish playing one segment.
            updateAddress();
        }
        output = ((uint16_t *)mData)[(int)mCursor];
        mCursor += convertPeriodToPhaseIncrement(period);
    }
    return output;
}

AmigaLocalSound::AmigaLocalSound()
        : mFifo(256) {
    for (int i = 0; i < kNumChannels; i++) {
        mChannels[i].setPeriod(400 + (i * 100));
    }
}

// Define Amiga Register base address
#define AMIGA_CHIP_BASE 0xDFF000

// Amiga Sound Registers
#define DMACONW_OFFSET 0x96
#define ADKCONW_OFFSET 0x9E
#define AUDXLCH_OFFSET 0xA0

// Channel Offsets
#define AUDCHAN_ADR_OFFSET 0x00
#define AUDCHAN_LEN_OFFSET 0x04
#define AUDCHAN_PER_OFFSET 0x06
#define AUDCHAN_VOL_OFFSET 0x08
#define AUDCHAN_DAT_OFFSET 0x0A
#define AUDCHAN_SIZE       0x10

// Flags for setting bits in DMACONW
#define FLAG_SET_CLR 0x8000
#define FLAG_DMA_DMAEN 0x0200
#define FLAG_AUD0EN 0x0001
#define FLAG_AUD1EN 0x0002
#define FLAG_AUD2EN 0x0004
#define FLAG_AUD3EN 0x0008

void AmigaLocalSound::renderAudio(float *outputLeft, float *outputRight) {
    // Process all the writes to the CHIP in the audio thread so they are atomic.
    processChipEvents();

    // Left channel is DMA 1+2, contrary to what the printed manual says.
    int32_t nextPeriod = mChannels[0].getPeriod();
    int32_t nextVolume = mChannels[0].getVolume();
    float outputs[kNumChannels] = {0.0f};
    for (int i = 0; i < kNumChannels; i++) {
        AmigaSoundChannel *soundChannel = &mChannels[i];
        bool modulateVolume = ((mAdkControl & (0x01 << i)) != 0);
        bool modulatePeriod = ((mAdkControl & (0x10 << i)) != 0);
        if (!(modulateVolume || modulatePeriod)) {
            outputs[i] = soundChannel->renderAudio(nextPeriod, nextVolume);
        }
        if (i < kNumChannels) { // Don't use modulation from channel 3.
            nextVolume = (modulateVolume)
                    ? soundChannel->renderModulation(nextPeriod)
                    : mChannels[i+1].getVolume();
            nextPeriod = (modulatePeriod)
                    ? soundChannel->renderModulation(nextPeriod)
                    : mChannels[i+1].getPeriod();
        }
    }
    *outputLeft = (outputs[1] + outputs[2]) * 0.5f;
    *outputRight = (outputs[0] + outputs[3]) * 0.5f;
}

void AmigaLocalSound::processChipEvents() {
    while (!mFifo.empty()) {
        ChipWriteEvent event = mFifo.read();
        writeRegisterInternal(event.amigaAddress, event.value);
        mFifo.advanceRead();
    }
}

void AmigaLocalSound::writeRegister(int32_t amigaAddress, int64_t value) {
    while (mFifo.full()) {
        // sleep until there is room in the buffer
        usleep(20 * 1000);
    }
    ChipWriteEvent event;
    event.amigaAddress = amigaAddress;
    event.value = value;
    mFifo.write(event);
}

/**
 * Interpret writes to the Amiga hardware registers.
 */
void AmigaLocalSound::writeRegisterInternal(int32_t amigaAddress, int64_t value) {
    int32_t offset = amigaAddress - AMIGA_CHIP_BASE;
    // Are we addressing a specific channel?
    if (offset >= AUDXLCH_OFFSET) {
        int channel = (offset - AUDXLCH_OFFSET) / AUDCHAN_SIZE;
        int channelOffset = offset & 0x0F; // Which channel register?
        switch (channelOffset) {
            case AUDCHAN_ADR_OFFSET:
                mChannels[channel].setNextAddress((const int8_t *)value);
                break;
            case AUDCHAN_LEN_OFFSET:
                mChannels[channel].setNextNumWords((int32_t)value);
                break;
            case AUDCHAN_PER_OFFSET:
                mChannels[channel].setPeriod((int32_t)value);
                break;
            case AUDCHAN_VOL_OFFSET:
                mChannels[channel].setVolume((int32_t)value);
                break;
            default:
                break;
        }
    } else {
        switch (offset) {
            case DMACONW_OFFSET:
                if ((value & FLAG_SET_CLR) != 0) {
                    mDmaControl |= value; // set bits
                } else {
                    mDmaControl = mDmaControl & ~value; // clear bits
                }
                // interpret current bits
                mEnabled = ((mDmaControl & FLAG_DMA_DMAEN) != 0);
                mChannels[0].setEnabled((mDmaControl & FLAG_AUD0EN) != 0);
                mChannels[1].setEnabled((mDmaControl & FLAG_AUD1EN) != 0);
                mChannels[2].setEnabled((mDmaControl & FLAG_AUD2EN) != 0);
                mChannels[3].setEnabled((mDmaControl & FLAG_AUD3EN) != 0);
                break;
            case ADKCONW_OFFSET:
                if ((value & FLAG_SET_CLR) != 0) {
                    mAdkControl |= value; // set bits
                } else {
                    mAdkControl = mAdkControl & ~value; // clear bits
                }
                break;
            default:
                break;
        }
    }
}
