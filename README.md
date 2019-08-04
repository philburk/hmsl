# HMSL - the Hierarchical Music Specification Language

HMSL is a set of extensions to the Forth programming language.
It includes tools and editors for experimental music composition and performance. 
HMSL was originally released in the 1980's for Mac Plus and Amiga, and was widely used by the computer music programming community. It has recently been ported to run on today's Mac OS using JUCE.

HMSL provides:

* an object oriented dialect called ODE
* hierarchical music composition classes such as sequential and parallel collections
* abstract multi-dimensional "shapes" that can be edited and played
* MIDI I/O toolbox and parsers
* cross platform GUI toolkit for editors and instruments
* support for live coding
* utilities for algorithmic composition including Markov Chains, randomness, scales, etc.

[**DOCUMENTATION and guided tours are here.**](docs)

Description of folders:

    docs/ - Original docs converted to Open Office format

    hmsl/ - original package
    hmsl/fth - the guts of HMSL
    hmsl/pieces - lots of examples and some pieces that were distributed with HMSL
    hmsl/screens - interactive GUI pages that need conversion
    hmsl/tools - tools written using HMSL, e.g. the score entry system

    native/Win32 - port of HMSL to pForth for Windows by Robert Marsanyi and Phil Burk
    native/juce - port of HMSL to pForth using JUCE by Phil Burk

## Credits

The current version of HMSL is built on top of pForth, a ‘C’ based Forth.

   <http://www.softsynth.com/pforth/>

* HMSL (C) 1986 Phil Burk, Larry Polansky, David Rosenboom.
* HMSL is now released under the open source Apache License V2.
* Original development 1985 - 1993 by Phil Burk, Larry Polansky and David Rosenboom at the Mills College Center for Contemporary Music.
* Port to Windows in 1996 by Phil Burk and Robert Marsanyi
* Port to Macintosh using Objective-C in 2015 by Andrew C Smith
* Port to JUCE in 2019 by Phil Burk
