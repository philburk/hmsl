/*
  ==============================================================================

    ExternalMidi.cpp
    Created: 2 Nov 2019 4:08:33pm
    Author:  Phil Burk

  ==============================================================================
*/

// Apple only, see isEnabledByDefault().
// Include before JUCE to avoid conflicts with JUCE names like Point.
#ifdef __APPLE__
#include <CoreMIDI/CoreMIDI.h>
#endif

#include "ExternalMidi.h"
#include "HostFileManager.h"
#include "pforth.h"

// ============== Clock Time ===================================


double ExternalMidi::getNativeTime() {
    return Time::getMillisecondCounterHiRes();
}

// ============== MIDI ===================================
// Called by HMSL upon initializing MIDI
//
// Returns error code (0 for no error)
cell_t ExternalMidi::init() {
    openInputs();
    openOutputs();
    if (mHmslOutputFailed) {
        // This happens if another instance of HMSL already owns the MIDI port.
        pfMessage("WARNING - could not create the HMSL external MIDI port.\n");
        pfMessage("Is another copy of HMSL running?\n");
        return -1;
    }
    return 0;
}

// Called by HMSL to terminate the MIDI connection
void ExternalMidi::term() {
    closeInputs();
    closeOutputs();
}

// Remember a choice made by the user, by device name.
// Only save devices that the user chose, so other devices keep their defaults.
void ExternalMidi::saveChoice(const char *onKey, const char *offKey,
                              const String &name, bool enabled) {
    PropertiesFile *settings = HostFileManager::getInstance()->getSettings();
    StringArray namesOn = StringArray::fromLines(settings->getValue(onKey));
    StringArray namesOff = StringArray::fromLines(settings->getValue(offKey));
    namesOn.removeString(name);
    namesOff.removeString(name);
    (enabled ? namesOn : namesOff).add(name);
    namesOn.removeEmptyStrings();
    namesOff.removeEmptyStrings();
    settings->setValue(onKey, namesOn.joinIntoString("\n"));
    settings->setValue(offKey, namesOff.joinIntoString("\n"));
    settings->saveIfNeeded();
}

// ============== MIDI Output ===================================
// List the virtual "HMSL" output, which other apps can listen to, plus every
// MIDI output on the system, eg. a hardware synthesizer. Open the ones that are on.
// "HMSL" is on by default. Other outputs are off until the user turns them on
// with MIDI.OUTPUT.ON, so a piece does not suddenly play a device by surprise.
void ExternalMidi::openOutputs() {
    mHmslOutputFailed = false;
    MessageManager::getInstance()->callFunctionOnMessageThread([](void *context) -> void * {
        ExternalMidi *self = static_cast<ExternalMidi *>(context);
        PropertiesFile *settings = HostFileManager::getInstance()->getSettings();
        StringArray namesOn = StringArray::fromLines(settings->getValue(kOutputsOnKey));
        StringArray namesOff = StringArray::fromLines(settings->getValue(kOutputsOffKey));

        auto hmslPort = std::make_unique<OutputPort>();
        hmslPort->info = MidiDeviceInfo(kMidiName, String());
        hmslPort->isHmslOutput = true;
        self->mOutputPorts.push_back(std::move(hmslPort));

        for (const MidiDeviceInfo &info : MidiOutput::getAvailableDevices()) {
            // Skip our own input, which would feed HMSL output back into HMSL.
            if (info.name == kMidiName) continue;
            auto port = std::make_unique<OutputPort>();
            port->info = info;
            self->mOutputPorts.push_back(std::move(port));
        }

        for (auto &port : self->mOutputPorts) {
            const String &name = port->info.name;
            if (namesOn.contains(name)) {
                port->enabled = true;
            } else if (namesOff.contains(name)) {
                port->enabled = false;
            } else {
                port->enabled = port->isHmslOutput;
            }
            if (port->enabled) {
                port->enabled = self->openOutput(*port);
                if (port->isHmslOutput && !port->enabled) {
                    self->mHmslOutputFailed = true;
                }
            }
        }
        return nullptr;
    }, this);

    String message = "MIDI output to:";
    for (auto &port : mOutputPorts) {
        if (port->enabled) message += " \"" + port->info.name + "\"";
    }
    pfMessage((message + "\nEnter MIDI.OUTPUTS to see all outputs.\n").toRawUTF8());
}

