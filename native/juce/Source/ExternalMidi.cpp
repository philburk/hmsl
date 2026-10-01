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


static std::unique_ptr<MidiOutput> sMidiOutput;

// ============== Clock Time ===================================


double ExternalMidi::getNativeTime() {
    return Time::getMillisecondCounterHiRes();
}

// ============== MIDI ===================================
// for callFunctionOnMessageThread()
static void *createNewMidiOutput(void *text) {
    // Save in a static unique_ptr.
    sMidiOutput = MidiOutput::createNewDevice(String((char *)text));
    return text;
}

// Called by HMSL upon initializing MIDI
//
// Returns error code (0 for no error)
cell_t ExternalMidi::init() {
    openInputs();
    MessageManager *messageManager = MessageManager::getInstance();
    messageManager->callFunctionOnMessageThread(createNewMidiOutput,
                                                (void *) kMidiName);
    if (sMidiOutput == nullptr) {
        // This happens if another instance of HMSL already owns the MIDI port.
        pfMessage("WARNING - could not create the HMSL external MIDI port.\n");
        pfMessage("Is another copy of HMSL running? External MIDI is disabled.\n");
        return -1;
    }
    sMidiOutput->startBackgroundThread();
    return 0;
}

// Called by HMSL to terminate the MIDI connection
void ExternalMidi::term() {
    closeInputs();
    if (sMidiOutput) sMidiOutput->stopBackgroundThread();
    sMidiOutput.reset(nullptr);
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
    saveInputSetting(port.info.name, port.enabled);
}

// Only save inputs that the user chose, so other inputs keep their defaults.
void ExternalMidi::saveInputSetting(const String &name, bool enabled) {
    PropertiesFile *settings = HostFileManager::getInstance()->getSettings();
    StringArray namesOn = StringArray::fromLines(settings->getValue(kInputsOnKey));
    StringArray namesOff = StringArray::fromLines(settings->getValue(kInputsOffKey));
    namesOn.removeString(name);
    namesOff.removeString(name);
    (enabled ? namesOn : namesOff).add(name);
    namesOn.removeEmptyStrings();
    namesOff.removeEmptyStrings();
    settings->setValue(kInputsOnKey, namesOn.joinIntoString("\n"));
    settings->setValue(kInputsOffKey, namesOff.joinIntoString("\n"));
    settings->saveIfNeeded();
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
    if (sMidiOutput == nullptr) return -1; // see init()
    MidiBuffer midiBuffer(MidiMessage((const void *)data, (int)count));
    const double scheduledMillis = nativeTicks;
    const double nowMillis = Time::getMillisecondCounterHiRes();
    const double playTimeMillis = std::max(scheduledMillis, nowMillis);
    sMidiOutput->sendBlockOfMessages(midiBuffer, playTimeMillis, 44100 /* sample rate */);
    return 0;
}
