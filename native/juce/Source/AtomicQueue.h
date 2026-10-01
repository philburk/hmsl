/*
  ==============================================================================

    AtomicQueue.h
    Created: 19 May 2019 5:08:36pm
    Author:  Phil Burk

  ==============================================================================
*/

#pragma once

#include <atomic>
#include <memory>

/**
 * Lock-free queue for one writer thread and one reader thread.
 * If more than one thread writes then the writers must hold a lock.
 */
template <class T>
class AtomicQueue {
public:
    AtomicQueue(int numElements) {
        // TODO assert power of 2
        mElements = std::make_unique<T[]>(numElements);
        mIndexMask = numElements - 1;
        mCapacity = numElements;
    }

    // Called by the writer thread.
    void write(T const& element) {
        if (full()) return;
        uint64_t writeCounter = mWriteCounter.load(std::memory_order_relaxed);
        int index = (int) (writeCounter & mIndexMask);
        mElements[index] = element;
        // Release so the reader sees the element before the new counter.
        mWriteCounter.store(writeCounter + 1, std::memory_order_release);
    }

    // Called by the reader thread.
    T read() {
        int index = (int) (mReadCounter.load(std::memory_order_relaxed) & mIndexMask);
        return mElements[index];
    }

    // Called by the reader thread.
    void advanceRead() {
        mReadCounter.store(mReadCounter.load(std::memory_order_relaxed) + 1,
                           std::memory_order_release);
    }

    bool empty() const {      // return true if empty
        return mWriteCounter.load(std::memory_order_acquire)
                <= mReadCounter.load(std::memory_order_acquire);
    }

    bool full() const {      // return true if full
        return (mWriteCounter.load(std::memory_order_acquire)
                - mReadCounter.load(std::memory_order_acquire)) >= mCapacity;
    }

private:
    std::unique_ptr<T[]> mElements;
    uint64_t mCapacity = 0;
    uint64_t mIndexMask = 0;
    std::atomic<uint64_t> mWriteCounter{0};
    std::atomic<uint64_t> mReadCounter{0};
};
