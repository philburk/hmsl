# HMSL
Hierarchical Music Specification Language

Forth tools for experimental music from the 1980’s.
HMSL was originally released for Macintosh and Amiga.

HMSL (C) 1986 Phil Burk, Larry Polansky, David Rosenboom

Port to Windows (C) 1996 Phil Burk and Robert Marsanyi

Port to Macintosh (C) 2015 Andrew C Smith

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

### Compiling the pforth dictionary

* Clone [pforth-xcode](https://www.github.com/kristopherjohnson/pforth-xcode)
    into the same directory into which you cloned hmsl.
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

### Packaging as a .app package

* Open xcode project in `hmsl/native/osx`.
* Select target `hmsl` from the target selection menu.
* Select Product > Build from the menu bar.

