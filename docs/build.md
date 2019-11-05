[Docs Home](.)

# Building HMSL from Source

You probably don't need to build HMSL from source.
You can download a [precompiled binary release](https://github.com/philburk/hmsl/releases) from GitHub and try it out.
But if you want to modify the C++ part of HMSL then read on.

## Install JUCE

JUCE is required to build HMSL. Install JUCE from [here](https://shop.juce.com/)

## Building on OSX

The folder containing HMSL needs to be called "HMSL" so that the proper working directory can be
found by the HostFileManager in HMSL.

The XCode project was exported using the ProJucer tool.

New C/C++ files should only be added using the ProJucer.

### Checking out the code

    cd ~
    mkdir Work  # if needed
    cd Work
    mkdir hmsl
    cd hmsl
    git clone https://github.com/philburk/hmsl.git HMSL
    cd HMSL/pforth
    git submodule init
    git submodule update
    
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
* The next time you run the application, it will initialize HMSL.
