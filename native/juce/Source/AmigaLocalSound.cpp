/*
  ==============================================================================

    AmigaLocalSound.cpp
    Created: 2 Aug 2024 3:47:59pm
    Author:  Phil Burk

  ==============================================================================
*/

#include <stdlib.h>

#include "AmigaLocalSound.h"

float AmigaSoundChannel::render() {
    float output = 0.0f;
    if (!mEnabled) {
        mCursor = 0;
    } else {
        if (mCursor >= mNumBytes) {
            mCursor -= mNumBytes;
            // Update DMA address when we finish playing one segment.
            mData = mNextData; // FIXME use mutex for atomic update
            mNumBytes = mNextNumBytes;
        }
        int8_t sample = mData[(int)mCursor];
        mCursor += mPhaseIncrement;
        output = sample * mAmplitudeScaler;
    }
    return output;
}

AmigaLocalSound::AmigaLocalSound() {
    for (int i = 0; i < kNumChannels; i++) {
        channels[i].setPhaseIncrement(0.1 + (0.05 * i));
    }
}

// Define Amiga Register Locations
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

// Flags for setting bits.
#define FLAG_SET_CLR 0x8000
#define FLAG_DMA_DMAEN 0x0200
#define FLAG_AUD0EN 0x0001
#define FLAG_AUD1EN 0x0002
#define FLAG_AUD2EN 0x0004
#define FLAG_AUD3EN 0x0008

float AmigaLocalSound::renderLeft() {
    // Left channel is 1,2, contrary to what the printed manual says.
    return mEnabled
            ? ((channels[1].render() + channels[2].render()) * 0.5f)
            : 0.0f;
}

float AmigaLocalSound::renderRight() {
    return mEnabled
            ? ((channels[0].render() + channels[3].render()) * 0.5f)
            : 0.0f;
}

/**
 * Interpret writes to the Amiga hardware registers.
 */
void AmigaLocalSound::writeRegister(int32_t amigaAddress, int64_t value) {
    int32_t offset = amigaAddress - AMIGA_CHIP_BASE;
    if (offset >= AUDXLCH_OFFSET) {
        int channel = (offset - AUDXLCH_OFFSET) / 16;
        int channelOffset = offset & 0x0F;
        switch (channelOffset) {
            case AUDCHAN_ADR_OFFSET:
                channels[channel].setNextAddress((const int8_t *)value);
                break;
            case AUDCHAN_LEN_OFFSET:
                channels[channel].setNextNumBytes((int32_t)(value * 2)); // value is in words
                break;
            case AUDCHAN_PER_OFFSET:
                channels[channel].setPeriod((int32_t)value);
                break;
            case AUDCHAN_VOL_OFFSET:
                channels[channel].setAmplitude(value * (1.0f / 64));
                break;
            default:
                break;
        }
    } else {
        switch (offset) {
            case DMACONW_OFFSET:
                if ((value & FLAG_SET_CLR) != 0) {
                    mDmaControl |= value;
                } else {
                    mDmaControl = (mDmaControl & ~value);
                }
                mEnabled = ((mDmaControl & FLAG_DMA_DMAEN) != 0);
                channels[0].setEnabled((mDmaControl & FLAG_AUD0EN) != 0);
                channels[1].setEnabled((mDmaControl & FLAG_AUD1EN) != 0);
                channels[2].setEnabled((mDmaControl & FLAG_AUD2EN) != 0);
                channels[3].setEnabled((mDmaControl & FLAG_AUD3EN) != 0);

                break;
            case ADKCONW_OFFSET:
                break;
            default:
                break;
        }
    }
}
