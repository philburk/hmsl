[Docs Home](.)

# Building HMSL from Source

You probably don't need to build HMSL from source.
You can download a [precompiled binary release](https://github.com/philburk/hmsl/releases) from GitHub and try it out.
But if you want to modify the C++ part of HMSL then read on.

## Install JUCE

JUCE is required to build HMSL. Install JUCE from [here](https://shop.juce.com/)

## Building on OSX

The XCode project was exported using the ProJucer tool.

New C/C++ files should only be added using the ProJucer.

### Checking out the code

You can clone HMSL into any folder.

    git clone https://github.com/philburk/hmsl.git HMSL
    cd HMSL
    git submodule update --init

### Exporting from ProJucer

Unless you need to add a JUCE file, or update the JUCE version, you can probably skip to "Compiling the JUCE port" below.

* Open the folder "native/juce"
* Double click on JuceHMSL.jucer
* Add files if needed by opening File Explorer and right clicking on Source.
* At the top of the ProJucer page, set "Selected exporter" to "XCode (macOS)"
* Click on the white and blue circular icon to the right of that menu to "Save and Open IDE".

### Compiling the JUCE port

From the top HMSL folder, enter:

    ./scripts/build.sh

This will:

* build "build/JuceHMSL.app" using XCode (signed ad hoc for local use),
* compile the pForth dictionary from "pforth/fth/system.fth",
* compile HMSL on top of that using "hmsl/fth/make_hmsl.fth",
* save the result in "hmsl/pforth.dic".

Then run HMSL with:

    open build/JuceHMSL.app

To rebuild just the dictionary after editing Forth code, enter:

    build/JuceHMSL.app/Contents/MacOS/JuceHMSL --build-dictionary

You can still build and debug from XCode.
Pass "--build-dictionary" as a launch argument in the scheme to compile the dictionary.

### Packaging a Release for Mac OS

You will need a "Developer ID Application" certificate in your keychain
and notarization credentials stored with:

    xcrun notarytool store-credentials NOTARY_PROFILE --apple-id {email} --team-id {team}

1. Update the version number in native/juce/Source/hmsl_version.h. It is the only place the version is set.
2. From the top HMSL folder, enter:

        ./scripts/release.sh

This builds the app and dictionary, puts the dictionary and the HMSL source folders
inside HMSL.app, signs it, makes "build/HMSL_{version}.dmg", then notarizes and staples the DMG.

The DMG window layout is in "scripts/dmg_settings.py" and the background is drawn by
"scripts/make_dmg_background.swift". The first release on a new machine installs
uv, Python 3.12 and dmgbuild into the "build" folder, so it needs internet access.

To make a signed DMG quickly without notarizing, enter:

    ./scripts/release.sh --skip-notarize

### Test the Release
1. Upload the DMG file to a folder on Google Drive, then download it to ~/Downloads.
1. Open the DMG and drag HMSL.app to Applications. It should launch without any security warnings.
1. Choose a work folder when asked.
1. HMSL should ask you to initialize by entering: y
2. Wait 5 seconds for HMSL to initialize.
1. Enter: SHEP
1. You should hear some notes and see the Shape Editor appear.
3. Close the Shape Editor window.
4. Enter:  include hap:swirl.fth
5. Enter:  swirl
6. Hear some odd bells and an "Uhh" sound.
7. Clock the "Forward" button. The shape should start rotating in a {time,pitch} space.
8. Close the SWIRL window.


## Make a Release on GitHub
1. Look at the PRs and Commits since the last Release and prepare Release Notes.
1. Under Releases, create a new release and drag the new DMG file to attach it.

