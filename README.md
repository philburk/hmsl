# HMSL
Hierarchical Music Specification Language

Forth tools for experimental music from the 1980’s.
HMSL was originally released for Macintosh and Amiga.

HMSL (C) 1986 Phil Burk, Larry Polansky, David Rosenboom

Port to Windows (C) 1996 Phil Burk and Robert Marsanyi

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

## OSX: Compilation and installation

* Open xcode project in `hmsl/native/osx`
* Compile the HMSL-OSX command-line program
* Download [pFORTH](https://www.github.com/philburk/pforth)
* Copy HMSL-OSX program to `pforth/fth`
* Navigate to `pforth/fth` and run `./HMSL-OSX -i system.fth`
* Copy the newly-created `pforth.dic` and HMSL-OSX to `hmsl/hmsl`
* In `hmsl/hsml`, run command `./HMSL-OSX fth/make_hmsl.fth`
* Press `n` to avoid starting HMSL this first time (it won't work anyway)
* Run `./HMSL-OSX` to start HMSL! (and this time press `y`)