// Called on the message thread.
bool ExternalMidi::openOutput(OutputPort &port) {
    port.output = port.isHmslOutput
            ? MidiOutput::createNewDevice(kMidiName)
            : MidiOutput::openDevice(port.info.identifier);
    if (port.output == nullptr) return false;
    port.output->startBackgroundThread(); // for sending messages at a future time
    return true;
}

void ExternalMidi::closeOutput(OutputPort &port) {
    if (port.output == nullptr) return;
    port.output->stopBackgroundThread();
    port.output.reset();
}

void ExternalMidi::closeOutputs() {
    for (auto &port : mOutputPorts) {
        closeOutput(*port);
    }
    mOutputPorts.clear();
}

String ExternalMidi::getOutputName(int index) const {
    if (index < 0 || index >= getNumOutputs()) return String();
    return mOutputPorts[index]->info.name;
}

bool ExternalMidi::isOutputEnabled(int index) const {
    if (index < 0 || index >= getNumOutputs()) return false;
    return mOutputPorts[index]->enabled;
}

int ExternalMidi::getOutputMessageCount(int index) const {
    if (index < 0 || index >= getNumOutputs()) return 0;
    return mOutputPorts[index]->numMessages;
}

void ExternalMidi::setOutputEnabled(int index, bool enabled) {
    if (index < 0 || index >= getNumOutputs()) return;
    OutputPort &port = *mOutputPorts[index];
    if (enabled != port.enabled) {
        if (enabled) {
            struct Request { ExternalMidi *self; OutputPort *port; };
            Request request{this, &port};
            MessageManager::getInstance()->callFunctionOnMessageThread([](void *context) -> void * {
                Request *r = static_cast<Request *>(context);
                return (void *) (intptr_t) r->self->openOutput(*r->port);
            }, &request);
            port.enabled = port.output != nullptr;
        } else {
            closeOutput(port);
            port.enabled = false;
        }
    }
    // Remember the choice even if it did not change, so it overrides the default.
    saveChoice(kOutputsOnKey, kOutputsOffKey, port.info.name, port.enabled);
}

// ============== MIDI Input ===================================
// List every MIDI input on the system, eg. a keyboard, plus a virtual input
// named "HMSL" that other apps can send to. Open the ones that are on.
// The user can turn inputs on or off with MIDI.INPUT.ON and MIDI.INPUT.OFF.
void ExternalMidi::openInputs() {
    MessageManager::getInstance()->callFunctionOnMessageThread([](void *context) -> void * {
        ExternalMidi *self = static_cast<ExternalMidi *>(context);
        PropertiesFile *settings = HostFileManager::getInstance()->getSettings();
        StringArray namesOn = StringArray::fromLines(settings->getValue(kInputsOnKey));
        StringArray namesOff = StringArray::fromLines(settings->getValue(kInputsOffKey));

        auto hmslPort = std::make_unique<InputPort>();
        hmslPort->info = MidiDeviceInfo(kMidiName, String());
        hmslPort->isHmslInput = true;
        self->mInputPorts.push_back(std::move(hmslPort));

        Array<MidiDeviceInfo> devices = MidiInput::getAvailableDevices();
        for (int i = 0; i < devices.size(); i++) {
            // Skip our own output, which would feed HMSL output back into HMSL.
            if (devices[i].name == kMidiName) continue;
            auto port = std::make_unique<InputPort>();
            port->info = devices[i];
            self->mInputPorts.push_back(std::move(port));
        }

        for (int i = 0; i < (int) self->mInputPorts.size(); i++) {
            InputPort &port = *self->mInputPorts[i];
            const String &name = port.info.name;
            if (namesOn.contains(name)) {
                port.enabled = true;
            } else if (namesOff.contains(name)) {
                port.enabled = false;
            } else {
                port.enabled = port.isHmslInput || self->isEnabledByDefault(devices.indexOf(port.info), port.info);
            }
            if (port.enabled) {
                self->openInput(port);
            }
        }
        return nullptr;
    }, this);

    String message = "MIDI input from:";
    for (auto &port : mInputPorts) {
        if (port->enabled) message += " \"" + port->info.name + "\"";
    }
    pfMessage((message + "\nEnter MIDI.INPUTS to see all inputs.\n").toRawUTF8());
}

// Called on the message thread.
bool ExternalMidi::openInput(InputPort &port) {
    port.input = port.isHmslInput
            ? MidiInput::createNewDevice(kMidiName, this)
            : MidiInput::openDevice(port.info.identifier, this);
    if (port.input == nullptr) return false;
    port.source = port.input.get();
    port.input->start();
    return true;
}

