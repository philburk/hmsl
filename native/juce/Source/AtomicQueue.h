/*
  ==============================================================================

    AtomicQueue.h
    Created: 19 May 2019 5:08:36pm
    Author:  Phil Burk

  ==============================================================================
*/

#pragma once

#include <memory>

template <class T>
class AtomicQueue {
public:
    AtomicQueue(int numElements) {
        // TODO assert power of 2
        mElements = std::make_unique<T[]>(numElements);
        mIndexMask = numElements - 1;
        mCapacity = numElements;
    }

    void write(T const& element) {
        if (full()) return;
        int index = (int) (mWriteCounter & mIndexMask);
        mElements[index] = element;
        mWriteCounter++;
    }

    T read() {
        int index = (int) (mReadCounter & mIndexMask);
        return mElements[index];
    }

    void advanceRead() {
        mReadCounter++;
    }

    bool empty() const {      // return true if empty
        return mWriteCounter <= mReadCounter;
    }

    bool full() const {      // return true if full
        return (mWriteCounter - mReadCounter) >= mCapacity;
    }

private:
    std::unique_ptr<T[]> mElements;
    uint64_t mCapacity = 0;
    uint64_t mIndexMask = 0;
    uint64_t mWriteCounter = 0;
    uint64_t mReadCounter = 0;
};
