
# UNDER CONSTRUCTION
# CURRENTLY BEING PORTED to JUCE
# DO NOT USE - 5/27/2019
# Status

* PForth is now a git submodule under HMSL.
* PForth works in a new Terminal Window written using JUCE.
* Command line history working in Forth.
* Basic graphic commands are working except for XOR.
* HMSL compiles on a 64-bit pForth. We switched to 64-bit because XCode no longer supports 32-bit apps.
* MIDI not implemented.
* Control grids draw badly because of missing XOR mode that was used for highlights and rubber banding.

# HMSL
Hierarchical Music Specification Language

Forth tools for experimental music from the 1980’s.
HMSL was originally released for Macintosh and Amiga.

HMSL (C) 1986 Phil Burk, Larry Polansky, David Rosenboom

    Port to Windows (C) 1996 Phil Burk and Robert Marsanyi
    Port to Macintosh (C) 2015 Andrew C Smith
    Port to JUCE (C) 2019 Phil Burk

HMSL is released under the open source Apache License V2.

A description of HMSL and complete documentation can be found here:

   <http://www.softsynth.com/hmsl/>

PHMSL is built on top of pForth, a ‘C’ based Forth.

   <http://www.softsynth.com/pforth/>

Description of folders:

    docs/ - Original docs converted to Open Office format

    hmsl/ - original package
    hmsl/fth - the guts of HMSL
    hmsl/pieces - lots of examples and some pieces that were distributed with HMSL
    hmsl/screens - interactive GUI pages that need conversion
    hmsl/tools - tools written using HMSL, e.g. the score entry system

    native/Win32 - port of HMSL to pForth for Windows by Robert Marsanyi and Phil Burk
    native/juce - port of HMSL to pForth using JUCE by Phil Burk
    
    native/osx - port of HMSL to pForth for Mac OSX by Andrew Smith and Phil Burk - OBSOLETE

## Building HMSL on OSX

The folder containing HMSL needs to be called "HMSL" so that the proper working directory can be
found by the HostFileManager in HMSL.

The XCode project was exported using the ProJucer tool.
JUCE is not required to build HMSL.

### Compiling the JUCE port
* Launch the XCode project at "HMSL/native/juce/Builds/MacOSX/JuceHMSL.xcodeproj".
* In "HMSL/native/juce/Source/ForthThread.cpp", set PF_COMPILE_SYSTEM to 1
* Run the application. It will compile the pForth dictionary.
* Move the dictionary file from "HMSL/pforth/fth/pforth.dic" to "HMSL/hmsl/pforth.dic".
* In "HMSL/native/juce/Source/ForthThread.cpp", set PF_COMPILE_SYSTEM to 0
* Run the application. It will open a terminal window.
* Enter:   include fth/make_hmsl.fth
* It will compile HMSL and save a new pforth.dic.
* Close the terminal window.
* The next time you launch the application, it will ruun HMSL.

### OBSOLETE Compiling the Objective-C port
* Clone [pforth](https://www.github.com/philburk/pforth)
    into the same directory into which you cloned hmsl.
* Rename the folder `pforth-xcode`.
* Open xcode project in `hmsl/native/osx`
* Compile the HMSL-OSX command-line program. Ensure that it finds all necessary
    files, including the `pforth-xcode/csrc` folder.
* Copy the built HMSL-OSX program to `pforth-xcode/fth`. You can generally find it in
    `native/osx/Build/Products/Debug`.
* Navigate to `pforth-xcode/fth` and run `./HMSL-OSX -i system.fth`
* Copy the newly-created `pforth.dic` and HMSL-OSX to `hmsl/hmsl`
* In `hmsl/hsml`, run command `./HMSL-OSX fth/make_hmsl.fth`
* Press `n` to avoid starting HMSL this first time (it won't work anyway)
* Run `./HMSL-OSX` to start HMSL! (and this time press `y`)

#### Packaging as a .app package

* Open xcode project in `hmsl/native/osx`.
* Select target `hmsl` from the target selection menu.
* Select Product > Build from the menu bar.

