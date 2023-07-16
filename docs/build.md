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
    
### Exporting from ProJucer

Unless you need to add a JUCE file, or update the JUCE version, you can probably skip to "Compiling the JUCE port" below.

* Open the folder "native/juce"
* Double click on JuceHMSL.jucer
* At the top of the ProJucer page, set "Selected exporter" to "XCode (macOS)"
* Click on the white and blue circulat icon to the right of that menu to "Save and Open IDE".

### Compiling the JUCE port
* Launch the XCode project at "HMSL/native/juce/Builds/MacOSX/JuceHMSL.xcodeproj".
* In "JuceHMSL/Source/ForthThread.cpp", set PF_COMPILE_SYSTEM to 1
* Run the application from XCode.
* It will open a terminal window and compile the pForth dictionary.
* Close the terminal window.
* Move the dictionary file from "HMSL/pforth/fth/pforth.dic" to "HMSL/hmsl/pforth.dic".
* In "HMSL/native/juce/Source/ForthThread.cpp", set PF_COMPILE_SYSTEM to 0
* Run the application. It will open a terminal window.
* Enter:   include fth/make_hmsl.fth
* It will compile HMSL and save a new pforth.dic.
* Close the terminal window by entering:  BYE
* The next time you run the application, it will initialize HMSL.

### Packaging a Release for Mac OS
1. Checkout the master repositories of HMSL and pForth.
2. Update the version number in native/juce/Source/Main.cpp
3. Update master repository.
4. Build the app as described above.
5. Open the folder ~/Work/hmsl/HMSL_Release/HMSL/hmsl.
6. Replace the JuceHMSL.app file in that folder with "~/Work/hmsl/HMSL/native/juce/Builds/MacOSX/build/Debug/JuceHMSL.app".
7. Replace the pforth.dic file with "~/Work/hmsl/HMSL/hmsl/pforth.dic".
8. Replace the "pieces" folder with "~/Work/hmsl/HMSL/hmsl/pieces".
8. Replace the "tools" folder with "~/Work/hmsl/HMSL/hmsl/tools".
9. Make a zip file from HMSL_Release/HMSL.
10. Rename it "HMSL_{version}.zip" using underscores, eg. "HMSL_0_5_5.zip"
11. Under Releases, create a new release and drag the new ZIP file to attach it.

