# HMSL
Hierarchical Music Specification Language

HMSL is a set of extensions to the Forth programming language.
It includes tools and editors for experimental music composition and performance. 
HMSL was originally released in the 1980's for Mac Plus and Amiga, and was widely used by the computer music programming community. It has recently been resurrected and runs on today's Mac OS.

HMSL provides:

* an object oriented dialect called ODE
* hierarchical music composition classes such as sequential and parallel collections
* abstract multi-dimensional "shapes" that can be edited and played
* MIDI I/O toolbox and parsers
* cross platform GUI toolkit for editors and instruments
* support for live coding
* utilities for Markov Chains, randomness, scales, etc.


HMSL (C) 1986 Phil Burk, Larry Polansky, David Rosenboom.
HMSL is now released under the open source Apache License V2.

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

## Status of JUCE Port

HMSL was ported to [JUCE](https://juce.com) in 2019 

* PForth is now a git submodule under HMSL.
* PForth works in a new Terminal Window written using JUCE.
* Command line history working in Forth.
* Basic graphic commands and mouse input are working.
* HMSL compiles on a 64-bit pForth. We switched to 64-bit because XCode no longer supports 32-bit apps.

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

## Quick Start

1. Double click JuceHMSL.app
1. Hit 'y' key to initialize HMSL.
1. Launch a synthesizer program like [Simple Synth](http://notahat.com/simplesynth/) and select "HMSL" as the MIDI source.
1. Enter: midi.seqout
1. You should hear a few notes play.
1. Enter: shep
1. The Shape Editor window should appear and you should hear a repeated melody.
1. Click "Draw" option.
1. Draw on the graph to extend the melody.
1. Close the graphics window to stop the editor.
1. Read more tutorials and docs at <http://www.softsynth.com/hmsl/>

## Credits

* Original development 1985 - 1993 by Phil Burk, Larry Polansky and David Rosenboom at the Mills College Center for Contemporary Music.
* Port to Windows in 1996 by Phil Burk and Robert Marsanyi
* Port to Macintosh using Objective-C in 2015 by Andrew C Smith
* Port to JUCE in 2019 by Phil Burk
