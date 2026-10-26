# HMSL App Architecture

This diagram describes the current JUCE app (`native/juce`), which runs the
HMSL Forth environment on pForth. The older Objective-C macOS and Win32 ports
are separate implementations and are not part of this runtime.

```mermaid
flowchart TB
    User[User]

    subgraph App["HMSL desktop app — JUCE"]
        Startup["JUCEApplication<br/>startup and work-folder selection"]
        TerminalUI["TerminalWindow / TerminalComponent<br/>keyboard, command line, display"]
        TerminalModel["TerminalModel<br/>input and output queues"]
        ForthThread["ForthThread<br/>pForth interpreter thread"]
        PForth["pForth runtime<br/>C interpreter and Forth dictionary"]
        HMSL["HMSL Forth environment<br/>ODE, music objects, MIDI, graphics,<br/>editors, tools and pieces"]
        HostBridge["Native host words and adapters<br/>hmsl_custom.c, host_midi.cpp,<br/>hmsl_host_graphics.cpp"]
        HostFiles["HostFileManager<br/>dictionary, source files, work folder,<br/>user settings"]

        GraphicsWindow["GraphicsWindow / MainComponent<br/>HMSL graphics windows"]
        DrawQueue["Drawing command queue"]
        EventQueue["Mouse and window event queue"]
        MidiBase["MidiBase<br/>HMSL clock and MIDI port selection"]
        LocalSynth["LocalSynth<br/>ME2000 / Amiga sound emulation"]
        ExternalMidi["ExternalMidi<br/>device and virtual MIDI ports"]
    end

    subgraph Platform["Operating system and devices"]
        Audio["JUCE audio device"]
        MidiDevices["External MIDI devices<br/>and other MIDI applications"]
        Files["App bundle, repository or user work folder"]
    end

    User --> Startup
    Startup --> TerminalUI
    Startup --> HostFiles
    TerminalUI <-->|keyboard and terminal I/O| TerminalModel
    TerminalModel <-->|pForth character I/O| ForthThread
    ForthThread --> PForth
    PForth --> HMSL
    PForth <--> HostBridge
    HMSL <--> HostBridge

    HostBridge -->|drawing requests| DrawQueue
    DrawQueue -->|render on JUCE UI thread| GraphicsWindow
    GraphicsWindow -->|mouse and window input| EventQueue
    EventQueue -->|polled by HMSL| HostBridge

    HostBridge <--> MidiBase
    MidiBase <-->|MIDI and clock| LocalSynth
    MidiBase <-->|MIDI and clock| ExternalMidi
    LocalSynth --> Audio
    ExternalMidi <--> MidiDevices

    HostFiles <--> Files
    HostFiles -->|dictionary path and Forth file access| ForthThread
```

## Dictionary build

The app's `--build-dictionary` mode first runs pForth's
`pforth/fth/system.fth`, then loads `hmsl/fth/make_hmsl.fth` to compile the
HMSL sources on top of pForth and save `hmsl/pforth.dic`. The regular runtime
loads that dictionary and uses the selected HMSL work folder for Forth files.

```mermaid
flowchart LR
    PForthSources["pforth/fth/system.fth"] --> PForthBuild["pForth base dictionary"]
    PForthBuild --> HMSLSources["hmsl/fth/make_hmsl.fth<br/>loads HMSL Forth modules"]
    HMSLSources --> Dictionary["hmsl/pforth.dic"]
    Dictionary --> Runtime["ForthThread loads dictionary"]
    WorkFolder["HMSL work folder<br/>pieces, tools and user files"] --> Runtime
```

The JUCE application and its adapters are in `native/juce/Source`; HMSL's
Forth module load order is defined in `hmsl/fth/load_hmsl.fth`. See
[Building HMSL](build.md) for the build and packaging workflow.
