/*
  ==============================================================================

    ExternalMidi.h
    Created: 2 Nov 2019 4:08:33pm
    Author:  Phil Burk

  ==============================================================================
*/

#pragma once

#include "../JuceLibraryCode/JuceHeader.h"
#include "MidiBase.h"

class ExternalMidi : public MidiBase {
public:
    virtual ~ExternalMidi() = default;

    cell_t init() override;
    void term() override;

    cell_t write(ucell_ptr_t data, cell_t count, cell_t ticks) override;

    double getNativeTime() override;

};
