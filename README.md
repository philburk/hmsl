# Status of Port

* PForth is now a git submodule under HMSL.
* PForth works in a new Terminal Window written using JUCE.
* Command line history working in Forth.
* Basic graphic commands are working.
* HMSL compiles on a 64-bit pForth. We switched to 64-bit because XCode no longer supports 32-bit apps.

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

## Building HMSL on OSX

The folder containing HMSL needs to be called "HMSL" so that the proper working directory can be
found by the HostFileManager in HMSL.

The XCode project was exported using the ProJucer tool.
JUCE is not required to build HMSL.
New C/C++ files should only be added using the ProJucer.

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
* The next time you launch the application, it will run HMSL.

