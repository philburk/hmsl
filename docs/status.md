# Status of HMSL

Summer 2019: HMSL is currently being ported to run on modern laptops using [JUCE](https://juce.com).

## Status of JUCE Port

* PForth is now a git submodule under HMSL.
* PForth works in a new Terminal Window written using JUCE.
* Command line history working in Forth.
* Basic graphic commands and mouse input are working.
* HMSL compiles on a 64-bit pForth. We switched to 64-bit because XCode no longer supports 32-bit apps.