void ExternalMidi::closeInput(InputPort &port) {
    if (port.input == nullptr) return;
    port.input->stop();
    port.source = nullptr;
    port.input.reset();
}

void ExternalMidi::closeInputs() {
    for (auto &port : mInputPorts) {
        closeInput(*port);
    }
    mInputPorts.clear();
}

#ifdef __APPLE__
// Apple only: Inputs that belong to hardware or a driver are on by default.
// Virtual sources created by other apps, eg. "Logic Pro Virtual Out", are off
// because they often echo a keyboard that HMSL already receives directly.
// JUCE lists inputs in the same order as MIDIGetSource().
bool ExternalMidi::isEnabledByDefault(int deviceIndex, const MidiDeviceInfo & /* info */) const {
    if (deviceIndex < 0 || deviceIndex >= (int) MIDIGetNumberOfSources()) return true;
    MIDIEndpointRef source = MIDIGetSource((ItemCount) deviceIndex);
    MIDIEntityRef entity = 0;
    OSStatus result = MIDIEndpointGetEntity(source, &entity);
    return result == noErr && entity != 0;
}
#else
// On other platforms, every input is on by default.
bool ExternalMidi::isEnabledByDefault(int /* deviceIndex */, const MidiDeviceInfo & /* info */) const {
    return true;
}
#endif

String ExternalMidi::getInputName(int index) const {
    if (index < 0 || index >= getNumInputs()) return String();
    return mInputPorts[index]->info.name;
}

bool ExternalMidi::isInputEnabled(int index) const {
    if (index < 0 || index >= getNumInputs()) return false;
    return mInputPorts[index]->enabled;
}

int ExternalMidi::getInputMessageCount(int index) const {
    if (index < 0 || index >= getNumInputs()) return 0;
    return mInputPorts[index]->numMessages;
}

void ExternalMidi::setInputEnabled(int index, bool enabled) {
    if (index < 0 || index >= getNumInputs()) return;
    InputPort &port = *mInputPorts[index];
    if (enabled != port.enabled) {
        if (enabled) {
            struct Request { ExternalMidi *self; InputPort *port; };
            Request request{this, &port};
            MessageManager::getInstance()->callFunctionOnMessageThread([](void *context) -> void * {
                Request *r = static_cast<Request *>(context);
                return (void *) (intptr_t) r->self->openInput(*r->port);
            }, &request);
            port.enabled = port.input != nullptr;
        } else {
            closeInput(port);
            port.enabled = false;
        }
    }
    // Remember the choice even if it did not change, so it overrides the default.
    saveChoice(kInputsOnKey, kInputsOffKey, port.info.name, port.enabled);
}

void ExternalMidi::handleIncomingMidiMessage(MidiInput *source,
                                             const MidiMessage &message) {
    for (auto &port : mInputPorts) {
        if (port->source == source) {
            port->numMessages++;
            break;
        }
    }
    // Write whole messages so that bytes from different inputs are not mixed.
    std::lock_guard<std::mutex> lock(mInputWriteLock);
    const uint8_t *data = message.getRawData();
    for (int i = 0; i < message.getRawDataSize(); i++) {
        if (mInputQueue.full()) {
            mNumBytesDropped++;
        } else {
            mInputQueue.write(data[i]);
        }
    }
}

// Called on the Forth thread.
cell_t ExternalMidi::recv() {
    if (mInputQueue.empty()) return -1;
    cell_t byte = mInputQueue.read();
    mInputQueue.advanceRead();
    return byte;
}

// Called when HMSL wants to schedule a MIDI packet
//
// addr - Array of unsigned chars to write to MIDI (the data)
// count - the number of bytes in the addr array
// nativeTicks - time in native ticks to play the data
//
// Returns error code (0 for no error)
cell_t ExternalMidi::write(ucell_ptr_t data, cell_t count, double nativeTicks) {
    // Use the timestamp to schedule the MIDI events in the future.
    MidiBuffer midiBuffer(MidiMessage((const void *)data, (int)count));
    const double scheduledMillis = nativeTicks;
    const double nowMillis = Time::getMillisecondCounterHiRes();
    const double playTimeMillis = std::max(scheduledMillis, nowMillis);
    // Send to every output that is on.
    bool sent = false;
    for (auto &port : mOutputPorts) {
        if (port->output == nullptr) continue;
        port->output->sendBlockOfMessages(midiBuffer, playTimeMillis, 44100 /* sample rate */);
        port->numMessages++;
        sent = true;
    }
    return sent ? 0 : -1;
}
